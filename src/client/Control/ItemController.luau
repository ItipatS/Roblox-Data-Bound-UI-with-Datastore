local ItemController = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local EquipItemEvent = game.ReplicatedStorage:WaitForChild("EquipItemEvent")
local UnequipItemEvent = game.ReplicatedStorage:WaitForChild("UnequipItemEvent")
-- Internal state: stores info for the currently selected item.
local selectedItem = nil  -- Table with keys: itemData, originalSlot, dragProxy, quantity, inputConnections
local dragProxy = nil     -- Current drag proxy UI element

-- Configuration: adjust the drag proxy size as needed.
local DRAG_PROXY_SIZE = UDim2.new(0.05, 0, 0.1, 0)

----------------------------------------------------------
-- Helper Functions
----------------------------------------------------------

-- Creates a drag proxy from the original item frame.
local function createDragProxy(itemFrame, quantity)
	local proxy = itemFrame:Clone()
	proxy.Name = "DragProxy"
	proxy.Size = DRAG_PROXY_SIZE
	proxy.AnchorPoint = Vector2.new(0.5, 0.5)
	-- Optionally display the quantity if this is a stackable item.
	if quantity and tonumber(quantity) and tonumber(quantity) > 1 then
		if proxy:FindFirstChild("Quantity") then
			proxy.Quantity.Text = "x" .. tostring(quantity)
			proxy.Quantity.Visible = true
		end
	else
		if proxy:FindFirstChild("Quantity") then
			proxy.Quantity.Text = ""
			proxy.Quantity.Visible = false
		end
	end
	return proxy
end

-- Shows the drag proxy by cloning the original item frame and parenting it to the top-level ScreenGui.
local function showDragProxy(originalSlot, quantity)
	if dragProxy then
		dragProxy:Destroy()
		dragProxy = nil
	end
	dragProxy = createDragProxy(originalSlot, quantity)
	local topGui = originalSlot:FindFirstAncestorWhichIsA("ScreenGui")
	if topGui then
		dragProxy.Parent = topGui
	else
		dragProxy.Parent = originalSlot.Parent
	end
	dragProxy.Visible = true
	return dragProxy
end

-- Hides and cleans up the drag proxy.
local function hideDragProxy()
	if dragProxy then
		dragProxy:Destroy()
		dragProxy = nil
	end
end

-- Updates the drag proxy position based on the current mouse position.
local function updateDragProxyPosition()
	if not dragProxy then return end
	local mousePos = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	local correctedX = mousePos.X - inset.X
	local correctedY = mousePos.Y - inset.Y
	dragProxy.Position = UDim2.new(0, correctedX, 0, correctedY)
end

-- Disconnects any input connections associated with the current selection.
local function disconnectInputConnections()
	if selectedItem and selectedItem.inputConnections then
		for _, conn in ipairs(selectedItem.inputConnections) do
			if conn.Connected then
				conn:Disconnect()
			end
		end
		selectedItem.inputConnections = nil
	end
end

----------------------------------------------------------
-- Public Functions
----------------------------------------------------------

-- Called when the player clicks on an inventory item.
-- itemFrame: the ImageButton representing the item.
-- itemData: a table with item info (including UID, Type, Quantity, etc.)
function ItemController.SelectItem(itemFrame, itemData, itemconfig)
	-- If an item is already selected, cancel its selection.
	if selectedItem then
		ItemController.CancelSelection()
	end

	-- Determine the quantity to pick up.
	local quantity = 1
	if itemData.Quantity then
		quantity = itemData.Quantity
	end

	-- Hide the original item frame to show that it’s been picked up.
	itemFrame.Visible = false

	-- Create the drag proxy that follows the mouse.
	local proxy = showDragProxy(itemFrame, quantity)
	updateDragProxyPosition()

	-- Set up input connections: one to update the proxy position on mouse movement,
	-- and one to listen for a click to drop the item.
	local connections = {}
	table.insert(connections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			updateDragProxyPosition()
		end
	end))
	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Use GetGuiObjectsAtPosition to find the UI elements under the mouse.
			local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
			if playerGui then
				local guiObjects = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
				local validTarget = nil
				for _, obj in ipairs(guiObjects) do
					-- Check for a marker that indicates a drop target.
					-- In this example, valid drop targets should have a Name of "DropTarget" or an attribute "TargetType".
					if obj ~= dragProxy and (obj.Name == "DropTarget" or obj:GetAttribute("TargetType")) then
						validTarget = obj
						break
					end
				end
				if validTarget then
					-- Use the TargetType attribute if available, otherwise fall back to the object's Name.
					local targetType = validTarget:GetAttribute("TargetType") or validTarget.Name
					
					if selectedItem.originalSlot.Parent.Name and targetType == selectedItem.originalSlot.Parent.Name then
						ItemController.CancelSelection()
					else
						ItemController.PlaceItem(validTarget, targetType)
					end
				else
					-- No valid target found: cancel the selection and return the item.
					ItemController.CancelSelection()
				end
			end
		end
	end))

	selectedItem = {
		itemconfig = itemconfig,
		itemData = itemData,
		originalSlot = itemFrame,
		dragProxy = proxy,
		quantity = quantity,
		inputConnections = connections,
	}
end

-- Called when the player clicks on a drop target (such as an equipment slot, chest, or shop).
-- targetSlot: the UI element representing the drop target.
-- targetSlotName: a string indicating the type/category of the slot (e.g., "Equipment", "Chest", "Shop").
-- Returns true if the drop is valid and the item is placed.
function ItemController.PlaceItem(targetSlot, targetSlotType)
	if not selectedItem then return false end

	-- Validate the drop: check if the selected item's Type is allowed in the target slot.
	local slotToAllowedType = {
		Helmet = {"Helmet"},
		ChestPlate = {"ChestPlate"},
		Leggings = {"Leggings"},
		Weapon = {"Weapon", "LeftHand", "RightHand"},
		Accessory = {"Accessory", "Acc1", "Acc2", "Acc3", "Acc4"},
		Chest = {"Consumable", "Material", "Misc"},
		Shop = {"Any"},  -- Shop accepts any item.
		Inventory = {"ItemSlots"}
	}

	local allowedTypes = slotToAllowedType[selectedItem.itemconfig.Type]

	if targetSlotType == "ItemSlots" or targetSlotType == "Any" then
		if selectedItem.originalSlot.Parent.Name ~= targetSlotType then
			-- The item came from equipment, so fire the unequip remote event.
			UnequipItemEvent:FireServer(selectedItem.itemData.UID)
			ItemController.CancelSelection()
			return
		else
			-- The item is already in inventory; simply cancel the selection.
			ItemController.CancelSelection()
			return
		end
	end

	if allowedTypes and allowedTypes[1] ~= "Any" then
		local valid = false
		for _, allowed in ipairs(allowedTypes) do	
			if targetSlotType == allowed then
				valid = true
				EquipItemEvent:FireServer(selectedItem.itemData.UID, targetSlotType)
				break
			end
			if not valid then
				warn("Invalid drop: item type", selectedItem.itemconfig.Type, "cannot go into slot", targetSlotType)
				ItemController.CancelSelection()
				return false
			end
		end
	else
		warn("Invalid drop: item type", selectedItem.itemconfig.Type, "cannot go into slot", targetSlotType)
		ItemController.CancelSelection()
		return false
	end
	-- Remove the drag proxy and clear the target slot, then place the item.
	hideDragProxy()
	targetSlot:ClearAllChildren()

	local newItemFrame = selectedItem.originalSlot:Clone()
	newItemFrame.Name = "PlacedItem"
	newItemFrame:SetAttribute("ItemUID", selectedItem.itemData.UID)
	newItemFrame.Visible = true
	newItemFrame.Parent = targetSlot
	newItemFrame.Position = UDim2.new(0.5,0,0.5,0)

	-- Optionally fire a RemoteEvent to inform the server of the transfer.
	-- e.g., InventoryActionEvent:FireServer({ActionType="transfer", ItemUID=selectedItem.itemData.UID, Destination=targetSlotName})

	disconnectInputConnections()
	selectedItem = nil
	return true
end

-- Cancels the current selection and returns the item to its original slot.
function ItemController.CancelSelection()
	if selectedItem then
		if selectedItem.originalSlot then
			selectedItem.originalSlot.Visible = true
		end
		disconnectInputConnections()
		selectedItem = nil
	end
	hideDragProxy()
end

-- Optional: Extend this function to handle additional actions (right-click, shift-click, etc.)
function ItemController.HandleAction(actionType, data)
	if actionType == "dropOne" then
		-- Process dropping one item
	elseif actionType == "transferHalf" then
		-- Process transferring half the stack
	elseif actionType == "quickTransfer" then
		-- Process a quick transfer (e.g., shift+click)
	end
	-- Always validate on the server side as needed.
end

return ItemController
