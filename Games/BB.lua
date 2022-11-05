local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeamService = game:GetService("Teams")

if game.PlaceVersion > 1317 then
    local Loaded,PromptLib = false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
    PromptLib("Unsupported game version","You are at risk of getting autoban\nAre you sure you want to load Parvus?",{
        {Text = "Yes",LayoutOrder = 0,Primary = false,Callback = function() Loaded = true end},
        {Text = "No",LayoutOrder = 0,Primary = true,Callback = function() end}
    }) repeat task.wait(1) until Loaded
end

local LocalPlayer = PlayerService.LocalPlayer
local Aimbot,SilentAim,Trigger,GunModel,
PredictedVelocity,PredictedGravity,
GravityCorrection,Tortoiseshell
= false,nil,nil,nil,1600,150,2,
require(ReplicatedStorage.TS)

repeat task.wait() until not LocalPlayer.PlayerGui:FindFirstChild("LoadingGui").Enabled
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Tortoiseshell = require(ReplicatedStorage.TS)

local BanCommands = {
    "GetUpdate","SetUpdate","Invoke",
    "GetSetting","FireProjectile"
}

local Window = Parvus.Utilities.UI:Window({
    Name = "🎃 Parvus Hub — "..Parvus.Game,
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
            AimbotSection:Slider({Name = "Distance",Flag = "Aimbot/Distance",Min = 25,Max = 1000,Value = 250,Unit = "meters"})
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
            SilentAimSection:Toggle({Name = "AutoShoot",Flag = "BadBusiness/AutoShoot",Value = false})
            SilentAimSection:Toggle({Name = "AutoShoot 360 Mode",Flag = "BadBusiness/AutoShoot/AllFOV",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FOV",Flag = "SilentAim/DynamicFOV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100})
            SilentAimSection:Slider({Name = "Distance",Flag = "SilentAim/Distance",Min = 25,Max = 1000,Value = 1000,Unit = "meters"})
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
            TriggerSection:Slider({Name = "Distance",Flag = "Trigger/Distance",Min = 25,Max = 1000,Value = 250,Unit = "meters"})
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
            GlobalSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 250,Unit = "meters"})
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
        local HeadSection = VisualsTab:Section({Name = "Head Circles",Side = "Right"}) do
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
            WCSection:Toggle({Name = "Enabled",Flag = "BadBusiness/WeaponCustom/Enabled",Value = false})
            WCSection:Toggle({Name = "Hide Textures",Flag = "BadBusiness/WeaponCustom/Texture",Value = true})
            WCSection:Colorpicker({Name = "Color",Flag = "BadBusiness/WeaponCustom/Color",Value = {1,0.75,1,0.5,true}})
            WCSection:Slider({Name = "Reflectance",Flag = "BadBusiness/WeaponCustom/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            WCSection:Dropdown({Name = "Material",Flag = "BadBusiness/WeaponCustom/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local WMSection = MiscTab:Section({Name = "Weapon Modification",Side = "Left"}) do
            WMSection:Toggle({Name = "Enabled",Flag = "BadBusiness/WeaponMod/Enabled",Value = false})
            WMSection:Slider({Name = "Weapon Shake",Flag = "BadBusiness/WeaponMod/WeaponScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Camera Shake",Flag = "BadBusiness/WeaponMod/CameraScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Recoil Scale",Flag = "BadBusiness/WeaponMod/RecoilScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Bullet Drop",Flag = "BadBusiness/WeaponMod/BulletDrop",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Label({Text = "Respawn to make it work"})
        end
        local ACSection = MiscTab:Section({Name = "Arms Customization",Side = "Right"}) do
            ACSection:Toggle({Name = "Enabled",Flag = "BadBusiness/ArmsCustom/Enabled",Value = false})
            ACSection:Toggle({Name = "Hide Textures",Flag = "BadBusiness/ArmsCustom/Texture",Value = true})
            ACSection:Colorpicker({Name = "Color",Flag = "BadBusiness/ArmsCustom/Color",Value = {1,0,1,1,false}})
            ACSection:Slider({Name = "Reflectance",Flag = "BadBusiness/ArmsCustom/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            ACSection:Dropdown({Name = "Material",Flag = "BadBusiness/ArmsCustom/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local FlySection = MiscTab:Section({Name = "Fly",Side = "Right"}) do
            FlySection:Toggle({Name = "Enabled",Flag = "BadBusiness/Fly/Enabled",Value = false})
            :Keybind({Flag = "BadBusiness/Fly/Keybind"})
            FlySection:Slider({Name = "Speed",Flag = "BadBusiness/Fly/Speed",Min = 10,Max = 100,Value = 100})
            FlySection:Toggle({Name = "No Clip",Flag = "BadBusiness/Fly/NoClip",Value = false})
        end
        local AASection = MiscTab:Section({Name = "Anti-Aim",Side = "Right"}) do
            AASection:Toggle({Name = "Enabled",Flag = "BadBusiness/AntiAim/Enabled",Value = false})
            :Keybind({Flag = "BadBusiness/AntiAim/Keybind"})
            AASection:Slider({Name = "Pitch",Flag = "BadBusiness/AntiAim/Pitch",Min = -1.5,Max = 1.5,Precise = 2,Value = -1.5})
            AASection:Slider({Name = "Pitch Random",Flag = "BadBusiness/AntiAim/PitchRandom",Min = 0,Max = 1.5,Precise = 2,Value = 0})
            AASection:Toggle({Name = "Lean Random",Flag = "BadBusiness/AntiAim/LeanRandom",Value = true})
        end
        --[[local MiscSection = MiscTab:Section({Name = "Misc",Side = "Left"}) do
            MiscSection:Toggle({Name = "Anti-Kick",Flag = "BadBusiness/AntiKick",Value = false})
        end]]
    end
    local SettingsTab = Window:Tab({Name = "Settings"}) do
        local MenuSection = SettingsTab:Section({Name = "Menu",Side = "Left"}) do
            MenuSection:Toggle({Name = "Enabled",IgnoreFlag = true,Flag = "UI/Toggle",
            Value = Window.Enabled,Callback = function(Bool) Window:Toggle(Bool) end})
            :Keybind({Value = "RightShift",Flag = "UI/Keybind",DoNotClear = true})
            MenuSection:Toggle({Name = "Open On Load",Flag = "UI/OOL",Value = true})
            MenuSection:Toggle({Name = "Blur Gameplay",Flag = "UI/Blur",Value = false,
            Callback = function() Window:Toggle(Window.Enabled) end})
            MenuSection:Toggle({Name = "Watermark",Flag = "UI/Watermark",Value = true,
            Callback = function(Bool) Window.Watermark:Toggle(Bool) end})
            MenuSection:Toggle({Name = "Custom Mouse",Flag = "Mouse/Enabled",Value = false})
            MenuSection:Colorpicker({Name = "Color",Flag = "UI/Color",Value = {0.0836667,1,1,0,false},
            Callback = function(HSVAR,Color) Window:SetColor(Color) end})
        end
        SettingsTab:AddConfigSection("Left")
        SettingsTab:Button({Name = "Rejoin",Side = "Left",
        Callback = Parvus.Utilities.Misc.ReJoin})
        SettingsTab:Button({Name = "Server Hop",Side = "Left",
        Callback = Parvus.Utilities.Misc.ServerHop})
        SettingsTab:Button({Name = "Join Discord Server",Side = "Left",
        Callback = Parvus.Utilities.Misc.JoinDiscord})
        :ToolTip("Join for support, updates and more!")
        local BackgroundSection = SettingsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Dropdown({Name = "Image",Flag = "Background/Image",List = {
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
                end},
                {Name = "Halloween",Mode = "Button",Value = true,Callback = function()
                    Window.Background.Image = "rbxassetid://11113209821"
                    Window.Flags["Background/CustomImage"] = ""
                end},
            }})
            BackgroundSection:Textbox({Name = "Custom Image",Flag = "Background/CustomImage",Placeholder = "rbxassetid://ImageId",
            Callback = function(String) if string.gsub(String," ","") ~= "" then Window.Background.Image = String end end})
            BackgroundSection:Colorpicker({Name = "Color",Flag = "Background/Color",Value = {0.0836667,1,1,0,false},
            Callback = function(HSVAR,Color) Window.Background.ImageColor3 = Color Window.Background.ImageTransparency = HSVAR[4] end})
            BackgroundSection:Slider({Name = "Tile Offset",Flag = "Background/Offset",Min = 74, Max = 296,Value = 74,
            Callback = function(Number) Window.Background.TileSize = UDim2.new(0,Number,0,Number) end})
        end
        local CrosshairSection = SettingsTab:Section({Name = "Custom Crosshair",Side = "Right"}) do
            CrosshairSection:Toggle({Name = "Enabled",Flag = "Mouse/Crosshair/Enabled",Value = false})
            CrosshairSection:Colorpicker({Name = "Color",Flag = "Mouse/Crosshair/Color",Value = {1,1,1,0,false}})
            CrosshairSection:Slider({Name = "Size",Flag = "Mouse/Crosshair/Size",Min = 0,Max = 20,Value = 4})
            CrosshairSection:Slider({Name = "Gap",Flag = "Mouse/Crosshair/Gap",Min = 0,Max = 10,Value = 2})
        end
        local CreditsSection = SettingsTab:Section({Name = "Credits",Side = "Right"}) do
            CreditsSection:Label({Text = "This script was made by AlexR32#0157"})
            CreditsSection:Divider()
            CreditsSection:Label({Text = "Thanks to Jan for awesome Background Patterns"})
            CreditsSection:Label({Text = "Thanks to Infinite Yield Team for Server Hop and Rejoin"})
            CreditsSection:Label({Text = "Thanks to Blissful for Offscreen Arrows"})
            CreditsSection:Label({Text = "Thanks to coasts for Universal ESP"})
            CreditsSection:Label({Text = "Thanks to el3tric for Bracket V2"})
            CreditsSection:Label({Text = "❤️ ❤️ ❤️ ❤️"})
        end
    end
end

Window:LoadDefaultConfig()
Window:SetValue("Background/Offset",296)
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
        if type(Args[1]) == "string" and table.find(BanCommands,Args[1]) then
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

local Events = getupvalue(Tortoiseshell.Network.BindEvent,1)
local WeaponConfigs = getupvalue(Tortoiseshell.Items.GetConfig,3)
local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter,1)
--local ControllersFolder = getupvalue(Tortoiseshell.Items.GetController,2)
local Projectiles = getupvalue(Tortoiseshell.Projectiles.InitProjectile,1)

local Notify = Instance.new("BindableEvent")
Notify.Event:Connect(function(Text)
    Parvus.Utilities.UI:Notification2(Text)
end)

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.zero
BodyVelocity.MaxForce = Vector3.zero

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
RaycastParams.IgnoreWater = true

local function Raycast(Origin,Direction,Table)
    RaycastParams.FilterDescendantsInstances = Table
    return Workspace:Raycast(Origin,Direction,RaycastParams)
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
    return Distance * 0.28 <= MaxDistance
end
local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return not Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,
    {Workspace.Geometry,Workspace.Terrain})
end
local function FindGunModel()
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
local function GetHitboxPart(Hitbox,Name)
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

local function ToggleShoot(Toggle)
    if Toggle then
        Tortoiseshell.Input:AutomateBegan("Shoot")
    else
        Tortoiseshell.Input:AutomateEnded("Shoot")
    end
end

local function FixUnit(Vector)
    if Vector.Magnitude == 0 then
    return Vector3.zero end
    return Vector.Unit
end
local function FlatCameraVector()
    local Camera = Workspace.CurrentCamera
    return Camera.CFrame.LookVector * Vector3.new(1,0,1),
        Camera.CFrame.RightVector * Vector3.new(1,0,1)
end
local function InputToVelocity() local Velocities,LookVector,RightVector = {},FlatCameraVector()
    Velocities[1] = UserInputService:IsKeyDown(Enum.KeyCode.W) and LookVector or Vector3.zero
    Velocities[2] = UserInputService:IsKeyDown(Enum.KeyCode.S) and -LookVector or Vector3.zero
    Velocities[3] = UserInputService:IsKeyDown(Enum.KeyCode.A) and -RightVector or Vector3.zero
    Velocities[4] = UserInputService:IsKeyDown(Enum.KeyCode.D) and RightVector or Vector3.zero
    Velocities[5] = UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0,1,0) or Vector3.zero
    Velocities[6] = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Vector3.new(0,-1,0) or Vector3.zero
    return FixUnit(Velocities[1] + Velocities[2] + Velocities[3] + Velocities[4] + Velocities[5] + Velocities[6])
end

local function PlayerFly(Config)
    local Character = Characters[LocalPlayer]
    if not Character then return end
    
    if not Config.Enabled then BodyVelocity.MaxForce = Vector3.zero
        if Character and Character.PrimaryPart
        and not Character.PrimaryPart.CanCollide then
            Character.PrimaryPart.CanCollide = true
        end return
    end
    if Character and Character.PrimaryPart then
        BodyVelocity.Parent = Character.PrimaryPart
        BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.Velocity = InputToVelocity() * Config.Speed
        Character.PrimaryPart.CanCollide = not Window.Flags["BadBusiness/Fly/NoClip"]
    end
end

local function CustomizeGun(Config)
    if not Config.Enabled then return end
    if not GunModel then return end
    for Index,Instance in pairs(GunModel.Body:GetDescendants()) do
        if Config.HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Config.Color[6]
            Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
            Instance.Reflectance = Config.Reflectance
            Instance.Material = Config.Material
        end
    end
end
local function CustomizeArms(Config)
    if not Config.Enabled then return end
    for Index,Instance in pairs(Workspace.Arms:GetDescendants()) do
        if Config.HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Config.Color[6]
            Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
            Instance.Reflectance = Config.Reflectance
            Instance.Material = Config.Material
        end
    end
end

local function ComputeProjectiles(Config,Hitbox)
    local Projectiles = {}
    local Camera = Workspace.CurrentCamera
    local RayResult =  Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,{Hitbox})

    --[[for Index = 1,Config.Projectile.Amount do
        table.insert(Projectiles,{
            (Tortoiseshell.Input.Reticle:LookVector(Config.Projectile.Choke)
            + Vector3.new(0,Config.Projectile.GravityCorrection/1000,0)).Unit,ID
        })
    end]]
    for Index = 1,Config.Projectile.Amount do
        table.insert(Projectiles,{
            (Hitbox.Position - Camera.CFrame.Position).Unit,
            Tortoiseshell.Projectiles:GetID()
        })
    end

    if not RayResult then return end
    return Camera.CFrame.Position,Projectiles,
    RayResult.Position,RayResult.Normal
end
local function AutoShoot(Hitbox,Enabled)
    if not Enabled or not Hitbox then return end
    local Weapon,Config = GetEquippedWeapon()

    if Weapon and Config then
        --[[if Config.Controller == "Melee" then
            local Camera = Workspace.CurrentCamera
            if (Hitbox[3].Position - Camera.CFrame.Position).Magnitude < 22.5 then
                local Health = Hitbox[3].Parent.Parent.Health.Value
                
                local Backstab = Hitbox[3].CFrame * CFrame.new(0,0,-Config.Melee.Range)
                local RayResult =  Raycast(Backstab.Position,
                Hitbox[3].Position - Backstab.Position,{Hitbox[3]})

                Tortoiseshell.Network:Fire("Item_Melee","StabBegin",Weapon)
                task.wait(Config.Melee.Delay + Config.Melee.Time)
                Tortoiseshell.Network:Fire("Item_Melee","Stab",Weapon,Hitbox[3],
                RayResult.Position,Backstab.LookVector * (Config.Melee.Range + 1))

                if Health ~= Hitbox[3].Parent.Parent.Health.Value then
                    Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3],RayResult.Position)
                end
            end return
        end]]
        
        local State = Weapon.State
        local Ammo = State.Ammo.Server
        local FireMode = State.FireMode.Server
        local Reloading = State.Reloading.Server

        local OldAmmo = Ammo.Value
        if Ammo.Value > 0 then
            local FireModeFromList = Config.FireModeList[FireMode.Value]
            local CurrentFireMode = Config.FireModes[FireModeFromList]
            local CameraPosition,ShootProjectiles,RayPosition,
            RayNormal = ComputeProjectiles(Config,Hitbox[3])
            if not CameraPosition then return end
            Tortoiseshell.Network:Fire("Item_Paintball","Shoot",
            Weapon,CameraPosition,ShootProjectiles)

            task.wait((RayPosition - CameraPosition).Magnitude
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
                    Title = "Autoshoot | Hit " .. Hitbox[1].Name .. " | Remaining Ammo: " .. Ammo.Value,
                    Color = Color3.new(1,0.5,0.25),Duration = 3
                })
            end
        else
            if Reloading.Value then
                local ReloadTime = Config.Magazine.ReloadTime
                local Milliseconds = (ReloadTime % 1) * 10
                local Seconds = ReloadTime % 60

                Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
                Parvus.Utilities.UI:Notification2({
                    Title = "Autoshoot | Reloading | Approx Time: " .. string.format("%d sec. %d msec.",Seconds,Milliseconds),
                    Color = Color3.new(1,0.25,0.25),Duration = 3
                }) task.wait(ReloadTime)
            end
        end
    end
end

local function GetHitbox(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    
    local FieldOfView,ClosestHitbox = Config.DynamicFOV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView or Config.FieldOfView

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        local Character,Shield = GetCharacterInfo(Player,Config.Shield)
        if Player ~= LocalPlayer and Character and Shield and TeamCheck(Player) then
            for Index,BodyPart in pairs(Config.BodyParts) do
                local Hitbox = GetHitboxPart(Character,BodyPart) if not Hitbox then continue end
                local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                if WallCheck(Config.WallCheck,Hitbox)
                and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and Magnitude < FieldOfView then
                        FieldOfView,ClosestHitbox = Magnitude,{Player,Character,Hitbox,Distance,ScreenPosition}
                    end
                end
            end
        end
    end

    return ClosestHitbox
end
local function GetHitboxWithPrediction(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera

    local FieldOfView,ClosestHitbox = Config.DynamicFOV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView or Config.FieldOfView

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        local Character,Shield = GetCharacterInfo(Player,false)
        if Player ~= LocalPlayer and Character and Shield and TeamCheck(Player) then
            for Index,BodyPart in pairs(Config.BodyParts) do
                local Hitbox = GetHitboxPart(Character,BodyPart) if not Hitbox then continue end
                local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                if WallCheck(Config.WallCheck,Hitbox)
                and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                    local PredictionGravity = Vector3.new(0,(Distance + GravityCorrection / 1000) / PredictedGravity,0)
                    local PredictionVelocity = (Hitbox.AssemblyLinearVelocity * Distance) / PredictedVelocity
                    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(Config.Prediction
                    and Hitbox.Position + PredictionGravity + PredictionVelocity or Hitbox.Position)

                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and Magnitude < FieldOfView then
                        FieldOfView,ClosestHitbox = Magnitude,{Player,Character,Hitbox,Distance,ScreenPosition}
                    end
                end
            end
        end
    end

    return ClosestHitbox
end
local function GetHitboxAllFOV(Config)
    local Camera = Workspace.CurrentCamera
    local InTheRange,ClosestHitbox = math.huge,nil

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        local Character,Shield = GetCharacterInfo(Player,true)
        if Player ~= LocalPlayer and Character and Shield and TeamCheck(Player) then
            for Index,BodyPart in pairs(Config.BodyParts) do
                local Hitbox = GetHitboxPart(Character,BodyPart) if not Hitbox then continue end
                local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                if WallCheck(Config.WallCheck,Hitbox)
                and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                    local Magnitude = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                    if Magnitude < InTheRange then
                        InTheRange,ClosestHitbox = Magnitude,{Player,Character,Hitbox,Distance}
                    end
                end
            end
        end
    end

    return ClosestHitbox
end

local function AimAt(Hitbox,Config)
    if not Hitbox then return end
    local Camera = Workspace.CurrentCamera
    local Mouse = UserInputService:GetMouseLocation()

    local PredictionGravity = Vector3.new(0,(Hitbox[4] + GravityCorrection / 1000) / PredictedGravity,0)
    local PredictionVelocity = (Hitbox[3].AssemblyLinearVelocity * Hitbox[4]) / PredictedVelocity
    local HitboxOnScreen = Camera:WorldToViewportPoint(Config.Prediction
    and Hitbox[3].Position + PredictionGravity + PredictionVelocity or Hitbox[3].Position)

    mousemoverel(
        (HitboxOnScreen.X - Mouse.X) * Config.Sensitivity,
        (HitboxOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Network.Fire,function(Self,...)
    local Args = {...} if SilentAim and not Window.Flags["BadBusiness/AutoShoot"] then
        if Args[2] == "__Hit" and math.random(0,100)
        <= Window.Flags["SilentAim/HitChance"] then
            Args[4] = SilentAim[3].Position
            Args[5] = SilentAim[3]
            Args[7] = SilentAim[2]
            Tortoiseshell.UI.Events.Hitmarker:Fire(
            SilentAim[3],SilentAim[3].Position)
        end
    end
    if Window.Flags["BadBusiness/AntiAim/Enabled"] and Args[3] == "Look" then
        if Window.Flags["BadBusiness/AntiAim/LeanRandom"] then
            Tortoiseshell.Network:Fire("Character","State","Lean",math.random(-1,1))
        end
        Args[4] = Window.Flags["BadBusiness/AntiAim/Pitch"] < 0
        and Window.Flags["BadBusiness/AntiAim/Pitch"] + Random.new():NextNumber(0,
        Window.Flags["BadBusiness/AntiAim/PitchRandom"])
        or Window.Flags["BadBusiness/AntiAim/Pitch"] - Random.new():NextNumber(0,
        Window.Flags["BadBusiness/AntiAim/PitchRandom"])
    end return Self,unpack(Args)
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Projectiles.InitProjectile,function(Self,...)
    local Args = {...} if Args[4] == LocalPlayer then PredictedVelocity = Projectiles[Args[1]].Speed
        PredictedGravity = Projectiles[Args[1]].Gravity ~= 0 and Projectiles[Args[1]].Gravity or 1
    end return Self,...
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Raycast.CastGeometryAndEnemies,function(Self,...)
    local Args = {...} if Window.Flags["BadBusiness/WeaponMod/Enabled"] and Args[4] and Args[4].Gravity then
        Args[4].Gravity = Args[4].Gravity * (Window.Flags["BadBusiness/WeaponMod/BulletDrop"] / 100)
    end return Self,unpack(Args)
end)

OldGetAnimator = hookfunction(Tortoiseshell.Items.GetAnimator,function(Self,...)
    local Args = {...} if Args[1] then GunModel = Args[3] end
    return OldGetAnimator(Self,...)
end)

Parvus.Utilities.Misc:FixUpValue(Tortoiseshell.Items.GetConfig,function(...)
    local Args = {...} local Config = Args[1]
    if Window.Flags["BadBusiness/WeaponMod/Enabled"]
    and (Config.Recoil and Config.Recoil.Default) then
        Config.Recoil.Default.WeaponScale = 
        Config.Recoil.Default.WeaponScale * (Window.Flags["BadBusiness/WeaponMod/WeaponScale"] / 100)

        Config.Recoil.Default.CameraScale = 
        Config.Recoil.Default.CameraScale * (Window.Flags["BadBusiness/WeaponMod/CameraScale"] / 100)

        Config.Recoil.Default.RecoilScale = 
        Config.Recoil.Default.RecoilScale * (Window.Flags["BadBusiness/WeaponMod/RecoilScale"] / 100)
    end return unpack(Args)
end,true)

-- Patched
--[[for Index,Event in pairs(Events) do
    if Event.Event == "Votekick" then
        Parvus.Utilities.Misc:FixUpValue(Event.Callback,function(...)
            local Args = {...} if Args[1] == "Message" then
                if string.find(Args[2],LocalPlayer.Name)
                and Window.Flags["BadBusiness/AntiKick"] then
                    Notify:Fire({
                        Title = "Anti-Kick | Rejoining in 5 secs",
                        Color = Color3.new(0.5,1,0.5),Duration = 5
                    }) task.wait(5)
                    Parvus.Utilities.Misc:ReJoin()
                end
            end return ...
        end) break
    end
end]]

RunService.Heartbeat:Connect(function()
    SilentAim = GetHitbox({
        Enabled = Window.Flags["SilentAim/Enabled"],
        WallCheck = Window.Flags["SilentAim/WallCheck"],
        DistanceCheck = Window.Flags["SilentAim/DistanceCheck"],
        DynamicFOV = Window.Flags["SilentAim/DynamicFOV"],
        FieldOfView = Window.Flags["SilentAim/FieldOfView"],
        Distance = Window.Flags["SilentAim/Distance"],
        BodyParts = Window.Flags["SilentAim/BodyParts"],
        Shield = true
    })
    if Aimbot then AimAt(
        GetHitbox({
            Enabled = Window.Flags["Aimbot/Enabled"],
            WallCheck = Window.Flags["Aimbot/WallCheck"],
            DistanceCheck = Window.Flags["Aimbot/DistanceCheck"],
            DynamicFOV = Window.Flags["Aimbot/DynamicFOV"],
            FieldOfView = Window.Flags["Aimbot/FieldOfView"],
            Distance = Window.Flags["Aimbot/Distance"],
            BodyParts = Window.Flags["Aimbot/BodyParts"]
        }),{
            Prediction = Window.Flags["Aimbot/Prediction"],
            Sensitivity = Window.Flags["Aimbot/Smoothness"] / 100
        })
    end

    PlayerFly({
        Enabled = Window.Flags["BadBusiness/Fly/Enabled"],
        Speed = Window.Flags["BadBusiness/Fly/Speed"]
    })
    CustomizeGun({
        Enabled = Window.Flags["BadBusiness/WeaponCustom/Enabled"],
        HideTextures = Window.Flags["BadBusiness/WeaponCustom/Texture"],
        Color = Window.Flags["BadBusiness/WeaponCustom/Color"],
        Reflectance = Window.Flags["BadBusiness/WeaponCustom/Reflectance"],
        Material = Window.Flags["BadBusiness/WeaponCustom/Material"][1]
    })
    CustomizeArms({
        Enabled = Window.Flags["BadBusiness/ArmsCustom/Enabled"],
        HideTextures = Window.Flags["BadBusiness/ArmsCustom/Texture"],
        Color = Window.Flags["BadBusiness/ArmsCustom/Color"],
        Reflectance = Window.Flags["BadBusiness/ArmsCustom/Reflectance"],
        Material = Window.Flags["BadBusiness/ArmsCustom/Material"][1]
    })
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if not Window.Flags["BadBusiness/AutoShoot"] then return end
    AutoShoot(Window.Flags["BadBusiness/AutoShoot/AllFOV"]
    and GetHitboxAllFOV({
        WallCheck = Window.Flags["SilentAim/WallCheck"],
        DistanceCheck = Window.Flags["SilentAim/DistanceCheck"],
        Distance = Window.Flags["SilentAim/Distance"],
        BodyParts = Window.Flags["SilentAim/BodyParts"]
    }) or SilentAim,Window.Flags["BadBusiness/AutoShoot"])
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if not Trigger then return end
    local TriggerHitbox = GetHitboxWithPrediction({
        Enabled = Window.Flags["Trigger/Enabled"],
        Prediction = Window.Flags["Trigger/Prediction"],
        WallCheck = Window.Flags["Trigger/WallCheck"],
        DistanceCheck = Window.Flags["Trigger/DistanceCheck"],
        DynamicFOV = Window.Flags["Trigger/DynamicFOV"],
        FieldOfView = Window.Flags["Trigger/FieldOfView"],
        Distance = Window.Flags["Trigger/Distance"],
        BodyParts = Window.Flags["Trigger/BodyParts"]
    })

    if TriggerHitbox then ToggleShoot(true)
        task.wait(Window.Flags["Trigger/Delay"])
        if Window.Flags["Trigger/HoldMode"] then
            while task.wait() do
                TriggerHitbox = GetHitboxWithPrediction({
                    Enabled = Window.Flags["Trigger/Enabled"],
                    Prediction = Window.Flags["Trigger/Prediction"],
                    WallCheck = Window.Flags["Trigger/WallCheck"],
                    DistanceCheck = Window.Flags["Trigger/DistanceCheck"],
                    DynamicFOV = Window.Flags["Trigger/DynamicFOV"],
                    FieldOfView = Window.Flags["Trigger/FieldOfView"],
                    Distance = Window.Flags["Trigger/Distance"],
                    BodyParts = Window.Flags["Trigger/BodyParts"]
                }) if not TriggerHitbox or not Trigger then break end
            end
        end ToggleShoot(false)
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
