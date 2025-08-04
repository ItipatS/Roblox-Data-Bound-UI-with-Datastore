-- Modules/AdditionalStatsModule.lua
local SpecialStat = {}

function SpecialStat.MoonlightBurst()
	-- Passive-style effect: triggers AoE on crit
	return {
		Stat = "MoonlightBurst",
		Value = 1, -- just a flag (1 = enabled)
		IsPassive = true
	}
end

function SpecialStat.LunarCritAura()
	-- CritChance aura boost scaling with luck
	local bonus = 0.05
	return {
		Stat = "LunarCritAura",
		Value = bonus,
		IsPassive = true
	}
end

function SpecialStat.BloodPact()
	-- Trade HP for bonus damage
	return {
		Stat = "BloodPact",
		Value = 1,
		IsPassive = true
	}
end

function SpecialStat.ShadowFlash()
	-- Extra dash after kill
	return {
		Stat = "ShadowFlash",
		Value = 1,
		IsPassive = true
	}
end

-- Fallback if unknown stat
function SpecialStat._default(statName)
	return {
		Stat = statName,
		Value = 1,
		IsPassive = true
	}
end

return function(statName)
	local fn = SpecialStat[statName]
	return fn and fn() or SpecialStat._default(statName)
end
