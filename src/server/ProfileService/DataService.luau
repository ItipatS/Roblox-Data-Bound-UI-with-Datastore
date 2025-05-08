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
	HGem = 0,
	Coin = 0,
	Exp = 0,
	Level = 0,
	Point = 0,
	Quest = {},
	Inventory = {},
	LogInTimes = 0,
	TotalGameTime = 0,
}

local GameProfileStore = ProfileService.New(GetStoreName(), ProfileTemplate )

local function DoSomethingWithALoadedProfile(player, profile)
	profile.Data.LogInTimes += 1
	 	
	if profile.Data.LogInTimes == 1 then
		-- Initialize inventory for new players
		profile.Data.Inventory["Carrot"] = {Quantity = 1}
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
