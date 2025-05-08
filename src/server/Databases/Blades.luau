-- ServerStorage.Modules.Blades
local Blades = {}

-- Recursive deep copy function for tables.
local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Blade database. BaseStats are now defined as ranges.
Blades.Data = {
	AzakanaBlade = {
		Tier = 'demon',
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
		Tier = 'moon',
		Tradable = true,
		Category = "Blade",
		Type = "Great Sword",
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

-- Generates a randomized copy of a blade based on its base data.
-- This function randomizes the base stats from the defined ranges and initializes an empty AdditionalStats table.
function Blades:GenerateRandomBlade(bladeID)
	local baseData = self.Data[bladeID]
	if not baseData then
		warn("Blade ID not found: " .. tostring(bladeID))
		return nil
	end

	local blade = DeepCopy(baseData)

	-- Randomize base stats: for each stat, choose a random value between the min and max.
	for statName, range in pairs(blade.Stat.BaseStats) do
		local value = math.random(range.min * 100, range.max * 100) / 100
		blade.Stat.BaseStats[statName] = value
	end

	-- Prepare an empty table for additional modifiers (such as gemstone bonus, Burning, CritBoost, etc.)
	blade.AdditionalStats = {}

	return blade
end

-- Returns a copy of the base blade data without randomization.
function Blades:GetBladeFromID(bladeID)
	local data = self.Data[bladeID]
	if data then
		return DeepCopy(data)
	end
	return nil
end

return Blades
