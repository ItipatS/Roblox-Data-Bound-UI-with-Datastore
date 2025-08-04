-- SkillModule.lua
local Skills = {
	-- Example Handle 1
	["Spirit Cleave"] = {
		name = "Spirit Cleave",
		Icon = "rbxassetid://...",
		Cooldown = 12,
		scaling = {
			Strength = 0.5,
			Arcane = 0.5,
		},
		damageTypeOverride = {
			Physical = 0.5,
			Magic = 0.5,
		},
		flatdamage = 10,
		description = "cleaves in a cone in the target direction deal max hp% damage and gain shield",
		skillprefab = nil,
	},
}


return Skills
