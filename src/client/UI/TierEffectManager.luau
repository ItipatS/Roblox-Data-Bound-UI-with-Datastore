-- TierEffectManager.lua
local TweenManager = require(script.Parent.TweenManager)

local TierEffectManager = {}

-- Internal mapping from tier names to functions that start their effects.
local tierEffects = {
	-- For the rainbow tier, we pass in the configuration (colorSequence, direction, duration)
	demon = function(nameLabel, config)
		local options = {
			colorSequence = config.colorSequence,
			direction = config.direction,
			duration = config.duration or 2,
		}
		return {
			colorLoop = TweenManager.StartColorSequenceLoop(nameLabel, options),
			gradient = TweenManager.StartTextGradientEffect(nameLabel, options),
			glow = TweenManager.StartGlow(nameLabel),
		}
	end,
	
	rainbow = function(nameLabel, config)
		local options = {
			colorSequence = config.colorSequence,
			direction = config.direction,
			duration = config.duration or 2,
		}
		return {
			colorLoop = TweenManager.StartColorSequenceLoop(nameLabel, options),
			--gradient = TweenManager.StartTextGradientEffect(nameLabel, options),
			glow = TweenManager.StartGlow(nameLabel),
		}
	end,
	
	test = function(nameLabel, config)
		local options = {
			colorSequence = config.colorSequence,
			direction = config.direction,
			duration = config.duration or 2,
		}
		return {
			colorLoop = TweenManager.StartColorSequenceLoop(nameLabel, options),
			gradient = TweenManager.StartTextGradientEffect(nameLabel, options),
			glow = TweenManager.StartGlow(nameLabel),
		}
	end,
	-- Add more tiers with unique effects as needed.
}

-- Helper to clear all active effects via their stop functions.
local function clearEffects(stopFunctions, nameLabel, newColor)
	if stopFunctions then
		for key, stopFunc in pairs(stopFunctions) do
			stopFunc()
		end
	end
	if nameLabel and newColor and typeof(newColor) == "Color3" then
		nameLabel.TextColor3 = newColor
	end
end

-- Applies effects to the UI element based on the provided tier.
-- If the tier is a table with an 'effect' field, use the corresponding effect function.
-- Otherwise, if it’s a static Color3 or unrecognized, simply set the color.
function TierEffectManager.ApplyEffects(nameLabel, tier)
	local stopFunctions = nil
	if type(tier) == "table" and tier.effect then
		local effectName = tier.effect
		if tierEffects[effectName] then
			stopFunctions = tierEffects[effectName](nameLabel, tier)
		end
	elseif type(tier) == "string" then
		-- If tier is a string, try to see if we have an effect for it.
		if tierEffects[tier] then
			stopFunctions = tierEffects[tier](nameLabel, {})
		else
			nameLabel.TextColor3 = tier
		end
	elseif typeof(tier) == "Color3" then
		nameLabel.TextColor3 = tier
	else
		nameLabel.TextColor3 = Color3.new(1,1,1)
	end
	return stopFunctions
end

-- Expose the clear function for convenience.
TierEffectManager.ClearEffects = clearEffects

return TierEffectManager
