local ContextActionService = game:GetService("ContextActionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
--local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local MainModule = {DefaultLighting = {}}

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local SetIdentity = setidentity or (syn and syn.set_thread_identity)
local Request = request or (http and http.request) or (syn and syn.request)

do -- Thanks to Kiriot22
    local OldPluginManager,Message = nil,nil
    task.spawn(function() SetIdentity(2)
        local Success,Error = pcall(getrenv().PluginManager)
        Message = Error
    end)
    OldPluginManager = hookfunction(getrenv().PluginManager,function()
        return error(Message)
    end)
end

repeat task.wait() until Stats.Network:FindFirstChild("ServerStatsItem")
local Ping = Stats.Network.ServerStatsItem["Data Ping"]

repeat task.wait() until Workspace:FindFirstChildOfClass("Terrain")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local XZVector,YVector = Vector3.new(1,0,1),Vector3.new(0,1,0)
local Movement = {Forward = 0,Backward = 0,Right = 0,Left = 0,Up = 0,Down = 0}
local function GetFlatVector(CF) return CF.LookVector * XZVector,CF.RightVector * XZVector end
local function GetUnit(Vector) if Vector.Magnitude == 0 then return Vector end return Vector.Unit end

local function MovementBind(ActionName,InputState)
    Movement[ActionName] = InputState == Enum.UserInputState.Begin and 1 or 0
    return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("Forward",MovementBind,false,Enum.KeyCode.W)
ContextActionService:BindAction("Backward",MovementBind,false,Enum.KeyCode.S)
ContextActionService:BindAction("Left",MovementBind,false,Enum.KeyCode.A)
ContextActionService:BindAction("Right",MovementBind,false,Enum.KeyCode.D)
ContextActionService:BindAction("Up",MovementBind,false,Enum.KeyCode.Space)
ContextActionService:BindAction("Down",MovementBind,false,Enum.KeyCode.LeftShift)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

--[[function MainModule.HideObject(Object)
    if gethui then Object.Parent = gethui() return end
    if syn and syn.protect_gui then
        syn.protect_gui(Object)
        Object.Parent = CoreGui
        return
    end
end]]

function MainModule.SetupFPS()
    local StartTime,TimeTable,LastTime = os.clock(),{},nil
    return function() LastTime = os.clock()
        for Index = #TimeTable, 1, -1 do
            TimeTable[Index + 1] = TimeTable[Index] >= LastTime - 1
            and TimeTable[Index] or nil
        end TimeTable[1] = LastTime
        return os.clock() - StartTime >= 1 and #TimeTable
        or #TimeTable / (os.clock() - StartTime)
    end
end
function MainModule.MovementToDirection()
    local LookVector,RightVector = GetFlatVector(Camera.CFrame)
    local ZMovement = LookVector * (Movement.Forward - Movement.Backward)
    local XMovement = RightVector * (Movement.Right - Movement.Left)
    local YMovement = YVector * (Movement.Up - Movement.Down)
    return GetUnit(ZMovement + XMovement + YMovement)
end
function MainModule.NewThreadLoop(Wait,Function)
    task.spawn(function()
        while true do
            local Delta = task.wait(Wait)
            local Success,Error = pcall(Function,Delta)
            if not Success then
                warn("thread error " .. Error)
            elseif Error == "break" then
                --[[print("thread stopped")]] break
            end
        end
    end)
end
function MainModule.FixUpValue(fn,hook,global)
    if global then
        old = hookfunction(fn,function(...)
            return hook(old,...)
        end)
    else
        local old = nil
        old = hookfunction(fn,function(...)
            return hook(old,...)
        end)
    end
end

function MainModule.ReJoin()
    if #PlayerService:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nParvus Hub\nRejoining...")
        task.wait(0.5) TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end
function MainModule.ServerHop()
    local DataDecoded,Servers = HttpService:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=2&excludeFullGames=true&limit=100"
    )).data,{}
    for Index,ServerData in ipairs(DataDecoded) do
        if type(ServerData) == "table" and ServerData.id ~= game.JobId then
            table.insert(Servers,ServerData.id)
        end
    end
    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,Servers[math.random(#Servers)]
        )
    else
        Parvus.Utilities.UI:Notification({
            Title = "Parvus Hub",
            Description = "Couldn't find a server",
            Duration = 5
        })
    end
end
function MainModule.JoinDiscord()
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

--[[
# UI Color
  - Default   = 1,0.25,1,0,true
  - Christmas = 0.4541666507720947,0.20942406356334686,0.7490196228027344,0,false
  - Halloween = 0.0836667,1,1,0,false
# Background Color
  - Default   = 1,1,0,0,false
  - Christmas = 0.12000000476837158,0.10204081237316132,0.9607843160629272,0.5,false
  - Halloween = 0.0836667,1,1,0,false
]]

function MainModule.SettingsSection(Self,Window,UIKeybind,CustomMouse)
    local OptionsTab = Window:Tab({Name = "Options"}) do
        local MenuSection = OptionsTab:Section({Name = "Menu",Side = "Left"}) do
            local UIToggle = MenuSection:Toggle({Name = "UI Enabled",Flag = "UI/Enabled",IgnoreFlag = true,
            Value = Window.Enabled,Callback = function(Bool) Window.Enabled = Bool end})
            UIToggle:Keybind({Value = UIKeybind,Flag = "UI/Keybind",DoNotClear = true})
            UIToggle:Colorpicker({Flag = "UI/Color",Value = {1,0.25,1,0,true},
            Callback = function(HSVAR,Color) Window.Color = Color end})

            MenuSection:Toggle({Name = "Open On Load",Flag = "UI/OOL",Value = true})
            MenuSection:Toggle({Name = "Blur Gameplay",Flag = "UI/Blur",Value = false,
            Callback = function(Bool) Window.Blur = Bool end})

            MenuSection:Toggle({Name = "Custom Mouse",Flag = "Mouse/Enabled",Value = CustomMouse})

            MenuSection:Toggle({Name = "Watermark",Flag = "UI/Watermark/Enabled",Value = true,
            Callback = function(Bool) Window.Watermark.Enabled = Bool end}):Keybind({Flag = "UI/Watermark/Keybind"})

            MenuSection:Button({Name = "Rejoin",Callback = Self.ReJoin})
            MenuSection:Button({Name = "Server Hop",Callback = Self.ServerHop})
            MenuSection:Button({Name = "Copy Lua Invite",Callback = function()
                setclipboard("game:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. game.PlaceId .. ", \"" .. game.JobId .. "\");")
            end})
            MenuSection:Button({Name = "Copy JS Invite",Callback = function()
                setclipboard("Roblox.GameLauncher.joinGameInstance(" .. game.PlaceId .. ", \"" .. game.JobId .. "\");")
            end})
        end

        OptionsTab:AddConfigSection("Parvus","Left")

        local DiscordSection = OptionsTab:Section({Name = "Discord",Side = "Left"}) do
            DiscordSection:Label({Text = "Invite Code: sYqDpbPYb7"})
            DiscordSection:Button({Name = "Copy Invite Link",Callback = function() setclipboard("https://discord.gg/sYqDpbPYb7") end})
            DiscordSection:Button({Name = "Join Through Discord App",Callback = Self.JoinDiscord})
        end

        local BackgroundSection = OptionsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Colorpicker({Name = "Color",Flag = "Background/Color",Value = {1,1,0,0,false},
            Callback = function(HSVAR,Color) Window.Background.ImageColor3 = Color Window.Background.ImageTransparency = HSVAR[4] end})
            BackgroundSection:Textbox({HideName = true,Flag = "Background/CustomImage",Placeholder = "rbxassetid://ImageId",
            Callback = function(String,EnterPressed) if EnterPressed then Window.Background.Image = String end end})
            BackgroundSection:Dropdown({HideName = true,Flag = "Background/Image",List = {
                {Name = "Legacy",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://2151741365"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Hearts",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073763717"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Abstract",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073743871"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Hexagon",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073628839"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Circles",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071579801"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Lace With Flowers",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071575925"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Floral",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://5553946656"
                    Window.Flags["Background/CustomImage"] = ""
                end,Value = true},
                {Name = "Halloween",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://11113209821"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Christmas",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://11711560928"
                    Window.Flags["Background/CustomImage"] = ""
                end}
            }})
            local TileOffset = BackgroundSection:Slider({Name = "Tile Offset",Flag = "Background/Offset",Min = 74,Max = 296,Value = 74,Wide = true,
            Callback = function(Number) Window.Background.TileSize = UDim2.fromOffset(Number,Number) end})
            Window.Background.TileSize = UDim2.fromOffset(TileOffset.Value,TileOffset.Value)
        end
        local CrosshairSection = OptionsTab:Section({Name = "Custom Crosshair",Side = "Right"}) do
            CrosshairSection:Toggle({Name = "Enabled",Flag = "Crosshair/Enabled",Value = false})
            :Colorpicker({Flag = "Crosshair/Color",Value = {1,1,1,0,false}})
            CrosshairSection:Slider({Name = "Size",Flag = "Crosshair/Size",Min = 0,Max = 20,Value = 4,Unit = "px",Wide = true})
            CrosshairSection:Slider({Name = "Gap",Flag = "Crosshair/Gap",Min = 0,Max = 10,Value = 2,Unit = "px",Wide = true})
        end
        local CreditsSection = OptionsTab:Section({Name = "Credits",Side = "Right"}) do
            CreditsSection:Label({Text = "Made by AlexR32#0157"})
            CreditsSection:Label({Text = "(I dont take friend requests,\nfind me on my server)"})
            CreditsSection:Divider({Text = "Special thanks to"})
            CreditsSection:Label({Text = "Jan for awesome Background Patterns"})
            CreditsSection:Label({Text = "Infinite Yield Team for Server Hop and Rejoin"})
            CreditsSection:Label({Text = "Blissful for Offscreen Arrows"})
            CreditsSection:Label({Text = "coasts for Universal ESP"})
            CreditsSection:Label({Text = "mickeyrbx for CalculateBox"})
            CreditsSection:Label({Text = "Kiriot22 for Anti plugin crash"})
            CreditsSection:Label({Text = "el3tric for Bracket V2"})
            CreditsSection:Label({Text = "and much more people\nbehind this project"})
            CreditsSection:Label({Text = "❤️ ❤️ ❤️ ❤️"})
        end
    end
end
function MainModule.LightingSection(Self,Tab,Side)
    local LightingSection = Tab:Section({Name = "Lighting",Side = Side}) do
        LightingSection:Toggle({Name = "Enabled",Flag = "Lighting/Enabled",Value = false,
        Callback = function(Bool) if Bool then return end
            for Property,Value in pairs(Self.DefaultLighting) do
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
function MainModule.SetupWatermark(Self,Window)
    local GetFPS = Self:SetupFPS()
    RunService.Heartbeat:Connect(function()
        if Window.Watermark.Enabled then
            Window.Watermark.Title = string.format(
                "Parvus Hub    %s    %i FPS    %i MS",
                os.date("%X"),GetFPS(),math.round(Ping:GetValue())
            )
        end
    end)
end
function MainModule.InitAutoLoad(Window)
    Window:AutoLoadConfig("Parvus")
    Window:SetValue("UI/Enabled",
    Window.Flags["UI/OOL"])
end

function MainModule.SetupLighting(Self,Flags)
    Self.DefaultLighting = {
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
        if Property == "TimeOfDay" then return end local Value = nil
        if not pcall(function() Value = Lighting[Property] end) then return end
        local CustomValue,FormatedValue = Flags["Lighting/" .. Property],Value
        local DefaultValue = Self.DefaultLighting[Property]

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
            Self.DefaultLighting[Property] = Value
        end
    end)
    RunService.Heartbeat:Connect(function()
        if Flags["Lighting/Enabled"] then
            for Property in pairs(Self.DefaultLighting) do
                local CustomValue = Flags["Lighting/" .. Property]
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

return MainModule
