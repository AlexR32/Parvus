local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

repeat task.wait() until Workspace:FindFirstChild("Bots")
local Events = ReplicatedStorage:WaitForChild("Events")
local RemoteEvent = Events:WaitForChild("RemoteEvent")

local LocalPlayer = PlayerService.LocalPlayer
local Aimbot,SilentAim,NPCFolder,Network,
GroundTip,AircraftTip,PredictedVelocity
= false,nil,Workspace.Bots,{},nil,nil,1000

local Teleports,NoClipEvent = {
    {"Forward Operating Base",Vector3.new(-3962.565, 64.188, 805.001)},
    {"Communications Tower",Vector3.new(-1487.503, 809.622, -4416.927)},
    {"Department of Utilities",Vector3.new(306.193, 62.148, -3153.789)},
    {"Vietnama Village",Vector3.new(737.021, 117.422, -97.472)},
    {"Fort Ronograd",Vector3.new(6269.501, 185.632, -1232.474)},
    {"Ronograd City",Vector3.new(3536.074, 175.622, 1099.497)},
    {"Sochraina City",Vector3.new(-918, 73.622, 4178.497)},
    {"El Chara",Vector3.new(-4789.463, 107.638, 5298.004)},
    {"Naval Docks",Vector3.new(6167.5, 129.622, 2092)},
    {"Quarry",Vector3.new(272.762, 85.563, 2208.969)},
}

local Window = Parvus.Utilities.UI:Window({
    Name = "🎃 Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local GlobalSection = AimAssistTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Toggle({Name = "Team Check",Flag = "TeamCheck",Value = false})
            GlobalSection:Toggle({Name = "NPC Mode",Flag = "BRM5/NPCMode",Value = true})
        end
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
                {Name = "HumanoidRootPart",Mode = "Toggle"}
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
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FOV",Flag = "SilentAim/DynamicFOV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100})
            SilentAimSection:Slider({Name = "Distance",Flag = "SilentAim/Distance",Min = 25,Max = 1000,Value = 250,Unit = "meters"})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "HumanoidRootPart",Mode = "Toggle"}
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
            TriggerSection:Toggle({Name = "Switch To RMB",Flag = "Trigger/RMBMode",Value = false})
            TriggerSection:Dropdown({Name = "Body Parts",Flag = "Trigger/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "HumanoidRootPart",Mode = "Toggle"}
            }})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = false})
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
    local NPCVisualsTab = Window:Tab({Name = "NPC Visuals"}) do
        local GlobalSection = NPCVisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Civilian Color",Flag = "ESP/NPC/Ally",Value = {0.33333334326744,0.75,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/NPC/Enemy",Value = {1,0.75,1,0,false}})
            GlobalSection:Toggle({Name = "Hide Civilians",Flag = "ESP/NPC/TeamCheck",Value = true})
            GlobalSection:Toggle({Name = "Distance Check",Flag = "ESP/NPC/DistanceCheck",Value = true})
            GlobalSection:Slider({Name = "Distance",Flag = "ESP/NPC/Distance",Min = 25,Max = 1000,Value = 250,Unit = "meters"})
        end
        local BoxSection = NPCVisualsTab:Section({Name = "Boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "Box Enabled",Flag = "ESP/NPC/Box/Enabled",Value = false})
            BoxSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Box/Filled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Box/Outline",Value = true})
            BoxSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Box/Thickness",Min = 1,Max = 10,Value = 1})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Box/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            BoxSection:Divider()
            BoxSection:Toggle({Name = "Text Enabled",Flag = "ESP/NPC/Text/Enabled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Text/Outline",Value = true})
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/NPC/Text/Autoscale",Value = true})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/NPC/Text/Font",List = {
                {Name = "UI",Mode = "Button",Value = true},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button"}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/NPC/Text/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Text/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local OoVSection = NPCVisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Arrow/Filled",Value = true})
            OoVSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Arrow/Outline",Value = true})
            OoVSection:Slider({Name = "Height",Flag = "ESP/NPC/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Width",Flag = "ESP/NPC/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/NPC/Arrow/Distance",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HeadSection = NPCVisualsTab:Section({Name = "Head Circles",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Head/Enabled",Value = false})
            HeadSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Head/Filled",Value = true})
            HeadSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Head/Outline",Value = true})
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
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local EnvSection = MiscTab:Section({Name = "Environment"}) do
            EnvSection:Toggle({Name = "Enabled",Flag = "BRM5/Lighting/Enabled",Value = false})
            EnvSection:Toggle({Name = "Brightness",Flag = "BRM5/Lighting/Brightness",Value = false,Callback = function(Bool)
                Lighting.GlobalShadows = not Bool
            end})
            EnvSection:Slider({Name = "Clock Time",Flag = "BRM5/Lighting/Time",Min = 0,Max = 24,Value = 12})
            EnvSection:Slider({Name = "Fog Density",Flag = "BRM5/Lighting/Fog",Min = 0,Max = 1,Precise = 2,Value = 0.25})
        end
        local WeaponSection = MiscTab:Section({Name = "Weapon"}) do
            WeaponSection:Toggle({Name = "Recoil",Flag = "BRM5/Recoil/Enabled",Value = false})
            WeaponSection:Slider({Name = "Recoil Percent",Flag = "BRM5/Recoil/Value",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WeaponSection:Toggle({Name = "Instant Hit",Flag = "BRM5/BulletDrop",Value = false})
            :ToolTip("silent aim works better with it")
            WeaponSection:Toggle({Name = "Unlock Firemodes",Flag = "BRM5/Firemodes",Value = false})
            :ToolTip("re-equip your weapon to make it work")
            WeaponSection:Toggle({Name = "Rapid Fire",Flag = "BRM5/RapidFire/Enabled",Value = false}):ToolTip("re-equip your weapon to disable")
            WeaponSection:Slider({Name = "Round Per Minute",Flag = "BRM5/RapidFire/Value",Min = 45,Max = 1000,Value = 1000})
        end
        local CharSection = MiscTab:Section({Name = "Character"}) do
            CharSection:Toggle({Name = "NoClip",Flag = "BRM5/NoClip",Value = false,
            Callback = function(Bool)
                if Bool and not NoClipEvent then
                    NoClipEvent = RunService.Stepped:Connect(function()
                        NoClip(true)
                    end)
                elseif not Bool and NoClipEvent then
                    NoClipEvent:Disconnect() NoClipEvent = nil
                    task.wait(0.1) NoClip(false)
                end
            end}):Keybind()
            CharSection:Toggle({Name = "Anti Skydive",Flag = "BRM5/AntiFall",Value = false}):Keybind()
            CharSection:Toggle({Name = "No NVG Effect",Flag = "BRM5/DisableNVG",Value = false})
            CharSection:Toggle({Name = "No NVG Shape",Flag = "BRM5/NVGShape",Value = false})
            CharSection:Toggle({Name = "No Camera Bob",Flag = "BRM5/NoBob",Value = false})
            CharSection:Toggle({Name = "Speedhack",Flag = "BRM5/WalkSpeed/Enabled",Value = false}):Keybind()
            CharSection:Slider({Name = "Speed",Flag = "BRM5/WalkSpeed/Value",Min = 16,Max = 1000,Value = 120})
        end
        local TPSection = MiscTab:Section({Name = "Teleports"}) do
            for Index,Table in pairs(Teleports) do
                TPSection:Button({Name = Table[1],Callback = function()
                    TeleportCharacter(Table[2])
                end})
            end
        end
        local VehSection = MiscTab:Section({Name = "Vehicle"}) do
            VehSection:Toggle({Name = "Enabled",Flag = "BRM5/Vehicle/Enabled",Value = false})
            VehSection:Slider({Name = "Speed",Flag = "BRM5/Vehicle/Speed",Min = 0,Max = 1000,Value = 100})
            VehSection:Slider({Name = "Acceleration",Flag = "BRM5/Vehicle/Acceleration",Min = 1,Max = 50,Value = 1})
            :ToolTip("lower = faster")
        end
        local HeliSection = MiscTab:Section({Name = "Helicopter"}) do
            HeliSection:Toggle({Name = "Enabled",Flag = "BRM5/Helicopter/Enabled",Value = false})
            HeliSection:Slider({Name = "Speed",Flag = "BRM5/Helicopter/Speed",Min = 0,Max = 500,Value = 200})
        end
        local AirSection = MiscTab:Section({Name = "Aircraft"}) do
            AirSection:Toggle({Name = "Speed Enabled",Flag = "BRM5/Aircraft/Enabled",Value = false}):Keybind()
            AirSection:Slider({Name = "Speed",Flag = "BRM5/Aircraft/Speed",Min = 130,Max = 950,Value = 130})
            AirSection:Toggle({Name = "Fly Enabled",Flag = "BRM5/Aircraft/FlyEnabled",Value = false}):Keybind()
            AirSection:Toggle({Name = "Fly Use Camera",Flag = "BRM5/Aircraft/Camera",Value = false})
            AirSection:Slider({Name = "Fly Speed",Flag = "BRM5/Aircraft/FlySpeed",Min = 145,Max = 500,Value = 200})
            AirSection:Button({Name = "Setup Switches/Engines",Callback = function()
                local Aircraft = RequireModule("MovementService")
                if not Aircraft._handler or not Aircraft._handler._main then return end
                EnableSwitch("cicu")
                EnableSwitch("oxygen")
                EnableSwitch("battery")
                EnableSwitch("ac_r")
                EnableSwitch("ac_l")
                EnableSwitch("inverter")
                EnableSwitch("take_apu")
                EnableSwitch("apu")
                EnableSwitch("engine_r")
                EnableSwitch("engine_l")
                EnableSwitch("fuel_r_l")
                EnableSwitch("fuel_l_l")
                EnableSwitch("fuel_r_r")
                EnableSwitch("fuel_l_r")
                Network:FireServer("CallInteraction", "Fire", "Canopy")
                Parvus.Utilities.UI:Notification({
                    Title = "Aircraft thingy",
                    Description = "Please wait till your engines start up, you dont need to touch anything",
                    Duration = 30
                })
                repeat task.wait() until Aircraft._handler._main.APU.engine.PlaybackSpeed == 1
                Network:FireServer("CallInteraction","Fire","LeftEngine")
                Network:FireServer("CallInteraction","Fire","RightEngine")
            end})
            AirSection:Button({Name = "Unlock Camera",Callback = function()
                local Aircraft = RequireModule("MovementService")
                local CameraMod = RequireModule("CameraService")
                CameraMod:Mount(Aircraft._handler._controller, "Character")
                CameraMod._handler._zoom = 128
            end})
        end
        local MiscSection = MiscTab:Section({Name = "Misc",Side = "Left"}) do
            MiscSection:Button({Name = "Enable Fake RGE",Callback = function()
                local serverSettings = getupvalue(require(ReplicatedStorage.Packages.server).Get,1)
                if not serverSettings.CHEATS_ENABLED then
                    serverSettings.CHEATS_ENABLED = true
                    for Index,Connection in pairs(getconnections(RemoteEvent.OnClientEvent)) do
                        Connection.Function("InitRGE")
                    end
                end
            end})
            MiscSection:Button({Name = "Force Reset Character",Callback = function()
                Network:FireServer("ResetCharacter")
            end})
        end
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
            MenuSection:Toggle({Name = "Custom Mouse",Flag = "Mouse/Enabled",Value = true})
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

function NoClip(Enabled) if not LocalPlayer.Character then return end
    for Index,Value in pairs(LocalPlayer.Character:GetDescendants()) do
        if Value:IsA("BasePart") then Value.CanCollide = not Enabled end
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

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.IgnoreWater = true

local function Raycast(Origin,Direction,Table)
    RaycastParams.FilterDescendantsInstances = Table
    return Workspace:Raycast(Origin,Direction,RaycastParams)
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

local function TeamCheck(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
end

local function DistanceCheck(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance * 0.28 <= MaxDistance
end

local function WallCheck(Enabled,Hitbox,Character)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return not Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,
    {LocalPlayer.Character,Character})
end

local function GetHitbox(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera

    local FieldOfView,ClosestHitbox = Config.DynamicFOV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView or Config.FieldOfView

    if Config.NPCMode then
        for Index,NPC in pairs(NPCFolder:GetChildren()) do
            local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
            local IsAlive = Humanoid and Humanoid.Health > 0
            if not NPC:FindFirstChildWhichIsA("ProximityPrompt",true) and
            NPC:FindFirstChildWhichIsA("AlignOrientation",true) and IsAlive then
                for Index,BodyPart in pairs(Config.BodyParts) do
                    local Hitbox = NPC:FindFirstChild(BodyPart) if not Hitbox then continue end
                    local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                    if WallCheck(Config.WallCheck,Hitbox,NPC)
                    and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                        local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView then
                            FieldOfView,ClosestHitbox = Magnitude,{NPC,NPC,Hitbox,Distance,ScreenPosition}
                        end
                    end
                end
            end
        end
    else
        for Index,Player in pairs(PlayerService:GetPlayers()) do
            local Character = Player.Character if not Character then continue end
            local Humanoid = Character:FindFirstChildOfClass("Humanoid") if not Humanoid then continue end
            if Player ~= LocalPlayer and Humanoid.Health > 0 and TeamCheck(Config.TeamCheck,Player) then
                for Index,BodyPart in pairs(Config.BodyParts) do
                    local Hitbox = Character:FindFirstChild(BodyPart) if not Hitbox then continue end
                    local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                    if WallCheck(Config.WallCheck,Hitbox,Character)
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
    end

    return ClosestHitbox
end

local function GetHitboxWithPrediction(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera

    local FieldOfView,ClosestHitbox = Config.DynamicFOV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView or Config.FieldOfView
    
    if Config.NPCMode then
        for Index,NPC in pairs(NPCFolder:GetCharacter()) do
            local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
            local IsAlive = Humanoid and Humanoid.Health > 0
            if not NPC:FindFirstChildWhichIsA("ProximityPrompt",true) and
            NPC:FindFirstChildWhichIsA("AlignOrientation",true) and IsAlive then
                for Index,BodyPart in pairs(Config.BodyParts) do
                    local Hitbox = NPC:FindFirstChild(BodyPart) if not Hitbox then continue end
                    local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                    if WallCheck(Config.WallCheck,Hitbox,NPC)
                    and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                        local PredictionVelocity = (Hitbox.AssemblyLinearVelocity * Distance) / PredictedVelocity
                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction
                        and Hitbox.Position + PredictionVelocity or Hitbox.Position)
    
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView then
                            FieldOfView,ClosestHitbox = Magnitude,{NPC,NPC,Hitbox,Distance,ScreenPosition}
                        end
                    end
                end
            end
        end
    else
        for Index,Player in pairs(PlayerService:GetPlayers()) do
            local Character = Player.Character if not Character then continue end
            local Humanoid = Character:FindFirstChildOfClass("Humanoid") if not Humanoid then continue end
            if Player ~= LocalPlayer and Humanoid.Health > 0 and TeamCheck(Config.TeamCheck,Player) then
                for Index,BodyPart in pairs(Config.BodyParts) do
                    local Hitbox = Character:FindFirstChild(BodyPart) if not Hitbox then continue end
                    local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                    if WallCheck(Config.WallCheck,Hitbox,Character)
                    and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                        local PredictionVelocity = (Hitbox.AssemblyLinearVelocity * Distance) / Config.Prediction.Velocity
                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction
                        and Hitbox.Position + PredictionVelocity or Hitbox.Position)
    
                        local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if OnScreen and Magnitude < FieldOfView then
                            FieldOfView,ClosestHitbox = Magnitude,{Player,Character,Hitbox,Distance,ScreenPosition}
                        end
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

    local PredictionVelocity = (Hitbox[3].AssemblyLinearVelocity * Hitbox[4]) / PredictedVelocity
    local HitboxOnScreen = Camera:WorldToViewportPoint(Config.Prediction
    and Hitbox[3].Position + PredictionVelocity or Hitbox[3].Position)

    mousemoverel(
        (HitboxOnScreen.X - Mouse.X) * Config.Sensitivity,
        (HitboxOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

function RequireModule(Name)
    for Index, Instance in pairs(getloadedmodules()) do
        if Instance.Name == Name then
            return require(Instance)
        end
    end
end
local function HookFunction(ModuleName,Function,Callback)
    local Module,OldFunction = RequireModule(ModuleName)
    while task.wait() do
        if Module and Module[Function] then
            OldFunction = Module[Function]
            break
        end
        Module = RequireModule(ModuleName)
    end
    Module[Function] = function(...)
        local Args = Callback({...})
        if not Args then return end
        return OldFunction(unpack(Args))
    end
end
local function HookSignal(Signal,Index,Callback)
    local Connection = getconnections(Signal)[Index]
    if not Connection then return end
    local OldConnection = Connection.Function
    if not OldConnection then return end
    Connection:Disable()
    Signal:Connect(function(...)
        local Args = Callback({...})
        if not Args then return end
        OldConnection(unpack(Args))
    end)
end

local function Teleport(Position,Velocity)
	local PrimaryPart = LocalPlayer.Character
    and LocalPlayer.Character.PrimaryPart
    if not PrimaryPart then return end
    local TPModule = {}

	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	AlignPosition.Attachment0 = PrimaryPart.RootRigAttachment

    local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	AlignOrientation.Attachment0 = PrimaryPart.RootRigAttachment

    --AlignPosition.MaxForce = 10000
    AlignPosition.MaxVelocity = Velocity
	AlignPosition.Position = Position

	AlignPosition.Parent = PrimaryPart
    AlignOrientation.Parent = PrimaryPart

	function TPModule:Update(Position,Velocity)
        AlignPosition.MaxVelocity = Velocity
		AlignPosition.Position = Position
	end
	function TPModule:Wait()
		while task.wait() do
			if (PrimaryPart.Position - AlignPosition.Position).Magnitude < 5 then
				break
			end
		end
	end
	function TPModule:Destroy()
        TPModule:Wait()
		AlignPosition:Destroy()
        AlignOrientation:Destroy()
    end return TPModule
end

function TeleportCharacter(Position)
    local PrimaryPart = LocalPlayer.Character
    and LocalPlayer.Character.PrimaryPart
    if not PrimaryPart then return end

    local OldAF = Window:GetValue("BRM5/AntiFall")
    local OldNC = Window:GetValue("BRM5/NoClip")
    Window:SetValue("BRM5/AntiFall",true)
    Window:SetValue("BRM5/NoClip",true)

    LocalPlayer.Character.Humanoid.Sit = true
    PrimaryPart.CFrame = CFrame.new(PrimaryPart.Position + Vector3.new(0,500,0))
    local TP = Teleport(Position + Vector3.new(0,500,0),500)
    TP:Destroy() PrimaryPart.CFrame = CFrame.new(Position)
    LocalPlayer.Character.Humanoid.Sit = false

    Window:SetValue("BRM5/AntiFall",OldAF)
    Window:SetValue("BRM5/NoClip",OldNC)
end
function EnableSwitch(Switch)
    local CameraMod = RequireModule("CameraService")
    if not CameraMod._handler._buttons then return end
    for Index,Switches in pairs(CameraMod._handler._buttons) do
        if Switches._id == Switch then
            Switches:Update()
            Switches:Select()
            CameraMod._switch = Switches
            CameraMod._switch:Activate()
            CameraMod._switch:Unselect()
        end
    end
end
local function AircraftFly(Config,Args)
    if not Config.Enabled then return Args end
    local Camera = Workspace.CurrentCamera
    Args[1]._force.MaxForce = Vector3.new(1, 1, 1) * 40000000
    Args[1]._force.Velocity = InputToVelocity() * Config.Speed
    if Config.Camera then
        Args[1]._gyro.MaxTorque = Vector3.new(1, 1, 1) * 4000
        Args[1]._gyro.CFrame = Camera.CFrame * CFrame.Angles(0,math.pi,0)
    end
end

HookFunction("ControllerClass","LateUpdate",function(Args)
    if Window.Flags["BRM5/WalkSpeed/Enabled"] then
        Args[1].Speed = Window.Flags["BRM5/WalkSpeed/Value"]
    end return Args
end)
HookFunction("MovementService","Mount",function(Args)
    if Window.Flags["BRM5/AntiFall"] then
        if Args[3] == "Skydive" or Args[3] == "Parachute" then
            return
        end
    end return Args
end)
HookFunction("CharacterCamera","Update",function(Args)
    if Window.Flags["BRM5/NoBob"] then
        Args[1]._shakes = {}
        Args[1]._bob = 0
    end
    if Window.Flags["BRM5/Recoil/Enabled"] then
        Args[1]._recoil.Velocity = Args[1]._recoil.Velocity * (Window.Flags["BRM5/Recoil/Value"] / 100)
    end return Args
end)
HookFunction("TurretCamera","Update",function(Args)
    if Window.Flags["BRM5/Recoil/Enabled"] then
        Args[1]._recoil.Velocity = Args[1]._recoil.Velocity * (Window.Flags["BRM5/Recoil/Value"] / 100)
    end return Args
end)
HookFunction("FirearmInventory","new",function(Args)
    if Window.Flags["BRM5/Firemodes"] then
        if not table.find(Args[2].Tune.Firemodes,1) then
            table.insert(Args[2].Tune.Firemodes,1)
        end
        if not table.find(Args[2].Tune.Firemodes,2) then
            table.insert(Args[2].Tune.Firemodes,2)
        end
        if not table.find(Args[2].Tune.Firemodes,3) then
            table.insert(Args[2].Tune.Firemodes,3)
        end
        Args[2].Mode = 1
    end return Args
end)
HookFunction("FirearmInventory","_discharge",function(Args)
    if Window.Flags["BRM5/RapidFire/Enabled"] then
        Args[1]._config.Tune.RPM = Window.Flags["BRM5/RapidFire/Value"]
    end
    if Window.Flags["BRM5/BulletDrop"] then
        Args[1]._config.Tune.Velocity = 1e6
    end PredictedVelocity = Args[1]._config.Tune.Velocity
    return Args
end)
HookFunction("GroundMovement","Update",function(Args)
    if Window.Flags["BRM5/Vehicle/Enabled"] then
        Args[1]._tune.Speed = Window.Flags["BRM5/Vehicle/Speed"]
        Args[1]._tune.Accelerate = Window.Flags["BRM5/Vehicle/Acceleration"]
    end return Args
end)
HookFunction("HelicopterMovement","Update",function(Args)
    if Window.Flags["BRM5/Helicopter/Enabled"] then
        Args[1]._tune.Speed = Window.Flags["BRM5/Helicopter/Speed"]
    end return Args
end)
HookFunction("AircraftMovement","_discharge",function(Args)
    if Window.Flags["BRM5/BulletDrop"] then
        Args[1]._tune.Velocity = 1e6
    end PredictedVelocity = Args[1]._tune.Velocity
    AircraftTip = Args[1]._tip return Args
end)
HookFunction("AircraftMovement","Update",function(Args)
    if Window.Flags["BRM5/Aircraft/Enabled"] then
        --[[Args[1]._speed = 1
        Args[1]._gyro.CFrame = Args[1]._gyro.CFrame * CFrame.Angles(math.rad(-Args[3].Y * Args[4] * 50), 0, math.rad(Args[3].X * Args[4] * 50));
		Args[1]._gyro.MaxTorque = Vector3.new(1, 1, 1) * 4000
        Args[1]._force.MaxForce = Vector3.new(1, 1, 1) * 40000000 * Args[1]._speed 
        Args[1]._force.Velocity = Args[1]._main.CFrame.LookVector * -Window.Flags["BRM5/Aircraft/Speed"]]
        Args[1]._model.RPM.Value = Window.Flags["BRM5/Aircraft/Speed"]
    end Args = AircraftFly({
        Enabled = Window.Flags["BRM5/Aircraft/FlyEnabled"],
        Camera = Window.Flags["BRM5/Aircraft/Camera"],
        Speed = Window.Flags["BRM5/Aircraft/FlySpeed"]
    },Args) return Args
end)
HookFunction("TurretMovement","_discharge",function(Args)
    if Window.Flags["BRM5/BulletDrop"] then
        Args[1]._tune.Velocity = 1e6
    end PredictedVelocity = Args[1]._tune.Velocity
    GroundTip = Args[1]._tip return Args
end)
HookFunction("EnvironmentService","Update",function(Args)
    if Window.Flags["BRM5/Lighting/Enabled"] then
        Args[1]._atmoshperes.Default.Density = Window.Flags["BRM5/Lighting/Fog"]
        if Args[1]._atmoshperes.Desert and Args[1]._atmoshperes.Snow then
            Args[1]._atmoshperes.Desert.Density = Window.Flags["BRM5/Lighting/Fog"]
            Args[1]._atmoshperes.Snow.Density = Window.Flags["BRM5/Lighting/Fog"]
        end
    end return Args
end)
HookSignal(RemoteEvent.OnClientEvent,1,function(Args)
    if Args[1] == "ReplicateNVG" then
        if Window.Flags["BRM5/DisableNVG"] then
            Args[2] = false
        end
        if Window.Flags["BRM5/NVGShape"] then
            Args[3] = ""
        end
    --[[elseif Args[1] == "InitInventory" then
        if Window.Flags["BRM5/AntiFall"]
        and Args[2] == true then return end]]
    end return Args
end)

task.spawn(function()
    for Index,Table in pairs(getgc(true)) do
        if typeof(Table) == "table"
        and rawget(Table,"FireServer")
        and rawget(Table,"InvokeServer") then
            function Network:FireServer(...)
                Table:FireServer(...)
            end
            function Network:InvokeServer(...)
                Table:InvokeServer(...)
            end
            break
        end
    end
end)
task.spawn(function()
    for Index,Table in pairs(getgc(true)) do
        if typeof(Table) == "table"
        and rawget(Table,"FireServer")
        and rawget(Table,"InvokeServer")  then
            local OldFireServer = Table.FireServer
            --local OldInvokeServer = Table.InvokeServer
            Table.FireServer = function(Self, ...) local Args = {...}
                if checkcaller() then return OldFireServer(Self, ...) end
                if Window.Flags["BRM5/AntiFall"] then
                    if Args[1] == "ReplicateSkydive" and
                    (Args[2] == 3 or Args[2] == 2) then
                        return
                    end
                end
                return OldFireServer(Self, ...)
            end
            --[[Table.FireServer = function(Self, ...)
                local Args = {...}
                if Args[1] ~= "UpdateCharacter" then
                    print("Network:FireServer(" .. FormatTable(Args) .. ")")
                end
                return OldFireServer(Self, ...)
            end
            Table.InvokeServer = function(Self, ...)
                local Args = {...}
                print("Network:InvokeServer(" .. FormatTable(Args) .. ")")
                return OldInvokeServer(Self, ...)
            end]]
        end
    end
end)

local OldNamecall
OldNamecall = hookmetamethod(game,"__namecall",function(Self, ...)
    local Method,Args = getnamecallmethod(),{...}
    if Window.Flags["BRM5/AntiFall"] then
        if Method == "TakeDamage" then return end
    end

    if SilentAim and Method == "Raycast" then
        if math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
            local Camera = Workspace.CurrentCamera
            if Args[1] == Camera.CFrame.Position then
                Args[2] = SilentAim[3].Position - Camera.CFrame.Position
            elseif AircraftTip and Args[1] == AircraftTip.WorldCFrame.Position then
                Args[2] = SilentAim[3].Position - AircraftTip.WorldCFrame.Position
            elseif GroundTip and Args[1] == GroundTip.WorldCFrame.Position then
                Args[2] = SilentAim[3].Position - GroundTip.WorldCFrame.Position
            end
        end
    end

    return OldNamecall(Self, unpack(Args))
end)

RunService.Heartbeat:Connect(function()
    SilentAim = GetHitbox({
        Enabled = Window.Flags["SilentAim/Enabled"],
        WallCheck = Window.Flags["SilentAim/WallCheck"],
        DistanceCheck = Window.Flags["SilentAim/DistanceCheck"],
        DynamicFOV = Window.Flags["SilentAim/DynamicFOV"],
        FieldOfView = Window.Flags["SilentAim/FieldOfView"],
        Distance = Window.Flags["SilentAim/Distance"],
        BodyParts = Window.Flags["SilentAim/BodyParts"],
        NPCMode = Window.Flags["BRM5/NPCMode"],
        TeamCheck = Window.Flags["TeamCheck"]
    })
    if Aimbot then AimAt(
        GetHitbox({
            Enabled = Window.Flags["Aimbot/Enabled"],
            WallCheck = Window.Flags["Aimbot/WallCheck"],
            DistanceCheck = Window.Flags["Aimbot/DistanceCheck"],
            DynamicFOV = Window.Flags["Aimbot/DynamicFOV"],
            FieldOfView = Window.Flags["Aimbot/FieldOfView"],
            Distance = Window.Flags["Aimbot/Distance"],
            BodyParts = Window.Flags["Aimbot/BodyParts"],
            NPCMode = Window.Flags["BRM5/NPCMode"],
            TeamCheck = Window.Flags["TeamCheck"]
        }),{
            Prediction = Window.Flags["Aimbot/Prediction"],
            Sensitivity = Window.Flags["Aimbot/Smoothness"] / 100
        })
    end

    if Window.Flags["BRM5/Lighting/Enabled"] then
        Lighting.ClockTime = Window.Flags["BRM5/Lighting/Time"]
    end
end)
RunService.RenderStepped:Connect(function()
    if Window.Flags["BRM5/Lighting/Brightness"] then
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    local Press = Window.Flags["Trigger/RMBMode"] and mouse2press or mouse1press
    local Release = Window.Flags["Trigger/RMBMode"] and mouse2release or mouse1release

    if not Trigger then return end
    local TriggerHitbox = GetHitboxWithPrediction({
        Enabled = Window.Flags["Trigger/Enabled"],
        Prediction = Window.Flags["Trigger/Prediction"],
        WallCheck = Window.Flags["Trigger/WallCheck"],
        DistanceCheck = Window.Flags["Trigger/DistanceCheck"],
        DynamicFOV = Window.Flags["Trigger/DynamicFOV"],
        FieldOfView = Window.Flags["Trigger/FieldOfView"],
        Distance = Window.Flags["Trigger/Distance"],
        BodyParts = Window.Flags["Trigger/BodyParts"],
        NPCMode = Window.Flags["BRM5/NPCMode"],
        TeamCheck = Window.Flags["TeamCheck"]
    })

    if TriggerHitbox then Press()
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
                    BodyParts = Window.Flags["Trigger/BodyParts"],
                    NPCMode = Window.Flags["BRM5/NPCMode"],
                    TeamCheck = Window.Flags["TeamCheck"]
                }) if not TriggerHitbox or not Trigger then break end
            end
        end Release()
    end
end)

for Index,NPC in pairs(NPCFolder:GetChildren()) do
    if NPC:WaitForChild("HumanoidRootPart",5) and
    NPC.HumanoidRootPart:FindFirstChild("AlignOrientation") then
        Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
    end
end
NPCFolder.ChildAdded:Connect(function(NPC)
    if NPC:WaitForChild("HumanoidRootPart",5) and
    NPC.HumanoidRootPart:FindFirstChild("AlignOrientation") then
        Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
    end
end)
NPCFolder.ChildRemoved:Connect(function(NPC)
    Parvus.Utilities.Drawing:RemoveESP(NPC)
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
