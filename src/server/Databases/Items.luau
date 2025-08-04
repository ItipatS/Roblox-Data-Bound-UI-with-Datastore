--ServerStorage items.lua

local Items = {
	FallenYellowStar ={
		Stackable = true,
		Tier = 'three',
		Rarity = "Rare",
		Tradable = true,
		Category = "Crafting material",
		Model = 'FallenYellowStar',

		Viewport = {
			Model = CFrame.new(Vector3.new(0,0,0)),
			Camera = CFrame.new( Vector3.new(2,1,0), Vector3.new())
		},
		Name = 'Fallen Yellow Star',

		DescriptionLines = {
			"Yellow is quite common.",
			"Disappears after the sunrise."
		},
		Border = {
			ImageRectOffset = 10,
			ImageColor3 = 1
		},
	},
	RainbowVoxel ={
		Stackable = true,
		Tier = 'Rainbow',
		Rarity = "Legendary",
		Tradable = true,
		Category = "Crafting material",
		Model = 'RainbowVoxel',

		Viewport = {
			Model = CFrame.new(Vector3.new(0,0,0)),
			Camera = CFrame.new( Vector3.new(2,1,0), Vector3.new())
		},
		Name = 'Rainbow Voxel',
		Border = {
			ImageRectOffset = 10,
			ImageColor3 = 1
		},
		DescriptionLines = {
			"No one know where'd it from.",
			"But who cares it's RaInBoW."
		},
	},
}

return Items