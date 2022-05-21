local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

repeat task.wait() until Workspace:FindFirstChild("Bots")
local Events = ReplicatedStorage:WaitForChild("Events")
local RemoteEvent = Events:WaitForChild("RemoteEvent")

local LocalPlayer = PlayerService.LocalPlayer
local Ping = Stats.Network.ServerStatsItem["Data Ping"]
local Aimbot,SilentAim,NPCFolder,GroundTip,AircraftTip,PredictedVelocity
= false,nil,Workspace.Bots,nil,nil,1000

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
                {Name = "HumanoidRootPart",Mode = "Toggle",Value = true}
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
        local MiscSection = AimAssistTab:Section({Name = "Misc",Side = "Left"}) do
            MiscSection:Dropdown({Name = "Target Mode",Flag = "BRM5/TargetMode",List = {
                {Name = "Player",Mode = "Button"},
                {Name = "NPC",Mode = "Button",Value = true}
            }})
        end
        local SilentAimSection = AimAssistTab:Section({Name = "Silent Aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false})
            :Keybind({Mouse = true,Flag = "SilentAim/Keybind"})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FoV",Flag = "SilentAim/DynamicFoV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 50})
            SilentAimSection:Dropdown({Name = "Priority",Flag = "SilentAim/Priority",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "HumanoidRootPart",Mode = "Toggle"}
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
            TriggerSection:Toggle({Name = "Visibility Check",Flag = "Trigger/WallCheck",Value = true})
            TriggerSection:Toggle({Name = "Dynamic FoV",Flag = "Trigger/DynamicFoV",Value = false})
            TriggerSection:Slider({Name = "Field of View",Flag = "Trigger/FieldOfView",Min = 0,Max = 500,Value = 10})
            TriggerSection:Slider({Name = "Delay",Flag = "Trigger/Delay",Min = 0,Max = 1,Precise = 2,Value = 0.15})
            TriggerSection:Slider({Name = "Hold Time",Flag = "Trigger/HoldTime",Min = 0,Max = 1,Precise = 2,Value = 0})
            TriggerSection:Dropdown({Name = "Priority",Flag = "Trigger/Priority",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "HumanoidRootPart",Mode = "Toggle",Value = true}
            }})
            TriggerSection:Divider({Text = "Prediction"})
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Prediction/Enabled",Value = false})
            TriggerSection:Slider({Name = "Velocity",Flag = "Trigger/Prediction/Velocity",Min = 100,Max = 5000,Value = 1600})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.33333334326744,0.75,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.75,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = false})
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
        --[[local LightingSection = VisualsTab:Section({Name = "Lighting",Side = "Right"}) do
            LightingSection:Toggle({Name = "Enabled",Flag = "Lighting/Enabled",Value = false})
            LightingSection:Colorpicker({Name = "Ambient",Flag = "Lighting/Ambient",Value = {1,0,0,0,false}})
            LightingSection:Slider({Name = "Brightness",Flag = "Lighting/Brightness",Min = 0,Max = 10,Precise = 2,Value = 3})
            LightingSection:Slider({Name = "ClockTime",Flag = "Lighting/ClockTime",Min = 0,Max = 24,Precise = 2,Value = 14.5})
            LightingSection:Colorpicker({Name = "ColorShift_Bottom",Flag = "Lighting/ColorShift_Bottom",Value = {1,0,0,0,false}})
            LightingSection:Colorpicker({Name = "ColorShift_Top",Flag = "Lighting/ColorShift_Top",Value = {1,0,0,0,false}})
            LightingSection:Slider({Name = "EnvironmentDiffuseScale",Flag = "Lighting/EnvironmentDiffuseScale",Min = 0,Max = 1,Precise = 3,Value = 1})
            LightingSection:Slider({Name = "EnvironmentSpecularScale",Flag = "Lighting/EnvironmentSpecularScale",Min = 0,Max = 1,Precise = 3,Value = 1})
            LightingSection:Slider({Name = "ExposureCompensation",Flag = "Lighting/ExposureCompensation",Min = -3,Max = 3,Precise = 2,Value = 0})
            LightingSection:Colorpicker({Name = "FogColor",Flag = "Lighting/FogColor",Value = {1,0,1,0,false}})
            LightingSection:Slider({Name = "FogEnd",Flag = "Lighting/FogEnd",Min = 0,Max = 100000,Value = 100000})
            LightingSection:Slider({Name = "FogStart",Flag = "Lighting/FogStart",Min = 0,Max = 100000,Value = 0})
            LightingSection:Slider({Name = "GeographicLatitude",Flag = "Lighting/GeographicLatitude",Min = 0,Max = 360,Precise = 1,Value = 23.5})
            LightingSection:Toggle({Name = "GlobalShadows",Flag = "Lighting/GlobalShadows",Value = true})
            LightingSection:Colorpicker({Name = "OutdoorAmbient",Flag = "Lighting/OutdoorAmbient",Value = {1,0,0,0,false}})
            LightingSection:Slider({Name = "ShadowSoftness",Flag = "Lighting/ShadowSoftness",Min = 0,Max = 1,Precise = 2,Value = 1})
        end]]
    end
    local NPCVisualsTab = Window:Tab({Name = "NPC Visuals"}) do
        local GlobalSection = NPCVisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Civilian Color",Flag = "ESP/NPC/Ally",Value = {0.33333334326744,0.75,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/NPC/Enemy",Value = {1,0.75,1,0,false}})
            GlobalSection:Toggle({Name = "Hide Civilians",Flag = "ESP/NPC/TeamCheck",Value = true})
        end
        local BoxSection = NPCVisualsTab:Section({Name = "Boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Box/Enabled",Value = false})
            BoxSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Box/Filled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Box/Outline",Value = true})
            BoxSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Box/Thickness",Min = 1,Max = 10,Value = 1})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Box/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            BoxSection:Divider({Text = "Text / Info"})
            BoxSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Text/Enabled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Text/Outline",Value = true})
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/NPC/Text/Autoscale",Value = true})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/NPC/Text/Font",List = {
                {Name = "UI",Mode = "Button"},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button",Value = true}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/NPC/Text/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Text/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local OoVSection = NPCVisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Arrow/Filled",Value = true})
            OoVSection:Slider({Name = "Height",Flag = "ESP/NPC/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Width",Flag = "ESP/NPC/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/NPC/Arrow/Distance",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HeadSection = NPCVisualsTab:Section({Name = "Head Circles",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Head/Enabled",Value = false})
            HeadSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Head/Filled",Value = true})
            HeadSection:Toggle({Name = "Autoscale",Flag = "ESP/NPC/Head/Autoscale",Value = true})
            HeadSection:Slider({Name = "Radius",Flag = "ESP/NPC/Head/Radius",Min = 1,Max = 10,Value = 8})
            HeadSection:Slider({Name = "NumSides",Flag = "ESP/NPC/Head/NumSides",Min = 3,Max = 100,Value = 4})
            HeadSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Head/Thickness",Min = 1,Max = 10,Value = 1})
            HeadSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Head/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local TracerSection = NPCVisualsTab:Section({Name = "Tracers",Side = "Right"}) do
            TracerSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Tracer/Enabled",Value = false})
            TracerSection:Dropdown({Name = "Mode",Flag = "ESP/NPC/Tracer/Mode",List = {
                {Name = "From Bottom",Mode = "Button",Value = true},
                {Name = "From Mouse",Mode = "Button"}
            }})
            TracerSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Tracer/Thickness",Min = 1,Max = 10,Value = 1})
            TracerSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Tracer/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HighlightSection = NPCVisualsTab:Section({Name = "Highlights",Side = "Right"}) do
            HighlightSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Highlight/Enabled",Value = false})
            HighlightSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Highlight/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            HighlightSection:Colorpicker({Name = "Outline Color",Flag = "ESP/NPC/Highlight/OutlineColor",Value = {1,1,0,0.5,false}})
        end
    end
    local GameTab = Window:Tab({Name = Parvus.Current}) do
        local EnvSection = GameTab:Section({Name = "Environment"}) do
            EnvSection:Toggle({Name = "Enabled",Flag = "BRM5/Lighting/Enabled",Value = false})
            EnvSection:Toggle({Name = "Brightness",Flag = "BRM5/Lighting/Brightness",Value = false,Callback = function(Bool)
                Lighting.GlobalShadows = not Bool
            end})
            EnvSection:Slider({Name = "Clock Time",Flag = "BRM5/Lighting/Time",Min = 0,Max = 24,Value = 12})
            EnvSection:Slider({Name = "Fog Density",Flag = "BRM5/Lighting/Fog",Min = 0,Max = 1,Precise = 2,Value = 0.25})
        end
        local WeaponSection = GameTab:Section({Name = "Weapon"}) do
            WeaponSection:Toggle({Name = "Recoil",Flag = "BRM5/Recoil/Enabled",Value = false})
            WeaponSection:Slider({Name = "Recoil Percent",Flag = "BRM5/Recoil/Value",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WeaponSection:Toggle({Name = "Instant Hit",Flag = "BRM5/BulletDrop",Value = false})
            :ToolTip("silent aim works better with it")
            WeaponSection:Toggle({Name = "Unlock Firemodes",Flag = "BRM5/Firemodes",Value = false})
            :ToolTip("re-equip your weapon to make it work")
            WeaponSection:Toggle({Name = "Rapid Fire",Flag = "BRM5/RapidFire/Enabled",Value = false}):ToolTip("re-equip your weapon to disable")
            WeaponSection:Slider({Name = "Round Per Minute",Flag = "BRM5/RapidFire/Value",Min = 45,Max = 1000,Value = 1000})
        end
        local CharSection = GameTab:Section({Name = "Character"}) do
            CharSection:Toggle({Name = "No NVG Effect",Flag = "BRM5/DisableNVG",Value = false})
            CharSection:Toggle({Name = "No NVG Shape",Flag = "BRM5/NVGMode",Value = false})
            CharSection:Toggle({Name = "No Camera Bob",Flag = "BRM5/NoBob",Value = false})
            CharSection:Toggle({Name = "Speedhack",Flag = "BRM5/WalkSpeed/Enabled",Value = false}):Keybind({Flag = "BRM5/WalkSpeed/Keybind"})
            CharSection:Slider({Name = "Speed",Flag = "BRM5/WalkSpeed/Value",Min = 16,Max = 1000,Value = 120})
        end
        local VehSection = GameTab:Section({Name = "Vehicle"}) do
            VehSection:Toggle({Name = "Enabled",Flag = "BRM5/Vehicle/Enabled",Value = false})
            VehSection:Slider({Name = "Speed",Flag = "BRM5/Vehicle/Speed",Min = 0,Max = 1000,Value = 100})
            VehSection:Slider({Name = "Acceleration",Flag = "BRM5/Vehicle/Acceleration",Min = 1,Max = 50,Value = 1})
            :ToolTip("lower = faster")
        end
        local HeliSection = GameTab:Section({Name = "Helicopter"}) do
            HeliSection:Toggle({Name = "Enabled",Flag = "BRM5/Helicopter/Enabled",Value = false})
            HeliSection:Slider({Name = "Speed",Flag = "BRM5/Helicopter/Speed",Min = 0,Max = 500,Value = 200})
        end
    end
    local SettingsTab = Window:Tab({Name = "Settings"}) do
        local MenuSection = SettingsTab:Section({Name = "Menu",Side = "Left"}) do
            local MenuToggle = MenuSection:Toggle({Name = "Enabled",IgnoreFlag = true,Value = Window.Enabled,
            Callback = function(Bool) 
                Window:Toggle(Bool)
            end}):Keybind({Value = "RightShift",Flag = "UI/Keybind",DoNotClear = true})
            MenuSection:Toggle({Name = "Watermark",Flag = "UI/Watermark",Value = true,
            Callback = function(Bool) 
                Window.Watermark:Toggle(Bool)
            end})
            MenuSection:Toggle({Name = "Custom Mouse",Flag = "Mouse/Enabled",Value = true})
            MenuSection:Colorpicker({Name = "Color",Flag = "UI/Color",Value = {1,0.25,1,0,true},
            Callback = function(HSVAR,Color)
                Window:SetColor(Color)
            end})
        end
        SettingsTab:AddConfigSection("Left")
        SettingsTab:Button({Name = "Rejoin",Side = "Left",
        Callback = function()
            if #PlayerService:GetPlayers() <= 1 then
                LocalPlayer:Kick("\nParvus Hub\nRejoining...")
                task.wait(0.5)
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            else
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end})
        SettingsTab:Button({Name = "Server Hop",Side = "Left",
        Callback = function()
            local Request = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local DataDecoded,Servers = HttpService:JSONDecode(Request).data,{}
            for Index,ServerData in ipairs(DataDecoded) do
                if type(ServerData) == "table" and ServerData.id ~= game.JobId then
                    table.insert(Servers,ServerData.id)
                end
            end
            if #Servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)])
            else
                Parvus.Utilities.UI:Notification({
                    Title = "Parvus Hub",
                    Description = "Couldn't find a server",
                    Duration = 5
                })
            end
        end})
        SettingsTab:Button({Name = "Join Discord Server",Side = "Left",Callback = function()
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
        end}):ToolTip("Join for support, updates and more!")
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
local GetFPS = Parvus.Utilities.SetupFPS()
Parvus.Utilities.Drawing:Cursor(Window.Flags)
Parvus.Utilities.Drawing:FoVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FoVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FoVCircle("SilentAim",Window.Flags)
--[[local DefaultLighting = {
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
}]]

local function WallCheck(Enabled,Hitbox,Character)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return not Camera:GetPartsObscuringTarget({Hitbox.Position},{
        LocalPlayer.Character,
        Character
    })[1]
end
local function GetHitbox(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera

    local FieldOfView,ClosestHitbox = Config.DynamicFoV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView
    or Config.FieldOfView,nil

    if Config.TargetMode == "NPC" then
        for Index, NPC in pairs(NPCFolder:GetChildren()) do
            local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
            local IsAlive = Humanoid and Humanoid.Health > 0
            if not NPC:FindFirstChildWhichIsA("ProximityPrompt",true) and IsAlive then
                for Index, HumanoidPart in pairs(Config.Priority) do
                    local Hitbox = NPC:FindFirstChild(HumanoidPart)
                    if Hitbox then
                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox,NPC) then
                            FieldOfView = Magnitude
                            ClosestHitbox = Hitbox
                        end
                    end
                end
            end
        end
    elseif Config.TargetMode == "Player" then
        for Index, Player in pairs(PlayerService:GetPlayers()) do
            local Character = Player.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local IsAlive = Humanoid and Humanoid.Health > 0
            if Player ~= LocalPlayer and IsAlive and LocalPlayer.Team ~= Player.Team then
                for Index, HumanoidPart in pairs(Config.Priority) do
                    local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                    if Hitbox then
                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox,Character) then
                            FieldOfView = Magnitude
                            ClosestHitbox = Hitbox
                        end
                    end
                end
            end
        end
    end

    return ClosestHitbox
end
local function Trigger(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera

    local FieldOfView,ClosestHitbox = Config.DynamicFoV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView
    or Config.FieldOfView,nil

    if Config.TargetMode == "NPC" then
        for Index, NPC in pairs(NPCFolder:GetChildren()) do
            local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
            local IsAlive = Humanoid and Humanoid.Health > 0
            if not NPC:FindFirstChildWhichIsA("ProximityPrompt",true) and IsAlive then
                for Index, HumanoidPart in pairs(Config.Priority) do
                    local Hitbox = NPC:FindFirstChild(HumanoidPart)
                    if Hitbox then
                        local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                        local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction
                        and Hitbox.Position + HitboxVelocityCorrection or Hitbox.Position)
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox,NPC) then
                            FieldOfView = Magnitude
                            ClosestHitbox = Hitbox
                        end
                    end
                end
            end
        end
    elseif Config.TargetMode == "Player" then
        for Index, Player in pairs(PlayerService:GetPlayers()) do
            local Character = Player.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local IsAlive = Humanoid and Humanoid.Health > 0
            if Player ~= LocalPlayer and IsAlive and TeamCheck(Config.TeamCheck,Player) then
                for Index, HumanoidPart in pairs(Config.Priority) do
                    local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                    if Hitbox then
                        local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                        local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction
                        and Hitbox.Position + HitboxVelocityCorrection or Hitbox.Position)
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox,Character) then
                            FieldOfView = Magnitude
                            ClosestHitbox = Hitbox
                        end
                    end
                end
            end
        end
    end

    if ClosestHitbox then
        task.wait(Config.Delay)
        mouse1press()
        task.wait(Config.HoldTime)
        mouse1release()
    end
end
local function AimAt(Hitbox,Config)
    if not Hitbox then return end
    local Camera = Workspace.CurrentCamera
    local Mouse = UserInputService:GetMouseLocation()

    local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
    local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

    local HitboxOnScreen = Camera:WorldToViewportPoint(Config.Prediction
    and Hitbox.Position + HitboxVelocityCorrection or Hitbox.Position)
    mousemoverel(
        (HitboxOnScreen.X - Mouse.X) * Config.Sensitivity,
        (HitboxOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

local function RequireModule(Name)
    for Index, Instance in pairs(getloadedmodules()) do
        if Instance.Name == Name then
            return require(Instance)
        end
    end
end
local function HookSignal(Signal,Index,Callback)
    local Connection = getconnections(Signal)[Index]
    local OldConnection = Connection.Function
    Connection:Disable()
    Signal:Connect(function(...)
        local args = Callback({...})
        OldConnection(unpack(args))
    end)
end
local function HookFunction(Module,Function,Callback)
    Module = RequireModule(Module) local OldFunction
    while task.wait() do
        if Module and Module[Function] then
            OldFunction = Module[Function]
            break
        end
        Module = RequireModule("ControllerClass")
    end
    Module[Function] = function(...)
        local args = Callback({...})
        return OldFunction(unpack(args))
    end
end

HookFunction("ControllerClass","LateUpdate",function(args)
    if Window.Flags["BRM5/WalkSpeed/Enabled"] then
        args[1].Speed = Window.Flags["BRM5/WalkSpeed/Value"]
    end
    return args
end)
HookFunction("CharacterCamera","Update",function(args)
    if Window.Flags["BRM5/NoBob"] then
        args[1]._shakes = {}
        args[1]._bob = 0
    end
    if Window.Flags["BRM5/Recoil/Enabled"] then
        args[1]._recoil.Velocity = args[1]._recoil.Velocity * (Window.Flags["BRM5/Recoil/Value"] / 100)
    end
    return args
end)
HookFunction("TurretCamera","Update",function(args)
    if Window.Flags["BRM5/Recoil/Enabled"] then
        args[1]._recoil.Velocity = args[1]._recoil.Velocity * (Window.Flags["BRM5/Recoil/Value"] / 100)
    end
    return args
end)
HookFunction("FirearmInventory","new",function(args)
    if Window.Flags["BRM5/Firemodes"] then
        if not table.find(args[2].Tune.Firemodes,1) then
            table.insert(args[2].Tune.Firemodes,1)
        end
        if not table.find(args[2].Tune.Firemodes,2) then
            table.insert(args[2].Tune.Firemodes,2)
        end
        if not table.find(args[2].Tune.Firemodes,3) then
            table.insert(args[2].Tune.Firemodes,3)
        end
        args[2].Mode = 1
    end
    return args
end)
HookFunction("FirearmInventory","_discharge",function(args)
    if Window.Flags["BRM5/RapidFire/Enabled"] then
        args[1]._config.Tune.RPM = Window.Flags["BRM5/RapidFire/Value"]
    end
    if Window.Flags["BRM5/BulletDrop"] then
        args[1]._config.Tune.Velocity = 1e6
    end
    PredictedVelocity = args[1]._config.Tune.Velocity
    return args
end)
HookFunction("GroundMovement","Update",function(args)
    if Window.Flags["BRM5/Vehicle/Enabled"] then
        args[1]._tune.Speed = Window.Flags["BRM5/Vehicle/Speed"]
        args[1]._tune.Accelerate = Window.Flags["BRM5/Vehicle/Acceleration"]
    end
    return args
end)
HookFunction("HelicopterMovement","Update",function(args)
    if Window.Flags["BRM5/Helicopter/Enabled"] then
        args[1]._tune.Speed = Window.Flags["BRM5/Helicopter/Speed"]
    end
    return args
end)
HookFunction("AircraftMovement","_discharge",function(args)
    if Window.Flags["BRM5/BulletDrop"] then
        args[1]._tune.Velocity = 1e6
    end
    PredictedVelocity = args[1]._tune.Velocity
    AircraftTip = args[1]._tip
    return args
end)
HookFunction("TurretMovement","_discharge",function(args)
    if Window.Flags["BRM5/BulletDrop"] then
        args[1]._tune.Velocity = 1e6
    end
    PredictedVelocity = args[1]._tune.Velocity
    GroundTip = args[1]._tip
    return args
end)
HookFunction("EnvironmentService","Update",function(args)
    if Window.Flags["BRM5/Lighting/Enabled"] then
        args[1]._atmoshperes.Default.Density = Window.Flags["BRM5/Lighting/Fog"]
        if args[1]._atmoshperes.Desert and args[1]._atmoshperes.Snow then
            args[1]._atmoshperes.Desert.Density = Window.Flags["BRM5/Lighting/Fog"]
            args[1]._atmoshperes.Snow.Density = Window.Flags["BRM5/Lighting/Fog"]
        end
    end
    return args
end)
HookSignal(RemoteEvent.OnClientEvent,1,function(args)
    if args[1] == "ReplicateNVG" then
        if Window.Flags["BRM5/DisableNVG"] then
            args[2] = false
        end
        if Window.Flags["BRM5/NVGShape"] then
            args[3] = ""
        end
    end
    return args
end)

local __namecall
__namecall = hookmetamethod(game,"__namecall",function(self,...)
    local args = {...}
    if SilentAim then
        if getnamecallmethod() == "Raycast" and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
            local Camera = Workspace.CurrentCamera
            if args[1] == Camera.CFrame.Position then
                args[2] = SilentAim.Position - Camera.CFrame.Position
            elseif AircraftTip and args[1] == AircraftTip.WorldCFrame.Position then
                args[2] = SilentAim.Position - AircraftTip.WorldCFrame.Position
            elseif GroundTip and args[1] == GroundTip.WorldCFrame.Position then
                args[2] = SilentAim.Position - GroundTip.WorldCFrame.Position
            end
        end
    end
    return __namecall(self, unpack(args))
end)

--[[local __newindex
__newindex = hookmetamethod(game,"__newindex",function(self,index,value)
    if checkcaller() then return __newindex(self,index,value) end
    if self == Lighting and Window.Flags["Lighting/"..index] then
        DefaultLighting[index] = value
    end
    return __newindex(self,index,value)
end)]]

RunService.Heartbeat:Connect(function()
    SilentAim = GetHitbox({
        Enabled = Window.Flags["SilentAim/Enabled"],
        WallCheck = Window.Flags["SilentAim/WallCheck"],
        DynamicFoV = Window.Flags["SilentAim/DynamicFoV"],
        FieldOfView = Window.Flags["SilentAim/FieldOfView"],
        Priority = Window.Flags["SilentAim/Priority"],
        TargetMode = Window.Flags["BRM5/TargetMode"][1]
    })
    if Aimbot then AimAt(
        GetHitbox({
            Enabled = Window.Flags["Aimbot/Enabled"],
            WallCheck = Window.Flags["Aimbot/WallCheck"],
            DynamicFoV = Window.Flags["Aimbot/DynamicFoV"],
            FieldOfView = Window.Flags["Aimbot/FieldOfView"],
            Priority = Window.Flags["Aimbot/Priority"],
            TargetMode = Window.Flags["BRM5/TargetMode"][1]
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
    if Window.Flags["BRM5/Lighting/Enabled"] then
        Lighting.ClockTime = Window.Flags["BRM5/Lighting/Time"]
    end
    --[[for Property,Value in pairs(DefaultLighting) do
        Lighting[Property] = Window.Flags["Lighting/Enabled"] and
        Parvus.Utilities.UI:TableToColor(Window.Flags["Lighting/"..Property])
        or Value
    end]]
end)
RunService.RenderStepped:Connect(function()
    if Window.Flags["BRM5/Lighting/Brightness"] then
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
end)
Parvus.Utilities.NewThreadLoop(0,function()
    Trigger({
        Enabled = Window.Flags["Trigger/Enabled"],
        WallCheck = Window.Flags["Trigger/WallCheck"],
        Prediction = Window.Flags["Trigger/Prediction"],
        DynamicFoV = Window.Flags["Trigger/DynamicFoV"],
        FieldOfView = Window.Flags["Trigger/FieldOfView"],
        TargetMode = Window.Flags["BRM5/TargetMode"][1],
        Priority = Window.Flags["Trigger/Priority"],
        HoldTime = Window.Flags["Trigger/HoldTime"],
        Delay = Window.Flags["Trigger/Delay"],
    })
end)

for Index,NPC in pairs(NPCFolder:GetChildren()) do
    Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
end
NPCFolder.ChildAdded:Connect(function(NPC)
    Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
end)
NPCFolder.ChildRemoved:Connect(function(NPC)
    Parvus.Utilities.Drawing:RemoveESP(NPC)
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
