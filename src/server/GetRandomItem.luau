local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local GetRandomItemButton = Instance.new("RemoteEvent", ReplicatedStorage)
GetRandomItemButton.Name = "GetRandomItemButton"
local Database = require(ServerScriptService.Server.ProfileService.ItemDatabase)
local GameActions = require(ServerScriptService.Server.GameActionsService.GameActions)
local EquipmentGenerator = require(ServerScriptService.Server.Equipment.EquipmentGenerator)
local ItemData = Database.GetAll()
local keys = {}


for key in pairs(ItemData) do
	table.insert(keys, key)
end

local GetRandomItem = {}

local function GenerateRandomItem(player)
    -- Step 2: Pick a random key
    local randomKey = keys[math.random(1, #keys)]
    -- Step 3: Get the item using that key
    local randomItem = ItemData[randomKey]

    if not randomItem then
			warn("Item not found: " .. randomKey)
			return
		end
		if randomItem.Stackable then
			newItem = { ID = randomKey, Quantity = 1}
		elseif not randomItem.Stackable then
			newItem = EquipmentGenerator.GenerateEquipment(randomKey, nil)
		else
			newItem = { ID = randomKey}
		end

		GameActions.AddItem(player, newItem)
    GameActions.AddItem(player, randomItem)
end

GetRandomItemButton.OnServerEvent:Connect(function(player)
    GenerateRandomItem(player)
end)

return GetRandomItem

