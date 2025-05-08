-- ServerStorage.Modules.ItemDatabase.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GetDatabaseRF = ReplicatedStorage.Remotes.GetDatabase
local ItemDatabase = {}

-- This stores flat data (key -> itemData)
local flatData = {}

-- This optionally tracks data by category (module name)
local categorizedData = {}

-- Helper to safely flatten a module
local function flattenModule(moduleScript)
	local ok, module = pcall(require, moduleScript)
	if not ok then
		warn("[ItemDatabase] Failed to require:", moduleScript:GetFullName(), module)
		return
	end

	local data = module.Data or module
	if type(data) ~= "table" then
		warn("[ItemDatabase] Invalid data format in", moduleScript.Name)
		return
	end

	categorizedData[moduleScript.Name] = {}

	for key, value in pairs(data) do
		if flatData[key] then
			warn("[ItemDatabase] Duplicate item ID detected:", key)
		end
		flatData[key] = value
		categorizedData[moduleScript.Name][key] = value
	end
end

-- Scan and flatten all modules
local function loadAll()
	local dbFolder = script.Parent.Parent.Databases
	for _, module in ipairs(dbFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			flattenModule(module)
		end
	end
end

-- Public API
function ItemDatabase.GetItem(itemID)
	return flatData[itemID]
end

function ItemDatabase.GetAll()
	return flatData
end

function ItemDatabase.GetCategory(name)
	return categorizedData[name]
end

function ItemDatabase.Reload()
	table.clear(flatData)
	table.clear(categorizedData)
	loadAll()
end

-- Initialize on load
loadAll()

-- Send to client
GetDatabaseRF.OnServerInvoke = function()
	return ItemDatabase.GetAll()
end

return ItemDatabase
