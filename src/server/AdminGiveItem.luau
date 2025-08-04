local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Database = require(ServerScriptService.Server.ProfileService.ItemDatabase)
local GameActions = require(ServerScriptService.Server.GameActionsService.GameActions)
local EquipmentGenerator = require(ServerScriptService.Server.Equipment.EquipmentGenerator)

local AdminGiveItem = {}

-- List of authorized admin UserIds
local AdminList = {
	[94439374] = true,  -- Replace with your UserId
}

-- Example usage in your admin command:

function AdminGiveItem.onPlayerChatted(player, message)
	print(player, message)
	-- !give RainbowVoxel 1
	-- !give AzakanaBlade 1
	if not AdminList[player.UserId] then return end
	
	local args = string.split(message, " ")
	if args[1] == "!give" then
		local itemID = tostring(args[2])
		local quantity = tonumber(args[3]) or 1

		local newItem
		local itemData = Database.GetItem(itemID)
		if not itemData then
			warn("Item not found: " .. itemID)
			return
		end
		if itemData.Stackable then
			newItem = { ID = itemID, Quantity = quantity}
		elseif not itemData.Stackable then
			newItem = EquipmentGenerator.GenerateEquipment(itemID, nil)
		else
			newItem = { ID = itemID}
		end

		GameActions.AddItem(player, newItem)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		AdminGiveItem.onPlayerChatted(player, message)
	end)
end)
return AdminGiveItem