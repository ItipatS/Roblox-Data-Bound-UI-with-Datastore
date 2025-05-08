-- UIData.lua (Place this in ReplicatedStorage.Modules or a similar shared location)
local UIData = {}

function UIData.Bordercalculate(num)
	local baseX = 0       -- Starting x-coordinate
	local baseY = 0       -- Starting y-coordinate
	local blockSizeX = 64  -- Width of each block
	local blockSizeY = 64  -- Height of each block
	local rowLength = 10   -- Number of numbers in a row

	local row = math.floor((num - 1) / rowLength)
	local offset = (num - 1) % rowLength

	local x = baseX + offset * blockSizeX
	local y = baseY + row * blockSizeY

	return Vector2.new(x, y)
end

UIData.Tier = {
	minus1 = Color3.new(0.27451, 0.27451, 0.27451),
	one = Color3.new(1, 1, 1),
	two = Color3.new(0.588235, 1, 0.313725),
	three = Color3.new(0, 0.34902, 1),
	four = Color3.new(1, 0.772549, 0.239216),
	five = Color3.new(1, 0.52549, 0.533333),
	six = Color3.new(1, 0.32549, 0.964706),
	seven = Color3.new(0.905882, 0.529412, 1),
	eight = Color3.new(1, 0, 0.0156863),
	nine = Color3.new(0.352941, 1, 1),
	-- For the rainbow tier, we now store a table with our effect configuration.
	rainbow = {
		effect = "rainbow",
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255,165,0)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,128,0)),
			ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(75,0,130)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(148,0,211))
		}),
		direction = "bounce",  -- Change to "bounce" if desired.
		duration = 1,
	},
	-- For the rainbow tier, we now store a table with our effect configuration.
	demon = {
		effect = "demon",
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.3, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 0, 115)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(87, 0, 138))
		}),
		direction = "forward",  -- Change to "bounce" if desired.
		duration = 2,
	},
	
	test = {
		effect = "test",
		colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.166, Color3.fromRGB(190, 250, 255)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(94, 212, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 52, 152)),
			ColorSequenceKeypoint.new(0.666, Color3.fromRGB(52, 1, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 0, 47)),
		}),
		direction = "bounce",  -- Change to "bounce" if desired.
		duration = 2,
	},
}
function UIData:GetTier(Tier)
	return self.Tier[Tier]
end

return UIData
