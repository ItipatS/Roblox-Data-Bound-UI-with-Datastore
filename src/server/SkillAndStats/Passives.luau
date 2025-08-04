local Passives = {
	-- Example Handle 1
	["Gathering Storm"] = {
		name = "Gathering Storm",
		scaling = nil, --same as weapon(blade)
		damageTypeOverride = nil, --same as weapon(blade)
		applyType = "finisherhit",
		timeToActive = 2, --Need finisherhit 2 times to gain passive
		multiplier = 0,
		multiplierPerCopy = 0.2,
		
		triggerFunction = function(player)
            --Hit enemy with finisher 2 times gain special dash attack
			print(player.Name .. " triggers a dash attack!")
		end,
		
		description = "Hit enemy with finisher 2 times gain special dash attack",
		skillprefab = nil,
	},
	
	["Way of the Hunter"] = {
		name = "Way of the Hunter",
		scaling = nil, --same as weapon(blade)
		damageTypeOverride = nil,
		flatdamage = 1,
		applyType = "allhit",
		baseChance = 0.4, -- per 1 
		chancePerCopy  = 0.1,
		multiplier = 0,
		multiplierPerCopy  = 0.2,

        triggerFunction = function(player)
            --all hit has chance to deal magic damage as 20% of hit damage
			print(player.Name .. " triggers Way of the Hunter!")
		end,
		description = "all hit has chance to deal bonus magic damage",
		skillprefab = nil,
	},
	["LifeLeech"] = {
		name = "LifeLeech",
		scaling = nil, --same as weapon(blade)
		damageTypeOverride = nil, --same as weapon(blade)
		applyType = "allhit",
		baseChance = 0.5, -- per 1
		multiplier = 0,
		multiplierPerCopy = 0.2,
		
		triggerFunction = function(player)
			print(player.Name .. " triggers LifeLeech!")
		end,
		
		description = "all hit has chance to heal amount of hit damage",
		skillprefab = nil,
	},
	
}

return Passives
