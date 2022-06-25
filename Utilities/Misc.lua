local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local Request = syn and syn.request or request
local Misc = {}

function Misc:SetupFPS()
    local StartTime,TimeTable,
    LastTime = os.clock(), {}
    return function()
        LastTime = os.clock()
        for Index = #TimeTable, 1, -1 do
            TimeTable[Index + 1] = TimeTable[Index] >= LastTime - 1 and TimeTable[Index] or nil
        end
        TimeTable[1] = LastTime
        return os.clock() - StartTime >= 1 and #TimeTable or #TimeTable / (os.clock() - StartTime)
    end
end

function Misc:HideObject(Object)
    if gethui then Object.Parent = gethui() return end
    if syn and syn.protect_gui then
        syn.protect_gui(Object)
        Object.Parent = CoreGui
        return
    end
end

function Misc:NewThreadLoop(Wait,Function)
    coroutine.wrap(function()
        while task.wait(Wait) do
            local Success, Error = pcall(Function)
            if not Success then
                warn("thread error " .. Error)
            end
        end
    end)()
end

function Misc:ReJoin()
    if #PlayerService:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nParvus Hub\nRejoining...")
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end

function Misc:ServerHop()
    local Request = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local DataDecoded,Servers = HttpService:JSONDecode(Request).data,{}
    for Index,ServerData in ipairs(DataDecoded) do
        if type(ServerData) == "table" and ServerData.id ~= game.JobId then
            table.insert(Servers,ServerData.id)
        end
    end
    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)])
    else
        Parvus.Utilities.UI:Notification({
            Title = "Parvus Hub",
            Description = "Couldn't find a server",
            Duration = 5
        })
    end
end

function Misc:JoinDiscord()
    local Request = syn and syn.request or request
    Request({
        ["Url"] = "http://localhost:6463/rpc?v=1",
        ["Method"] = "POST",
        ["Headers"] = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        },
        ["Body"] = HttpService:JSONEncode({
            ["cmd"] = "INVITE_BROWSER",
            ["nonce"] = string.lower(HttpService:GenerateGUID(false)),
            ["args"] = {
                ["code"] = "sYqDpbPYb7"
            }
        })
    })
end

return Misc