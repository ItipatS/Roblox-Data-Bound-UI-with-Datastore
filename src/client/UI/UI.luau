local UIManager = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Table to track which UI elements are currently open.
local openUIs = {}
local openCompositeGroups = {}
-- Table to track which UI elements are in transition.
local UITransitioning = {}

local inventoryStateChangedCallback = nil

-- Tables to cache UI elements and store their original parent.
local UIElements = {}
local OriginalParents = {}

-- Setter for the inventory state callback.
function UIManager:SetInventoryStateCallback(callback)
	inventoryStateChangedCallback = callback
end

-- Cache important UI elements from the player's interface.
local function CacheUIElements()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local interface = playerGui:WaitForChild("Interface")

	-- Cache quickMenu.
	local quickMenu = interface:FindFirstChild("quickMenu")
	if quickMenu then
		quickMenu:SetAttribute("OriginalSize", quickMenu.Size)
		quickMenu:SetAttribute("OriginalPosition", quickMenu.Position)
		UIElements.quickMenu = quickMenu
		OriginalParents.quickMenu = interface
		quickMenu.Parent = nil
	else
		warn("quickMenu not found in Interface!")
	end

	-- Cache Inventory.
	local inventory = interface:FindFirstChild("Inventory")
	if inventory then
		inventory:SetAttribute("OriginalSize", inventory.Size)
		inventory:SetAttribute("OriginalPosition", inventory.Position)
		UIElements.Inventory = inventory
		OriginalParents.Inventory = interface
		inventory.Parent = nil
	else
		warn("Inventory not found in Interface!")
	end

	-- Cache Equipment.
	local equipment = interface:FindFirstChild("Equipments")
	if equipment then
		equipment:SetAttribute("OriginalSize", equipment.Size)
		equipment:SetAttribute("OriginalPosition", equipment.Position)
		UIElements.Equipments = equipment
		OriginalParents.Equipments = interface
		equipment.Parent = nil
	else
		warn("Equipments not found in Interface!")
	end

	-- Cache Shop.
	local shop = interface:FindFirstChild("Shop")
	if shop then
		shop:SetAttribute("OriginalSize", shop.Size)
		shop:SetAttribute("OriginalPosition", shop.Position)
		UIElements.Shop = shop
		OriginalParents.Shop = interface
		shop.Parent = nil
	else
		warn("Shop not found in Interface!")
	end

	-- Cache Chest.
	local chest = interface:FindFirstChild("Chest")
	if chest then
		chest:SetAttribute("OriginalSize", chest.Size)
		chest:SetAttribute("OriginalPosition", chest.Position)
		UIElements.Chest = chest
		OriginalParents.Chest = interface
		chest.Parent = nil
	else
		warn("Chest not found in Interface!")
	end
end

function UIManager:GetUIElement(name)
	return UIElements[name]
end

-- In UIManager, add a function to open a composite state.
function UIManager:OpenCompositeUI(uiGroup, groupName, callback)
	for key, ui in pairs(openUIs) do
		local inGroup = false
		for _, k in ipairs(uiGroup) do
			if key == k then
				inGroup = true
				break
			end
		end
		if ui and not inGroup then
			self:CloseUI(ui, key)
		end
	end

	-- Now open each UI element in the group.
	for _, key in ipairs(uiGroup) do
		local uiElement = UIElements[key]
		if uiElement then
			self:DoOpenUI(uiElement, key)
			openUIs[key] = uiElement
		end
	end
	openCompositeGroups[groupName] = uiGroup
	if callback then callback() end
end

function UIManager:CloseCompositeUI(uiGroup, groupName, callback)
	for _, key in ipairs(uiGroup) do
		local uiElement = UIElements[key]
		if uiElement then
			self:DoCloseUI(uiElement, key)
			openUIs[key] = nil
		end
	end
	-- Clear the composite group state correctly:
	openCompositeGroups[groupName] = nil
	if callback then callback() end
end



-- Internal function to perform the opening tween.
function UIManager:DoOpenUI(newUI, name, callback)
	if UITransitioning[newUI] then return end  -- Prevent re-entry
	UITransitioning[newUI] = true
	local targetSize = newUI:GetAttribute("OriginalSize")
	local targetPosition = newUI:GetAttribute("OriginalPosition")

	-- Reparent if needed.
	if newUI.Parent == nil then
		newUI.Parent = OriginalParents[name] or LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
	end

	newUI.Visible = true
	newUI.Size = UDim2.new(0, 0, 0, 0)
	newUI.Position = UDim2.new(0.5, 0, 0.5, 0)

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(newUI, tweenInfo, {Size = targetSize, Position = targetPosition})
	tween:Play()
	tween.Completed:Connect(function()
		UITransitioning[newUI] = false
		if inventoryStateChangedCallback and name == "Inventory" then
			inventoryStateChangedCallback(true)
		end
		openUIs[name] = newUI
		if callback then callback() end
	end)
end

-- Internal function to perform the closing tween.
function UIManager:DoCloseUI(ui, name, callback)
	if UITransitioning[ui] then return end  -- Prevent re-entry
	UITransitioning[ui] = true
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(ui, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
	tween:Play()
	tween.Completed:Connect(function()
		ui.Parent = nil
		openUIs[name] = nil
		UITransitioning[ui] = false
		if inventoryStateChangedCallback and name == "Inventory" then
			inventoryStateChangedCallback(false)
		end
		if callback then callback() end
	end)
end

-- Public function to open a UI element.
-- 'name' is the key for the cached UI (e.g., "Inventory", "Equipment", "Shop", "Chest").
function UIManager:OpenUI(newUI, name, callback)
	-- Close all other open UIs first
	for key, ui in pairs(openUIs) do
		if ui and key ~= name then
			self:CloseUI(ui, key)
		end
	end

	-- Now open the new UI.
	if UITransitioning[newUI] then return end
	self:DoOpenUI(newUI, name, callback)
end


-- Public function to close a UI element.
function UIManager:CloseUI(ui, name, callback)
	self:DoCloseUI(ui, name, callback)
end

-- Public function to toggle a UI element.
function UIManager:ToggleUI(ui, name)
	if UITransitioning[ui] then return end
	if ui.Parent == nil then
		self:OpenUI(ui, name)
		return false
	else
		self:CloseUI(ui, name)
		return true
	end
end

function UIManager:ToggleCompositeUI(uiGroup, groupName)

	-- Check if the group is currently open.
	if openCompositeGroups[groupName] then
		self:CloseCompositeUI(uiGroup, groupName)
		return false
	else
		self:OpenCompositeUI(uiGroup, groupName)
		return true
	end
end

CacheUIElements()

return UIManager
