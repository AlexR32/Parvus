local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeamService = game:GetService("Teams")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
repeat task.wait(1) until not LocalPlayer.PlayerGui:FindFirstChild("LoadingGui").Enabled

local Loaded1,Loaded2,PromptLib = false,false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
if identifyexecutor() ~= "Synapse X" then
    PromptLib("Unsupported executor","Synapse X only for safety measures\nIf you still want to use the script, click \"Ok\"",{
        {Text = "Ok",LayoutOrder = 0,Primary = false,Callback = function() Loaded1 = true end},
    }) repeat task.wait(1) until Loaded1
end

if game.PlaceVersion > 1333 then
    PromptLib("Unsupported game version","You are at risk of getting autoban\nAre you sure you want to load Parvus?",{
        {Text = "Yes",LayoutOrder = 0,Primary = false,Callback = function() Loaded2 = true end},
        {Text = "No",LayoutOrder = 0,Primary = true,Callback = function() end}
    }) repeat task.wait(1) until Loaded2
end

--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Tortoiseshell = require(ReplicatedStorage.TS)

local SilentAim,Aimbot,Trigger = nil,false,false
local Tortoiseshell,WeaponModel,NewRandom = require(ReplicatedStorage.TS),nil,Random.new()
local ProjectileSpeed,ProjectileGravity,GravityCorrection = 1600,Vector3.new(0,150,0),2
local BanCommands = {"GetUpdate","SetUpdate","Invoke","GetSetting","FireProjectile"}

local Events = getupvalue(Tortoiseshell.Network.BindEvent,1)
local WeaponConfigs = getupvalue(Tortoiseshell.Items.GetConfig,3)
local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter,1)
--local ControllersFolder = getupvalue(Tortoiseshell.Items.GetController,2)
local Projectiles = getupvalue(Tortoiseshell.Projectiles.InitProjectile,1)

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.MaxForce = Vector3.one * math.huge
BodyVelocity.Velocity = Vector3.zero

local Notify = Instance.new("BindableEvent")
Notify.Event:Connect(function(Text)
    Parvus.Utilities.UI:Notification2(Text)
end)

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = false})
            AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/WallCheck",Value = false})
            AimbotSection:Toggle({Name = "Distance Check",Flag = "Aimbot/DistanceCheck",Value = false})
            AimbotSection:Toggle({Name = "Dynamic FOV",Flag = "Aimbot/DynamicFOV",Value = false})
            AimbotSection:Keybind({Name = "Keybind",Flag = "Aimbot/Keybind",Value = "MouseButton2",
            Mouse = true,Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})
            AimbotSection:Slider({Name = "Smoothness",Flag = "Aimbot/Smoothness",Min = 0,Max = 100,Value = 25,Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View",Flag = "Aimbot/FieldOfView",Min = 0,Max = 500,Value = 100})
            AimbotSection:Slider({Name = "Distance",Flag = "Aimbot/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            AimbotSection:Dropdown({Name = "Body Parts",Flag = "Aimbot/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle"},
                {Name = "Chest",Mode = "Toggle"},
                {Name = "Abdomen",Mode = "Toggle"},
                {Name = "Hips",Mode = "Toggle"}
            }})
        end
        local AFOVSection = AimAssistTab:Section({Name = "Aimbot FOV Circle",Side = "Left"}) do
            AFOVSection:Toggle({Name = "Enabled",Flag = "Aimbot/Circle/Enabled",Value = true})
            AFOVSection:Toggle({Name = "Filled",Flag = "Aimbot/Circle/Filled",Value = false})
            AFOVSection:Colorpicker({Name = "Color",Flag = "Aimbot/Circle/Color",Value = {1,0.66666662693024,1,0.25,false}})
            AFOVSection:Slider({Name = "NumSides",Flag = "Aimbot/Circle/NumSides",Min = 3,Max = 100,Value = 14})
            AFOVSection:Slider({Name = "Thickness",Flag = "Aimbot/Circle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local TFOVSection = AimAssistTab:Section({Name = "Trigger FOV Circle",Side = "Left"}) do
            TFOVSection:Toggle({Name = "Enabled",Flag = "Trigger/Circle/Enabled",Value = true})
            TFOVSection:Toggle({Name = "Filled",Flag = "Trigger/Circle/Filled",Value = false})
            TFOVSection:Colorpicker({Name = "Color",Flag = "Trigger/Circle/Color",
            Value = {0.0833333358168602,0.6666666269302368,1,0.25,false}})
            TFOVSection:Slider({Name = "NumSides",Flag = "Trigger/Circle/NumSides",Min = 3,Max = 100,Value = 14})
            TFOVSection:Slider({Name = "Thickness",Flag = "Trigger/Circle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local SilentAimSection = AimAssistTab:Section({Name = "Silent Aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false})
            :Keybind({Mouse = true,Flag = "SilentAim/Keybind"})
            SilentAimSection:Toggle({Name = "AutoShoot",Flag = "BB/AutoShoot/Enabled",Value = false})
            SilentAimSection:Toggle({Name = "AutoShoot 360 Mode",Flag = "BB/AutoShoot/AllFOV",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FOV",Flag = "SilentAim/DynamicFOV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100})
            SilentAimSection:Slider({Name = "Distance",Flag = "SilentAim/Distance",Min = 25,Max = 1000,Value = 1000,Unit = "studs"})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle"},
                {Name = "Chest",Mode = "Toggle"},
                {Name = "Abdomen",Mode = "Toggle"},
                {Name = "Hips",Mode = "Toggle"}
            }})
        end
        local SAFOVSection = AimAssistTab:Section({Name = "Silent Aim FOV Circle",Side = "Right"}) do
            SAFOVSection:Toggle({Name = "Enabled",Flag = "SilentAim/Circle/Enabled",Value = true})
            SAFOVSection:Toggle({Name = "Filled",Flag = "SilentAim/Circle/Filled",Value = false})
            SAFOVSection:Colorpicker({Name = "Color",Flag = "SilentAim/Circle/Color",
            Value = {0.6666666865348816,0.6666666269302368,1,0.25,false}})
            SAFOVSection:Slider({Name = "NumSides",Flag = "SilentAim/Circle/NumSides",Min = 3,Max = 100,Value = 14})
            SAFOVSection:Slider({Name = "Thickness",Flag = "SilentAim/Circle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local TriggerSection = AimAssistTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Enabled",Value = false})
            TriggerSection:Toggle({Name = "Prediction",Flag = "Trigger/Prediction",Value = true})
            TriggerSection:Toggle({Name = "Visibility Check",Flag = "Trigger/WallCheck",Value = true})
            TriggerSection:Toggle({Name = "Distance Check",Flag = "Trigger/DistanceCheck",Value = false})
            TriggerSection:Toggle({Name = "Dynamic FOV",Flag = "Trigger/DynamicFOV",Value = false})
            TriggerSection:Keybind({Name = "Keybind",Flag = "Trigger/Keybind",Value = "MouseButton2",
            Mouse = true,Callback = function(Key,KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})
            TriggerSection:Slider({Name = "Field Of View",Flag = "Trigger/FieldOfView",Min = 0,Max = 500,Value = 25})
            TriggerSection:Slider({Name = "Distance",Flag = "Trigger/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            TriggerSection:Slider({Name = "Delay",Flag = "Trigger/Delay",Min = 0,Max = 1,Precise = 2,Value = 0.15})
            TriggerSection:Toggle({Name = "Hold Mode",Flag = "Trigger/HoldMode",Value = false})
            TriggerSection:Dropdown({Name = "Body Parts",Flag = "Trigger/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle"},
                {Name = "Chest",Mode = "Toggle"},
                {Name = "Abdomen",Mode = "Toggle"},
                {Name = "Hips",Mode = "Toggle"}
            }})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = true})
            GlobalSection:Toggle({Name = "Use Team Color",Flag = "ESP/Player/TeamColor",Value = false})
            GlobalSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
            GlobalSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
        end
        local BoxSection = VisualsTab:Section({Name = "Boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "Box Enabled",Flag = "ESP/Player/Box/Enabled",Value = false})
            BoxSection:Toggle({Name = "Healthbar",Flag = "ESP/Player/Box/Healthbar",Value = false})
            BoxSection:Toggle({Name = "Filled",Flag = "ESP/Player/Box/Filled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/Player/Box/Outline",Value = true})
            BoxSection:Slider({Name = "Thickness",Flag = "ESP/Player/Box/Thickness",Min = 1,Max = 10,Value = 1})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Box/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            BoxSection:Divider()
            BoxSection:Toggle({Name = "Text Enabled",Flag = "ESP/Player/Text/Enabled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/Player/Text/Outline",Value = true})
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Text/Autoscale",Value = true})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/Player/Text/Font",List = {
                {Name = "UI",Mode = "Button",Value = true},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button"}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/Player/Text/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Text/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/Player/Arrow/Filled",Value = true})
            OoVSection:Toggle({Name = "Outline",Flag = "ESP/Player/Arrow/Outline",Value = true})
            OoVSection:Slider({Name = "Width",Flag = "ESP/Player/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Height",Flag = "ESP/Player/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/Player/Arrow/Distance",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/Player/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/Player/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HeadSection = VisualsTab:Section({Name = "Head Dots",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Head/Enabled",Value = false})
            HeadSection:Toggle({Name = "Filled",Flag = "ESP/Player/Head/Filled",Value = true})
            HeadSection:Toggle({Name = "Outline",Flag = "ESP/Player/Head/Outline",Value = true})
            HeadSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Head/Autoscale",Value = true})
            HeadSection:Slider({Name = "Radius",Flag = "ESP/Player/Head/Radius",Min = 1,Max = 10,Value = 8})
            HeadSection:Slider({Name = "NumSides",Flag = "ESP/Player/Head/NumSides",Min = 3,Max = 100,Value = 4})
            HeadSection:Slider({Name = "Thickness",Flag = "ESP/Player/Head/Thickness",Min = 1,Max = 10,Value = 1})
            HeadSection:Slider({Name = "Transparency",Flag = "ESP/Player/Head/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local TracerSection = VisualsTab:Section({Name = "Tracers",Side = "Right"}) do
            TracerSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Tracer/Enabled",Value = false})
            TracerSection:Dropdown({Name = "Mode",Flag = "ESP/Player/Tracer/Mode",List = {
                {Name = "From Bottom",Mode = "Button",Value = true},
                {Name = "From Mouse",Mode = "Button"}
            }})
            TracerSection:Slider({Name = "Thickness",Flag = "ESP/Player/Tracer/Thickness",Min = 1,Max = 10,Value = 1})
            TracerSection:Slider({Name = "Transparency",Flag = "ESP/Player/Tracer/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HighlightSection = VisualsTab:Section({Name = "Highlights",Side = "Right"}) do
            HighlightSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Highlight/Enabled",Value = false})
            HighlightSection:Slider({Name = "Transparency",Flag = "ESP/Player/Highlight/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            HighlightSection:Colorpicker({Name = "Outline Color",Flag = "ESP/Player/Highlight/OutlineColor",Value = {1,1,0,0.5,false}})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local WCSection = MiscTab:Section({Name = "Weapon Customization",Side = "Left"}) do
            WCSection:Toggle({Name = "Enabled",Flag = "BB/WeaponCustom/Enabled",Value = false})
            :Colorpicker({Flag = "BB/WeaponCustom/Color",Value = {1,0.75,1,0.5,true}})
            WCSection:Toggle({Name = "Hide Textures",Flag = "BB/WeaponCustom/Texture",Value = true})
            WCSection:Slider({Name = "Reflectance",Flag = "BB/WeaponCustom/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            WCSection:Dropdown({Name = "Material",Flag = "BB/WeaponCustom/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local WMSection = MiscTab:Section({Name = "Weapon Modification",Side = "Left"}) do
            WMSection:Toggle({Name = "Enabled",Flag = "BB/WeaponMod/Enabled",Value = false})
            WMSection:Slider({Name = "Weapon Shake",Flag = "BB/WeaponMod/WeaponScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Camera Shake",Flag = "BB/WeaponMod/CameraScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Recoil Scale",Flag = "BB/WeaponMod/RecoilScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Bullet Drop",Flag = "BB/WeaponMod/BulletDrop",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Label({Text = "Respawn to make it work"})
        end
        local ACSection = MiscTab:Section({Name = "Arms Customization",Side = "Right"}) do
            ACSection:Toggle({Name = "Enabled",Flag = "BB/ArmsCustom/Enabled",Value = false})
            :Colorpicker({Flag = "BB/ArmsCustom/Color",Value = {1,0,1,1,false}})
            ACSection:Toggle({Name = "Hide Textures",Flag = "BB/ArmsCustom/Texture",Value = true})
            ACSection:Slider({Name = "Reflectance",Flag = "BB/ArmsCustom/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            ACSection:Dropdown({Name = "Material",Flag = "BB/ArmsCustom/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local CharSection = MiscTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "Fly",Flag = "BB/Fly/Enabled",Value = false,Callback = function(Bool)
                if Bool and Characters[LocalPlayer] then BodyVelocity.Parent = Characters[LocalPlayer].PrimaryPart
                else BodyVelocity.Parent = nil end
            end}):Keybind({Flag = "BB/Fly/Keybind"})
            CharSection:Slider({Name = "Fly Speed",Flag = "BB/Fly/Speed",Min = 10,Max = 100,Value = 100})
            CharSection:Toggle({Name = "NoClip",Flag = "BB/NoClip",Value = false,Callback = function(Bool)
                if Characters[LocalPlayer] then Characters[LocalPlayer].PrimaryPart.CanCollide = not Bool end
            end})
        end
        local AASection = MiscTab:Section({Name = "Anti-Aim",Side = "Right"}) do
            AASection:Toggle({Name = "Enabled",Flag = "BB/AntiAim/Enabled",Value = false})
            :Keybind({Flag = "BB/AntiAim/Keybind"})
            AASection:Slider({Name = "Pitch",Flag = "BB/AntiAim/Pitch",Min = -1.5,Max = 1.5,Precise = 2,Value = -1.5})
            AASection:Slider({Name = "Pitch Random",Flag = "BB/AntiAim/PitchRandom",Min = 0,Max = 1.5,Precise = 2,Value = 0})
            AASection:Toggle({Name = "Lean Random",Flag = "BB/AntiAim/LeanRandom",Value = true})
        end
        --[[local MiscSection = MiscTab:Section({Name = "Misc",Side = "Left"}) do
        end]]
    end Parvus.Utilities.Misc:SettingsSection(Window,"RightShift",false)
end

Window:SetValue("Background/Offset",296)
Window:LoadDefaultConfig("Parvus")
Window:SetValue("UI/Toggle",Window.Flags["UI/OOL"])

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)

do local OldNamecall,OldTaskSpawn
OldNamecall = hookmetamethod(game,"__namecall",function(Self,...)
    if checkcaller() then return OldNamecall(Self,...) end
    local Method,Args = getnamecallmethod(),{...}

    if Method == "FireServer" then
        if type(Args[1]) == "string"
        and table.find(BanCommands,Args[1]) then
            print("blocked",Args[2]) return
        end
    end

    return OldNamecall(Self,...)
end)
OldTaskSpawn = hookfunction(getrenv().task.spawn,function(...)
    if checkcaller() then return OldTaskSpawn(...) end

    local Args = {...}
    if type(Args[1]) == "function" then
        local Constants = getconstants(Args[1])
        if table.find(Constants,"wait") then
            print("blocked wtd crash")
            wait(31622400) -- 366 days
        end
    end

    return OldTaskSpawn(...)
end) end

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Whitelist
WallCheckParams.IgnoreWater = true

-- Fly Logic
local XZ,YPlus,YMinus = Vector3.new(1,0,1),Vector3.new(0,1,0),Vector3.new(0,-1,0)
local function FixUnit(Vector) if Vector.Magnitude == 0 then return Vector3.zero end return Vector.Unit end
local function FlatCameraVector(CameraCF) return CameraCF.LookVector * XZ,CameraCF.RightVector * XZ end
local function InputToVelocity() local LookVector,RightVector = FlatCameraVector(Camera.CFrame)
    local Forward  = UserInputService:IsKeyDown(Enum.KeyCode.W) and LookVector or Vector3.zero
    local Backward = UserInputService:IsKeyDown(Enum.KeyCode.S) and -LookVector or Vector3.zero
    local Left     = UserInputService:IsKeyDown(Enum.KeyCode.A) and -RightVector or Vector3.zero
    local Right    = UserInputService:IsKeyDown(Enum.KeyCode.D) and RightVector or Vector3.zero
    local Up       = UserInputService:IsKeyDown(Enum.KeyCode.Space) and YPlus or Vector3.zero
    local Down     = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and YMinus or Vector3.zero
    return FixUnit(Forward + Backward + Left + Right + Up + Down)
end

local function Raycast(Origin,Direction,Table)
    WallCheckParams.FilterDescendantsInstances = Table
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end

local function GetPlayerTeam(Player)
    for Index,Team in pairs(TeamService:GetChildren()) do
        if Team.Players:FindFirstChild(Player.Name) then
            return Team.Name
        end
    end
end
local function TeamCheck(Player)
    local Team = GetPlayerTeam(Player)
    local LPTeam = GetPlayerTeam(LocalPlayer)
    return LPTeam ~= Team or Team == "FFA"
end
local function DistanceCheck(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance <= MaxDistance
end
local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    return not Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,
    {Workspace.Geometry,Workspace.Terrain})
end

local function FindWeaponModel()
    for Index,Instance in pairs(Workspace:GetChildren()) do
        if Instance:FindFirstChild("AnimationController") then
            return Instance
        end
    end
end
local function GetCharacterInfo(Player,Shield)
    local Character = Characters[Player]
    if not Character then return end
    if Character.Parent == nil then return end

    if Shield then
        local Health = Character:FindFirstChild("Health")
        if not Health then return end
        return Character:FindFirstChild("Hitbox"),
        not Health:FindFirstChild("Shield")
    else
        return Character:FindFirstChild("Hitbox"),true
    end
end
local function GetHitbox(Hitbox,Name)
    for Index,Part in pairs(Hitbox:GetChildren()) do
        local WeldConstraint = Part:FindFirstChildOfClass("WeldConstraint")
        if not WeldConstraint then continue end
        if tostring(WeldConstraint.Part0) == Name then
            return Part
        end
    end
end
local function GetEquippedController()
    local Controllers = Tortoiseshell.Items:GetControllers()
    for Weapon,Controller in pairs(Controllers) do
        if Controller.Equipped then
            return Controller
        end
    end
end
local function GetEquippedWeapon()
    local Controllers = Tortoiseshell.Items:GetControllers()
    for Weapon,Controller in pairs(Controllers) do
        if Controller.Equipped then
            return Weapon,WeaponConfigs[Weapon]
        end
    end
end
--[[local function ToggleShoot(Toggle)
    Tortoiseshell.Input[Toggle and "AutomateBegan"
    or "AutomateEnded"](Tortoiseshell.Input,"Shoot")
end]]
local function PlayerFly(Enabled,Speed)
    if not Enabled then return end
    BodyVelocity.Velocity = InputToVelocity() * Speed
end

local function CustomizeWeapon(Enabled,HideTextures,Color,Reflectance,Material)
    if not Enabled then return end
    if not WeaponModel then return end
    for Index,Instance in pairs(WeaponModel.Body:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Color[6]
            Instance.Transparency = Color[4] > 0.95 and 0.95 or Color[4]
            Instance.Reflectance = Reflectance
            Instance.Material = Material
        end
    end
end
local function CustomizeArms(Enabled,HideTextures,Color,Reflectance,Material)
    if not Enabled then return end
    for Index,Instance in pairs(Workspace.Arms:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Color[6]
            Instance.Transparency = Color[4] > 0.95 and 0.95 or Color[4]
            Instance.Reflectance = Reflectance
            Instance.Material = Material
        end
    end
end

--[[local function CalculateTrajectory(targetPosition: Vector3, targetVelocity: Vector3, shooterPosition: Vector3, shooterVelocity: Vector3, projectileSpeed: number, gravity: number)	
	local a = Vector3.new(0,math.abs(gravity),0)
	local v = targetVelocity - shooterVelocity
	local p = targetPosition - shooterPosition
	local distance = p.Magnitude

	local timeTaken = (distance / projectileSpeed)
	return (targetPosition + v * timeTaken) + (a * timeTaken^2 / 2)
end]]

local function CalculateTrajectory(Origin,Velocity,Time,Gravity)
    --[[local PredictedPosition = Origin + Velocity * Time
    local Delta = (PredictedPosition - Origin).Magnitude
    Time = Time + Delta / ProjectileSpeed]]
    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end
local function ComputeProjectiles(Config,Hitbox)
    local RayResult =  Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,{Hitbox})
    if not RayResult then return end

    local ShootProjectiles = {}
    for Index = 1,Config.Projectile.Amount do
        table.insert(ShootProjectiles,{
            (Hitbox.Position - Camera.CFrame.Position).Unit,
            Tortoiseshell.Projectiles:GetID()
        })
    end

    return ShootProjectiles,
    RayResult.Position,RayResult.Normal
end
local function AutoShoot(Hitbox,Enabled)
    if not Enabled or not Hitbox then return end
    local Weapon,Config = GetEquippedWeapon()

    if Weapon and Config then
        if Config.Controller == "Melee" then
            if (Hitbox[3].Position - Camera.CFrame.Position).Magnitude <= 15 then
                Tortoiseshell.Network:Fire("Item_Melee","StabBegin",Weapon)
                Tortoiseshell.Network:Fire("Item_Melee","Stab",Weapon,Hitbox[3],Hitbox[3].Position,
                (Hitbox[3].Position - Camera.CFrame.Position).Unit * (Config.Melee.Range + 1))
                Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3])

                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Stab %s"):format(Hitbox[1].Name),
                    Color = Color3.new(1,0.5,0.25),Duration = 3
                }) task.wait(1 / Config.Melee.Speed)
            end return
        end

        local State = Weapon.State
        local Ammo = State.Ammo.Server
        if Ammo.Value > 0 and Config.Controller == "Paintball" then
            local FireMode = State.FireMode.Server
            local OldAmmo = Ammo.Value

            local FireModeFromList = Config.FireModeList[FireMode.Value]
            local CurrentFireMode = Config.FireModes[FireModeFromList]


            local ShootProjectiles,RayPosition,RayNormal
            = ComputeProjectiles(Config,Hitbox[3])
            if not ShootProjectiles then return end

            Tortoiseshell.Network:Fire("Item_Paintball","Shoot",
            Weapon,Camera.CFrame.Position,ShootProjectiles)

            task.wait((RayPosition - Camera.CFrame.Position).Magnitude
            / Projectiles[Config.Projectile.Template].Speed)

            for Index,Projectile in pairs(ShootProjectiles) do
                Tortoiseshell.Network:Fire("Projectiles","__Hit",
                Projectile[2],RayPosition,Hitbox[3],RayNormal,Hitbox[1])
            end

            Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
            Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3],RayPosition,
            Config.Projectile.Amount and Config.Projectile.Amount > 3)
            task.wait(60/CurrentFireMode.FireRate)

            if (OldAmmo - Ammo.Value) >= 1 then
                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Hit %s | Ammo %s"):format(
                        Hitbox[1].Name,Ammo.Value
                    ),Color = Color3.new(1,0.5,0.25),Duration = 3
                })
            end
        else local Reloading = State.Reloading.Server
            if Reloading.Value then
                local ReloadTime = Config.Magazine.ReloadTime
                local Milliseconds = (ReloadTime % 1) * 10
                local Seconds = ReloadTime % 60

                Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Reloading | Approx Time: %d.%d sec."):format(Seconds,Milliseconds),
                    Color = Color3.new(1,0.25,0.25),Duration = 3
                }) task.wait(ReloadTime)
            end
        end
    end
end

local function GetClosest(Enabled,FOV,DFOV,BP,WC,DC,MD,PE,Shield)
    -- FieldOfView,DynamicFieldOfView,BodyParts
    -- WallCheck,DistanceCheck,MaxDistance
    -- PredictionEnabled

    if not Enabled then return end local Closest = nil
    FOV = DFOV and FOV * (1 + (80 - Camera.FieldOfView) / 100) or FOV

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character,Shield = GetCharacterInfo(Player,Shield)
        if Character and Shield and TeamCheck(Player) then
            for Index,BodyPart in pairs(BP) do
                BodyPart = GetHitbox(Character,BodyPart) if not BodyPart then continue end
                local Distance = (BodyPart.Position - Camera.CFrame.Position).Magnitude

                if WallCheck(WC,BodyPart) and DistanceCheck(DC,Distance,MD) then
                    --[[local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(PE and CalculateTrajectory(BodyPart.Position,
                    BodyPart.AssemblyLinearVelocity,ProjectileGravity,Distance / ProjectileSpeed) or BodyPart.Position)]]

                    local LPCharacter = Characters[LocalPlayer]
                    local Velocity = LPCharacter and LPCharacter.PrimaryPart.AssemblyLinearVelocity or Vector3.zero
                    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(PE and CalculateTrajectory(BodyPart.Position,
                    BodyPart.AssemblyLinearVelocity - Velocity,Distance / ProjectileSpeed,ProjectileGravity) or BodyPart.Position)
                    local NewFOV = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and NewFOV < FOV then FOV,Closest = NewFOV,{Player,Character,BodyPart,ScreenPosition} end
                end
            end
        end
    end

    return Closest
end

local function GetClosestAllFOV(BP,WC,DC,MD)
    local Distance,Closest = math.huge,nil

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character,Shield = GetCharacterInfo(Player,true)
        if Character and Shield and TeamCheck(Player) then
            for Index,BodyPart in pairs(BP) do
                BodyPart = GetHitbox(Character,BodyPart) if not BodyPart then continue end
                local NewDistance = (BodyPart.Position - Camera.CFrame.Position).Magnitude

                if WallCheck(WC,BodyPart) and DistanceCheck(DC,Distance,MD) then
                    if NewDistance < Distance then
                        Distance,Closest = NewDistance,{Player,Character,BodyPart}
                    end
                end
            end
        end
    end

    return Closest
end

local function AimAt(Hitbox,Smoothness)
    if not Hitbox then return end
    local Mouse = UserInputService:GetMouseLocation()

    mousemoverel(
        (Hitbox[4].X - Mouse.X) * Smoothness,
        (Hitbox[4].Y - Mouse.Y) * Smoothness
    )
end

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Network.Fire,function(Old,Self,...)
    local Args = {...}

    if Args[2] == "__Hit" then
        if (SilentAim and not Window.Flags["BB/AutoShoot/Enabled"])
        and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
            Args[4] = SilentAim[3].Position
            Args[5] = SilentAim[3]
            Args[7] = SilentAim[2]
            Tortoiseshell.UI.Events.Hitmarker:Fire(
            SilentAim[3],SilentAim[3].Position)
            return Old(Self,unpack(Args))
        end
    end

    if Args[3] == "Look" then
        if Window.Flags["BB/AntiAim/Enabled"] then
            if Window.Flags["BB/AntiAim/LeanRandom"] then
                Tortoiseshell.Network:Fire("Character","State","Lean",math.random(-1,1))
            end
            Args[4] = Window.Flags["BB/AntiAim/Pitch"] < 0
            and Window.Flags["BB/AntiAim/Pitch"] + NewRandom:NextNumber(0,
            Window.Flags["BB/AntiAim/PitchRandom"])
            or Window.Flags["BB/AntiAim/Pitch"] - NewRandom:NextNumber(0,
            Window.Flags["BB/AntiAim/PitchRandom"])
            return Old(Self,unpack(Args))
        end
    end

    return Old(Self,...)
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Projectiles.InitProjectile,function(Old,Self,...)
    local Args = {...} if Args[4] == LocalPlayer then ProjectileSpeed = Projectiles[Args[1]].Speed
        ProjectileGravity = Vector3.new(0,math.abs(Projectiles[Args[1]].Gravity),0)
    end return Old(Self,...)
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Raycast.CastGeometryAndEnemies,function(Old,Self,...)
    local Args = {...} if Window.Flags["BB/WeaponMod/Enabled"] and Args[4] and Args[4].Gravity then
        Args[4].Gravity = Args[4].Gravity * (Window.Flags["BB/WeaponMod/BulletDrop"] / 100)
    end return Old(Self,unpack(Args))
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Items.GetAnimator,function(Old,Self,...)
    local Args = {...} if Args[1] then WeaponModel = Args[3] end
    return Old(Self,...)
end,true)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Items.GetConfig,function(Old,Self,...)
    local Args = {Old(Self,...)} local Config = Args[1]
    if Window.Flags["BB/WeaponMod/Enabled"]
    and (Config.Recoil and Config.Recoil.Default) then
        Config.Recoil.Default.WeaponScale = 
        Config.Recoil.Default.WeaponScale * (Window.Flags["BB/WeaponMod/WeaponScale"] / 100)

        Config.Recoil.Default.CameraScale = 
        Config.Recoil.Default.CameraScale * (Window.Flags["BB/WeaponMod/CameraScale"] / 100)

        Config.Recoil.Default.RecoilScale = 
        Config.Recoil.Default.RecoilScale * (Window.Flags["BB/WeaponMod/RecoilScale"] / 100)
    end return unpack(Args)
end)

RunService.Heartbeat:Connect(function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"],
        Window.Flags["SilentAim/FieldOfView"],
        Window.Flags["SilentAim/DynamicFOV"],
        Window.Flags["SilentAim/BodyParts"],
        Window.Flags["SilentAim/WallCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/Distance"],
        false,true
    )
    if Aimbot then
        AimAt(GetClosest(
            Window.Flags["Aimbot/Enabled"],
            Window.Flags["Aimbot/FieldOfView"],
            Window.Flags["Aimbot/DynamicFOV"],
            Window.Flags["Aimbot/BodyParts"],
            Window.Flags["Aimbot/WallCheck"],
            Window.Flags["Aimbot/DistanceCheck"],
            Window.Flags["Aimbot/Distance"],
            Window.Flags["Aimbot/Prediction"],
            false
        ),Window.Flags["Aimbot/Smoothness"] / 100)
    end
end)

Parvus.Utilities.Misc:NewThreadLoop(1,function()
    local Weapon,Config = GetEquippedWeapon()
    if Weapon and Config then
        if Config.Projectile and Config.Projectile.GravityCorrection then
            GravityCorrection = Config.Projectile.GravityCorrection
        end
    end
end)
Parvus.Utilities.Misc:NewThreadLoop(0.025,function()
    CustomizeWeapon(
        Window.Flags["BB/WeaponCustom/Enabled"],
        Window.Flags["BB/WeaponCustom/Texture"],
        Window.Flags["BB/WeaponCustom/Color"],
        Window.Flags["BB/WeaponCustom/Reflectance"],
        Window.Flags["BB/WeaponCustom/Material"][1]
    )
    CustomizeArms(
        Window.Flags["BB/ArmsCustom/Enabled"],
        Window.Flags["BB/ArmsCustom/Texture"],
        Window.Flags["BB/ArmsCustom/Color"],
        Window.Flags["BB/ArmsCustom/Reflectance"],
        Window.Flags["BB/ArmsCustom/Material"][1]
    )
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    PlayerFly(
        Window.Flags["BB/Fly/Enabled"],
        Window.Flags["BB/Fly/Speed"]
    )
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if not Window.Flags["BB/AutoShoot/Enabled"] then return end
    AutoShoot(Window.Flags["BB/AutoShoot/AllFOV"]
    and GetClosestAllFOV(
        Window.Flags["SilentAim/BodyParts"],
        Window.Flags["SilentAim/WallCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/Distance"]
    ) or SilentAim,Window.Flags["BB/AutoShoot/Enabled"])
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if not Trigger then return end
    local TriggerHitbox = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/FieldOfView"],
        Window.Flags["Trigger/DynamicFOV"],
        Window.Flags["Trigger/BodyParts"],
        Window.Flags["Trigger/WallCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/Distance"],
        Window.Flags["Trigger/Prediction"],
        false
    )

    if TriggerHitbox then --ToggleShoot(true)
        Tortoiseshell.Input:AutomateBegan("Shoot")
        task.wait(Window.Flags["Trigger/Delay"])
        if Window.Flags["Trigger/HoldMode"] then
            while task.wait() do
                TriggerHitbox = GetClosest(
                    Window.Flags["Trigger/Enabled"],
                    Window.Flags["Trigger/FieldOfView"],
                    Window.Flags["Trigger/DynamicFOV"],
                    Window.Flags["Trigger/BodyParts"],
                    Window.Flags["Trigger/WallCheck"],
                    Window.Flags["Trigger/DistanceCheck"],
                    Window.Flags["Trigger/Distance"],
                    Window.Flags["Trigger/Prediction"],
                    false
                ) if not TriggerHitbox or not Trigger then break end
            end
        end --ToggleShoot(false)
        Tortoiseshell.Input:AutomateEnded("Shoot")
    end
end)

Workspace.Characters.ChildAdded:Connect(function(Child)
    if Child.Name == LocalPlayer.Name then
        repeat task.wait() until Child.PrimaryPart
        Child.PrimaryPart.CanCollide = not Window.Flags["BB/NoClip"]
        if Window.Flags["BB/Fly/Enabled"] then
            BodyVelocity.Parent = Child.PrimaryPart
        end
    end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

for Index,Player in pairs(PlayerService:GetPlayers()) do
    if Player == LocalPlayer then continue end
    Parvus.Utilities.Drawing:AddESP(Player,"Player","ESP/Player",Window.Flags)
end
PlayerService.PlayerAdded:Connect(function(Player)
    Parvus.Utilities.Drawing:AddESP(Player,"Player","ESP/Player",Window.Flags)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    Parvus.Utilities.Drawing:RemoveESP(Player)
end)
