local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local Misc = {Hooks = {},
    DefaultLighting = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        ColorShift_Top = Lighting.ColorShift_Top,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        ExposureCompensation = Lighting.ExposureCompensation,
        FogColor = Lighting.FogColor,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GeographicLatitude = Lighting.GeographicLatitude,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ShadowSoftness = Lighting.ShadowSoftness
    }
}

repeat task.wait() until
Stats.Network:FindFirstChild("ServerStatsItem")
local Ping = Stats.Network.ServerStatsItem["Data Ping"]

local LocalPlayer = PlayerService.LocalPlayer
local Request = (syn and syn.request)
or (http and http.request) or request

do local SetIdentity = syn and syn.set_thread_identity or setidentity
local OldPluginManager,Message -- Thanks to Kiriot22
task.spawn(function() SetIdentity(2)
    local Success,Error = pcall(getrenv().PluginManager)
    Message = Error
end)
OldPluginManager = hookfunction(getrenv().PluginManager, function()
    return error(Message)
end) end

function Misc:SetupFPS()
    local StartTime,TimeTable,
    LastTime = os.clock(), {}
    return function() LastTime = os.clock()
        for Index = #TimeTable, 1, -1 do
            TimeTable[Index + 1] = TimeTable[Index] >= LastTime - 1 and TimeTable[Index] or nil
        end TimeTable[1] = LastTime
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
    task.spawn(function()
        while task.wait(Wait) do
            local Success,Error = pcall(Function)
            if not Success then
                warn("thread error " .. Error)
            end
        end
    end)
end
function Misc:FixUpValue(fn,new,reverse)
    if not reverse then local oldFn
        oldFn = hookfunction(fn,function(...)
            return oldFn(new(...))
        end)
    else local oldFn
        oldFn = hookfunction(fn,function(...)
            return new(oldFn(...))
        end)
    end
end

function Misc:ReJoin()
    if #PlayerService:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nParvus Hub\nRejoining...")
        task.wait(0.5) TeleportService:Teleport(game.PlaceId)
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
            Title = "🎃 Parvus Hub",
            Description = "Couldn't find a server",
            Duration = 5
        })
    end
end

function Misc:JoinDiscord()
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

function Misc:SetupWatermark(Window)
    local GetFPS = Misc:SetupFPS()
    RunService.Heartbeat:Connect(function()
        if Window.Flags["UI/Watermark"] then
            Window.Watermark:SetTitle(string.format(
                "🎃 Parvus Hub    %s    %i FPS    %i MS",
                os.date("%X"),GetFPS(),math.round(Ping:GetValue())
            ))
        end
    end)
end

function Misc:SetupLighting(Flags) local OldNewIndex
    Lighting.Changed:Connect(function(Property) --pcall(function()
        local FormatedProperty = gethiddenproperty(Lighting,Property)
        local NormalProperty = gethiddenproperty(Lighting,Property)
        if type(FormatedProperty) == "number" then
            if Property == "EnvironmentSpecularScale"
            or Property == "EnvironmentDiffuseScale" then
                FormatedProperty = tonumber(string.format("%.3f",FormatedProperty))
            else FormatedProperty = tonumber(string.format("%.2f",FormatedProperty)) end
        end
        
        if FormatedProperty ~= Parvus.Utilities.UI:TableToColor(Flags["Lighting/"..Property])
        and NormalProperty ~= Misc.DefaultLighting[Property] then
            Misc.DefaultLighting[Property] = NormalProperty
        end
    end) --end)
    
    OldNewIndex = hookmetamethod(game,"__newindex",function(Self,Index,Value)
        if checkcaller() then return OldNewIndex(Self,Index,Value) end
        if Self == Lighting then Misc.DefaultLighting[Index] = Value end
        return OldNewIndex(Self,Index,Value)
    end)

    RunService.Heartbeat:Connect(function()
        if Flags["Lighting/Enabled"] then
            for Property,Value in pairs(Misc.DefaultLighting) do
                local CustomValue = Parvus.Utilities.UI:TableToColor(Flags["Lighting/"..Property])
                --if CustomValue ~= nil then sethiddenproperty(Lighting,Property,CustomValue) end
                if CustomValue ~= nil then Lighting[Property] = CustomValue end
            end
        end
    end)
end

return Misc
