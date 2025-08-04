local SpecialStat = require(script.Parent.SpecialStat)

local AdditionalStats = {}


local function countDic(t)
	local c = 0
	for _ in pairs(t) do c += 1 end
	return c
end

AdditionalStats.RarityWeights = {
	Common = {
		Common = 60,
		Rare = 30,
		Epic = 10,
		Legendary = 5
	},
	Rare = {
		Common = 40,
		Rare = 40,
		Epic = 20,
		Legendary = 10
	},
	Epic = {
		Common = 15,
		Rare = 30,
		Epic = 40,
		Legendary = 15
	},
	Legendary = {
		Common = 10,
		Rare = 20,
		Epic = 30,
		Legendary = 20
	}
}

AdditionalStats.StatDefinitions = {
	CritChance = {
		Rarities = { "Rare", "Epic", "Legendary" },
		Category = "Offense",
		Formula = function(rarityMult)
			return 10 + rarityMult * 5
		end,
		Description = "Increases chance to deal critical hits."
	},
	BurnChance = {
		Rarities = { "Common", "Rare" },
		Category = "Debuff",
		Formula = function(rarityMult)
			return 5 + rarityMult * 3
		end,
		Description = "Chance to apply burn on hit."
	},
	OmniVamp = {
		Rarities = { "Legendary" },
		Category = "Sustain",
		Formula = function(rarityMult)
			return 3 + rarityMult * 2
		end,
		Description = "Heals for a portion of all damage dealt."
	},
	-- etc.
}


AdditionalStats.SpecialStats = {
	Moon = {
		"MoonlightBurst",
		"LunarCritAura"
	},
	Demon = {
		"BloodPact",
		"ShadowFlash"
	},
    Celestial = {
        "HolyNova",
         "HeavenStrike"
    },
}

function AdditionalStats.GenerateSpecial(tier)
	local tierPool = AdditionalStats.SpecialStats[tier]
	if not tierPool then return nil end

	local statName = tierPool[math.random(1, #tierPool)]
	return SpecialStat(statName)
end

-- Rarity weights (or just use Enum-like system)
AdditionalStats.RarityValues = {
	Common = 1,
	Rare = 2,
	Epic = 3,
	Legendary = 4
}

function AdditionalStats.GetWeightedStatPool(rarity)
	local weights = AdditionalStats.RarityWeights[rarity]
	local result = {}

	for statName, def in pairs(AdditionalStats.StatDefinitions) do
		for _, r in ipairs(def.Rarities or {}) do
			local weight = weights[r]
			if weight then
				for i = 1, weight do
					table.insert(result, statName)
				end
			end
		end
	end

	return result
end

function AdditionalStats.Generate(rarity, tier)
	local results = {}
	local rarityMult = tonumber(string.format("%.2f", AdditionalStats.RarityValues[rarity] / 4)) or 0.25
	local pool = AdditionalStats.GetWeightedStatPool(rarity) or {}
	local statCount = math.random(1, math.min(4, AdditionalStats.RarityValues[rarity]))

	for i = 1, statCount do
        local statName = pool[math.random(1, #pool)]
        local formula = AdditionalStats.StatDefinitions[statName] and AdditionalStats.StatDefinitions[statName].Formula
        local value = formula and formula(rarityMult) or 0

        if results[statName] then
            results[statName] += value * 0.5
        else
            results[statName]  = value
        end
    end

	local newSpecial = AdditionalStats.GenerateSpecial(tier)
	if newSpecial then
		results[newSpecial.Stat] = newSpecial.Value
	end

	return results
end

function AdditionalStats.ReforgeStats(weaponData)
	local results = {}
	local rarity = weaponData.Rarity
	local lockStat = weaponData.Lock
	local oldStats = weaponData.Stats or {}
	local tier = weaponData.Tier
	local rarityMult = AdditionalStats.RarityValues[rarity] or 1
	local pool = AdditionalStats.GetWeightedStatPool(rarity)
	local maxCount = AdditionalStats.MaxStatCount[rarity] or 1

	-- Preserve locked stat
	if lockStat and oldStats[lockStat] then
		results[lockStat] = oldStats[lockStat]
	end

	-- Re-roll remaining stats
	for i = 1, maxCount do
		local statName = pool[math.random(1, #pool)]
		local formula = AdditionalStats.StatDefinitions[statName] and AdditionalStats.StatDefinitions[statName].Formula
		local value = formula and formula(rarityMult) or 0

		if results[statName] then
			results[statName] = value * 0.5
		else
			results[statName] = value
		end
	end

	-- Re-roll or retain special stat
	local newSpecial = AdditionalStats.GenerateSpecial(tier)
	if newSpecial then
		results[newSpecial.Stat] = newSpecial.Value
	end

	return results
end


return AdditionalStats