local module = {}

local LocalPlayer = game:GetService("Players").LocalPlayer
local UIManager = require(script.Parent.UI)

local QuickMenuButton:ImageButton = LocalPlayer.PlayerGui.Interface.Menu
local quickMenu = UIManager:GetUIElement("quickMenu")

local Map:ImageButton  = quickMenu.Map
local Quest:ImageButton  = quickMenu.Quest
local Bag:ImageButton  = quickMenu.Bag

QuickMenuButton.MouseButton1Click:Connect(function()
	if quickMenu then
		UIManager:ToggleUI(quickMenu, "quickMenu")
	else
		warn(quickMenu, " is not cached!")
	end
end)

Bag.MouseButton1Click:Connect(function()
	local inventoryGroup = {"Inventory", "Equipments"}
	UIManager:ToggleCompositeUI(inventoryGroup, "InventoryGroup")
end)



return module
