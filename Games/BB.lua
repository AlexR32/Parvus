local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = PlayerService.LocalPlayer
local Ping = Stats.Network.ServerStatsItem["Data Ping"]
local Aimbot,SilentAim,Trigger,
PredictedVelocity,PredictedGravity,
GravityCorrection,Tortoiseshell
= false,nil,nil,1600,150,2,
require(ReplicatedStorage.TS)

repeat task.wait() until not
LocalPlayer.PlayerGui:FindFirstChild("LoadingGui")

--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Tortoiseshell = require(ReplicatedStorage.TS)

local BanReasons,BanCommands = {
    "Unsafe function",
    "Camera object", -- Crash
    "Geometry deleted", -- Crash
    "Deleted remote", -- Crash
    "Looking hard",
    "Unbound gloop", -- Crash
    "_G", -- Crash
    "Hitbox extender",
    "Alternate mode",
    "Shooting hard",
    "Fallback config",
    "Int check",
    "Thawed",
    "Coregui instance",
    "Floating",
    "Root"
},{
    "GetUpdate",
    "SetUpdate",
    "GetSetting",
    "FireProjectile",
    "Invoke"
}

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Current,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = false})
            AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/WallCheck",Value = false})
            AimbotSection:Toggle({Name = "Dynamic FoV",Flag = "Aimbot/DynamicFoV",Value = false})
            AimbotSection:Keybind({Name = "Keybind",Flag = "Aimbot/Keybind",Value = "MouseButton2",Mouse = true,
            Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})
            AimbotSection:Slider({Name = "Smoothness",Flag = "Aimbot/Smoothness",Min = 0,Max = 100,Value = 25,Unit = "%"})
            AimbotSection:Slider({Name = "Field of View",Flag = "Aimbot/FieldOfView",Min = 0,Max = 500,Value = 100})
            AimbotSection:Dropdown({Name = "Priority",Flag = "Aimbot/Priority",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle",Value = true},
                {Name = "Chest",Mode = "Toggle",Value = true},
                {Name = "Abdomen",Mode = "Toggle",Value = true},
                {Name = "Hips",Mode = "Toggle",Value = true}
            }})
        end
        local AFoVSection = AimAssistTab:Section({Name = "Aimbot FoV Circle",Side = "Left"}) do
            AFoVSection:Toggle({Name = "Enabled",Flag = "Aimbot/Circle/Enabled",Value = true})
            AFoVSection:Toggle({Name = "Filled",Flag = "Aimbot/Circle/Filled",Value = false})
            AFoVSection:Colorpicker({Name = "Color",Flag = "Aimbot/Circle/Color",Value = {1,0.75,1,0.5,false}})
            AFoVSection:Slider({Name = "NumSides",Flag = "Aimbot/Circle/NumSides",Min = 3,Max = 100,Value = 100})
            AFoVSection:Slider({Name = "Thickness",Flag = "Aimbot/Circle/Thickness",Min = 1,Max = 10,Value = 1})
        end
        local TFoVSection = AimAssistTab:Section({Name = "Trigger FoV Circle",Side = "Left"}) do
            TFoVSection:Toggle({Name = "Enabled",Flag = "Trigger/Circle/Enabled",Value = true})
            TFoVSection:Toggle({Name = "Filled",Flag = "Trigger/Circle/Filled",Value = false})
            TFoVSection:Colorpicker({Name = "Color",Flag = "Trigger/Circle/Color",Value = {1,0.25,1,0.5,true}})
            TFoVSection:Slider({Name = "NumSides",Flag = "Trigger/Circle/NumSides",Min = 3,Max = 100,Value = 100})
            TFoVSection:Slider({Name = "Thickness",Flag = "Trigger/Circle/Thickness",Min = 1,Max = 10,Value = 1})
        end
        local SilentAimSection = AimAssistTab:Section({Name = "Silent Aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false})
            :Keybind({Mouse = true,Flag = "SilentAim/Keybind"})
            SilentAimSection:Toggle({Name = "AutoShoot",Flag = "BadBusiness/AutoShoot",Value = false})
            SilentAimSection:Toggle({Name = "AutoShoot 360 Mode",Flag = "BadBusiness/AutoShoot/AllFoV",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FoV",Flag = "SilentAim/DynamicFoV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 50})
            SilentAimSection:Dropdown({Name = "Priority",Flag = "SilentAim/Priority",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle"},
                {Name = "Chest",Mode = "Toggle"},
                {Name = "Abdomen",Mode = "Toggle"},
                {Name = "Hips",Mode = "Toggle"}
            }})
        end
        local SAFoVSection = AimAssistTab:Section({Name = "Silent Aim FoV Circle",Side = "Right"}) do
            SAFoVSection:Toggle({Name = "Enabled",Flag = "SilentAim/Circle/Enabled",Value = true})
            SAFoVSection:Toggle({Name = "Filled",Flag = "SilentAim/Circle/Filled",Value = false})
            SAFoVSection:Colorpicker({Name = "Color",Flag = "SilentAim/Circle/Color",Value = {0.66666668653488,0.75,1,0.5,false}})
            SAFoVSection:Slider({Name = "NumSides",Flag = "SilentAim/Circle/NumSides",Min = 3,Max = 100,Value = 100})
            SAFoVSection:Slider({Name = "Thickness",Flag = "SilentAim/Circle/Thickness",Min = 1,Max = 10,Value = 1})
        end
        local TriggerSection = AimAssistTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Enabled",Value = false})
            TriggerSection:Toggle({Name = "Prediction",Flag = "Trigger/Prediction",Value = false})
            TriggerSection:Toggle({Name = "Visibility Check",Flag = "Trigger/WallCheck",Value = true})
            TriggerSection:Toggle({Name = "Dynamic FoV",Flag = "Trigger/DynamicFoV",Value = false})
            TriggerSection:Keybind({Name = "Keybind",Flag = "Trigger/Keybind",Value = "MouseButton2",Mouse = true,
            Callback = function(Key,KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})
            TriggerSection:Slider({Name = "Field of View",Flag = "Trigger/FieldOfView",Min = 0,Max = 500,Value = 10})
            TriggerSection:Slider({Name = "Delay",Flag = "Trigger/Delay",Min = 0,Max = 1,Precise = 2,Value = 0.15})
            TriggerSection:Toggle({Name = "Hold Mode",Flag = "Trigger/HoldMode",Value = false})
            TriggerSection:Dropdown({Name = "Priority",Flag = "Trigger/Priority",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Neck",Mode = "Toggle",Value = true},
                {Name = "Chest",Mode = "Toggle",Value = true},
                {Name = "Abdomen",Mode = "Toggle",Value = true},
                {Name = "Hips",Mode = "Toggle",Value = true}
            }})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.33333334326744,0.75,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.75,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = true})
            GlobalSection:Toggle({Name = "Use Team Color",Flag = "ESP/Player/TeamColor",Value = false})
        end
        local BoxSection = VisualsTab:Section({Name = "Boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Box/Enabled",Value = false})
            BoxSection:Toggle({Name = "Filled",Flag = "ESP/Player/Box/Filled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/Player/Box/Outline",Value = true})
            BoxSection:Slider({Name = "Thickness",Flag = "ESP/Player/Box/Thickness",Min = 1,Max = 10,Value = 1})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Box/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            BoxSection:Divider({Text = "Text / Info"})
            BoxSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Text/Enabled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/Player/Text/Outline",Value = true})
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Text/Autoscale",Value = true})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/Player/Text/Font",List = {
                {Name = "UI",Mode = "Button"},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button",Value = true}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/Player/Text/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Text/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/Player/Arrow/Filled",Value = true})
            OoVSection:Slider({Name = "Width",Flag = "ESP/Player/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Height",Flag = "ESP/Player/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/Player/Arrow/Distance",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/Player/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/Player/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HeadSection = VisualsTab:Section({Name = "Head Circles",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Head/Enabled",Value = false})
            HeadSection:Toggle({Name = "Filled",Flag = "ESP/Player/Head/Filled",Value = true})
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
    local GameTab = Window:Tab({Name = Parvus.Current}) do
        local WCSection = GameTab:Section({Name = "Weapon Customization",Side = "Left"}) do
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
        local WMSection = GameTab:Section({Name = "Weapon Modification",Side = "Left"}) do
            WMSection:Toggle({Name = "Enabled",Flag = "BadBusiness/WeaponMod/Enabled",Value = false})
            WMSection:Slider({Name = "Weapon Shake",Flag = "BadBusiness/WeaponMod/WeaponScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Camera Shake",Flag = "BadBusiness/WeaponMod/CameraScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Recoil Scale",Flag = "BadBusiness/WeaponMod/RecoilScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Bullet Drop",Flag = "BadBusiness/WeaponMod/BulletDrop",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Label({Text = "Respawn to make it work"})
        end
        local ACSection = GameTab:Section({Name = "Arms Customization",Side = "Right"}) do
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
        local FlySection = GameTab:Section({Name = "Fly",Side = "Right"}) do
            FlySection:Toggle({Name = "Enabled",Flag = "BadBusiness/Fly/Enabled",Value = false})
            :Keybind({Flag = "BadBusiness/Fly/Keybind"})
            FlySection:Slider({Name = "Speed",Flag = "BadBusiness/Fly/Speed",Min = 10,Max = 100,Value = 100})
            FlySection:Toggle({Name = "No Clip",Flag = "BadBusiness/Fly/NoClip",Value = false})
        end
        local AASection = GameTab:Section({Name = "Anti-Aim",Side = "Right"}) do
            AASection:Toggle({Name = "Enabled",Flag = "BadBusiness/AntiAim/Enabled",Value = false})
            :Keybind({Flag = "BadBusiness/AntiAim/Keybind"})
            AASection:Slider({Name = "Pitch",Flag = "BadBusiness/AntiAim/Pitch",Min = -1.5,Max = 1.5,Precise = 2,Value = -1.5})
            AASection:Slider({Name = "Pitch Random",Flag = "BadBusiness/AntiAim/PitchRandom",Min = 0,Max = 1.5,Precise = 2,Value = 0})
            AASection:Toggle({Name = "Lean Random",Flag = "BadBusiness/AntiAim/LeanRandom",Value = true})
        end
        local MiscSection = GameTab:Section({Name = "Misc",Side = "Right"}) do
            MiscSection:Toggle({Name = "Anti-Kick",Flag = "BadBusiness/AntiKick",Value = false})
        end
    end
    local SettingsTab = Window:Tab({Name = "Settings"}) do
        local MenuSection = SettingsTab:Section({Name = "Menu",Side = "Left"}) do
            MenuSection:Toggle({Name = "Enabled",Flag = "UI/Toggle",IgnoreFlag = true,Value = Window.Enabled,
            Callback = function(Bool) Window:Toggle(Bool) end}):Keybind({Value = "RightShift",Flag = "UI/Keybind",DoNotClear = true})
            MenuSection:Toggle({Name = "Open On Load",Flag = "UI/OOL",Value = true})
            MenuSection:Toggle({Name = "Blur Gameplay",Flag = "UI/Blur",Value = false,
            Callback = function() Window:Toggle(Window.Enabled) end})
            MenuSection:Toggle({Name = "Watermark",Flag = "UI/Watermark",Value = true,
            Callback = function(Bool) Window.Watermark:Toggle(Bool) end})
            MenuSection:Toggle({Name = "Custom Mouse",Flag = "Mouse/Enabled",Value = false})
            MenuSection:Colorpicker({Name = "Color",Flag = "UI/Color",Value = {1,0.25,1,0,true},
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
                {Name = "Floral",Mode = "Button",Value = true,Callback = function()
                    Window.Background.Image = "rbxassetid://5553946656"
                    Window.Flags["Background/CustomImage"] = ""
                end}
            }})
            BackgroundSection:Textbox({Name = "Custom Image",Flag = "Background/CustomImage",Placeholder = "ImageId",
            Callback = function(String)
                if string.gsub(String," ","") ~= "" then
                    Window.Background.Image = "rbxassetid://" .. String
                end
            end})
            BackgroundSection:Colorpicker({Name = "Color",Flag = "Background/Color",Value = {1,1,0,0,false},
            Callback = function(HSVAR,Color)
                Window.Background.ImageColor3 = Color
                Window.Background.ImageTransparency = HSVAR[4]
            end})
            BackgroundSection:Slider({Name = "Tile Offset",Flag = "Background/Offset",Min = 74, Max = 296,Value = 74,
            Callback = function(Number)
                Window.Background.TileSize = UDim2.new(0,Number,0,Number)
            end})
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
Window:SetValue("UI/Toggle",
Window.Flags["UI/OOL"])

local GetFPS = Parvus.Utilities.Misc:SetupFPS()
--repeat task.wait() until Parvus.Utilities.Drawing.Cursor
Parvus.Utilities.Drawing:Cursor(Window.Flags)
Parvus.Utilities.Drawing:FoVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FoVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FoVCircle("SilentAim",Window.Flags)

do --[[local OldRandom
OldRandom = hookfunction(math.random, function(...)
    if checkcaller() then return OldRandom(...) end
    local args = {...}
    if args[1] == 1 and args[2] <= 1000 then
        print(args[1],args[2])
        return math.huge
    end
    return OldRandom(...)
end)]]
local OldTaskSpawn
OldTaskSpawn = hookfunction(getrenv().task.spawn, function(...)
    if checkcaller() then return OldTaskSpawn(...) end
    local Args = {...}
    if type(Args[1]) == "function" then
        local Constants = getconstants(Args[1])
        if table.find(Constants,"print")
        and table.find(Constants,"ouch") then
            return
        end
    end
    return OldTaskSpawn(...)
end)
-- Thanks to Kiriot22
local Message
local SetIdentity = syn and syn.set_thread_identity or setidentity
task.spawn(function()
    SetIdentity(2)
    local Success,Error = pcall(getrenv().PluginManager)
    Message = Error
end)
local OldPluginManager
OldPluginManager = hookfunction(getrenv().PluginManager, function()
    return error(Message)
end) end


local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method,Args = getnamecallmethod(),{...}
    if Method == "FireServer" then
        if typeof(Args[1]) == "string" and table.find(BanCommands,Args[1]) then
            for Index, Reason in pairs(BanReasons) do
                if typeof(Args[2]) == "string" and string.match(Args[2],Reason) then
                    return
                end
            end
        end
    end
    return OldNamecall(Self, ...)
end)

--This thing laggy as hell, dont use in your scripts
--[[local DefaultRecoil = {}
for Index,Config in pairs(getgc(true)) do
    if type(Config) == "table"
    and rawget(Config,"Recoil")
    and type(Config.Recoil) == "table"
    and Config.Recoil.Default then
        DefaultRecoil[Config.Model] = {
            WeaponScale = Config.Recoil.Default.WeaponScale,
            CameraScale = Config.Recoil.Default.CameraScale,
            RecoilScale = Config.Recoil.Default.RecoilScale
        }
    end
end
local function UpdateRecoil()
    for Index,Config in pairs(getgc(true)) do
        if type(Config) == "table"
        and rawget(Config,"Controller")
        and rawget(Config,"Model") then
            if Config.Recoil and Config.Recoil.Default and
                DefaultRecoil[Config.Model] then

                local Modified = Parvus.Config.GameFeatures.WeaponModification
                local Default = DefaultRecoil[Config.Model]

                Config.Recoil.Default.WeaponScale = Modified.Enabled
                and Default.WeaponScale * Modified.WeaponScale
                or Default.WeaponScale

                Config.Recoil.Default.CameraScale = Modified.Enabled
                and Default.CameraScale * Modified.CameraScale
                or Default.CameraScale

                Config.Recoil.Default.RecoilScale = Modified.Enabled
                and Default.RecoilScale * Modified.RecoilScale
                or Default.RecoilScale
            end
        end
    end
end]]

local Events = getupvalue(Tortoiseshell.Network.BindEvent,1)
local WeaponConfigs = getupvalue(Tortoiseshell.Items.GetConfig,3)
--local ControllersFolder = getupvalue(Tortoiseshell.Items.GetController,2)
local Projectiles = getupvalue(Tortoiseshell.Projectiles.InitProjectile,1)

local Notify = Instance.new("BindableEvent")
Notify.Event:Connect(function(Text)
    Parvus.Utilities.UI:Notification2(Text)
end)

local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.zero
BodyVelocity.MaxForce = Vector3.zero


local function Raycast(Origin,Direction,Table)
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    RaycastParams.FilterDescendantsInstances = Table
    RaycastParams.IgnoreWater = true
    return Workspace:Raycast(Origin,Direction,RaycastParams)
end

local function TeamCheck(Player)
    return LocalPlayer.Team ~= Player.Team
    or tostring(Player.Team) == "FFA"
end
local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return not Raycast(
        Camera.CFrame.Position,
        Hitbox.Position - Camera.CFrame.Position,
        {Workspace.Geometry,Workspace.Terrain}
    )
end
local function FindGunModel()
    for Index,Instance in pairs(Workspace:GetChildren()) do
        if Instance:FindFirstChild("AnimationController") then
            return Instance
        end
    end
end
local function GetCharacterInfo(Player,Shield)
    local Character = Player.Character
    if not Character then return end
    local Root = Character.PrimaryPart
    if not Root then return end
    local ShieldEmitter = Root:FindFirstChild("ShieldEmitter")
    if not ShieldEmitter then return end

    if Shield then
        return Character:FindFirstChild("Hitbox"),
        not ShieldEmitter.Enabled
    else
        return Character:FindFirstChild("Hitbox"),true
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
--[[local function GetCurrentConfig()
    local Weapon,Config = GetEquippedWeapon()
    if Weapon and Config then
        local Controller = require(ControllersFolder[Config.Controller])
        local Proto = debug.getproto(Controller.Create,1,true)
        return getupvalue(Proto[1],1), getupvalue(Proto[2],1)
    end
end]]

local function ToggleShoot(Toggle)
    if Toggle then
        Tortoiseshell.Input:AutomateBegan("Shoot")
    else
        Tortoiseshell.Input:AutomateEnded("Shoot")
    end
end

local function InputToVelocity()
    local Camera = Workspace.CurrentCamera
    local Velocities = {}

    Velocities[1] = UserInputService:IsKeyDown(Enum.KeyCode.W)
    and Camera.CFrame.LookVector or Vector3.zero
    Velocities[2] = UserInputService:IsKeyDown(Enum.KeyCode.S)
    and -Camera.CFrame.LookVector or Vector3.zero
    Velocities[3] = UserInputService:IsKeyDown(Enum.KeyCode.A)
    and -Camera.CFrame.RightVector or Vector3.zero
    Velocities[4] = UserInputService:IsKeyDown(Enum.KeyCode.D)
    and Camera.CFrame.RightVector or Vector3.zero
    Velocities[5] = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    and Vector3.new(0,1,0) or Vector3.zero
    Velocities[6] = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    and Vector3.new(0,-1,0) or Vector3.zero
    
    return (
        Velocities[1] +
        Velocities[2] +
        Velocities[3] +
        Velocities[4] +
        Velocities[5] +
        Velocities[6]
    )
end
local function PlayerFly(Config)
    if not Config.Enabled then
        BodyVelocity.MaxForce = Vector3.zero
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            LocalPlayer.Character.PrimaryPart.CanCollide = true
        end
        return
    end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        BodyVelocity.Parent = LocalPlayer.Character.PrimaryPart
        BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.Velocity = InputToVelocity() * Config.Speed
        LocalPlayer.Character.PrimaryPart.CanCollide
        = not Window.Flags["BadBusiness/Fly/NoClip"]
    end
end

local function CustomizeGun(Config)
    if not Config.Enabled then return end
    local GunModel = FindGunModel()
    if GunModel then
        for Index,Instance in pairs(GunModel.Body:GetDescendants()) do
            if Config.HideTextures and Instance:IsA("Texture") then
                Instance.Transparency = 1
            elseif Instance:IsA("BasePart") and Instance.Transparency < 1
            and Instance.Reflectance < 1 then
                Instance.Color = Parvus.Utilities.UI:TableToColor(Config.Color)
                Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
                Instance.Reflectance = Config.Reflectance
                Instance.Material = Config.Material
            end
        end
    end
end
local function CustomizeArms(Config)
    if not Config.Enabled then return end
    for Index,Instance in pairs(Workspace.Arms:GetDescendants()) do
        if Config.HideTextures
        and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") 
        and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Parvus.Utilities.UI:TableToColor(Config.Color)
            Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
            Instance.Reflectance = Config.Reflectance
            Instance.Material = Config.Material
        end
    end
end

local function ComputeProjectiles(Config,Hitbox)
    local Projectiles = {}
    local Camera = Workspace.CurrentCamera
    local ID = Tortoiseshell.Projectiles:GetID()
    local RayResult =  Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,{Hitbox})

    for Index = 1,Config.Projectile.Amount do
        table.insert(Projectiles,{
            (Tortoiseshell.Input.Reticle:LookVector(Config.Projectile.Choke)
            + Vector3.new(0,Config.Projectile.GravityCorrection/1000,0)).Unit,ID
        })
    end
    
    if RayResult then
        return Projectiles,RayResult.Position,RayResult.Normal,ID
    else
        return Projectiles,Hitbox.Position,Vector3.one,ID
    end
end
local function AutoShoot(Hitbox,Enabled)
    if not Enabled then return end
    local Weapon,Config = GetEquippedWeapon()

    if Weapon and Config then
        local State = Weapon:FindFirstChild("State")
        local Ammo = State and State:FindFirstChild("Ammo")
        local FireMode = State and State:FindFirstChild("FireMode")
        local Reloading = State and State:FindFirstChild("Reloading")

        local OldAmmo = Ammo and Ammo.Server.Value
        if Ammo and Ammo.Server.Value > 0 then if not Hitbox then return end
            local FireModeFromList = Config.FireModeList[FireMode.Server.Value]
            local CurrentFireMode = Config.FireModes[FireModeFromList]
            local Projectiles,RayPosition,RayNormal,ID = ComputeProjectiles(Config,Hitbox[2])
            
            Tortoiseshell.Network:Fire("Item_Paintball","Shoot",Weapon,
            Tortoiseshell.Input.Reticle:GetPosition(),Projectiles)

            Tortoiseshell.Network:Fire("Projectiles","__Hit",ID,
            RayPosition,Hitbox[2],RayNormal,Hitbox[1])

            task.wait(60/CurrentFireMode.FireRate)
            if (OldAmmo - Ammo.Server.Value) >= 1 then
                Parvus.Utilities.UI:Notification2({
                    Title = "Autoshoot | Hit " .. Hitbox[1].Name .. " | Remaining Ammo: " .. Ammo.Server.Value,
                    Color = Color3.new(1,0.5,0.25),
                    Duration = 3
                })
            end
        else
            if Reloading and not Reloading.Server.Value then
                local ReloadTime = Config.Magazine.ReloadTime
                local Milliseconds = (ReloadTime % 1) * 10
                local Seconds = ReloadTime % 60

                Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
                Parvus.Utilities.UI:Notification2({
                    Title = "Autoshoot | Reloading | Approx Time: " .. string.format("%d sec. %d msec.",Seconds,Milliseconds),
                    Color = Color3.new(1,0.25,0.25),
                    Duration = 3
                }) task.wait(ReloadTime)
            end
        end
    end
end

local function GetHitbox(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    
    local FieldOfView,ClosestHitbox = Config.DynamicFoV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView
    or Config.FieldOfView,nil

    for Index, Player in pairs(PlayerService:GetPlayers()) do
        local Character,Shield = GetCharacterInfo(Player,Config.Shield)
        if Player ~= LocalPlayer and Shield and TeamCheck(Player) then
            for Index, HumanoidPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                if Hitbox then
                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox) then
                        FieldOfView = Magnitude
                        ClosestHitbox = {Player,Hitbox}
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

    local FieldOfView,ClosestHitbox = Config.DynamicFoV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView
    or Config.FieldOfView,nil

    for Index, Player in pairs(PlayerService:GetPlayers()) do
        local Character,Shield = GetCharacterInfo(Player,true)
        if Player ~= LocalPlayer and Shield and TeamCheck(Player) then
            for Index, HumanoidPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                if Hitbox then
                    local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                    local HitboxGravityCorrection = Vector3.new(0,HitboxDistance / PredictedGravity,0) / GravityCorrection
                    local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction
                    and Hitbox.Position + HitboxGravityCorrection + HitboxVelocityCorrection or Hitbox.Position)

                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox) then
                        FieldOfView = Magnitude
                        ClosestHitbox = Hitbox
                    end
                end
            end
        end
    end

    return ClosestHitbox
end
local function GetHitboxAllFoV(Config)
    local Camera = Workspace.CurrentCamera
    local Distance,ClosestHitbox = math.huge,nil
    for Index, Player in pairs(PlayerService:GetPlayers()) do
        local Character,Shield = GetCharacterInfo(Player,true)
        if Player ~= LocalPlayer and Shield and TeamCheck(Player) then
            for Index, HumanoidPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                if Hitbox then
                    local Magnitude = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                    if Magnitude < Distance and WallCheck(Config.WallCheck,Hitbox) then
                        Distance,ClosestHitbox = Magnitude,{Player,Hitbox}
                    end
                end
            end
        end
    end

    return ClosestHitbox
end

local function AimAt(Hitbox,Config)
    if not Hitbox then return end
    Hitbox = Hitbox[2]
    local Camera = Workspace.CurrentCamera
    local Mouse = UserInputService:GetMouseLocation()

    local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
    local HitboxGravityCorrection = Vector3.new(0,(HitboxDistance + (GravityCorrection / 1000)) / PredictedGravity,0)
    local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

    local HitboxOnScreen = Camera:WorldToViewportPoint(Config.Prediction
    and Hitbox.Position + HitboxGravityCorrection + HitboxVelocityCorrection or Hitbox.Position)
    mousemoverel(
        (HitboxOnScreen.X - Mouse.X) * Config.Sensitivity,
        (HitboxOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

setreadonly(Tortoiseshell.Network,false)
local OldNetworkFire = Tortoiseshell.Network.Fire
Tortoiseshell.Network.Fire = function(Self,...) local Args = {...}
    if SilentAim and not Window.Flags["BadBusiness/AutoShoot"] then
        if Args[2] == "__Hit" and math.random(0,100)
        <= Window.Flags["SilentAim/HitChance"] then
            Args[4] = SilentAim[2].Position
            Args[5] = SilentAim[2]
            Args[7] = SilentAim[1]
        end
    end
    if Window.Flags["BadBusiness/AntiAim/Enabled"] and Args[3] == "Look" then
        if Window.Flags["BadBusiness/AntiAim/LeanRandom"] then
            Tortoiseshell.Network:Fire("Character","State","Lean",math.random(-1,1))
        end
        Args[4] = Window.Flags["BadBusiness/AntiAim/Pitch"] < -0
        and Window.Flags["BadBusiness/AntiAim/Pitch"] + Random.new():NextNumber(0,
        Window.Flags["BadBusiness/AntiAim/PitchRandom"])
        or Window.Flags["BadBusiness/AntiAim/Pitch"] - Random.new():NextNumber(0,
        Window.Flags["BadBusiness/AntiAim/PitchRandom"])
    end return OldNetworkFire(Self,unpack(Args))
end setreadonly(Tortoiseshell.Network,true)

setreadonly(Tortoiseshell.Projectiles,false)
local OldInitProjectile = Tortoiseshell.Projectiles.InitProjectile
Tortoiseshell.Projectiles.InitProjectile = function(Self,...) local Args = {...}
    if Args[4] == LocalPlayer then PredictedVelocity = Projectiles[Args[1]].Speed
        PredictedGravity = Projectiles[Args[1]].Gravity ~= 0 and Projectiles[Args[1]].Gravity or 1
    end return OldInitProjectile(Self,...)
end setreadonly(Tortoiseshell.Projectiles,true)

local OldGetConfig = Tortoiseshell.Items.GetConfig
Tortoiseshell.Items.GetConfig = function(Self,...) local Config = OldGetConfig(Self,...)
    if Window.Flags["BadBusiness/WeaponMod/Enabled"] and Config.Recoil and Config.Recoil.Default then
        Config.Recoil.Default.WeaponScale = 
        Config.Recoil.Default.WeaponScale * (Window.Flags["BadBusiness/WeaponMod/WeaponScale"] / 100)

        Config.Recoil.Default.CameraScale = 
        Config.Recoil.Default.CameraScale * (Window.Flags["BadBusiness/WeaponMod/CameraScale"] / 100)

        Config.Recoil.Default.RecoilScale = 
        Config.Recoil.Default.RecoilScale * (Window.Flags["BadBusiness/WeaponMod/RecoilScale"] / 100)
    end return Config
end

setreadonly(Tortoiseshell.Raycast,false)
local OldCastGeometryAndEnemies = Tortoiseshell.Raycast.CastGeometryAndEnemies
Tortoiseshell.Raycast.CastGeometryAndEnemies = function(Self,...) local Args = {...}
    if Window.Flags["BadBusiness/WeaponMod/Enabled"] and Args[4] and Args[4].Gravity then
        Args[4].Gravity = Args[4].Gravity * (Window.Flags["BadBusiness/WeaponMod/BulletDrop"] / 100)
    end return OldCastGeometryAndEnemies(Self,unpack(Args))
end setreadonly(Tortoiseshell.Raycast,true)

for Index,Event in pairs(Events) do
    if Event.Event == "Votekick" then
        local OldCallback = Event.Callback
        Event.Callback = function(...) local Args = {...}
            if Args[1] == "Message" then
                if string.find(Args[2],LocalPlayer.Name)
                and Window.Flags["BadBusiness/AntiKick"] then
                    Notify:Fire({
                        Title = "Anti-Kick | Rejoining in 10 secs",
                        Color = Color3.new(0.5,1,0.5),
                        Duration = 10
                    })
                    task.wait(10)
                    Parvus.Utilities.Misc:ReJoin()
                end
            end
            return OldCallback(...)
        end
        break
    end
end

RunService.Heartbeat:Connect(function()
    SilentAim = GetHitbox({
        Enabled = Window.Flags["SilentAim/Enabled"],
        WallCheck = Window.Flags["SilentAim/WallCheck"],
        DynamicFoV = Window.Flags["SilentAim/DynamicFoV"],
        FieldOfView = Window.Flags["SilentAim/FieldOfView"],
        Priority = Window.Flags["SilentAim/Priority"],
        Shield = true
    })
    if Aimbot then AimAt(
        GetHitbox({
            Enabled = Window.Flags["Aimbot/Enabled"],
            WallCheck = Window.Flags["Aimbot/WallCheck"],
            DynamicFoV = Window.Flags["Aimbot/DynamicFoV"],
            FieldOfView = Window.Flags["Aimbot/FieldOfView"],
            Priority = Window.Flags["Aimbot/Priority"]
        }),{
            Prediction = Window.Flags["Aimbot/Prediction"],
            Sensitivity = Window.Flags["Aimbot/Smoothness"] / 100
        })
    end

    if Window.Flags["UI/Watermark"] then
        Window.Watermark:SetTitle(string.format(
            "Parvus Hub    %s    %i FPS    %i MS",
            os.date("%X"),GetFPS(),math.round(Ping:GetValue())
        ))
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
    AutoShoot(Window.Flags["BadBusiness/AutoShoot/AllFoV"]
    and GetHitboxAllFoV({
        WallCheck = Window.Flags["Aimbot/WallCheck"],
        Priority = Window.Flags["Aimbot/Priority"]
    }) or SilentAim,Window.Flags["BadBusiness/AutoShoot"])
end)

Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if Trigger then
        local TriggerHB = GetHitboxWithPrediction({
            Enabled = Window.Flags["Trigger/Enabled"],
            WallCheck = Window.Flags["Trigger/WallCheck"],
            Prediction = Window.Flags["Trigger/Prediction"],
            DynamicFoV = Window.Flags["Trigger/DynamicFoV"],
            FieldOfView = Window.Flags["Trigger/FieldOfView"],
            Priority = Window.Flags["Trigger/Priority"]
        })

        if TriggerHB then
            task.wait(Window.Flags["Trigger/Delay"])
            ToggleShoot(true)
            if Window.Flags["Trigger/HoldMode"] then
                while task.wait() do
                    TriggerHB = GetHitboxWithPrediction({
                        Enabled = Window.Flags["Trigger/Enabled"],
                        WallCheck = Window.Flags["Trigger/WallCheck"],
                        Prediction = Window.Flags["Trigger/Prediction"],
                        DynamicFoV = Window.Flags["Trigger/DynamicFoV"],
                        FieldOfView = Window.Flags["Trigger/FieldOfView"],
                        Priority = Window.Flags["Trigger/Priority"]
                    })
                    if not TriggerHB then
                        ToggleShoot(false)
                        break
                    end
                end
            end
            ToggleShoot(false)
        end
    end
end)

--[[local function ShallowCopy(Table)
    local TableCopy
    if type(Table) == "table" then
        TableCopy = {}
        for Index,Value in pairs(Table) do
            if typeof(Value) == "table" then
                TableCopy[Index] = ShallowCopy(Value)
            else
                TableCopy[Index] = Value
            end
        end
    else
        TableCopy = Table
    end
    return TableCopy
end
local OldConfigs = {}
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if Window.Flags["BadBusiness/WeaponMod/Enabled"] then
        local First,Second = GetCurrentConfig()
        if not First and not Second then return end
        local Configs = {First = First, Second = Second}

        OldConfigs.First = ShallowCopy(First)
        OldConfigs.Second = ShallowCopy(Second)

        for Index,Config in pairs(Configs) do
            if Config.Recoil and Config.Recoil.Default then
                local OldConfig = OldConfigs[Index]
                Config.Recoil.Default.WeaponScale = 
                OldConfig.Recoil.Default.WeaponScale * (Window.Flags["BadBusiness/WeaponMod/WeaponScale"] / 100)

                Config.Recoil.Default.CameraScale = 
                OldConfig.Recoil.Default.CameraScale * (Window.Flags["BadBusiness/WeaponMod/CameraScale"] / 100)

                Config.Recoil.Default.RecoilScale = 
                OldConfig.Recoil.Default.RecoilScale * (Window.Flags["BadBusiness/WeaponMod/RecoilScale"] / 100)
            end
        end
    end
end)]]
Parvus.Utilities.Misc:NewThreadLoop(1,function()
    local Weapon,Config = GetEquippedWeapon()
    if Weapon and Config then
        if Config.Projectile and Config.Projectile.GravityCorrection then
            GravityCorrection = Config.Projectile.GravityCorrection
        end
    end
end)

for Index,Player in pairs(PlayerService:GetPlayers()) do
    if Player ~= LocalPlayer then
        Parvus.Utilities.Drawing:AddESP(Player,"Player","ESP/Player",Window.Flags)
    end
end
PlayerService.PlayerAdded:Connect(function(Player)
    Parvus.Utilities.Drawing:AddESP(Player,"Player","ESP/Player",Window.Flags)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    Parvus.Utilities.Drawing:RemoveESP(Player)
end)
