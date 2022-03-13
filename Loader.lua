repeat task.wait() until game.GameId ~= 0
if Parvus and Parvus.Loaded then
    Parvus.Utilities.UI:Notification("Parvus Hub","Script already executed!",5)
    return
end

getgenv().Parvus = {}
Parvus.Loaded = true
Parvus.Debug = false
Parvus.Current = "Loader"
Parvus.Config = {}
Parvus.Utilities = {
    Config = Parvus.Debug and loadfile("Parvus/Utilities/Config.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/Config.lua"))(),
    Cursor = Parvus.Debug and loadfile("Parvus/Utilities/Cursor.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/Cursor.lua"))(),
    ESP = Parvus.Debug and loadfile("Parvus/Utilities/ESP.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/ESP.lua"))(),
    UI = Parvus.Debug and loadfile("Parvus/Utilities/UI.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/UI.lua"))()
}

Parvus.Games = {
    ["1054526971"] = {
        Name = "Blackhawk Rescue Mission 5",
        Script = Parvus.Debug and readfile("Parvus/Games/BRM5.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/BRM5.lua")
    },
    ["580765040"] = {
        Name = "RAGDOLL UNIVERSE",
        Script = Parvus.Debug and readfile("Parvus/Games/RU.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/RU.lua")
    },
    ["1168263273"] = {
        Name = "Bad Business",
        Script = Parvus.Debug and readfile("Parvus/Games/BB.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/BB.lua")
    },
    --[[
    ["807930589"] = {
        Name = "The Wild West",
        Script = Parvus.Debug and readfile("Parvus/Games/TWW.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/TWW.lua")
    },
    ["2194874153"] = {
        Name = "Those Who Remain",
        Script = Parvus.Debug and readfile("Parvus/Games/TWR.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/TWR.lua")
    },
    ["2194874153"] = {
        Name = "Jailbird",
        Script = Parvus.Debug and readfile("Parvus/Games/Jailbird.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/Jailbird.lua")
    }
    ]]
}

--local ParvusModule = {}
local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local function getGameInfo()
    for Id,Info in pairs(Parvus.Games) do
        if tostring(game.GameId) == Id then
            return Info
        end
    end
end

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        getgenv().Parvus.Loaded = false
        local QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport
        QueueOnTeleport(Parvus.Debug and readfile("Parvus/Loader.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Loader.lua"))
    end
end)
--[[
function ParvusModule:AddUtility(Name, Loadstring)
    Parvus.Utilities[Name] = Loadstring
end

function ParvusModule:AddGame(GameId,Info)
    Parvus.Games[GameId] = Info
end
]]
--function ParvusModule:Load()
    local Info = getGameInfo()
    if Info then
        Parvus.Current = Info.Name
        Parvus.Utilities.UI:Notification("Parvus Hub",Parvus.Current .. " loaded!",5)
        loadstring(Info.Script)()
    else
        Parvus.Current = "Universal"
        Parvus.Utilities.UI:Notification("Parvus Hub",Parvus.Current .. " loaded!",5)
        loadstring(Parvus.Debug and readfile("Parvus/Universal.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Universal.lua"))()
    end
--end

--return ParvusModule
