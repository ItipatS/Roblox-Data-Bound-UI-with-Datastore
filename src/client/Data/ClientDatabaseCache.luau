-- ClientDatabaseCache.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetDatabaseRF = ReplicatedStorage.GetDatabase

local DatabaseCache = {}

local cachedData = nil

function DatabaseCache.GetData()
	if not cachedData then
		cachedData = GetDatabaseRF:InvokeServer()	
	end
	return cachedData
end

return DatabaseCache
