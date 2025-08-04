local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
-- ServerScriptService.Modules.GameActions

local DataManager = require(ServerScriptService.Server.ProfileService.DataManager)
local ItemDatabase = require(ServerScriptService.Server.ProfileService.ItemDatabase)
local EquipMentManager = require(ServerScriptService.Server.Equipment.EquipmentGenerator)

local EquipItemEvent = ReplicatedStorage.EquipItemEvent
local UnequipItemEvent = ReplicatedStorage.UnequipItemEvent
local ProfileUpdatedRE = ReplicatedStorage.ProfileUpdated

local GameActions = {}

local PendingUpdates = {}
local lastSent = {}

local function QueueProfileUpdate(player: Player)
	if not PendingUpdates[player] then
		PendingUpdates[player] = true
	end
	GameActions.Update()
end

function ShallowCopy(t)
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

-- Batches and sends profile updates every frame
function GameActions.Update()
	local now = tick()
	for player, _ in pairs(PendingUpdates) do
		if not lastSent[player] or now - lastSent[player] >= 0.2 then
			local profile = DataManager.Profiles[player]
			if profile then
				ProfileUpdatedRE:FireClient(player, ShallowCopy(profile.Data))
				lastSent[player] = now
			end
		end
	end
	table.clear(PendingUpdates)
end

-- GameActions.lua
function GameActions.Run(actionName, player, data)
	local action = GameActions[actionName]
	if action then
		return action(player, data)
	else
		warn("Invalid GameAction:", actionName)
		return false, "Invalid action"
	end
end


GameActions.AddItem = function(player, data)
	if not data then
		warn("No data provided to AddItem")
		return
	end
	local profile = DataManager.Profiles[player]
	if not profile then return end

	local inventory = profile.Data.Inventory
	if not inventory then
		inventory = {
			stackable = {},
			unstackable = {}
		}
		profile.Data.Inventory = inventory
	end

	inventory.stackable = inventory.stackable or {}
	inventory.unstackable = inventory.unstackable or {}

	-- Normalize to a list
	local itemList = {}

	if typeof(data) == "string" then
		table.insert(itemList, { id = data }) -- assume unstackable basic
	elseif typeof(data) == "table" and not data[1] then
		-- single item with metadata
		table.insert(itemList, data)
	elseif typeof(data) == "table" then
		-- list of items
		for _, item in pairs(data) do
			table.insert(itemList, item)
		end
	end

	for _, item in ipairs(itemList) do
		local id = item.id or item.ID
		if not id then
			warn("No ID provided for item")
			continue
		end
		local quantity = item.quantity or 1
		if typeof(quantity) ~= "number" or quantity <= 0 then
			warn("Invalid quantity for item:", id)
			continue
		end
		local itemInfo = ItemDatabase.GetItem(id)
		if not itemInfo then
			warn("Invalid item ID:", id)
			continue
		end

		local isLiveUnstackable = item.UID or item.BaseStats or item.AdditionalStats
		if not itemInfo.Stackable then
			for i = 1, quantity do
				if isLiveUnstackable then
					table.insert(inventory.unstackable, item)
				else
					local instance = EquipMentManager.GenerateEquipment(id, nil, nil)
					if instance then
						table.insert(inventory.unstackable, instance)
					end
				end
			end
		elseif itemInfo.Stackable then
			-- Stackable item
			local stack = inventory.stackable[id]
			if not stack then
				stack = { Quantity = 0}
				inventory.stackable[id] = stack
			end
			stack.Quantity += quantity
		else
			warn("Item is neither stackable nor unstackable:", id)
			continue
		end
	end
	
	QueueProfileUpdate(player)
end


GameActions.GetCoin = function(player, data)
    local profile = DataManager.Profiles[player]
    if not profile then return end

    profile.Data.Coin += data.Coin
    QueueProfileUpdate(player)
end

GameActions.GetGem = function(player, data)
    local profile = DataManager.Profiles[player]
    if not profile then return end

    profile.Data.HGem += data.HGem
    QueueProfileUpdate(player)
end

GameActions.GainExp = function(player, data)
    local profile = DataManager.Profiles[player]
	if not profile then return end

	profile.Data.Exp += data.amount

	while profile.Data.Exp >= profile.Data.Level * 100 do
		profile.Data.Exp -= profile.Data.Level * 100
		profile.Data.Level += 1
		profile.Data.Point += 2
	end

	QueueProfileUpdate(player)
end

GameActions.BuyItem = function(player, data)
    local profile = DataManager.Profiles[player]
    if not profile then return false, "No profile" end

    if profile.Data.Coin < data.Cost then
        return false, "Not enough coins"
    end

    profile.Data.Coin -= data.Cost
	GameActions.AddItem(player, data)
    return true
end


GameActions.ClaimQuestReward = function(player, data)
	local profile = DataManager.Profiles[player]
	if not profile then return end

	profile.Data.Coin += data.Coin or 0
    
    GameActions.AddItem(player, data)
	GameActions.GainExp(player, { amount = data.Exp or 0 })
end

EquipItemEvent.OnServerEvent:Connect(function(player, itemUID, slotName)
	if typeof(itemUID) ~= "string" or typeof(slotName) ~= "string" then
		return
	end
	GameActions.Equip(player, itemUID, slotName)
end)

UnequipItemEvent.OnServerEvent:Connect(function(player, itemUID)
	local profile = DataManager.Profiles[player]
	if not profile then return end

	-- Find which equipment slot contains the item using its UID
	for slotName, equippedItem in pairs(profile.Equipment) do
		if equippedItem and equippedItem.UID == itemUID then
			-- Unequip: Remove from equipment and return to inventory
			profile.Equipment[slotName] = nil
			table.insert(profile.Inventory.unstackable, equippedItem)
			QueueProfileUpdate(player)
			break
		end
	end
end)

GameActions.Equip = function(player, itemID, slotName)
	local profile = DataManager.Profiles[player]
	if not profile then return end

	local inventory = profile.Inventory
	if not inventory then return end

	-- Find the item in the unstackable inventory by UID.
	local itemIndex = nil
	local itemData = nil
	for index, unstackableItem in ipairs(inventory.unstackable) do
		if unstackableItem.UID == itemID then
			itemIndex = index
			-- Get the full item data from your database.
			itemData = ItemDatabase.GetItem(unstackableItem.ID)
			break
		end
	end

	if not itemData then
		warn("Item not found in unstackable inventory")
		return
	end

	-- Validate that the item can be equipped in the given slot.
	if not itemData.Type == slotName then
		warn("Cannot equip item of type", itemData.Type, "into slot", slotName)
		return
	end

	-- Store any previously equipped item before replacing it.
	local previousEquipped = profile.Equipment[slotName]
	if previousEquipped then
		-- Add the previously equipped item back into the inventory.
		table.insert(inventory.unstackable, previousEquipped)
	end

	-- Equip the new item.
	profile.Equipment[slotName] = inventory.unstackable[itemIndex]
	-- Remove the new item from the inventory.
	table.remove(inventory.unstackable, itemIndex)

	-- Update the player's profile.
	QueueProfileUpdate(player)

	-- (Optional) Recalculate stats here or do it on-the-fly.
end



return GameActions
