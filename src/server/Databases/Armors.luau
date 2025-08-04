-- ServerStorage.Modules.Armors
local Armors = {
	TestChestPlate = {
		Tier = 'Test',
		Rarity = "Legendary",
		Tradable = true,
		Category = "Equipment",
		Type = "ChestPlate",
		Model = "TestChestPlate_Preview", -- This corresponds to a model name in ReplicatedStorage.
		Torso = "TestChestPlate_Torso",
		RightArm = "TestChestPlate_RightArm",
		LeftArm = "TestChestPlate_LeftArm",
		Stat = {
			BaseStats = {
				Strength = {min = 4, max = 8},   -- Fixed for now; change to a range (e.g., {min = 3.5, max = 4.5}) if you want variability.
				Dexterity = {min = 6, max = 10},
				Arcane = {min = 8, max = 12},
			},
		},
		Passive = {
			["Tester Stonk"] = 1,
		},
		Viewport = {
			Model = CFrame.new(-1.5,0,0),
			Camera = CFrame.new(Vector3.new(2,0,0), Vector3.new())
		},
		Name = "Tester ChestPlate",
		DescriptionLines = {
			"Tool tip",
		},
		Border = {
			ImageRectOffset = 1,
			ImageColor3 = 1
		},
		Stackable = false,

	},
	-- Add more blades here as needed.
}

return Armors
