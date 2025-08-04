local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = {}
local ProfileUpdatedRE = Instance.new("RemoteEvent", ReplicatedStorage)
ProfileUpdatedRE.Name = "ProfileUpdated"
DataManager.Profiles = {}
DataManager.JoinTimes = {}

function DataManager.InitPlayerProfile(player: Player, profile)
    ProfileUpdatedRE:FireClient(player, profile.Data)
end

return DataManager