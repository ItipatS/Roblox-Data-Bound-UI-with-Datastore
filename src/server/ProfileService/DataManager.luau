local DataManager = {}
local ProfileUpdatedRE = game.ReplicatedStorage.Remotes.ProfileUpdated
DataManager.Profiles = {}
DataManager.JoinTimes = {}

function DataManager.InitPlayerProfile(player: Player, profile)
    ProfileUpdatedRE:FireClient(player, profile.Data)
end

return DataManager