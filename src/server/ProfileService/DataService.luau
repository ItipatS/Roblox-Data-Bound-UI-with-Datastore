--ServerStorage.System.DataService
local DataService = {}

local ProfileService = require(script.Parent.ProfileService)
local DataManager = require(script.Parent.DataManager)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function GetStoreName()
    return RunService:IsStudio() and "Test" or "Live"
end

local ProfileTemplate = {
	
	Inventory = {
		stackable = {
			-- e.g., [itemID] = { quantity = 5, type = "Consumable", ... }
		},
		unstackable = {
			-- e.g., { ID = "AzakanaBlade", Type = "Blade", other properties... }
		}
	},
	
	Equipment = {
		Helmet = nil,
		ChestPlate = nil,
		Leggings = nil,
		Acc1 = nil,
		Acc2 = nil,
		Acc3 = nil,
		Acc4 = nil,
		RightHand = nil,
		LeftHand = nil,
	},
	Passives = {},

	VoxlSoul = 0,
	Level = 1,
	Strength = 5,
	Vitality = 5,
	Agility = 5,
	Dexterity = 5,
	Intelligence = 5,
	Endurance = 5,
	Arcane = 5,
	Faith = 5,
	Luck = 5,

	LogInTimes = 0,
	TotalGameTime = 0,
	TotalKill = 0,
	BossDefeat = 0,
	TotalDeath = 0,
	UnusualDeaths = {
		Fall = 0,
	},
	HighestDamageDealt = 0,
	Quest ={},
	AchievementsEarned = {
		"None"
	},
	DistanceTraveled = 0,
	FavoriteBlade = "None",
	FavoriteHandle = "None",
	FavoriteStance = "None",
	PrismaticDefeat = 0,
}

local GameProfileStore = ProfileService.New(GetStoreName(), ProfileTemplate )

local function DoSomethingWithALoadedProfile(player, profile)
	profile.Data.LogInTimes += 1
	 	
	if profile.Data.LogInTimes == 1 then
		-- Initialize inventory for new players
		profile.Data.Inventory["RainbowVoxel"] = {Quantity = 1}
	end
	
	DataManager.JoinTimes[player] = tick()
	DataManager.InitPlayerProfile(player, profile)
end


local function PlayerAdded(player: Player) 
	
	--Start a new profile session
	local profile = GameProfileStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Sanity check to ensure profile exists
	if profile ~= nil then
		
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data error occured. Please rejoin.")
		end)
		
		if player.Parent == Players then

			DoSomethingWithALoadedProfile(player, profile)
			DataManager.Profiles[player] = profile

		else
			profile:EndSession()
		end
		
	else
		player:Kick('Failed to Load Data : OnPlayerAdded')
	end
end

local function PlayerRemoving(player:Player)
	local profile = DataManager.Profiles[player]
		if profile then
			
			local duration = tick() - DataManager.JoinTimes[player]
			profile.Data.TotalGameTime += duration
			profile.Data.TotalGameTime = math.floor(profile.Data.TotalGameTime * 1000)/1000
			DataManager.JoinTimes[player] = nil
			
			profile:EndSession()
			DataManager.Profiles[player] = nil
		end
end


local function Init()
	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(PlayerAdded, player)
	end
	
	Players.PlayerAdded:Connect(PlayerAdded)
	
	Players.PlayerRemoving:Connect(PlayerRemoving)
end

Init()

return DataService
