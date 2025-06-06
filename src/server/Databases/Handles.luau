-- ServerStorage.Modules.Handles
local Handles = {}

-- Handle data
Handles.Data = {
	AzakanaHandle = {
		Tier = 'demon',
		Tradable = true,
		Category = "Handle",
		Model = "AzakanaHandle", -- Model name in ServerStorage
		Stat = {
			BaseStats = {
				Strength = {min = 4, max = 4},   -- Fixed for now; change to a range (e.g., {min = 3.5, max = 4.5}) if you want variability.
				Dexterity = {min = 6, max = 6},
				Arcane = {min = 8, max = 8},
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
		Passive = {
			["Gathering Storm"] = 1,
		},
		Type = "Katana",
		Viewport = {
			Model = CFrame.new(Vector3.new(0,0,0)),
			Camera = CFrame.new(Vector3.new(2,1,0), Vector3.new())
		},	
		Name = "Azakana Handle",
		DescriptionLines = { 
			"A handle favored by vengeful spirits.",
			"It shimmers in the darkness."  -- You can have as many lines as needed.
		},
		Border = {
			ImageRectOffset = 1,
			ImageColor3 = 1
		},
		Stackable = false
	},
	MoonLightHandle = {
		Tier = 'moon',
		Tradable = true,
		Category = "Handle",
		Type = "Long Handle",
		Model = "MoonLightHandle", -- This corresponds to a model name in ReplicatedStorage.
		Stat = {
			BaseStats = {
				Strength = {min = 4, max = 8},   -- Fixed for now; change to a range (e.g., {min = 3.5, max = 4.5}) if you want variability.
				Dexterity = {min = 6, max = 10},
				Intelligence = {min = 8, max = 12},
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
			Model = CFrame.new(Vector3.new(0,0,0)),
			Camera = CFrame.new(Vector3.new(2,1,0), Vector3.new())
		},
		Name = "MoonLight Handle",
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
}

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

function Handles:GenerateRandomBlade(bladeID)
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


function Handles:GetHandleFromID(HandleID)
	for index, HandleData in ipairs(Handles.Data) do
		if HandleData.ID == HandleID then
			local modifiedItemData = DeepCopy(HandleData)
			return modifiedItemData
		end
	end
	return nil
end


return Handles
