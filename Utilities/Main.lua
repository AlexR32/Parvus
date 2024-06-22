local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
--local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
--local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local Utility = { DefaultLighting = {} }

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Request = request or (http and http.request)
local SetIdentity = setthreadidentity

do -- Thanks to Kiriot22
    local OldPluginManager, Message = nil, nil

    task.spawn(function()
        SetIdentity(2)
        local Success, Error = pcall(getrenv().PluginManager)
        Message = Error
    end)

    OldPluginManager = hookfunction(getrenv().PluginManager, function()
        return error(Message)
    end)
end

repeat task.wait() until Stats.Network:FindFirstChild("ServerStatsItem")
local Ping = Stats.Network.ServerStatsItem["Data Ping"]

repeat task.wait() until Workspace:FindFirstChildOfClass("Terrain")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local XZVector, YVector = Vector3.new(1, 0, 1), Vector3.new(0, 1, 0)
local Movement = { Forward = 0, Backward = 0, Right = 0, Left = 0, Up = 0, Down = 0 }
local function GetFlatVector(CF) return CF.LookVector * XZVector, CF.RightVector * XZVector end
local function GetUnit(Vector) if Vector.Magnitude == 0 then return Vector end return Vector.Unit end

local function MovementBind(ActionName, InputState)
    Movement[ActionName] = InputState == Enum.UserInputState.Begin and 1 or 0
    return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("Forward", MovementBind, false, Enum.KeyCode.W)
ContextActionService:BindAction("Backward", MovementBind, false, Enum.KeyCode.S)
ContextActionService:BindAction("Left", MovementBind, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", MovementBind, false, Enum.KeyCode.D)
ContextActionService:BindAction("Up", MovementBind, false, Enum.KeyCode.Space)
ContextActionService:BindAction("Down", MovementBind, false, Enum.KeyCode.LeftShift)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

--[[function Utility.HideObject(Object)
    Object.Parent = gethui()
end]]

function Utility.SetupFPS()
    local StartTime, TimeTable, LastTime = os.clock(), {}, nil

    return function()
        LastTime = os.clock()

        for Index = #TimeTable, 1, -1 do
            TimeTable[Index + 1] = TimeTable[Index] >= LastTime - 1 and TimeTable[Index] or nil
        end

        TimeTable[1] = LastTime
        return os.clock() - StartTime >= 1 and #TimeTable or #TimeTable / (os.clock() - StartTime)
    end
end
function Utility.MovementToDirection()
    local LookVector, RightVector = GetFlatVector(Camera.CFrame)
    local ZMovement = LookVector * (Movement.Forward - Movement.Backward)
    local XMovement = RightVector * (Movement.Right - Movement.Left)
    local YMovement = YVector * (Movement.Up - Movement.Down)

    return GetUnit(ZMovement + XMovement + YMovement)
end
function Utility.MakeBeam(Origin, Position, Color)
    --local BeamFolder = Instance.new("Folder")

    local OriginAttachment = Instance.new("Attachment")
    OriginAttachment.CFrame = CFrame.new(Origin)
    OriginAttachment.Name = "OriginAttachment"
    OriginAttachment.Parent = Terrain

    local PositionAttachment = Instance.new("Attachment")
    PositionAttachment.CFrame = CFrame.new(Position)
    PositionAttachment.Name = "PositionAttachment"
    PositionAttachment.Parent = Terrain

    local Beam = Instance.new("Beam")

    Beam.Name = "Beam"
    Beam.Color = ColorSequence.new(Color[6])
    Beam.LightEmission = 1
    Beam.LightInfluence = 1
    Beam.TextureMode = Enum.TextureMode.Static
    Beam.TextureSpeed = 0
    Beam.Transparency = NumberSequence.new(0)

    Beam.Attachment0 = OriginAttachment
    Beam.Attachment1 = PositionAttachment
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = 0.1
    Beam.Width1 = 0.1

    Beam.Parent = Terrain

    --BeamFolder = Terrain

    task.spawn(function()
        local Time = 1 * 60

        for Index = 1, Time do
            RunService.Heartbeat:Wait()
            Beam.Transparency = NumberSequence.new(Index / Time)
            Beam.Color = ColorSequence.new(Color[6])
        end

        OriginAttachment:Destroy()
        PositionAttachment:Destroy()
        Beam:Destroy()
    end)

    return Beam
end
function Utility.NewThreadLoop(Wait, Function)
    task.spawn(function()
        while true do
            local Delta = task.wait(Wait)
            local Success, Error = pcall(Function, Delta)
            if not Success then
                warn("thread error " .. Error)
            elseif Error == "break" then
                --print("thread stopped")
                break
            end
        end
    end)
end
function Utility.FixUpValue(fn, hook, gvar)
    if gvar then
        old = hookfunction(fn, function(...)
            return hook(old, ...)
        end)
    else
        local old = nil
        old = hookfunction(fn, function(...)
            return hook(old, ...)
        end)
    end
end

function Utility.ReJoin()
    if #PlayerService:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nParvus Hub\nRejoining...")
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
end
function Utility.ServerHop()
    local DataDecoded, Servers = HttpService:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?sortOrder=2&excludeFullGames=true&limit=100"
    )).data, {}

    for Index, ServerData in ipairs(DataDecoded) do
        if type(ServerData) == "table" and ServerData.id ~= game.JobId then
            table.insert(Servers, ServerData.id)
        end
    end

    if #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId, Servers[math.random(#Servers)]
        )
    else
        Parvus.Utilities.UI:Push({
            Title = "Parvus Hub",
            Description = "Couldn't find a server",
            Duration = 5
        })
    end
end
function Utility.JoinDiscord()
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

function Utility.InitAutoLoad(Window)
    Window:AutoLoadConfig("Parvus")
    Window:SetValue("UI/Enabled", Window.Flags["UI/OOL"])
end
function Utility.SetupWatermark(Self, Window)
    local GetFPS = Self:SetupFPS()

    RunService.Heartbeat:Connect(function()
        if Window.Watermark.Enabled then
            Window.Watermark.Title = string.format(
                "Parvus Hub    %s    %i FPS    %i MS",
                os.date("%X"), GetFPS(), math.round(Ping:GetValue())
            )
        end
    end)
end

--[[
# UI Color
  - Default   = 1, 0.25, 1, 0, true
  - Christmas = 0.4541666507720947, 0.20942406356334686, 0.7490196228027344, 0, false
  - Halloween = 0.0836667, 1, 1, 0, false
# Background Color
  - Default   = 1, 1, 0, 0, false
  - Christmas = 0.12000000476837158, 0.10204081237316132, 0.9607843160629272, 0.5, false
  - Halloween = 0.0836667, 1, 1, 0, false
]]

function Utility.SettingsSection(Self, Window, UIKeybind, CustomMouse)
    local Backgrounds = {
        {"None", "", false},
        {"Legacy", "rbxassetid://2151741365", false},
        {"Hearts", "rbxassetid://6073763717", false},
        {"Abstract", "rbxassetid://6073743871", false},
        {"Hexagon", "rbxassetid://6073628839", false},
        {"Geometric", "rbxassetid://2062021684", false},
        {"Circles", "rbxassetid://6071579801", false},
        {"Checkered", "rbxassetid://4806196507", false},
        {"Lace With Flowers", "rbxassetid://6071575925", false},
        {"Flowers & Leafs", "rbxassetid://10921866694", false},
        {"Floral", "rbxassetid://5553946656", true},
        {"Leafs", "rbxassetid://10921868665", false},
        {"Mountains", "rbxassetid://10921801398", false},
        {"Halloween", "rbxassetid://11113209821", false},
        {"Christmas", "rbxassetid://11711560928", false},
        --{"A", "rbxassetid://5843010904", false},
        {"Polka dots", "rbxassetid://6214418014", false},
        {"Mountains", "rbxassetid://6214412460", false},
        {"Zigzag", "rbxassetid://6214416834", false},
        {"Zigzag 2", "rbxassetid://6214375242", false},
        {"Tartan", "rbxassetid://6214404863", false},
        {"Roses", "rbxassetid://6214374619", false},
        {"Hexagons", "rbxassetid://6214320051", false},
        {"Leopard print", "rbxassetid://6214318622", false},
        {"Blue Cubes", "rbxassetid://7188838187", false},
        {"Blue Waves", "rbxassetid://10952910471", false},
        {"White Circles", "rbxassetid://5168924660", false},
        {"Animal Print", "rbxassetid://6299360527", false},
        {"Fur", "rbxassetid://990886896", false},
        {"Marble", "rbxassetid://8904067198", false},
        {"Touhou", "rbxassetid://646426813", false},
        --{"Anime", "rbxassetid://9730243545", false},
        --{"Anime2", "rbxassetid://12756726256", false},
        --{"Anime3", "rbxassetid://7027352997", false},
        --{"Anime4", "rbxassetid://5931352430", false},
        --{"Hu Tao Edit", "rbxassetid://11424961420", false},
        --{"Waves", "rbxassetid://5351821237", false},
        --{"Nebula", "rbxassetid://159454288", false},
        --{"VaporWave", "rbxassetid://1417494643", false},
        --{"Clouds", "rbxassetid://570557727", false},
        --{"Twilight", "rbxassetid://264907379", false},
        --{"ZXC Cat", "rbxassetid://10300256322", false},
        --{"Pavuk Redan", "rbxassetid://12652997937", false},
        --{"Pink Anime Girl", "rbxassetid://11696859404", false},
        --{"Dark Anime Girl", "rbxassetid://10341849875", false},
        --{"TokyoGhoul", "rbxassetid://14007782187", false}
    }

    local BackgroundsList = {}
    for Index, Data in pairs(Backgrounds) do
        BackgroundsList[#BackgroundsList + 1] = {
            Name = Data[1], Mode = "Button", Value = Data[3], Callback = function()
            Window.Flags["Background/CustomImage"] = ""
            Window.Background.Image = Data[2]
        end}
    end

    local OptionsTab = Window:Tab({Name = "Options"}) do
        local MenuSection = OptionsTab:Section({Name = "Menu", Side = "Left"}) do
            local UIToggle = MenuSection:Toggle({Name = "UI Enabled", Flag = "UI/Enabled", IgnoreFlag = true,
            Value = Window.Enabled, Callback = function(Bool) Window.Enabled = Bool end})
            UIToggle:Keybind({Value = UIKeybind, Flag = "UI/Keybind", IgnoreList = true, DoNotClear = true})
            UIToggle:Colorpicker({Flag = "UI/Color", Value = {1, 0.25, 1, 0, true},
            Callback = function(HSVAR, Color) Window.Color = Color end})

            MenuSection:Toggle({Name = "Keybinds", IgnoreFlag = true, Flag = "UI/KeybindList",
            Value = false, Callback = function(Bool) Window.KeybindList.Enabled = Bool end})

            MenuSection:Toggle({Name = "Open On Load", Flag = "UI/OOL", Value = true})
            MenuSection:Toggle({Name = "Blur Gameplay", Flag = "UI/Blur", Value = false,
            Callback = function(Bool) Window.Blur = Bool end})

            MenuSection:Toggle({Name = "Custom Mouse", Flag = "Mouse/Enabled", Value = CustomMouse})

            MenuSection:Toggle({Name = "Watermark", Flag = "UI/Watermark/Enabled", Value = true,
            Callback = function(Bool) Window.Watermark.Enabled = Bool end}):Keybind({Flag = "UI/Watermark/Keybind"})

            MenuSection:Button({Name = "Rejoin", Callback = Self.ReJoin})
            MenuSection:Button({Name = "Server Hop", Callback = Self.ServerHop})
            MenuSection:Button({Name = "Copy Lua Invite", Callback = function()
                setclipboard("game:GetService(\"TeleportService\"):TeleportToPlaceInstance(" .. game.PlaceId .. ", \"" .. game.JobId .. "\")")
            end})
            MenuSection:Button({Name = "Copy JS Invite", Callback = function()
                setclipboard("Roblox.GameLauncher.joinGameInstance(" .. game.PlaceId .. ", \"" .. game.JobId .. "\");")
            end})
        end
        OptionsTab:AddConfigSection("Parvus", "Left")
        local BackgroundSection = OptionsTab:Section({Name = "Background", Side = "Right"}) do
            BackgroundSection:Colorpicker({Name = "Color", Flag = "Background/Color", Value = {1, 1, 0, 0, false},
            Callback = function(HSVAR, Color) Window.Background.ImageColor3 = Color Window.Background.ImageTransparency = HSVAR[4] end})
            BackgroundSection:Textbox({HideName = true, Flag = "Background/CustomImage", Placeholder = "rbxassetid://ImageId",
            Callback = function(String, EnterPressed) if EnterPressed then Window.Background.Image = String end end})
            BackgroundSection:Dropdown({HideName = true, Flag = "Background/Image", List = BackgroundsList})

            local TileSize = nil
            BackgroundSection:Divider({Text = "Background Tile"})
            BackgroundSection:Dropdown({HideName = true, Flag = "Background/TileMode", List = {
                {Name = "Tile Offset", Mode = "Button", Value = true, Callback = function()
                    if not TileSize then return end
                    TileSize.Name = "Offset"
                    TileSize.Min = 74
                    TileSize.Max = 296
                    TileSize.Unit = ""

                    TileSize.Value = TileSize.Value
                end},
                {Name = "Tile Scale", Mode = "Button", Callback = function()
                    if not TileSize then return end
                    TileSize.Name = "Scale"
                    TileSize.Min = 25
                    TileSize.Max = 100
                    TileSize.Unit = "%"

                    TileSize.Value = TileSize.Value
                end}
            }})

            TileSize = BackgroundSection:Slider({Name = "Offset", Flag = "Background/TileSize", Min = 74, Max = 296, Value = 74,
            Callback = function(Number)
                if TileSize.Name == "Offset" then
                    Window.Background.TileSize = UDim2.fromOffset(Number, Number)
                elseif TileSize.Name == "Scale" then
                    Window.Background.TileSize = UDim2.fromScale(Number / 100, Number / 100)
                end
            end})

            TileSize.Value = TileSize.Value
        end
        local CrosshairSection = OptionsTab:Section({Name = "Custom Crosshair", Side = "Right"}) do
            CrosshairSection:Toggle({Name = "Enabled", Flag = "Crosshair/Enabled", Value = false})
            :Colorpicker({Flag = "Crosshair/Color", Value = {1, 1, 1, 0, false}})
            CrosshairSection:Slider({Name = "Size", Flag = "Crosshair/Size", Min = 0, Max = 20, Value = 4, Unit = "px"})
            CrosshairSection:Slider({Name = "Gap", Flag = "Crosshair/Gap", Min = 0, Max = 10, Value = 2, Unit = "px"})
        end
        local DiscordSection = OptionsTab:Section({Name = "Discord", Side = "Right"}) do
            DiscordSection:Label({Text = "Invite Code: sYqDpbPYb7"})
            DiscordSection:Button({Name = "Copy Invite Link", Callback = function() setclipboard("https://discord.gg/sYqDpbPYb7") end})
            DiscordSection:Button({Name = "Join Through Discord App", Callback = Self.JoinDiscord})
        end
        local CreditsSection = OptionsTab:Section({Name = "Credits", Side = "Right"}) do
            CreditsSection:Label({Text = "Made by AlexR32 @ discord.com"})
            CreditsSection:Label({Text = "I dont take friend requests\nfind me on my server: sYqDpbPYb7"})
            CreditsSection:Divider({Text = "Special thanks to"})
            CreditsSection:Label({Text = "Jan @ v3rmillion.net\nBackground patterns"})
            --CreditsSection:Label({Text = "Infinite Yield Team\nServer Hop and Rejoin"})
            CreditsSection:Label({Text = "CornCatCornDog @ v3rmillion.net\nOffscreen Arrows"})
            --CreditsSection:Label({Text = "coasts @ v3rmillion.net\nUniversal ESP"})
            CreditsSection:Label({Text = "mickeyrbx @ v3rmillion.net\nCalculateBox"})
            CreditsSection:Label({Text = "Kiriot22 @ v3rmillion.net\nAnti plugin crash"})
            CreditsSection:Label({Text = "el3tric @ v3rmillion.net\nBracket V2"})
            CreditsSection:Label({Text = "and much more people\nbehind this project"})
            CreditsSection:Label({Text = "❤️ ❤️ ❤️ ❤️"})
        end
    end

    Window:KeybindList({Enabled = false})
    Window:Watermark({Enabled = true})
end

function Utility.ESPSection(Self, Window, Name, Flag, BoxEnabled, ChamEnabled, HeadEnabled, TracerEnabled, OoVEnabled, LightingEnabled)
    local VisualsTab = Window:Tab({Name = Name}) do
        local GlobalSection = VisualsTab:Section({Name = "Global", Side = "Left"})
        if BoxEnabled then
            local BoxSection = VisualsTab:Section({Name = "Boxes", Side = "Left"}) do
                BoxSection:Toggle({Name = "Box Enabled", Flag = Flag .. "/Box/Enabled", Value = false})
                BoxSection:Toggle({Name = "Healthbar", Flag = Flag .. "/Box/HealthBar", Value = false})

                BoxSection:Toggle({Name = "Filled", Flag = Flag .. "/Box/Filled", Value = false})
                BoxSection:Toggle({Name = "Outline", Flag = Flag .. "/Box/Outline", Value = true})
                BoxSection:Slider({Name = "Thickness", Flag = Flag .. "/Box/Thickness", Min = 1, Max = 19, Value = 1, OnlyOdd = true})
                BoxSection:Slider({Name = "Transparency", Flag = Flag .. "/Box/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
                BoxSection:Slider({Name = "Corner Size", Flag = Flag .. "/Box/CornerSize", Min = 10, Max = 100, Value = 50, Unit = "%"})
                BoxSection:Divider()
                BoxSection:Toggle({Name = "Name Enabled", Flag = Flag .. "/Name/Enabled", Value = false})
                BoxSection:Toggle({Name = "Health Enabled", Flag = Flag .. "/Health/Enabled", Value = false})
                BoxSection:Toggle({Name = "Distance Enabled", Flag = Flag .. "/Distance/Enabled", Value = false})
                BoxSection:Toggle({Name = "Weapon Enabled", Flag = Flag .. "/Weapon/Enabled", Value = false})
                BoxSection:Toggle({Name = "Outline", Flag = Flag .. "/Name/Outline", Value = true})
                BoxSection:Toggle({Name = "Autoscale", Flag = Flag .. "/Name/Autoscale", Value = true})
                BoxSection:Slider({Name = "Size", Flag = Flag .. "/Name/Size", Min = 1, Max = 100, Value = 8})
                BoxSection:Slider({Name = "Transparency", Flag = Flag .. "/Name/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0.25})
                --BoxSection:Slider({Name = "Test", Flag = Flag .. "/Test", Min = 0, Max = 100, Value = 0})
            end
        end
        --[[if ChamEnabled then
            local ChamSection = VisualsTab:Section({Name = "Chams", Side = "Left"}) do
                ChamSection:Toggle({Name = "Enabled", Flag = Flag .. "/Highlight/Enabled", Value = false})
                ChamSection:Toggle({Name = "Occluded", Flag = Flag .. "/Highlight/Occluded", Value = false})
                ChamSection:Slider({Name = "Transparency", Flag = Flag .. "/Highlight/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
                ChamSection:Colorpicker({Name = "Outline Color", Flag = Flag .. "/Highlight/OutlineColor", Value = {1, 1, 0, 0.5, false}})
            end
        end]]
        if HeadEnabled then
            local HeadSection = VisualsTab:Section({Name = "Head Dots", Side = "Right"}) do
                HeadSection:Toggle({Name = "Enabled", Flag = Flag .. "/HeadDot/Enabled", Value = false})
                HeadSection:Toggle({Name = "Filled", Flag = Flag .. "/HeadDot/Filled", Value = true})
                HeadSection:Toggle({Name = "Outline", Flag = Flag .. "/HeadDot/Outline", Value = true})
                HeadSection:Toggle({Name = "Autoscale", Flag = Flag .. "/HeadDot/Autoscale", Value = true})
                HeadSection:Slider({Name = "Size", Flag = Flag .. "/HeadDot/Radius", Min = 1, Max = 100, Value = 4})
                --HeadSection:Slider({Name = "Smoothness", Flag = Flag .. "/HeadDot/Smoothness", Min = 0, Max = 100, Value = 10, Unit = "%"})
                HeadSection:Slider({Name = "NumSides", Flag = Flag .. "/HeadDot/NumSides", Min = 3, Max = 100, Value = 4})
                HeadSection:Slider({Name = "Thickness", Flag = Flag .. "/HeadDot/Thickness", Min = 1, Max = 10, Value = 1})
                HeadSection:Slider({Name = "Transparency", Flag = Flag .. "/HeadDot/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
            end
        end
        if TracerEnabled then
            local TracerSection = VisualsTab:Section({Name = "Tracers", Side = "Right"}) do
                TracerSection:Toggle({Name = "Enabled", Flag = Flag .. "/Tracer/Enabled", Value = false})
                TracerSection:Toggle({Name = "Outline", Flag = Flag .. "/Tracer/Outline", Value = true})
                TracerSection:Dropdown({Name = "Mode", Flag = Flag .. "/Tracer/Mode", List = {
                    {Name = "From Bottom", Mode = "Button", Value = true},
                    {Name = "From Mouse", Mode = "Button"}
                }})
                TracerSection:Slider({Name = "Thickness", Flag = Flag .. "/Tracer/Thickness", Min = 1, Max = 10, Value = 1})
                TracerSection:Slider({Name = "Transparency", Flag = Flag .. "/Tracer/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
            end
        end
        if OoVEnabled then
            local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows", Side = "Right"}) do
                OoVSection:Toggle({Name = "Enabled", Flag = Flag .. "/Arrow/Enabled", Value = false})
                OoVSection:Toggle({Name = "Filled", Flag = Flag .. "/Arrow/Filled", Value = true})
                OoVSection:Toggle({Name = "Outline", Flag = Flag .. "/Arrow/Outline", Value = true})
                OoVSection:Slider({Name = "Width", Flag = Flag .. "/Arrow/Width", Min = 14, Max = 28, Value = 14})
                OoVSection:Slider({Name = "Height", Flag = Flag .. "/Arrow/Height", Min = 14, Max = 28, Value = 28})
                OoVSection:Slider({Name = "Distance From Center", Flag = Flag .. "/Arrow/Radius", Min = 80, Max = 200, Value = 150})
                OoVSection:Slider({Name = "Thickness", Flag = Flag .. "/Arrow/Thickness", Min = 1, Max = 10, Value = 1})
                OoVSection:Slider({Name = "Transparency", Flag = Flag .. "/Arrow/Transparency", Min = 0, Max = 1, Precise = 2, Value = 0})
            end
        end
        if LightingEnabled then
            Self:LightingSection(VisualsTab)
        end

        return GlobalSection
    end
end

function Utility.LightingSection(Self, Tab, Side)
    local LightingSection = Tab:Section({Name = "Lighting", Side = Side}) do
        LightingSection:Toggle({Name = "Enabled", Flag = "Lighting/Enabled", Value = false,
        Callback = function(Bool) if Bool then return end
            for Property, Value in pairs(Self.DefaultLighting) do
                Lighting[Property] = Value
            end
        end})

        LightingSection:Colorpicker({Name = "Ambient", Flag = "Lighting/Ambient", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "Brightness", Flag = "Lighting/Brightness", Min = 0, Max = 10, Precise = 2, Value = 3})
        LightingSection:Slider({Name = "ClockTime", Flag = "Lighting/ClockTime", Min = 0, Max = 24, Precise = 2, Value = 12})
        LightingSection:Colorpicker({Name = "ColorShift_Bottom", Flag = "Lighting/ColorShift_Bottom", Value = {1, 0, 1, 0, false}})
        LightingSection:Colorpicker({Name = "ColorShift_Top", Flag = "Lighting/ColorShift_Top", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "EnvironmentDiffuseScale", Flag = "Lighting/EnvironmentDiffuseScale", Min = 0, Max = 1, Precise = 3, Value = 0})
        LightingSection:Slider({Name = "EnvironmentSpecularScale", Flag = "Lighting/EnvironmentSpecularScale", Min = 0, Max = 1, Precise = 3, Value = 0})
        LightingSection:Slider({Name = "ExposureCompensation", Flag = "Lighting/ExposureCompensation", Min = -3, Max = 3, Precise = 2, Value = 0})
        LightingSection:Colorpicker({Name = "FogColor", Flag = "Lighting/FogColor", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "FogEnd", Flag = "Lighting/FogEnd", Min = 0, Max = 100000, Value = 100000})
        LightingSection:Slider({Name = "FogStart", Flag = "Lighting/FogStart", Min = 0, Max = 100000, Value = 0})
        LightingSection:Slider({Name = "GeographicLatitude", Flag = "Lighting/GeographicLatitude", Min = 0, Max = 360, Precise = 1, Value = 23.5})
        LightingSection:Toggle({Name = "GlobalShadows", Flag = "Lighting/GlobalShadows", Value = false})
        LightingSection:Colorpicker({Name = "OutdoorAmbient", Flag = "Lighting/OutdoorAmbient", Value = {1, 0, 1, 0, false}})
        LightingSection:Slider({Name = "ShadowSoftness", Flag = "Lighting/ShadowSoftness", Min = 0, Max = 1, Precise = 2, Value = 0})
        LightingSection:Toggle({Name = "Terrain Decoration", Flag = "Terrain/Decoration", Value = gethiddenproperty(Terrain, "Decoration"),
        Callback = function(Value) sethiddenproperty(Terrain, "Decoration", Value) end})
    end
end
function Utility.SetupLighting(Self, Flags)
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
        local CustomValue, FormatedValue = Flags["Lighting/" .. Property], Value
        local DefaultValue = Self.DefaultLighting[Property]

        if type(CustomValue) == "table" then
            CustomValue = CustomValue[6]
        end

        if type(FormatedValue) == "number" then
            if Property == "EnvironmentSpecularScale" or Property == "EnvironmentDiffuseScale" then
                FormatedValue = tonumber(string.format("%.3f", FormatedValue))
            else
                FormatedValue = tonumber(string.format("%.2f", FormatedValue))
            end --print("format current", Property, FormatedValue)
        end

        if CustomValue ~= FormatedValue and Value ~= DefaultValue then
            --print("default prop", Property, Value)
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

return Utility
