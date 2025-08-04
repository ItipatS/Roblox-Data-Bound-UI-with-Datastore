local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetRandomItemButton:TextButton = Players.LocalPlayer.PlayerGui.Interface.TextButton
local GetRandomItem:RemoteEvent = ReplicatedStorage.GetRandomItemButton

local button = {}

GetRandomItemButton.MouseButton1Down:Connect(function()
    GetRandomItem:FireServer()
end)

return button