repeat task.wait() until game.GameId ~= 0

if Parvus and Parvus.Game then
    Parvus.Utilities.UI:Notification({
        Title = "🎃 Parvus Hub",
        Description = "Script already running!",
        Duration = 5
    }) return
end

local PlayerService = game:GetService("Players")
repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local QueueOnTeleport = queue_on_teleport or
(syn and syn.queue_on_teleport)
local LoadArgs = {...}

local function GetSupportedGame() local Game
    for Id,Info in pairs(Parvus.Games) do
        if tostring(game.GameId) == Id then
            Game = Info break
        end
    end if not Game then
        return Parvus.Games.Universal
    end return Game
end

local function Concat(Array,Separator)
    local Output = "" for Index,Value in ipairs(Array) do
        Output = Index == #Array and Output .. tostring(Value)
        or Output .. tostring(Value) .. Separator
    end return Output
end

local function GetScript(Script)
    return Parvus.Debug and readfile("Parvus/" .. Script .. ".lua")
    or game:HttpGetAsync(("%s%s.lua"):format(Parvus.Domain,Script))
end

local function LoadScript(Script)
    return loadstring(Parvus.Debug and readfile("Parvus/" .. Script .. ".lua")
    or game:HttpGetAsync(("%s%s.lua"):format(Parvus.Domain,Script)))()
end

getgenv().Parvus = {Debug = LoadArgs[1],Utilities = {},
    Domain = "https://raw.githubusercontent.com/AlexR32/Parvus/main/",Games = {
        ["Universal" ] = {Name = "Universal",                 Script = "Universal" },
        ["1168263273"] = {Name = "Bad Business",              Script = "Games/BB"  },
        ["1586272220"] = {Name = "Steel Titans",              Script = "Games/ST"  },
        ["807930589" ] = {Name = "The Wild West",             Script = "Games/TWW" },
        ["580765040" ] = {Name = "RAGDOLL UNIVERSE",          Script = "Games/RU"  },
        ["187796008" ] = {Name = "Those Who Remain",          Script = "Games/TWR" },
        ["358276974" ] = {Name = "Apocalypse Rising 2",       Script = "Games/AR2" },
        ["1054526971"] = {Name = "Blackhawk Rescue Mission 5",Script = "Games/BRM5"}
    }
}

Parvus.Utilities.UI = LoadScript("Utilities/UI")
Parvus.Utilities.Misc = LoadScript("Utilities/Misc")
Parvus.Utilities.Drawing = LoadScript("Utilities/Drawing")

local SupportedGame = GetSupportedGame()
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        QueueOnTeleport(([[local LoadArgs = {%s}
        loadstring(LoadArgs[1] and readfile("Parvus/Loader.lua") or
        game:HttpGetAsync("%sLoader.lua"))(unpack(LoadArgs))
        ]]):format(Concat(LoadArgs,","),Parvus.Domain))
    end
end)

if SupportedGame then
    Parvus.Game = SupportedGame.Name
    LoadScript(SupportedGame.Script)
    Parvus.Utilities.UI:Notification({
        Title = "🎃 Parvus Hub",
        Description = Parvus.Game .. " loaded!",
        Duration = LoadArgs[2]
    })
end
