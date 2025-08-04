-- InventoryManager.lua (ModuleScript in ReplicatedStorage or a LocalModules folder)
local InventoryManager = {}
--Data
local MainLocalProfile = require(script.Parent.Parent.Data.MainLocalProfile)
local DatabaseCache = require(script.Parent.Parent.Data.ClientDatabaseCache)
local MainDatabase = DatabaseCache.GetData()
local UIManager = require(script.Parent.UI)
local UIData = require(script.Parent.Parent.Data.UIData)
local TooltipBuilder = require(script.Parent.TooltipBuilder)
local TierEffectManager  = require(script.Parent.TierEffectManager)

--Service
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Interface = LocalPlayer.PlayerGui.Interface
local inventory =  UIManager:GetUIElement("Inventory")
local equipments =  UIManager:GetUIElement("Equipments")
local InventorySlots = inventory.ItemSlots
local callback

local Replicated = game:GetService("ReplicatedStorage")

local spinningModel = {}

local GUITemplate = StarterGui.Template
local InformationFrame = GUITemplate.InformationFrame
local ItemTemplate = GUITemplate.ItemTemplate

local lastRotationTime = 0 -- Keep track of the last rotation time
local currentCategory = "All"  -- default category
local isInventoryActive = false

local stopFunctions = {}

local EquipmentSlots = {
	Helmet 		= equipments.Helmet,
	ChestPlate 	= equipments.ChestPlate,
	Leggings	= equipments.Leggings,
	RightHand 	= equipments.RightHand,
	LeftHand 	= equipments.LeftHand,
	Acc1 		= equipments.Acc1,
	Acc2 		= equipments.Acc2,
	Acc3 		= equipments.Acc3,
	Acc4 		= equipments.Acc4,
}

local ItemController = require(script.Parent.Parent.Control.ItemController)

local getMaid = require(Replicated.Shared.Maid)
local Maid = getMaid.new()  -- Global maid for InventoryManager connections

local function setupModel(itemConfig, frame)
	local modelAsset = Replicated.ArmorsPreview:FindFirstChild(itemConfig.Model)
						or Replicated.Bodys:FindFirstChild(itemConfig.Model)
						or Replicated.Handles:FindFirstChild(itemConfig.Model)
						or Replicated.Items:FindFirstChild(itemConfig.Model)
	if modelAsset then
		local clonedModel = modelAsset:Clone()
		clonedModel.CFrame = itemConfig.Viewport.Model
		
		clonedModel:SetAttribute("InitialCFrame", clonedModel.CFrame)
		clonedModel:SetAttribute("CurrentAngle", 0)
		
		clonedModel.Parent = frame.ViewportFrame
		table.insert(spinningModel, clonedModel)
		local viewportCamera = Instance.new("Camera")
		viewportCamera.CFrame = itemConfig.Viewport.Camera
		frame.ViewportFrame.CurrentCamera = viewportCamera
	else
		warn("Model not found: " .. tostring(itemConfig.Model))
	end
end

local function updateTooltip(itemData, modData)
	-- Set the standard tooltip text for the description
	local tooltipText = TooltipBuilder.BuildTooltip(itemData, modData, UIData)
	InformationFrame.CapFrame.TextLabel.Text = tooltipText
	InformationFrame.CapFrame.NameLabel.Text = itemData.Name or "Unnamed"
	InformationFrame.Parent = Interface

	local tier = UIData:GetTier(itemData.Tier)
	-- Clear any previous effects.
	TierEffectManager.ClearEffects(stopFunctions, InformationFrame.CapFrame.NameLabel, tier)
	if typeof(tier) == "Color3" then
		InformationFrame.CapFrame.NameLabel.TextColor3 = tier
	end

	stopFunctions = TierEffectManager.ApplyEffects(InformationFrame.CapFrame.NameLabel, tier)

	InformationFrame.Visible = true

end


local function onItemMouseEnter(itemFrame, itemConfig, itemInstance)
	-- Store the original color using an attribute for later restoration
	local lastColor = itemFrame.ImageColor3
	itemFrame:SetAttribute("LastColor", lastColor)

	-- Darken the background slightly
	itemFrame.ImageColor3 = Color3.new(0.5,  0.5, 0.5)

	-- Update the tooltip. For unstackable items, pass itemInstance; for stackable, it’s nil.
	if itemInstance then
		updateTooltip(itemConfig, itemInstance)
	else
		updateTooltip(itemConfig)
	end

	-- Position the tooltip relative to the inventory frame
	local centerX = itemFrame.AbsolutePosition.X
	local centerY = itemFrame.AbsolutePosition.Y + itemFrame.AbsoluteSize.Y / 2
	InformationFrame.Position = UDim2.new(0, centerX, 0, centerY)
end

local function onItemMouseLeave(itemFrame)
	-- Restore original color
	local lastColor = itemFrame:GetAttribute("LastColor")
	if lastColor then
		itemFrame.ImageColor3 = lastColor
	end
	InformationFrame.Visible = false
end

local function createItemFrame(itemConfig, identifier)

	local itemFrame:ImageButton = ItemTemplate:Clone()
	itemFrame.Name = identifier

	-- Set border properties from the config
	for property, propertyValue in pairs(itemConfig.Border or {}) do
		if property == "ImageRectOffset" then
			itemFrame.ImageRectOffset = UIData.Bordercalculate(propertyValue)
		elseif property == "ImageColor3" then

			if typeof(UIData:GetTier(itemConfig.Tier)) ~= "Color3" then

				itemFrame.ImageColor3 = Color3.new(1, 1, 1)
			else
				itemFrame.ImageColor3 = UIData:GetTier(itemConfig.Tier)
			end
		else
			itemFrame.property = propertyValue
		end
	end

	return itemFrame
end

function InventoryManager.Update(profileData)

	-- Ensure inventory exists
	profileData.Inventory = profileData.Inventory or { stackable = {}, unstackable = {} }

	local InventoryIDCached = {}

	for itemID, itemData  in pairs(profileData.Inventory.stackable) do

		local quantity = itemData.Quantity
		local itemConfig = MainDatabase[itemID]
		if not itemConfig then continue end

		local itemFrame:ImageButton = InventorySlots:FindFirstChild(itemID)
		if not itemFrame then
			itemFrame = createItemFrame(itemConfig, itemID)
			itemFrame.LayoutOrder = quantity

			setupModel(itemConfig, itemFrame)

			itemFrame.Parent = InventorySlots

			Maid:GiveTask(itemFrame.MouseEnter:Connect(function()
				onItemMouseEnter(itemFrame, itemConfig)
			end))
			Maid:GiveTask(itemFrame.MouseLeave:Connect(function()
				onItemMouseLeave(itemFrame)
			end))
			Maid:GiveTask(itemFrame.MouseButton1Click:Connect(function()
				ItemController.SelectItem(itemFrame, itemData, itemConfig)
			end))

		end

		if quantity > 1 then
			itemFrame.Quantity.Text = 'x' .. quantity
		else
			itemFrame.Quantity.Text = ''
		end

		table.insert(InventoryIDCached, itemID)
	end

	-- Process unstackable items (each instance gets its own frame)
	for index, itemInstance in ipairs(profileData.Inventory.unstackable) do
		-- Use the item's ID to get base configuration.
		local itemConfig = MainDatabase[itemInstance.ID]
		if not itemConfig then continue end

		-- Create a unique frame name, for instance itemID_index
		local frameName = itemInstance.ID .. "_" .. index
		-- Check if the frame already exists in the inventory slots.
		local itemFrame:ImageButton = InventorySlots:FindFirstChild(frameName)
		if not itemFrame then
			-- Layout order can be based on index or other criteria.
			itemFrame = createItemFrame(itemConfig, frameName)
			itemFrame.LayoutOrder = index

			setupModel(itemConfig, itemFrame)

			itemFrame.Parent = InventorySlots

			Maid:GiveTask(itemFrame.MouseEnter:Connect(function()
				onItemMouseEnter(itemFrame, itemConfig, itemInstance)
			end))
			Maid:GiveTask(itemFrame.MouseLeave:Connect(function()
				onItemMouseLeave(itemFrame)
			end))
			Maid:GiveTask(itemFrame.MouseButton1Click:Connect(function()
				ItemController.SelectItem(itemFrame, itemInstance, itemConfig)
			end))

		end

		itemFrame.Quantity.Text = ""

		-- For unstackable items, there's no quantity text unless you choose to display uniqueness info.
		table.insert(InventoryIDCached, frameName)
	end

	-- Cleanup: Remove any UI frames that no longer correspond to inventory items.
	for _, Frame in ipairs(InventorySlots:GetChildren()) do
		if Frame:IsA('ImageButton') and not table.find(InventoryIDCached, Frame.Name) then
			Frame:Destroy()
		end
	end
end


function InventoryManager.UpdateEquipment(profileData)
	-- your equipment container
	local EquipmentsIDCached = {}
	
	for slotName, equippedItem in pairs(profileData.Equipment) do

		local itemConfig = MainDatabase[equippedItem.ID]
		if not itemConfig then continue end

		local slotFrame = EquipmentSlots[slotName]
		if slotFrame then

			local frameName = equippedItem.ID .. "_" .. slotName
			local equipmentFrame:ImageButton = slotFrame:FindFirstChild(frameName)
			if not equipmentFrame then
				-- Clear previous content in the equipment slot
				-- Create an equipment frame from a template (like your inventory template)
				equipmentFrame = createItemFrame(itemConfig, frameName)
				-- Setup the model or icon
				setupModel(itemConfig, equipmentFrame)
	
				equipmentFrame.Parent = slotFrame
				equipmentFrame.Position = UDim2.new(.5,0,.5,0)
				-- Connect tooltip events as needed
				Maid:GiveTask(equipmentFrame.MouseEnter:Connect(function()
					onItemMouseEnter(equipmentFrame, itemConfig, equippedItem)
				end))
				Maid:GiveTask(equipmentFrame.MouseLeave:Connect(function()
					onItemMouseLeave(equipmentFrame)
				end))

				Maid:GiveTask(equipmentFrame.MouseButton1Click:Connect(function()
					ItemController.SelectItem(slotFrame, equippedItem, itemConfig)
				end))

			end
			equipmentFrame.Quantity.Text = ""
			
			table.insert(EquipmentsIDCached, frameName)
		end
	end
	for slotName, slotFrame in pairs(EquipmentSlots) do
		for _, frame in ipairs(slotFrame:GetChildren()) do
			if frame:IsA('ImageButton') and not table.find(EquipmentsIDCached, frame.Name) then
				frame:Destroy()
			end
		end
	end

end


-- Function to set the current category (called by the tab script)
function InventoryManager.SetCategory(category)
	currentCategory = category
end

Maid:GiveTask(inventory.Exit.MouseButton1Click:Connect(function()
	local inventoryGroup = {"Inventory", "Equipments"}
	UIManager:ToggleCompositeUI(inventoryGroup, "InventoryGroup")
end))

local function resetAllRotations()
	for i = #spinningModel, 1, -1 do
		local model = spinningModel[i]
		if model and model.Parent then
			-- Reset the current angle to 0.
			model:SetAttribute("CurrentAngle", 0)
			-- Reset CFrame to its initial state.
			local initialCFrame = model:GetAttribute("InitialCFrame")
			if initialCFrame then
				model.CFrame = initialCFrame
			else
				model.CFrame = model.CFrame  -- Fallback: do nothing.
			end
		end
	end
end

local function rotateModel(model)
	local tween = TweenService:Create(model, TweenInfo.new(.5), {CFrame = model.CFrame * CFrame.Angles(0, math.rad(-45), 0)})
	tween:Play()
end


Maid:GiveTask(RunService.Heartbeat:Connect(function()
	if not isInventoryActive then return end
	local currentTime = tick()
	if currentTime - lastRotationTime >= 1.5 then -- Check if 0.75 seconds have passed
		lastRotationTime = currentTime 

		for i = #spinningModel, 1, -1 do
			local model = spinningModel[i]
			if not model.Parent then
				table.remove(spinningModel, i)
			else
				rotateModel(model)
			end
		end
	end
end))

-- Set the callback to update inventory state
UIManager:SetInventoryStateCallback(function(isOpen)
	isInventoryActive = isOpen
	if not isOpen then
		ItemController.CancelSelection()
	end
end)


-- Initialization function for the Inventory Manager
local function Initialize()
	-- Subscribe to profile updates
	callback = MainLocalProfile.Subscribe(function(profileData)
		if profileData and profileData.Inventory then
			InventoryManager.Update(profileData)
			InventoryManager.UpdateEquipment(profileData)
			resetAllRotations()
		end
	end)

	--[[local CategoryTabs = Interface.Inventory:FindFirstChild("Category")
	if CategoryTabs then
		for _, tabButton in ipairs(CategoryTabs:GetChildren()) do
			if tabButton:IsA("TextButton") then
				tabButton.MouseButton1Click:Connect(function()
					InventoryManager.SetCategory(tabButton.Text)
					InventoryManager.Update(LocalPlayer)
				end)
			end
		end
	end]]

end
Initialize()
return InventoryManager