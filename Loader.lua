repeat task.wait() until game.GameId ~= 0
if Parvus and Parvus.Loaded then
    Parvus.Utilities.UI:Notification({
        Title = "Parvus Hub",
        Description = "Script already executed!",
        Duration = 5
    })
    return
end

getgenv().Parvus = {
    Loaded = false,
    Debug = false,
    Current = "Loader",
    Utilities = {},
    Config = {}
}

Parvus.Utilities.UI = Parvus.Debug and loadfile("Parvus/Utilities/UI.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/UI.lua"))()
Parvus.Utilities.Config = Parvus.Debug and loadfile("Parvus/Utilities/Config.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/Config.lua"))()
Parvus.Utilities.Drawing = Parvus.Debug and loadfile("Parvus/Utilities/Drawing.lua")() or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/Drawing.lua"))()

Parvus.Utilities.SetupFPS = function()
    local LastIteration
    local FrameUpdate = {}
    local Start = os.clock()
    return function()
        LastIteration = os.clock()
        for Index = #FrameUpdate, 1, -1 do
            FrameUpdate[Index + 1] = FrameUpdate[Index] >= LastIteration - 1 and FrameUpdate[Index] or nil
        end
        FrameUpdate[1] = LastIteration
        return os.clock() - Start >= 1 and #FrameUpdate or #FrameUpdate / (os.clock() - Start)
    end
end

Parvus.Utilities.NewThreadLoop = function(Wait,Function)
    coroutine.wrap(function()
        while task.wait(Wait) do
            local success, error = pcall(Function)
            if not success then
                warn("thread error happend: " .. error)
            end
        end
    end)()
end

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
        Script = readfile("Parvus/Games/TWW.lua")--Parvus.Debug and readfile("Parvus/Games/TWW.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/TWW.lua")
    },
    ["2194874153"] = {
        Name = "Those Who Remain",
        Script = readfile("Parvus/Games/TWR.lua")--Parvus.Debug and readfile("Parvus/Games/TWR.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Games/TWR.lua")
    }]]
}

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local function IfGameSupported()
    for Id, Info in pairs(Parvus.Games) do
        if tostring(game.GameId) == Id then
            return Info
        end
    end
end

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        local QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport
        QueueOnTeleport(Parvus.Debug and readfile("Parvus/Loader.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Loader.lua"))
    end
end)

local SupportedGame = IfGameSupported()
if SupportedGame then
    Parvus.Current = SupportedGame.Name
    loadstring(SupportedGame.Script)()
    Parvus.Utilities.UI:Notification({
        Title = "Parvus Hub",
        Description = Parvus.Current .. " loaded!",
        Duration = 5
    })
    Parvus.Loaded = true
else
    Parvus.Current = "Universal"
    loadstring(Parvus.Debug and readfile("Parvus/Universal.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/Parvus/main/Universal.lua"))()
    Parvus.Utilities.UI:Notification({
        Title = "Parvus Hub",
        Description = Parvus.Current .. " loaded!",
        Duration = 5
    })
    Parvus.Loaded = true
end
