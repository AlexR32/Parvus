local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")


local Misc = {}
repeat task.wait() until
Stats.Network:FindFirstChild("ServerStatsItem")
local Ping = Stats.Network.ServerStatsItem["Data Ping"]
repeat task.wait() until Workspace:FindFirstChildOfClass("Terrain")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

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
    LastTime = os.clock(), {}, nil
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
            elseif Error == "break" then
                --[[print("thread stopped")]] break
            end
        end
    end)
end
function Misc:FixUpValue(fn,hook,global)
    if global then
        old = hookfunction(fn,function(...)
            return hook(old,...)
        end)
    else local old
        old = hookfunction(fn,function(...)
            return hook(old,...)
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
            Title = "Parvus Hub",
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
        if Window.Watermark.Enabled then
            Window.Watermark.Title = string.format(
                "Parvus Hub    %s    %i FPS    %i MS",
                os.date("%X"),GetFPS(),math.round(Ping:GetValue())
            )
        end
    end)
end

function Misc:LightingSection(Tab,Side)
    local LightingSection = Tab:Section({Name = "Lighting",Side = Side}) do
        LightingSection:Toggle({Name = "Enabled",Flag = "Lighting/Enabled",Value = false,
        Callback = function(Bool) if Bool then return end
            for Property,Value in pairs(Misc.DefaultLighting) do
                Lighting[Property] = Value
            end
        end})

        LightingSection:Colorpicker({Name = "Ambient",Flag = "Lighting/Ambient",Value = {1,0,1,0,false}})
        LightingSection:Slider({Name = "Brightness",Flag = "Lighting/Brightness",Min = 0,Max = 10,Precise = 2,Value = 3})
        LightingSection:Slider({Name = "ClockTime",Flag = "Lighting/ClockTime",Min = 0,Max = 24,Precise = 2,Value = 12})
        LightingSection:Colorpicker({Name = "ColorShift_Bottom",Flag = "Lighting/ColorShift_Bottom",Value = {1,0,1,0,false}})
        LightingSection:Colorpicker({Name = "ColorShift_Top",Flag = "Lighting/ColorShift_Top",Value = {1,0,1,0,false}})
        LightingSection:Slider({Name = "EnvironmentDiffuseScale",Flag = "Lighting/EnvironmentDiffuseScale",Min = 0,Max = 1,Precise = 3,Value = 0})
        LightingSection:Slider({Name = "EnvironmentSpecularScale",Flag = "Lighting/EnvironmentSpecularScale",Min = 0,Max = 1,Precise = 3,Value = 0})
        LightingSection:Slider({Name = "ExposureCompensation",Flag = "Lighting/ExposureCompensation",Min = -3,Max = 3,Precise = 2,Value = 0})
        LightingSection:Colorpicker({Name = "FogColor",Flag = "Lighting/FogColor",Value = {1,0,1,0,false}})
        LightingSection:Slider({Name = "FogEnd",Flag = "Lighting/FogEnd",Min = 0,Max = 100000,Value = 100000})
        LightingSection:Slider({Name = "FogStart",Flag = "Lighting/FogStart",Min = 0,Max = 100000,Value = 0})
        LightingSection:Slider({Name = "GeographicLatitude",Flag = "Lighting/GeographicLatitude",Min = 0,Max = 360,Precise = 1,Value = 23.5})
        LightingSection:Toggle({Name = "GlobalShadows",Flag = "Lighting/GlobalShadows",Value = false})
        LightingSection:Colorpicker({Name = "OutdoorAmbient",Flag = "Lighting/OutdoorAmbient",Value = {1,0,1,0,false}})
        LightingSection:Slider({Name = "ShadowSoftness",Flag = "Lighting/ShadowSoftness",Min = 0,Max = 1,Precise = 2,Value = 0})
        LightingSection:Toggle({Name = "Terrain Decoration",Flag = "Terrain/Decoration",Value = gethiddenproperty(Terrain,"Decoration"),
        Callback = function(Value) sethiddenproperty(Terrain,"Decoration",Value) end})
    end
end

function Misc:SetupLighting(Flags)
    Misc.DefaultLighting = {
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

    Lighting.Changed:Connect(function(Property)
        if Property == "TimeOfDay" then return end local Value
        if not pcall(function() Value = Lighting[Property] end) then return end
        local CustomValue,FormatedValue = Flags["Lighting/"..Property],Value
        local DefaultValue = Misc.DefaultLighting[Property]

        if type(CustomValue) == "table" then
            CustomValue = CustomValue[6]
        end

        if type(FormatedValue) == "number" then
            if Property == "EnvironmentSpecularScale" or Property == "EnvironmentDiffuseScale" then
                FormatedValue = tonumber(string.format("%.3f",FormatedValue))
            else
                FormatedValue = tonumber(string.format("%.2f",FormatedValue))
            end --print("format current",Property,FormatedValue)
        end

        if CustomValue ~= FormatedValue and Value ~= DefaultValue then
            --print("default prop",Property,Value)
            Misc.DefaultLighting[Property] = Value
        end
    end)
    RunService.Heartbeat:Connect(function()
        if Flags["Lighting/Enabled"] then
            for Property in pairs(Misc.DefaultLighting) do
                local CustomValue = Flags["Lighting/"..Property]
                if type(CustomValue) == "table" then
                    CustomValue = CustomValue[6]
                end
                if Lighting[Property] ~= CustomValue then
                    Lighting[Property] = CustomValue
                end
            end
        end
    end)
end

return Misc
