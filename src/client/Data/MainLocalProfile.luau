-- MainLocalProfile.lua
local MainLocalProfile = {}

local HTTPService = game:GetService("HttpService")
local Replicated = game:GetService("ReplicatedStorage")

local ProfileUpdatedRE  = Replicated:WaitForChild("ProfileUpdated")

local profileData = nil
local listeners = {}


ProfileUpdatedRE.OnClientEvent:Connect(function(newData)
	profileData = newData
	-- Notify all subscribed listeners
	for _, callback in ipairs(listeners) do
		callback(profileData)
	end
end)

-- Subscribe to changes in profile data.
function MainLocalProfile.Subscribe(callback)
	table.insert(listeners, callback)
end

return MainLocalProfile
