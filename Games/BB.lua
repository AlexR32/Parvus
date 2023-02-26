local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeamService = game:GetService("Teams")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local LoadingGui = PlayerGui:WaitForChild("LoadingGui")
repeat task.wait(0.5) until not LoadingGui.Enabled

local Loaded1,Loaded2,PromptLib = false,false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
if identifyexecutor() ~= "Synapse X" then
    PromptLib("Unsupported executor","Synapse X only for safety measures\nIf you still want to use the script, click \"Ok\"",{
        {Text = "Ok",LayoutOrder = 0,Primary = false,Callback = function() Loaded1 = true end},
    }) repeat task.wait(0.5) until Loaded1
end

if game.PlaceVersion > 1341 then
    PromptLib("Unsupported game version","You are at risk of getting autoban\nAre you sure you want to load Parvus?",{
        {Text = "Yes",LayoutOrder = 0,Primary = false,Callback = function() Loaded2 = true end},
        {Text = "No",LayoutOrder = 0,Primary = true,Callback = function() end}
    }) repeat task.wait(0.5) until Loaded2
end

--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Tortoiseshell = require(ReplicatedStorage.TS)

local SilentAim,Aimbot,Trigger,AutoshootHitbox,GrenadeHitbox = nil,false,false,nil,nil
local Tortoiseshell,HitmarkerScripts,WeaponModel = require(ReplicatedStorage.TS),{},nil
local ProjectileSpeed,ProjectileGravity,GravityCorrection = 1600,Vector3.new(0,150,0),2
local BanCommands = {"GetUpdate","SetUpdate","Invoke","GetSetting","FireProjectile"}
local NewRandom,CodesDebounce,FlyPosition = Random.new(),false,nil
local SetIdentity = syn and syn.set_thread_identity or setidentity

for Index,Connection in pairs(getconnections(Tortoiseshell.UI.Events.Hitmarker.Event)) do
    HitmarkerScripts[#HitmarkerScripts + 1] = getfenv(Connection.Function).script
end

local HandleCharacter
for Index,Connection in pairs(getconnections(Tortoiseshell.Characters.CharacterAdded)) do
    local Script = getfenv(Connection.Function).script
    if Script.Name == "CharacterAnimateScript" then
        HandleCharacter = Connection.Function
    end
end

local CharacterHandlers = getupvalue(HandleCharacter,3)
local Events = getupvalue(Tortoiseshell.Network.BindEvent,1)
local WeaponConfigs = getupvalue(Tortoiseshell.Items.GetConfig,3)
local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter,1)
--local ControllersFolder = getupvalue(Tortoiseshell.Items.GetController,2)
local Projectiles = getupvalue(Tortoiseshell.Projectiles.InitProjectile,1)
local HeartbeatConnections = getupvalue(Tortoiseshell.Timer.BindToHeartbeat,1)
local RenderStepConnections = getupvalue(Tortoiseshell.Timer.BindToRenderStep,1)

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.MaxForce = Vector3.one * math.huge
BodyVelocity.Velocity = Vector3.zero

local Notify = Instance.new("BindableEvent")
Notify.Event:Connect(function(Text)
    Parvus.Utilities.UI:Notification2(Text)
end)

local HitSounds = {
    {"AR2 Head","2062016772"},
    {"AR2 Body","2062015952"},
    {"BB Body","4645745735"},
    {"BB Kill","2636743632"},
    {"Neverlose","8726881116"},
    {"Gamesense","4817809188"},
    {"Baimware","3124331820"},
    {"Steve","4965083997"},
    {"Skeet","4753603610"},
    {"Body","3213738472"},
    {"Ding","7149516994"},
    {"Mario","2815207981"},
    {"Minecraft","6361963422"},
    {"Among Us","5700183626"},
    {"Button","12221967"},
    {"Oof","4792539171"},
    {"Osu","7149919358"},
    {"Osu Combobreak","3547118594"},
    {"Bambi","8437203821"},
    {"Click","8053704437"},
    {"Snow","6455527632"},
    {"Stone","3581383408"},
    {"Rust","1255040462"},
    {"Splat","12222152"},
    {"Bell","6534947240"},
    {"Slime","6916371803"},
    {"Saber","8415678813"},
    {"Bat","3333907347"},
    {"Bubble","6534947588"},
    {"Pick","1347140027"},
    {"Pop","198598793"},
    {"EmptyGun","203691822"},
    {"Bamboo","3769434519"},
    {"Stomp","200632875"},
    {"Bag","364942410"},
    {"Hitmarker","8543972310"},
    {"LaserSlash","199145497"},
    {"RailGunF","199145534"},
    {"Bruh","4275842574"},
    {"Crit","296102734"},
    {"Bonk","3765689841"},
    {"Clink","711751971"},
    {"CoD","160432334"},
    {"Lazer Beam","130791043"},
    
    {"Windows XP Error","160715357"},
    {"Windows XP Ding","489390072"},
    
    {"HL Med Kit","4720445506"},
    {"HL Door","4996094887"},
    {"HL Crowbar","546410481"},
    {"HL Revolver","1678424590"},
    {"HL Elevator","237877850"},
    
    {"TF2 HitSound","3455144981"},
    {"TF2 Squasher","3466981613"},
    {"TF2 Retro","3466984142"},
    {"TF2 Space","3466982899"},
    {"TF2 Vortex","3466980212"},
    {"TF2 Beepo","3466987025"},
    {"TF2 Bat","3333907347"},
    {"TF2 Pow","679798995"},
    {"TF2 You Suck","1058417264"},
    {"Quake Hitsound","4868633804"},
    {"Fart","131314452"},
    {"Fart2","6367774932"},
    {"FortniteGuns","3008769599"}
}

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
        local SAFOVSection = AimAssistTab:Section({Name = "Silent Aim FOV Circle",Side = "Left"}) do
            SAFOVSection:Toggle({Name = "Enabled",Flag = "SilentAim/Circle/Enabled",Value = true})
            SAFOVSection:Toggle({Name = "Filled",Flag = "SilentAim/Circle/Filled",Value = false})
            SAFOVSection:Colorpicker({Name = "Color",Flag = "SilentAim/Circle/Color",
            Value = {0.6666666865348816,0.6666666269302368,1,0.25,false}})
            SAFOVSection:Slider({Name = "NumSides",Flag = "SilentAim/Circle/NumSides",Min = 3,Max = 100,Value = 14})
            SAFOVSection:Slider({Name = "Thickness",Flag = "SilentAim/Circle/Thickness",Min = 1,Max = 10,Value = 2})
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
        local AutoshootSection = AimAssistTab:Section({Name = "Autoshoot",Side = "Right"}) do
            AutoshootSection:Toggle({Name = "Enabled",Flag = "BB/Autoshoot/Enabled",Value = false})
            :Keybind({Mouse = true,Flag = "BB/Autoshoot/Keybind"})
            AutoshootSection:Toggle({Name = "Beam Enabled",Flag = "BB/Autoshoot/Beam/Enabled",Value = true})
            :Colorpicker({Flag = "BB/Autoshoot/Beam/Color",Value = {1,0.75,1,0,true}})
            AutoshootSection:Toggle({Name = "Hitmarker Enabled",Flag = "BB/Autoshoot/Hitmarker",Value = true})
            AutoshootSection:Toggle({Name = "Tele-Grenade",Flag = "BB/Autoshoot/TeleGrenade",Value = false}):Keybind()
            AutoshootSection:Toggle({Name = "Auto Grenade",Flag = "BB/Autoshoot/AutoGrenade",Value = false}):Keybind()
            AutoshootSection:Toggle({Name = "Visibility Check",Flag = "BB/Autoshoot/WallCheck",Value = false}):Keybind()
            AutoshootSection:Toggle({Name = "Distance Check",Flag = "BB/Autoshoot/DistanceCheck",Value = false}):Keybind()
            AutoshootSection:Slider({Name = "Distance",Flag = "BB/Autoshoot/Distance",Min = 25,Max = 1000,Value = 1000,Unit = "studs"})
            AutoshootSection:Slider({Name = "Fire Rate",Flag = "BB/Autoshoot/FireRate",Min = 1,Max = 10,Value = 1,Unit = "x"})
            AutoshootSection:Dropdown({Name = "Body Parts",Flag = "BB/Autoshoot/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle"},
                {Name = "Chest",Mode = "Toggle"},
                {Name = "Abdomen",Mode = "Toggle"},
                {Name = "Hips",Mode = "Toggle"}
            }})
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
            BoxSection:Toggle({Name = "Healthbar",Flag = "ESP/Player/Box/HealthBar",Value = false})
            BoxSection:Toggle({Name = "Filled",Flag = "ESP/Player/Box/Filled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/Player/Box/Outline",Value = true})
            BoxSection:Slider({Name = "Thickness",Flag = "ESP/Player/Box/Thickness",Min = 1,Max = 10,Value = 1})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Box/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            BoxSection:Divider()
            BoxSection:Toggle({Name = "Name Enabled",Flag = "ESP/Player/Name/Enabled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/Player/Name/Outline",Value = true})
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Name/Autoscale",Value = true})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/Player/Name/Font",List = {
                {Name = "UI",Mode = "Button",Value = true},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button"}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/Player/Name/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Name/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/Player/Arrow/Filled",Value = true})
            OoVSection:Toggle({Name = "Outline",Flag = "ESP/Player/Arrow/Outline",Value = true})
            OoVSection:Slider({Name = "Width",Flag = "ESP/Player/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Height",Flag = "ESP/Player/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/Player/Arrow/Radius",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/Player/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/Player/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HeadSection = VisualsTab:Section({Name = "Head Dots",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Flag = "ESP/Player/HeadDot/Enabled",Value = false})
            HeadSection:Toggle({Name = "Filled",Flag = "ESP/Player/HeadDot/Filled",Value = true})
            HeadSection:Toggle({Name = "Outline",Flag = "ESP/Player/HeadDot/Outline",Value = true})
            HeadSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/HeadDot/Autoscale",Value = true})
            HeadSection:Slider({Name = "Radius",Flag = "ESP/Player/HeadDot/Radius",Min = 1,Max = 10,Value = 8})
            HeadSection:Slider({Name = "NumSides",Flag = "ESP/Player/HeadDot/NumSides",Min = 3,Max = 100,Value = 4})
            HeadSection:Slider({Name = "Thickness",Flag = "ESP/Player/HeadDot/Thickness",Min = 1,Max = 10,Value = 1})
            HeadSection:Slider({Name = "Transparency",Flag = "ESP/Player/HeadDot/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local TracerSection = VisualsTab:Section({Name = "Tracers",Side = "Right"}) do
            TracerSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Tracer/Enabled",Value = false})
            TracerSection:Toggle({Name = "Outline",Flag = "ESP/Player/Tracer/Outline",Value = true})
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
            WCSection:Toggle({Name = "Enabled",Flag = "BB/WC/Enabled",Value = false})
            :Colorpicker({Flag = "BB/WC/Color",Value = {1,0.75,1,0.5,true}})
            WCSection:Toggle({Name = "Hide Textures",Flag = "BB/WC/Texture",Value = true})
            WCSection:Slider({Name = "Reflectance",Flag = "BB/WC/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            WCSection:Dropdown({Name = "Material",Flag = "BB/WC/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local CCSection = MiscTab:Section({Name = "Character Customization",Side = "Left"}) do
            CCSection:Toggle({Name = "Enabled",Flag = "BB/CC/Enabled",Value = false})
            :Colorpicker({Flag = "BB/CC/Color",Value = {1,0.75,1,0.5,true}})
            CCSection:Toggle({Name = "Hide Textures",Flag = "BB/CC/Texture",Value = true})
            CCSection:Slider({Name = "Reflectance",Flag = "BB/CC/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            CCSection:Dropdown({Name = "Material",Flag = "BB/CC/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local HitSoundSection = MiscTab:Section({Name = "HitSound Customization",Side = "Left"}) do

            local HitSoundsList = {}
            for Index,Sound in pairs(HitSounds) do
                HitSoundsList[#HitSoundsList + 1] = {
                    Name = Sound[1],Mode = "Button",
                    Callback = function()
                        local HitSound
                        for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                            HitmarkerScript.HeadshotSound.Volume = 0
                            HitSound = HitmarkerScript.HitmarkerSound
                            HitSound.SoundId = "rbxassetid://" .. Sound[2]
                        end HitSound:Play()
                    end
                }
            end

            HitSoundSection:Button({Name = "Reset To Defaults",Callback = function()
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitmarkerScript.HeadshotSound.Volume = 0.7
                    HitmarkerScript.HitmarkerSound.Volume = 3.5
                    HitmarkerScript.HitmarkerSound.PlaybackSpeed = 1.4
                    HitmarkerScript.HitmarkerSound.SoundId = "rbxassetid://4645745735"
                end
            end})
            HitSoundSection:Slider({Name = "Volume",Flag = "BB/HitSound/Volume",Min = 0,Max = 5,Precise = 1,Value = 3.5,
            Callback = function(Value)
                local HitSound
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitSound = HitmarkerScript.HitmarkerSound
                    HitSound.Volume = Value
                end HitSound:Play()
            end})
            HitSoundSection:Slider({Name = "Pitch",Flag = "BB/HitSound/Pitch",Min = 0,Max = 5,Precise = 1,Value = 1.4,
            Callback = function(Value)
                local HitSound
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitSound = HitmarkerScript.HitmarkerSound
                    HitSound.PlaybackSpeed = Value
                end HitSound:Play()
            end})
            HitSoundSection:Dropdown({HideName = true,Flag = "BB/HitSound/Sound",List = HitSoundsList})
        end
        local WMSection = MiscTab:Section({Name = "Weapon Modification",Side = "Left"}) do
            WMSection:Toggle({Name = "Auto FireMode",Flag = "BB/FireMode/Enabled",Value = false})
            WMSection:Toggle({Name = "Recoil Enabled",Flag = "BB/Recoil/Enabled",Value = false})
            WMSection:Slider({Name = "Weapon Shake",Flag = "BB/Recoil/WeaponScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Camera Shake",Flag = "BB/Recoil/CameraScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Recoil Scale",Flag = "BB/Recoil/RecoilScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Bullet Drop",Flag = "BB/Recoil/BulletDrop",Min = 0,Max = 100,Value = 0,Unit = "%"})
        end
        local MiscSection = MiscTab:Section({Name = "Misc",Side = "Left"}) do
            MiscSection:Button({Name = "Redeem Codes",Callback = function()
                local Codes = ""
                local Success,Error = pcall(function()
                    Codes = game:HttpGet("https://roblox-bad-business.fandom.com/wiki/Codes")
                end)

                if Success then
                    for Code in Codes:gmatch("<td>([%w\n_]*)</td>") do
                        Tortoiseshell.Network:Invoke("Codes","Redeem",Code:gsub("\n",""))
                        --Code = Code:gsub("\n","")
                        --print(Code,Tortoiseshell.Network:Invoke("Codes","Redeem",Code))
                    end task.wait(0.1)
                    firesignal(LocalPlayer.PlayerGui.MenuGui.ClaimedFrame.CloseButton.MouseButton1Click)
                    firesignal(LocalPlayer.PlayerGui.MenuGui.PurchasedFrame.CloseButton.MouseButton1Click)
                    Parvus.Utilities.UI:Notification({Title = "Parvus Hub",Description = "All available codes are claimed!",Duration = 5})
                else
                    Parvus.Utilities.UI:Notification({Title = "Parvus Hub",Description = "Failed to get the codes:\n"..Error,Duration = 5})
                end
            end})
        end
        local ACSection = MiscTab:Section({Name = "Arms Customization",Side = "Right"}) do
            ACSection:Toggle({Name = "Enabled",Flag = "BB/AC/Enabled",Value = false})
            :Colorpicker({Flag = "BB/AC/Color",Value = {1,0,1,1,false}})
            ACSection:Toggle({Name = "Hide Textures",Flag = "BB/AC/Texture",Value = true})
            ACSection:Slider({Name = "Reflectance",Flag = "BB/AC/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            ACSection:Dropdown({Name = "Material",Flag = "BB/AC/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local KillSoundSection = MiscTab:Section({Name = "KillSound Customization",Side = "Right"}) do

            local KillSoundsList = {}
            for Index,Sound in pairs(HitSounds) do
                KillSoundsList[#KillSoundsList + 1] = {
                    Name = Sound[1],Mode = "Button",
                    Callback = function()
                        local KillSound
                        for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                            HitmarkerScript.MedalSound.Volume = 0
                            KillSound = HitmarkerScript.KillSound
                            KillSound.SoundId = "rbxassetid://" .. Sound[2]
                        end KillSound:Play()
                    end
                }
            end

            KillSoundSection:Button({Name = "Reset To Defaults",Callback = function()
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitmarkerScript.MedalSound.Volume = 0.8
                    HitmarkerScript.KillSound.Volume = 1
                    HitmarkerScript.KillSound.PlaybackSpeed = 1.5
                    HitmarkerScript.KillSound.SoundId = "rbxassetid://2636743632"
                end
            end})
            KillSoundSection:Slider({Name = "Volume",Flag = "BB/KillSound/Volume",Min = 0,Max = 5,Precise = 1,Value = 1,
            Callback = function(Value)
                local KillSound
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    KillSound = HitmarkerScript.KillSound
                    KillSound.Volume = Value
                end KillSound:Play()
            end})
            KillSoundSection:Slider({Name = "Pitch",Flag = "BB/KillSound/Pitch",Min = 0,Max = 5,Precise = 1,Value = 1.5,
            Callback = function(Value)
                local KillSound
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    KillSound = HitmarkerScript.KillSound
                    KillSound.PlaybackSpeed = Value
                end KillSound:Play()
            end})
            KillSoundSection:Dropdown({HideName = true,Flag = "BB/KillSound/Sound",List = KillSoundsList})
        end
        local CharSection = MiscTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "ThirdPerson Load Outfit",Flag = "BB/ThirdPerson/Outfit",Value = false})
            CharSection:Toggle({Name = "ThirdPerson",Flag = "BB/ThirdPerson/Enabled",Value = false,Callback = function(Bool)
                local LPCharacter = Characters[LocalPlayer]
                if not LPCharacter then return end

                if Window.Flags["BB/ThirdPerson/Outfit"] then
                    task.spawn(function() SetIdentity(2)
                        if not CharacterHandlers[LPCharacter] then
                            HandleCharacter(LPCharacter,LocalPlayer)
                        end
                    end)
                end

                for Index,Value in pairs(LPCharacter:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = Bool and 0 or 1
                    end
                end
            end}):Keybind({Flag = "BB/ThirdPerson/Keybind"})
            CharSection:Toggle({Name = "NoClip",Flag = "BB/NoClip/Enabled",Value = false,Callback = function(Bool)
                local LPCharacter = Characters[LocalPlayer]
                if LPCharacter and LPCharacter.PrimaryPart then LPCharacter.PrimaryPart.CanCollide = not Bool end
            end}):Keybind({Flag = "BB/NoClip/Keybind"})
            CharSection:Toggle({Name = "Fly",Flag = "BB/Fly/Enabled",Value = false,Callback = function(Bool)
                local LPCharacter = Characters[LocalPlayer]
                if Bool and (LPCharacter and LPCharacter.PrimaryPart) then
                    FlyPosition = LPCharacter.PrimaryPart.Position
                    --BodyVelocity.Parent = LPCharacter.PrimaryPart
                --else BodyVelocity.Parent = nil end
                end
            end}):Keybind({Flag = "BB/Fly/Keybind"})
            CharSection:Slider({Name = "Fly Speed",Flag = "BB/Fly/Speed",Min = 1,Max = 2.5,Precise = 1,Value = 2.5,Wide = true})
            CharSection:Slider({Name = "ThirdPerson FOV",Flag = "BB/ThirdPerson/FOV",Min = 1,Max = 79,Value = 15,Wide = true})
        end
        local AASection = MiscTab:Section({Name = "Anti-Aim",Side = "Right"}) do
            AASection:Toggle({Name = "Enabled",Flag = "BB/AntiAim/Enabled",Value = false}):Keybind({Flag = "BB/AntiAim/Keybind"})
            AASection:Slider({Name = "Refresh Rate",Flag = "BB/AntiAim/RefreshRate",Min = 0,Max = 1,Precise = 2,Value = 0.05,Wide = true})
            AASection:Slider({Name = "Pitch",Flag = "BB/AntiAim/Pitch/Value",Min = -2,Max = 2,Precise = 2,Value = -2})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Pitch/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
            AASection:Slider({Name = "Lean",Flag = "BB/AntiAim/Lean/Value",Min = -1.5,Max = 1.5,Precise = 2,Value = 0})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Lean/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
            AASection:Slider({Name = "Roll",Flag = "BB/AntiAim/Roll/Value",Min = -1,Max = 1,Precise = 2,Value = 1})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Roll/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
            AASection:Slider({Name = "Yaw",Flag = "BB/AntiAim/Yaw/Value",Min = -1,Max = 1,Precise = 2,Value = 1})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Yaw/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
        end
    end Parvus.Utilities.Misc:SettingsSection(Window,"RightShift",false)
end Parvus.Utilities.Misc:InitAutoLoad(Window)

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:SetupCrosshair(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)

do
    local OldNamecall,OldTaskSpawn
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
            if not table.find(Constants,"thread error ")
            and table.find(Constants,"wait") then
                print("blocked wtd crash")
                --print(repr(Constants))
                wait(31536000) -- 365 days
            end
        end

        return OldTaskSpawn(...)
    end)
end

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
local function GetGrenade()
    local Controllers = Tortoiseshell.Items:GetControllers()
    for Weapon,Controller in pairs(Controllers) do
        local Config = WeaponConfigs[Weapon]
        if Config.Category == "Grenade" then
            return Weapon,Config
        end
    end
end
local JitterValue,SpinValue = 1,0
local function GetAntiAimValue(Value,Mode)
    if Mode == "Random" then
        Value = math.abs(Value)
        return NewRandom:NextNumber(-Value,Value)
    elseif Mode == "Jitter" then
        Value = Value * JitterValue
    --elseif Mode == "Spin" then
    end
    return Value
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
    if WeaponModel.Parent == nil then return end

    for Index,Instance in pairs(WeaponModel.Body:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart")
        and Instance.Transparency < 1
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
        elseif Instance:IsA("BasePart")
        and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Color[6]
            Instance.Transparency = Color[4] > 0.95 and 0.95 or Color[4]
            Instance.Reflectance = Reflectance
            Instance.Material = Material
        end
    end
end
local function CustomizeCharacter(Enabled,HideTextures,Color,Reflectance,Material)
    if not Enabled then return end

    local LPCharacter = Characters[LocalPlayer]
    if not LPCharacter then return end

    for Index,Instance in pairs(LPCharacter:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart")
        and Instance.Transparency < 1
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

local function ProjectileBeam(Origin,Direction)
	local Beam = Instance.new("Part")

    Beam.BottomSurface = Enum.SurfaceType.Smooth
    Beam.TopSurface = Enum.SurfaceType.Smooth
    Beam.Material = Enum.Material.SmoothPlastic
    Beam.Color = Color3.new(1,0,0)

    Beam.CanCollide = false
	Beam.CanTouch = false
    Beam.CanQuery = false
    Beam.Anchored = true

	Beam.Size = Vector3.new(0.1,0.1,(Origin - Direction).Magnitude)
	Beam.CFrame = CFrame.new(Origin,Direction) * CFrame.new(0,0,-Beam.Size.Z / 2)

    Beam.Parent = Workspace

    task.spawn(function()
        for Index = 1, 60 * 1 do
            RunService.Heartbeat:Wait()
            Beam.Transparency = Index / (60 * 1)
            Beam.Color = Window.Flags["BB/Autoshoot/Beam/Color"][6]
        end Beam:Destroy()
    end)

	return Beam
end
local function ComputeProjectiles(Config,Hitbox)
    local Position = Camera.CFrame.Position
    local RayResult =  Raycast(Position,
    Hitbox.Position - Position,{Hitbox})
    if not RayResult then return end

    local ShootProjectiles = {}
    for Index = 1,Config.Projectile.Amount do
        table.insert(ShootProjectiles,{
            (Hitbox.Position - Position).Unit,
            Tortoiseshell.Projectiles:GetID()
        })
    end

    return ShootProjectiles,Position,
    RayResult.Position,RayResult.Normal
end
local function Autoshoot(Hitbox,FireRate)
    if not Hitbox then return end
    local Weapon,Config = GetEquippedWeapon()

    if Weapon and Config then
        if Config.Controller == "Melee" then
            if (Hitbox[3].Position - Camera.CFrame.Position).Magnitude <= 15 then
                Tortoiseshell.Network:Fire("Item_Melee","StabBegin",Weapon)
                Tortoiseshell.Network:Fire("Item_Melee","Stab",Weapon,Hitbox[3],Hitbox[3].Position,
                (Hitbox[3].Position - Camera.CFrame.Position).Unit * (Config.Melee.Range + 1))
                if Window.Flags["BB/Autoshoot/HM"] then
                    Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3])
                end

                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Stab %s"):format(Hitbox[1].Name),
                    Color = Color3.new(1,0.5,0.25),Duration = 3
                }) task.wait(1 / Config.Melee.Speed)
            end return
        end

        local State = Weapon.State
        local Ammo = State.Ammo.Server local AmmoValue = Ammo.Value
        local Health = Hitbox[2].Health local HealthValue = Health.Value
        if AmmoValue > 0 and Config.Controller == "Paintball" then
            local FireMode = State.FireMode.Server

            local FireModeFromList = Config.FireModeList[FireMode.Value]
            local CurrentFireMode = Config.FireModes[FireModeFromList]

            local ShootProjectiles,Position,RayPosition,RayNormal
            = ComputeProjectiles(Config,Hitbox[3])
            if not ShootProjectiles then return end

            task.spawn(function()
                Tortoiseshell.Network:Fire("Item_Paintball",
                "Shoot",Weapon,Position,ShootProjectiles)

                task.wait((RayPosition - Position).Magnitude
                /Projectiles[Config.Projectile.Template].Speed)

                for Index,Projectile in pairs(ShootProjectiles) do
                    Tortoiseshell.Network:Fire("Projectiles","__Hit",
                    Projectile[2],RayPosition,Hitbox[3],RayNormal,Hitbox[1])
                end
            end)

            if Window.Flags["BB/Autoshoot/Beam/Enabled"] then
                ProjectileBeam(Position - Vector3.new(0,5,0),RayPosition)
            end
            if Window.Flags["BB/Autoshoot/HM"] then
                Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3],RayPosition,
                Config.Projectile.Amount and Config.Projectile.Amount > 3)
            end
            Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
            task.wait(60/(CurrentFireMode.FireRate*FireRate))

            if (AmmoValue - Ammo.Value) >= 1 then
                --[[ProjectileBeam(Position,RayPosition)
                Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3],RayPosition,
                Config.Projectile.Amount and Config.Projectile.Amount > 3)]]
                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Hit %s | Ammo %s"):format(
                        Hitbox[1].Name,Ammo.Value
                    ),Color = Color3.new(1,0.5,0.25),Duration = 3
                })
            end
        else local Reloading = State.Reloading.Server
            if not Reloading.Value then
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
local function AutoGrenade(Enabled)
    if not Enabled then return end
    local Weapon,Config = GetEquippedWeapon()
    local Grenade,GrenadeConfig = GetGrenade()
    if Weapon and Grenade then
        local State = Grenade:WaitForChild("State")

        if State.Ammo.Server.Value > 0 then
            Tortoiseshell.Network:Fire("Item","Equip",Grenade)
            Tortoiseshell.Network:Fire("Item_Throwable","Cook",Grenade)
            Tortoiseshell.Network:Fire("Item_Throwable","Throw",Grenade,
                Camera.CFrame.Position,Camera.CFrame.LookVector
            ) Tortoiseshell.Network:Fire("Item","Equip",Weapon)
            task.wait(GrenadeConfig.Throwable.CookTime)
        end
    end
end

local function GetClosest(Enabled,FOV,DFOV,BP,WC,DC,MD,PE,Shield)
    -- FieldOfView,DynamicFieldOfView,BodyParts
    -- WallCheck,DistanceCheck,MaxDistance
    -- PredictionEnabled

    if not Enabled then return end local Closest
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
                    local Velocity = (LPCharacter and LPCharacter.PrimaryPart) and LPCharacter.PrimaryPart.AssemblyLinearVelocity or Vector3.zero
                    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(PE and CalculateTrajectory(BodyPart.Position,
                    BodyPart.AssemblyLinearVelocity - Velocity,Distance / ProjectileSpeed,ProjectileGravity) or BodyPart.Position)
                    local NewFOV = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and NewFOV < FOV then FOV,Closest = NewFOV,{Player,Character.Parent,BodyPart,ScreenPosition} end
                end
            end
        end
    end

    return Closest
end

local function GetClosestAllFOV(Enabled,BP,WC,DC,MD)
    -- BodyParts,WallCheck,DistanceCheck,MaxDistance

    if not Enabled then return end
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
                        Distance,Closest = NewDistance,{Player,Character.Parent,BodyPart}
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
        if (SilentAim and not Window.Flags["BB/Autoshoot/Enabled"])
        and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
            Args[4] = SilentAim[3].Position
            Args[5] = SilentAim[3]
            Args[7] = SilentAim[2]
            Tortoiseshell.UI.Events.Hitmarker:Fire(
            SilentAim[3],SilentAim[3].Position)
            return Old(Self,unpack(Args))
        end
    end

    if Args[2] == "Throw" then
        if (SilentAim and not Window.Flags["BB/Autoshoot/Enabled"])
        and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
            Args[5] = (SilentAim[3].Position - Camera.CFrame.Position).Unit
            Tortoiseshell.UI.Events.Hitmarker:Fire(
            SilentAim[3],SilentAim[3].Position)
            return Old(Self,unpack(Args))
        end
    end

    if Args[3] == "Look" then
        if Window.Flags["BB/AntiAim/Enabled"] then
            local Pitch = GetAntiAimValue(Window.Flags["BB/AntiAim/Pitch/Value"],Window.Flags["BB/AntiAim/Pitch/Mode"][1])
            local Lean = GetAntiAimValue(Window.Flags["BB/AntiAim/Lean/Value"],Window.Flags["BB/AntiAim/Lean/Mode"][1])
            Args[4] = Pitch Old(Self,"Character","State","Lean",Lean)

            --[[Old(Self,"Character","State","Aiming",true)
            Old(Self,"Character","State","Climbing",true)
            Old(Self,"Character","State","Grounded",true)
            Old(Self,"Character","State","InWater",true)
            Old(Self,"Character","State","Sliding",true)
            Old(Self,"Character","State","Sprinting",true)
            Old(Self,"Character","State","SuperSprinting",true)
            Old(Self,"Character","State","Swapping",true)
            Old(Self,"Character","State","Vaulting",true)
            Old(Self,"Character","State","Stance","Stand") -- "Crouch","Prone"]]

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
    local Args = {...} if Window.Flags["BB/Recoil/Enabled"] and Args[4] and Args[4].Gravity then
        Args[4].Gravity = Args[4].Gravity * (Window.Flags["BB/Recoil/BulletDrop"] / 100)
    end return Old(Self,unpack(Args))
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Items.GetAnimator,function(Old,Self,...)
    local Args = {...} if Args[1] then WeaponModel = Args[3] end
    return Old(Self,...)
end,true)

--[[Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Items.GetConfig,function(Old,Self,...)
    local Args = {Old(Self,...)} local Config = Args[1]
    if Window.Flags["BB/Recoil/Enabled"]
    and (Config and Config.Recoil and Config.Recoil.Default) then
        Config.Recoil.Default.WeaponScale = 
        Config.Recoil.Default.WeaponScale * (Window.Flags["BB/Recoil/WeaponScale"] / 100)

        Config.Recoil.Default.CameraScale = 
        Config.Recoil.Default.CameraScale * (Window.Flags["BB/Recoil/CameraScale"] / 100)

        Config.Recoil.Default.RecoilScale = 
        Config.Recoil.Default.RecoilScale * (Window.Flags["BB/Recoil/RecoilScale"] / 100)
    end return unpack(Args)
end)]]

local OldCamera = RenderStepConnections["Camera"]
RenderStepConnections["Camera"] = function(...)
    local Args = {OldCamera(...)}
    if Window.Flags["BB/ThirdPerson/Enabled"] then
        local LPCharacter = Characters[LocalPlayer]
        if LPCharacter and LPCharacter.Parent then
            Camera.CFrame = Camera.CFrame * CFrame.new(0,0,Window.Flags["BB/ThirdPerson/FOV"])
            return
        end
    end
    return unpack(Args)
end

local OldControl = HeartbeatConnections["Control"]
HeartbeatConnections["Control"] = function(...)
    local Args = {OldControl(...)}

    local LPCharacter = Characters[LocalPlayer]
    if LPCharacter and LPCharacter.Parent and LPCharacter.PrimaryPart then
        if Window.Flags["BB/Fly/Enabled"] and FlyPosition then
            FlyPosition += InputToVelocity() * Window.Flags["BB/Fly/Speed"]
            LPCharacter.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            LPCharacter.PrimaryPart.CFrame = CFrame.new(FlyPosition) * LPCharacter.PrimaryPart.CFrame.Rotation
        end
        if Window.Flags["BB/AntiAim/Enabled"] then
            local Roll = GetAntiAimValue(Window.Flags["BB/AntiAim/Roll/Value"],Window.Flags["BB/AntiAim/Roll/Mode"][1])
            local Yaw = GetAntiAimValue(Window.Flags["BB/AntiAim/Yaw/Value"],Window.Flags["BB/AntiAim/Yaw/Mode"][1])
            LPCharacter.PrimaryPart.CFrame *= CFrame.Angles(math.rad(180 * Roll),math.rad(180 * Yaw),0)
        end
    end

    return unpack(Args)
end

for Index,Event in pairs(Events) do
    if Event.Event == "Item_Throwable" then
        local OldCallback = Event.Callback
        Event.Callback = function(...) local Args = {...}
            Parvus.Utilities.Misc:NewThreadLoop(0,function()
                if Args[2].Parent == nil then return "break" end
                if GrenadeHitbox then
                    Args[2].PrimaryPart.Position = Hitbox[3].Position
                    --print("Grenade Teleported")
                end
            end) return OldCallback(...)
        end
    end
end

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

Parvus.Utilities.Misc:NewThreadLoop(0.25,function()
    local Weapon,Config = GetEquippedWeapon()
    if Weapon and Config then
        if Config.Projectile and Config.Projectile.GravityCorrection then
            GravityCorrection = Config.Projectile.GravityCorrection
        end
        if Window.Flags["BB/FireMode/Enabled"]
        and (Config.FireModeList and Config.FireModes) then
            Config.FireModes = {Auto = {FireRate = Config.FireModes[Config.FireModeList[1]].FireRate}}
            Config.FireModeList = {"Auto"}
        end
        if Window.Flags["BB/Recoil/Enabled"] and
        (Config.Recoil and Config.Recoil.Default) then
            Config.Recoil.Default.WeaponScale = 
            Config.Recoil.Default.WeaponScale * (Window.Flags["BB/Recoil/WeaponScale"] / 100)

            Config.Recoil.Default.CameraScale = 
            Config.Recoil.Default.CameraScale * (Window.Flags["BB/Recoil/CameraScale"] / 100)

            Config.Recoil.Default.RecoilScale = 
            Config.Recoil.Default.RecoilScale * (Window.Flags["BB/Recoil/RecoilScale"] / 100)
        end
    end
end)
Parvus.Utilities.Misc:NewThreadLoop(0.025,function()
    CustomizeWeapon(
        Window.Flags["BB/WC/Enabled"],
        Window.Flags["BB/WC/Texture"],
        Window.Flags["BB/WC/Color"],
        Window.Flags["BB/WC/Reflectance"],
        Window.Flags["BB/WC/Material"][1]
    )
    CustomizeArms(
        Window.Flags["BB/AC/Enabled"],
        Window.Flags["BB/AC/Texture"],
        Window.Flags["BB/AC/Color"],
        Window.Flags["BB/AC/Reflectance"],
        Window.Flags["BB/AC/Material"][1]
    )
    if Window.Flags["BB/ThirdPerson/Enabled"] then
        CustomizeCharacter(
            Window.Flags["BB/CC/Enabled"],
            Window.Flags["BB/CC/Texture"],
            Window.Flags["BB/CC/Color"],
            Window.Flags["BB/CC/Reflectance"],
            Window.Flags["BB/CC/Material"][1]
        )
    end
end)
--[[Parvus.Utilities.Misc:NewThreadLoop(0,function()
    PlayerFly(
        Window.Flags["BB/Fly/Enabled"],
        Window.Flags["BB/Fly/Speed"]
    )
end)]]
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    AutoshootHitbox = GetClosestAllFOV(
        Window.Flags["BB/Autoshoot/Enabled"],
        Window.Flags["BB/Autoshoot/BodyParts"],
        Window.Flags["BB/Autoshoot/WallCheck"],
        Window.Flags["BB/Autoshoot/DistanceCheck"],
        Window.Flags["BB/Autoshoot/Distance"]
    )
    GrenadeHitbox = GetClosestAllFOV(
        Window.Flags["BB/Autoshoot/TeleGrenade"],
        Window.Flags["BB/Autoshoot/BodyParts"]
    )
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    Autoshoot(AutoshootHitbox,
        Window.Flags["BB/Autoshoot/FireRate"]
    )
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    AutoGrenade(Window.Flags["BB/Autoshoot/AutoGrenade"])
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    task.wait(Window.Flags["BB/AntiAim/RefreshRate"])
    JitterValue = JitterValue == -1 and 1 or -1
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
            while task.wait(0) do
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
        repeat task.wait(0) until Child.PrimaryPart
        Child.PrimaryPart.CanCollide = not Window.Flags["BB/NoClip"]
        FlyPosition = Child.PrimaryPart.Position
        --[[if Window.Flags["BB/Fly/Enabled"] then
            BodyVelocity.Parent = Child.PrimaryPart
        end]]

        if Window.Flags["BB/ThirdPerson/Enabled"] then
            task.spawn(function()
                local LPCharacter = Characters[LocalPlayer]
                if not LPCharacter then return end

                if Window.Flags["BB/ThirdPerson/Outfit"] then
                    if not CharacterHandlers[LPCharacter] then
                        SetIdentity(2)
                        HandleCharacter(LPCharacter,LocalPlayer)
                    end
                end task.wait(0.5)

                for Index,Value in pairs(LPCharacter:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = 0
                    end
                end
            end)
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
