-- ServerStorage.Modules.Blades
local Blades = {
	AzakanaBlade = {
		Tier = 'Demon',
		Rarity = "Legendary",
		Tradable = true,
		Category = "Blade",
		Type = "Katana",
		Model = "AzakanaBody", -- This corresponds to a model name in ReplicatedStorage.
		Stat = {
			BaseStats = {
				Strength = {min = 4, max = 8},   -- Fixed for now; change to a range (e.g., {min = 3.5, max = 4.5}) if you want variability.
				Dexterity = {min = 6, max = 10},
				Arcane = {min = 8, max = 12},
			},
			Damagetype = {
				Physical = 0.5,
				Magic = 0.5,
			},
			Scaling = {
				Strength = 0.2,
				Dexterity = 0.3,
				Arcane = 0.5,
			},
			Requires = {
				Strength = 8,
				Dexterity = 8,
				Arcane = 12,
			}
		},
		AdditionalStats = {},
		Passive = {
			["Gathering Storm"] = 1,
		},
		
		Viewport = {
			Model = CFrame.new(-0.5,-0.5,-0.5) * CFrame.Angles(math.rad(45), math.rad(90), 0),
			Camera = CFrame.new(Vector3.new(2,1,0), Vector3.new())
		},
		Name = "Azakana Blade",
		DescriptionLines = {
			"A blade favored by vengeful spirits.",
			"It shimmers in the darkness."
		},
		Border = {
			ImageRectOffset = 1,
			ImageColor3 = 1
		},
		Stackable = false

	},
	MoonLightBlade = {
		Tier = 'Moon',
		Rarity = "Legendary",
		Tradable = true,
		Category = "Blade",
		Type = "GreatSword",
		Model = "MoonLightBody", -- This corresponds to a model name in ReplicatedStorage.
		Stat = {
			BaseStats = {
				Strength = {min = 4, max = 8},   -- Fixed for now; change to a range (e.g., {min = 3.5, max = 4.5}) if you want variability.
				Dexterity = {min = 6, max = 10},
				Intelligence = {min = 8, max = 12},
			},
			Damagetype = {
				Physical = 0.5,
				Magic = 0.5,
			},
			Scaling = {
				Strength = 0.3,
				Dexterity = 0.2,
				Intelligence = 0.7,
			},
			Requires = {
				Strength = 12,
				Dexterity = 6,
				Intelligence = 24,
			}
		},
		AdditionalStats = {},
		Passive = {
			["Moon Blessing"] = 1,
		},

		Viewport = {
			Model = CFrame.new(-0.5,-0.5,-0.5) * CFrame.Angles(math.rad(45), math.rad(90), 0),
			Camera = CFrame.new(Vector3.new(2,1,0), Vector3.new())
		},
		Name = "MoonLight Blade",
		DescriptionLines = {
			"This sword is imbued with magic of blue moon",
			"which shall be unleashed as a wave of moonlight."
		},
		Border = {
			ImageRectOffset = 1,
			ImageColor3 = 1
		},
		Stackable = false

	},
	-- Add more blades here as needed.
}

return Blades
