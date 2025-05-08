-- ClientDatabaseCache.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetDatabaseRF = ReplicatedStorage.Remotes.GetDatabase

local DatabaseCache = {}

local cachedData = nil

function DatabaseCache.GetData()
	if not cachedData then
		cachedData = GetDatabaseRF:InvokeServer()	
		print(cachedData)
	end
	return cachedData
end

return DatabaseCache
