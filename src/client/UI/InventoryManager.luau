-- InventoryManager.lua (ModuleScript in ReplicatedStorage or a LocalModules folder)
local InventoryManager = {}
--Data
local MainLocalProfile = require(script.Parent.Parent.Data.MainLocalProfile) -- Or your datastore System
local DatabaseCache = require(script.Parent.Parent.Data.ClientDatabaseCache)
local MainDatabase = DatabaseCache.GetData() -- Or YourDatabase
local UIManager = require(script.Parent.UI)
local UIData = require(script.Parent.Parent.Data.UIData)
local TooltipBuilder = require(script.Parent.TooltipBuilder)
local TierEffectManager  = require(script.Parent.TierEffectManager)

--Service
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Interface = LocalPlayer.PlayerGui.Interface
local inventory =  UIManager:GetUIElement("Inventory")
local equipments =  UIManager:GetUIElement("Equipments")
local InventorySlots = inventory.ItemSlots


local Replicated = game:GetService("ReplicatedStorage")
local Assets = Replicated.Models

local spinningModel = {}

local InformationFrame = script.InformationFrame:Clone()

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
	local modelAsset = Assets:FindFirstChild(itemConfig.Model)
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
	InformationFrame.TextLabel.Text = tooltipText
	InformationFrame.NameLabel.Text = itemData.Name or "Unnamed"
	InformationFrame.Parent = Interface

	local tier = UIData:GetTier(itemData.Tier)

	-- Clear any previous effects.
	TierEffectManager.ClearEffects(stopFunctions, InformationFrame.NameLabel, tier)
	if typeof(tier) == "Color3" then
		InformationFrame.NameLabel.TextColor3 = tier
	end

	stopFunctions = TierEffectManager.ApplyEffects(InformationFrame.NameLabel, tier)

	InformationFrame.Visible = true

end


local function onItemMouseEnter(inventoryFrame, itemConfig, itemInstance)
	-- Store the original color using an attribute for later restoration
	local lastColor = inventoryFrame.ImageColor3
	inventoryFrame:SetAttribute("LastColor", lastColor)

	-- Darken the background slightly
	inventoryFrame.ImageColor3 = Color3.new(0.5,  0.5, 0.5)

	-- Update the tooltip. For unstackable items, pass itemInstance; for stackable, it’s nil.
	if itemInstance then
		updateTooltip(itemConfig, itemInstance)
	else
		updateTooltip(itemConfig)
	end

	-- Position the tooltip relative to the inventory frame
	local centerX = inventoryFrame.AbsolutePosition.X + inventoryFrame.AbsoluteSize.X / 2
	local centerY = inventoryFrame.AbsolutePosition.Y + inventoryFrame.AbsoluteSize.Y / 2
	InformationFrame.Position = UDim2.new(0, centerX, 0, centerY)
end

local function onItemMouseLeave(inventoryFrame)
	-- Restore original color
	local lastColor = inventoryFrame:GetAttribute("LastColor")
	if lastColor then
		inventoryFrame.ImageColor3 = lastColor
	end
	InformationFrame.Visible = false
end

local function createInventoryFrame(itemConfig, identifier)

	local inventoryFrame:ImageButton = script.ItemTemplate:Clone()
	inventoryFrame.Name = identifier

	-- Set border properties from the config
	for property, propertyValue in pairs(itemConfig.Border or {}) do
		if property == "ImageRectOffset" then
			inventoryFrame.ImageRectOffset = UIData.Bordercalculate(propertyValue)
		elseif property == "ImageColor3" then

			if typeof(UIData:GetTier(itemConfig.Tier)) ~= "Color3" then

				inventoryFrame.ImageColor3 = Color3.new(1, 1, 1)
			else
				inventoryFrame.ImageColor3 = UIData:GetTier(itemConfig.Tier)
			end
		else
			inventoryFrame.property = propertyValue
		end
	end

	return inventoryFrame
end

function InventoryManager.Update(profileData)

	-- Ensure inventory exists
	profileData.Inventory = profileData.Inventory or { stackable = {}, unstackable = {} }

	local InventoryIDCached = {}


	for itemID, itemData  in pairs(profileData.Inventory.stackable) do

		local quantity = itemData.Quantity
		local itemConfig = MainDatabase[itemID]
		if not itemConfig then continue end

		local inventoryFrame:ImageButton = InventorySlots:FindFirstChild(itemID)
		if not inventoryFrame then
			inventoryFrame = createInventoryFrame(itemConfig, itemID)
			inventoryFrame.LayoutOrder = quantity

			setupModel(itemConfig, inventoryFrame)

			inventoryFrame.Parent = InventorySlots

			Maid:GiveTask(inventoryFrame.MouseEnter:Connect(function()
				onItemMouseEnter(inventoryFrame, itemConfig)
			end))
			Maid:GiveTask(inventoryFrame.MouseLeave:Connect(function()
				onItemMouseLeave(inventoryFrame)
			end))
			Maid:GiveTask(inventoryFrame.MouseButton1Click:Connect(function()
				ItemController.SelectItem(inventoryFrame, itemData, itemConfig)
			end))

		end

		if quantity > 1 then
			inventoryFrame.Quantity.Text = 'x' .. quantity
		else
			inventoryFrame.Quantity.Text = ''
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
		local inventoryFrame:ImageButton = InventorySlots:FindFirstChild(frameName)
		if not inventoryFrame then
			-- Layout order can be based on index or other criteria.
			inventoryFrame = createInventoryFrame(itemConfig, frameName)
			inventoryFrame.LayoutOrder = index

			setupModel(itemConfig, inventoryFrame)

			inventoryFrame.Parent = InventorySlots

			Maid:GiveTask(inventoryFrame.MouseEnter:Connect(function()
				onItemMouseEnter(inventoryFrame, itemConfig, itemInstance)
			end))
			Maid:GiveTask(inventoryFrame.MouseLeave:Connect(function()
				onItemMouseLeave(inventoryFrame)
			end))
			Maid:GiveTask(inventoryFrame.MouseButton1Click:Connect(function()
				ItemController.SelectItem(inventoryFrame, itemInstance, itemConfig)
			end))

		end

		inventoryFrame.Quantity.Text = ""

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
				equipmentFrame = createInventoryFrame(itemConfig, frameName)
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
local function Init()
	print("what")
	-- Subscribe to profile updates
	MainLocalProfile.Subscribe(function(profileData)
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

Init()

return InventoryManager