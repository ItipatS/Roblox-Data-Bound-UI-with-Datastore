-- ServerStorage.Modules.EquipmentGenerator
local EquipmentGenerator = {}
local HttpService = game:GetService("HttpService")
local ItemDatabase = require(game.ServerScriptService.Server.ProfileService.ItemDatabase)
local AdditionalStats = require(game.ServerScriptService.Server.SkillAndStats.AdditionalStats)
-- Internal helper: rolls base stats
local function rollBaseStats(base)
	local rolled = {}
	for stat, range in pairs(base.Stat.BaseStats) do
		rolled[stat]  = math.random(range.min * 100, range.max * 100) / 100
	end
	return rolled
end

-- Public: Generate item instance from base
function EquipmentGenerator.GenerateEquipment(itemID, enemyData)
	local base = ItemDatabase.GetItem(itemID)
	if not base then
		warn("[EquipmentGenerator] Item not found:", itemID)
		return nil
	end

	local rarity = base.Rarity or "Common"
	local tier = base.Tier or nil

	local item = {
		ID = itemID,
		UID = HttpService:GenerateGUID(false),
		BaseStats = rollBaseStats(base),
		AdditionalStats = AdditionalStats.Generate(rarity, tier),
	}

	return item
end


return EquipmentGenerator
