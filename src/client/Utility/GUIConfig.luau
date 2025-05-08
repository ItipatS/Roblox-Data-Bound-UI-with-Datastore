local GUIConfig = {}
local CAS = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

CAS:BindActionAtPriority("RightMouseDisable", function()
    return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.Medium.Value, Enum.UserInputType.MouseButton2)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

return GUIConfig