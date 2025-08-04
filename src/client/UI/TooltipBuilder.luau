-- TooltipBuilder.lua (Place in ReplicatedStorage.Modules or similar)

local TooltipBuilder = {}

-- Helper function: convert Color3 to hex string (e.g., "#RRGGBB")
function TooltipBuilder.Color3ToHex(color)
	local r = math.floor(color.R * 255)
	local g = math.floor(color.G * 255)
	local b = math.floor(color.B * 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

local damageColorMap = {
	Light = Color3.fromRGB(255, 255, 255),   -- white
	Dark = Color3.fromRGB(90, 0, 90),        -- dark purple
	Earth = Color3.fromRGB(139, 69, 19),     -- dirt brown
	Water = Color3.fromRGB(0, 128, 255),     -- blue
	Wind = Color3.fromRGB(0, 255, 128),      -- cyan
	Fire = Color3.fromRGB(255, 0, 0),        -- red
	Physical = Color3.fromRGB(255, 165, 79), -- faded orange
	Magic = Color3.fromRGB(255, 133, 216),   -- pink
}

local scalingColorMap = {
	vitality = Color3.fromRGB(34, 139, 34),       -- turtle green
	endurance  = Color3.fromRGB(205, 92, 92),       -- deep orange/red
	strength = Color3.fromRGB(255, 0, 0),         -- red
	dexterity = Color3.fromRGB(255, 255, 224),     -- whitish yellow
	intelligence  = Color3.fromRGB(0, 0, 255),         -- blue
	agi = Color3.fromRGB(127, 255, 0),       -- faded green
	faith = Color3.fromRGB(148, 0, 211),       -- faded purple
	arcane = Color3.fromRGB(255, 133, 216),     -- pink
	luck = Color3.fromRGB(255, 255, 255),     -- white
}

-- Helper to colorize a damage type line
local function colorDamageLine(damageType, value)
	local color = damageColorMap[damageType] or Color3.new(1,1,1)
	local hex = TooltipBuilder.Color3ToHex(color)
	-- e.g. "<font color='#RRGGBB'>Dark</font>: 0.5"
	return string.format("<font color=\"%s\">%s: %s</font>", hex, damageType, tostring(value))
end

local function colorScalingLine(stat, value)
	-- e.g. stat might be "Strength" or short like "str". 
	-- If you're storing short keys, ensure your data matches this map.
	local key = string.lower(stat) -- e.g. "strength" -> "strength"
	-- If you want them to be short like "str", 
	-- either store them as "str" in your data or do a conversion table.
	local color = scalingColorMap[key] or Color3.new(1,1,1)
	local hex = TooltipBuilder.Color3ToHex(color)
	-- e.g. "<font color='#RRGGBB'>str</font>: 0.5"
	return string.format("<font color=\"%s\">%s: %s</font>", hex, stat, tostring(value))
end

-- Build tooltip text from an item data table.
-- Assumes that the TextLabel displaying the tooltip has RichText enabled.
function TooltipBuilder.BuildTooltip(itemData ,modData ,uiData)
	-- uiData is a module that holds common UI info (like tier colors).
	-- For example, uiData:GetTierData(tierName) returns a Color3.
	local tooltipLines = {}
	
	table.insert(tooltipLines, itemData.Category or "")

	-- 3. Description lines
	if itemData.DescriptionLines then
		for _, line in ipairs(itemData.DescriptionLines) do
			table.insert(tooltipLines, line)
		end
	end


	-- 4. For weapons/parts (Category "Blade" or "Weapon"), add extra sections.
	if itemData.Category == "Blade" or itemData.Category == "Weapon" or itemData.Category == "Handle" or itemData.Category == "Equipment" then
		table.insert(tooltipLines, "") -- blank line as header separator

		if itemData.Stat and itemData.Stat.Requires then
			table.insert(tooltipLines, "-- Requires --")
			for statName, statValue in pairs(itemData.Stat.Requires) do
				table.insert(tooltipLines, colorScalingLine(statName, statValue))
			end
		end
		-- Header for Damage Types
		if modData.BaseStats then
			table.insert(tooltipLines, "-- Base Stats --")
			for statName, statValue in pairs(modData.BaseStats) do
				table.insert(tooltipLines, colorScalingLine(statName, statValue))
			end
		end
		
		-- Header for Scaling
		if itemData.Stat and itemData.Stat.Scaling then
			table.insert(tooltipLines, "-- Scaling --")
			for statKey, statValue in pairs(itemData.Stat.Scaling) do
				table.insert(tooltipLines, colorScalingLine(statKey, statValue))
			end
		end
		
		if itemData.Stat and itemData.Stat.Damagetype then
			table.insert(tooltipLines, "-- Damage Types --")
			for dmgType, dmgValue in pairs(itemData.Stat.Damagetype) do
				table.insert(tooltipLines, colorDamageLine(dmgType, dmgValue))
			end
		end

		-- Header for Passive
		if itemData.Passive then
			table.insert(tooltipLines, "-- Passive --")
			for passive, count in pairs(itemData.Passive) do
				table.insert(tooltipLines, passive .. " +" .. tostring(count))
			end
		end
		
		-- 6. Additional Stats (if available)
		if modData.AdditionalStats then
			table.insert(tooltipLines, "-- Attributes --")
			for modName, modValue in pairs(modData.AdditionalStats) do
				table.insert(tooltipLines, modName .. ": " .. tostring(modValue) .. "%")
			end
		end

		-- Header for Weapon Type (if applicable)
		if itemData.Type then
			table.insert(tooltipLines, "-- Type --")
			table.insert(tooltipLines, itemData.Type)
		end
		
	end
	
	local tradeText = itemData.Tradable and "Tradable" or "Untradable"
	local tradeColor = itemData.Tradable and Color3.new(0, 0.75, 0) or Color3.new(0.75, 0, 0)
	local tradeLine = string.format("<font color=\"%s\">%s</font>",
		TooltipBuilder.Color3ToHex(tradeColor),
		tradeText
	)
	table.insert(tooltipLines, tradeLine)

	-- Combine all lines with newline characters
	return table.concat(tooltipLines, "\n")
end

return TooltipBuilder
