local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = PlayerService.LocalPlayer
local Aimbot,SilentAim,Trigger,
PredictedVelocity,PredictedGravity
= false,nil,nil,1050,30.901500701904297
local NoClipEvent

local Framework = require(ReplicatedFirst.Framework) Framework:WaitForLoaded()
repeat task.wait() until Framework.Classes.Players.get()
local PlayerClass = Framework.Classes.Players.get()
local Interface = Framework.Libraries.Interface
local Animators = Framework.Classes.Animators
local Network = Framework.Libraries.Network
local Bullets = Framework.Libraries.Bullets

local SpreadFunction = getupvalue(Bullets.Fire,1)
local Events = getupvalue(Network.Add,4)
PredictedGravity = getupvalue(Events["Gravity Debug\r"],1)

local NullFunction = function() end
setupvalue(Network.Send,6,NullFunction)
setupvalue(Network.Fetch,6,NullFunction)

local LootBins = Workspace.Map.Shared.LootBins
local Randoms = Workspace.Map.Shared.Randoms
local Vehicles = Workspace.Vehicles.Spawned
local Zombies = Workspace.Zombies.Mobs
local Loot = Workspace.Loot
local OldPos,AnchorSafe = nil,true

local Places,ItemCategory,ItemMemory = {
    "ATVCrashsiteRenegade01","CampSovietBandit01","CrashPrisonBus01",
    "LifePreserverMilitary01","LifePreserverSoviet01","LifePreserverSpecOps01",
    "MilitaryBlockade01","MilitaryConvoy01","PartyTrailerDisco01",
    "PartyTrailerTechnoGold","PartyTrailerTechnoGoldDeagleMod1",
    "PirateTreasure01","SeahawkCrashsite04","SeahawkCrashsite05",
    "SeahawkCrashsite06","SeahawkCrashsite07","SpecialForcesCrash01"
},{
    "Containers","Accessories","Ammo","Attachments","Backpacks","Belts","Clothing",
    "Consumables","Firearms","Hats","Medical","Melees","Utility","VehicleParts","Vests"
},{}

--[[local Blacklist = {
    "Ping Return",
    "Animator Camera Position Report",
    "Get Server Debug State",
    "Set Character State",
    "Animator State Report",
    "Get Character Stat"
}

local OldSend,OldFetch = Network.Send,Network.Fetch
Network.Send = function(Self,...)
    local Args = {...}
    if not table.find(Blacklist,Args[1]) then
        print("Send",repr(Args))
    end return OldSend(Self,...)
end
Network.Fetch = function(Self,...)
    local Args = {...}
    if not table.find(Blacklist,Args[1]) then
        local Return = OldFetch(Self,...)
        print("Fetch:",repr(Args),"Returned:",repr(Return))
        return Return
    end return OldFetch(Self,...)
end]]

local Window = Parvus.Utilities.UI:Window({
    Name = "🎃 Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local GlobalSection = AimAssistTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Toggle({Name = "Team Check",Flag = "TeamCheck",Value = false})
        end
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            --AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = false})
            --AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/WallCheck",Value = false})
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
            --SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
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
            GlobalSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = true})
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
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Text/Autoscale",Value = false})
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
        local LightingSection = VisualsTab:Section({Name = "Lighting",Side = "Right"}) do
            LightingSection:Toggle({Name = "Enabled",Flag = "Lighting/Enabled",Value = false,
            Callback = function(Bool) if Bool then return end
                for Property,Value in pairs(Parvus.Utilities.Misc.DefaultLighting) do
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
        end
    end
    local ESPTab = Window:Tab({Name = "AR2 ESP"}) do
        local ItemSection = ESPTab:Section({Name = "Item ESP",Side = "Left"}) do local Items = {}
            ItemSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Items/DistanceCheck",Value = true})
            ItemSection:Slider({Name = "Distance",Flag = "AR2/ESP/Items/Distance",Min = 25,Max = 5000,Value = 50,Unit = "meters"})
            for Index,Name in pairs(ItemCategory) do
                local ItemFlag = "AR2/ESP/Items/" .. Name .. "/Enabled" Window.Flags[ItemFlag] = false
                Items[#Items + 1] = {Name = Name,Mode = "Toggle",Value = false,Callback = function(Selected,Option)
                    Window.Flags[ItemFlag] = Option.Value
                end}
            end
            ItemSection:Dropdown({Name = "ESP List",Flag = "AR2/Items",List = Items})
        end
        local ItemCSection = ESPTab:Section({Name = "Item Colors",Side = "Left"}) do
            for Index,Name in pairs(ItemCategory) do local ItemFlag = "AR2/ESP/Items/" .. Name
                ItemCSection:Colorpicker({Name = Name,Flag = ItemFlag.."/Color",Value = {1,0,1,0,false}})
            end
        end
        local RPSection = ESPTab:Section({Name = "Random Places ESP",Side = "Right"}) do
            RPSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/RandomPlaces/Enabled",Value = false})
            RPSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/RandomPlaces/DistanceCheck",Value = true})
            RPSection:Colorpicker({Name = "Color",Flag = "AR2/ESP/RandomPlaces/Color",Value = {1,0,1,0,false}})
            RPSection:Slider({Name = "Distance",Flag = "AR2/ESP/RandomPlaces/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "meters"})
        end
        local VehiclesSection = ESPTab:Section({Name = "Vehicles ESP",Side = "Right"}) do
            VehiclesSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Vehicles/Enabled",Value = false})
            VehiclesSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Vehicles/DistanceCheck",Value = true})
            VehiclesSection:Colorpicker({Name = "Color",Flag = "AR2/ESP/Vehicles/Color",Value = {1,0,1,0,false}})
            VehiclesSection:Slider({Name = "Distance",Flag = "AR2/ESP/Vehicles/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "meters"})
        end
        local ZombiesSection = ESPTab:Section({Name = "Zombies ESP",Side = "Right"}) do
            ZombiesSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Zombies/Enabled",Value = false})
            ZombiesSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Zombies/DistanceCheck",Value = true})
            ZombiesSection:Colorpicker({Name = "Color",Flag = "AR2/ESP/Zombies/Color",Value = {1,0,1,0,false}})
            ZombiesSection:Slider({Name = "Distance",Flag = "AR2/ESP/Zombies/Distance",Min = 25,Max = 5000,Value = 250,Unit = "meters"})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local RecoilSection = MiscTab:Section({Name = "Recoil Control",Side = "Left"}) do
            RecoilSection:Toggle({Name = "Enabled",Flag = "AR2/Recoil/Enabled",Value = false})
            RecoilSection:Slider({Name = "Spread",Flag = "AR2/Recoil/Spread",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Shift Force",Flag = "AR2/Recoil/ShiftForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Recoil Random",Flag = "AR2/Recoil/RandomInt",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Raise Force",Flag = "AR2/Recoil/RaiseForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Slide Force",Flag = "AR2/Recoil/SlideForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "KickUp Force",Flag = "AR2/Recoil/KickUpForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
        end
        --[[local FlySection = MiscTab:Section({Name = "Fly",Side = "Right"}) do
            FlySection:Toggle({Name = "Enabled",Flag = "AR2/Fly/Enabled",Value = false,
            Callback = function() if LocalPlayer.Character then
            OldPos = LocalPlayer.Character.PrimaryPart.Position end
            end}):Keybind({Flag = "BadBusiness/Fly/Keybind"})
            FlySection:Slider({Name = "Speed",Flag = "AR2/Fly/Speed",Min = 1,Max = 10,Precise = 1,Value = 1})
        end]]
        local MiscSection = MiscTab:Section({Name = "Misc",Side = "Right"}) do
            MiscSection:Toggle({Name = "Anti-Zombie",Flag = "AR2/AntiZombie/Enabled",Value = false}):Keybind()
            MiscSection:Toggle({Name = "No Fall Impact",Flag = "AR2/NoFallImpact",Value = false}):Keybind()
            MiscSection:Toggle({Name = "No Jump Delay",Flag = "AR2/NoJumpDelay",Value = false}):Keybind()
            MiscSection:Toggle({Name = "Always Run",Flag = "AR2/AlwaysRun",Value = false}):Keybind()

            local SpoofSCS = MiscSection:Toggle({Name = "Spoof SCS",Flag = "AR2/SSCS",Value = false})
            SpoofSCS:Keybind()
            SpoofSCS:ToolTip("SCS - Set Character State:\nNo Fall Damage\nLess Hunger / Thirst\nWhile Sprinting")

            MiscSection:Toggle({Name = "NoClip",Flag = "AR2/NoClip",Value = false,
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
            MiscSection:Toggle({Name = "Map ESP",Flag = "AR2/MapESP",Value = false,Callback = function(Bool)
                if Bool then Interface:Get("Map"):EnableGodview() else Interface:Get("Map"):DisableGodview() end
            end}):Keybind()
        end
    end
    local SettingsTab = Window:Tab({Name = "Settings"}) do
        local MenuSection = SettingsTab:Section({Name = "Menu",Side = "Left"}) do
            MenuSection:Toggle({Name = "Enabled",IgnoreFlag = true,Flag = "UI/Toggle",
            Value = Window.Enabled,Callback = function(Bool) Window:Toggle(Bool) end})
            :Keybind({Value = "RightControl",Flag = "UI/Keybind",DoNotClear = true})
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

function NoClip(Enabled)
    if LocalPlayer.Character then
        for Index,Value in pairs(LocalPlayer.Character:GetDescendants()) do
            if Value:IsA("BasePart") then
                Value.CanCollide = not Enabled
            end
        end
    end
end

Window:LoadDefaultConfig()
Window:SetValue("Background/Offset",296)
Window:SetValue("UI/Toggle",Window.Flags["UI/OOL"])

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Misc:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)

Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)

local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.FilterDescendantsInstances = {
    Workspace.Effects,
    Workspace.Sounds,
    Workspace.Locations,
    Workspace.Spawns
} RaycastParams.IgnoreWater = true

local function Raycast(Origin,Direction)
    local RaycastResult = Workspace:Raycast(Origin,Direction,RaycastParams)
    if RaycastResult then
		if (RaycastResult.Instance.Transparency == 1
        and RaycastResult.Instance.CanCollide == false)
        or not RaycastResult.Instance:IsDescendantOf(LocalPlayer.Character)
        or CollectionService:HasTag(RaycastResult.Instance,"Bullets Penetrate")
        or CollectionService:HasTag(RaycastResult.Instance,"Window Part")
        or CollectionService:HasTag(RaycastResult.Instance,"World Mesh")
        or CollectionService:HasTag(RaycastResult.Instance,"World Water Part") then
			return true
		end
    end
end

local function CastBullet(Hitbox)
    local RaycastParams2 = RaycastParams.new()
    RaycastParams2.FilterType = Enum.RaycastFilterType.Whitelist
    RaycastParams2.FilterDescendantsInstances = {Hitbox[2]}
    RaycastParams2.IgnoreWater = true

    local Camera = Workspace.CurrentCamera
    local RaycastResult = Workspace:Raycast(Camera.CFrame.Position,
    Hitbox[3].Position - Camera.CFrame.Position,RaycastParams2)
    if RaycastResult then
        return RaycastResult.Instance,
        RaycastResult.Position,
        RaycastResult.Normal
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
    Velocities[5] = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and Vector3.new(0,1,0) or Vector3.zero
    Velocities[6] = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and Vector3.new(0,-1,0) or Vector3.zero
    return FixUnit(Velocities[1] + Velocities[2] + Velocities[3] + Velocities[4] + Velocities[5] + Velocities[6])
end

--[[local function PlayerFly(Config)
    local Character = PlayerClass.Character
    if not Character or not OldPos then return end
    if Character.RootPart.Anchored then
        Network:Fetch("Set Character Unanchored")
    end if not Config.Enabled then return end
    OldPos = OldPos + InputToVelocity() * Config.Speed
    Character.RootPart.CFrame = CFrame.new(OldPos)
end]]

local function GetDistanceFromCamera(Position)
    local Camera = Workspace.CurrentCamera
    return (Position - Camera.CFrame.Position).Magnitude
end

local function TeamCheck(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
end

local function DistanceCheck(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance * 0.28 <= MaxDistance
end

local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position)
end

local function GetHitbox(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    
    local FieldOfView,ClosestHitbox = Config.DynamicFOV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView or Config.FieldOfView

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

    return ClosestHitbox
end

local function GetHitboxWithPrediction(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera

    local FieldOfView,ClosestHitbox = Config.DynamicFOV and
    ((120 - Camera.FieldOfView) * 4) + Config.FieldOfView or Config.FieldOfView

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        local Character = Player.Character if not Character then continue end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid") if not Humanoid then continue end
        if Player ~= LocalPlayer and Humanoid.Health > 0 and TeamCheck(Config.TeamCheck,Player) then
            for Index,BodyPart in pairs(Config.BodyParts) do
                local Hitbox = Character:FindFirstChild(BodyPart) if not Hitbox then continue end
                local Distance = (Hitbox.Position - Camera.CFrame.Position).Magnitude

                if WallCheck(Config.WallCheck,Hitbox,Character)
                and DistanceCheck(Config.DistanceCheck,Distance,Config.Distance) then
                    local PredictionGravity = Vector3.new(0,Distance / PredictedGravity,0)
                    local PredictionVelocity = (Hitbox.AssemblyLinearVelocity * Distance) / Config.Prediction.Velocity
                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction.Enabled
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

local function AimAt(Hitbox,Config)
    if not Hitbox then return end
    local Camera = Workspace.CurrentCamera
    local Mouse = UserInputService:GetMouseLocation()

    local PredictionGravity = Vector3.new(0,Hitbox[4] / PredictedGravity,0)
    local PredictionVelocity = (Hitbox[3].AssemblyLinearVelocity * Hitbox[4]) / PredictedVelocity
    local HitboxOnScreen = Camera:WorldToViewportPoint(Config.Prediction
    and Hitbox[3].Position + PredictionGravity + PredictionVelocity or Hitbox[3].Position)
    
    mousemoverel(
        (HitboxOnScreen.X - Mouse.X) * Config.Sensitivity,
        (HitboxOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

local function GetZombiesAllFOV(Config)
    local Camera = Workspace.CurrentCamera
    local ClosestZombies = {}

    for Index,Zombie in pairs(Zombies:GetChildren()) do
        local PrimaryPart = Zombie.PrimaryPart
        if not PrimaryPart then continue end

        local Magnitude = GetDistanceFromCamera(PrimaryPart.Position)
        if Magnitude <= Config.Distance then
            ClosestZombies[#ClosestZombies + 1] = PrimaryPart
        end
    end

    return ClosestZombies
end
local function GetItemsAllFOV(Config)
    local Camera = Workspace.CurrentCamera
    local ClosestItems = {}

    for Index,Item in pairs(LootBins:GetChildren()) do
        for Index, Group in pairs(Item:GetChildren()) do
            local Part = Group:FindFirstChild("Part")
            if not Part then continue end

            local Magnitude = GetDistanceFromCamera(Part.Position)
            if Magnitude <= Config.Distance then
                ClosestItems[#ClosestItems + 1] = Group
            end
        end
    end

    return ClosestItems
end
local function Length(Table) local Count = 0
    for Index, Value in pairs(Table) do
        Count += 1
    end return Count
end
local function CIIC(Data) -- ConcatItemsInContainer
    local String,Duplicates,Items
    = Data.DisplayName .. "\n",{},{}

    for Index,Value in pairs(Data.Occupants) do
        if Duplicates[Value.Name] then
            Duplicates[Value.Name] += 1
            print(Value.Name,Duplicates[Value.Name])
        else
            Duplicates[Value.Name] = 1
        end
    end

    for Item,Value in pairs(Duplicates) do
        if Value > 1 then
            Items[#Items + 1] = "[" .. Item .. "] x" .. Value
        else
            Items[#Items + 1] = "[" .. Item .. "]"
        end
    end
    return String .. table.concat(Items,"\n")
end

local OldSend = Network.Send
Network.Send = function(Self,Name,...) local Args = {...}
    --[[if Name == "Bullet Fired" and SilentAim
    and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
        local Hit,Position,Normal = CastBullet(SilentAim)
        if Hit then
            local Camera = Workspace.CurrentCamera
            local Unit = (SilentAim[3].Position - Camera.CFrame.Position).Unit
            Args[3] = Unit
            for Index,Bullet in pairs(Args[4]) do
                Bullet.Hit = Hit
                Bullet.Position = Position
                Bullet.HitPosition = Hit.Position
                Bullet.Normal = Normal
                Bullet.Direction = Unit
            end return OldSend(Self,Name,unpack(Args))
        end
    end]]
    if Window.Flags["AR2/SSCS"] then
        if Name == "Set Character State" then
            Args[1] = "Walking"
        end
    end
    return OldSend(Self,Name,unpack(Args))
end

setupvalue(Bullets.Fire,1,function(...)
    local Return = SpreadFunction(...)
    if Window.Flags["AR2/Recoil/Enabled"] then
        Return = Return * (Window.Flags["AR2/Recoil/Spread"] / 100)
    end return Return
end)

local OldFire = Bullets.Fire
Bullets.Fire = function(Self,...) local Args = {...}
    PredictedVelocity = Args[3].FireConfig.MuzzleVelocity
    if SilentAim and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
        local Camera = Workspace.CurrentCamera
        Args[5] = (SilentAim[3].Position - Camera.CFrame.Position).Unit
    end
    return OldFire(Self,unpack(Args))
end

local OldPost = Animators.Post
Animators.Post = function(Self,...) local Args = {...}
    if Args[1] == "FireImpulse" then
        if Window.Flags["AR2/Recoil/Enabled"] then
            Args[2][1] = Args[2][1] * (Window.Flags["AR2/Recoil/ShiftForce"] / 100)
            Args[2][2] = Args[2][2] * (Window.Flags["AR2/Recoil/RandomInt"] / 100)
            Args[2][3] = Args[2][3] * (Window.Flags["AR2/Recoil/RaiseForce"] / 100)
            Args[2][4] = Args[2][4] * (Window.Flags["AR2/Recoil/SlideForce"] / 100)
            Args[2][5] = Args[2][5] * (Window.Flags["AR2/Recoil/KickUpForce"] / 100)
        end
    end
    return OldPost(Self,unpack(Args))
end

local OldPlayAnimationReplicated = Animators.PlayAnimationReplicated
Animators.PlayAnimationReplicated = function(Self,Path,...)
    if Path == "Actions.Fall Impact"
    and Window.Flags["AR2/NoFallImpact"] then return end
    return OldPlayAnimationReplicated(Self,Path,...)
end

PlayerClass.CharacterAdded:Connect(function(Character)
    Character.MoveStateChanged:Connect(function(Old,New)
        if Window.Flags["AR2/AlwaysRun"] then
            Character.RunningInput = true
        end
        if Window.Flags["AR2/NoJumpDelay"] then
            Character.JumpDebounce = 0
        end
    end)
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
            TeamCheck = Window.Flags["TeamCheck"]
        }),{
            Prediction = Window.Flags["Aimbot/Prediction"],
            Sensitivity = Window.Flags["Aimbot/Smoothness"] / 100
        })
    end

    if Window.Flags["AR2/AntiZombie/Enabled"] then
        local ClosestZombies = GetZombiesAllFOV({Distance = 100})
        for Index,Zombie in pairs(ClosestZombies) do
            if isnetworkowner(Zombie) then
                Zombie.Anchored = true
            else
                Zombie.Anchored = false
            end
        end
    end
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
        BodyParts = Window.Flags["Trigger/BodyParts"],
        TeamCheck = Window.Flags["TeamCheck"]
    })

    if TriggerHitbox then mouse1press()
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
                    TeamCheck = Window.Flags["TeamCheck"]
                }) if not TriggerHitbox or not Trigger then break end
            end
        end mouse1release()
    end
end)
--[[Parvus.Utilities.Misc:NewThreadLoop(0,function()
    PlayerFly({
        Enabled = Window.Flags["AR2/Fly/Enabled"],
        Speed = Window.Flags["AR2/Fly/Speed"]
    })
end)]]
Parvus.Utilities.Misc:NewThreadLoop(1,function()
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return end
    local Items = GetItemsAllFOV({Distance = 100})

    if #Items > 0 and LocalPlayer.Character and not Interface:IsVisible("GameMenu") then
        for Index,Item in pairs(Items) do
            if not Interface:IsVisible("GameMenu") and not ItemMemory[Item] then
                local ContainerAvailable = Network:Fetch("Inventory Container Group Connect",Item)
                if ContainerAvailable and not Interface:IsVisible("GameMenu") then
                    Network:Send("Inventory Container Group Disconnect") ItemMemory[Item] = true
                    task.spawn(function() task.wait(120) ItemMemory[Item] = false end)
                end
            end
        end
    end
end)

for Index,Item in pairs(Loot:GetDescendants()) do
    local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
    if Item:IsA("Model") and ItemData then --print(ItemData.Parent.Name)
        Parvus.Utilities.Drawing:ItemESP(
            {Item.Parent,Item.Parent.Name,Item.Parent.Value.Position},
            "AR2/ESP/Items","AR2/ESP/Items/"..ItemData.Parent.Name,Window.Flags
        )
    end
end
for Index,Place in pairs(Randoms:GetChildren()) do
    if table.find(Places,Place.Name) then --print(Place.Name)
        Parvus.Utilities.Drawing:ItemESP(
            {Place,Place.Name,Place.Value.Position},
            "AR2/ESP/RandomPlaces","AR2/ESP/RandomPlaces",Window.Flags
        )
    end
end
for Index,Vehicle in pairs(Vehicles:GetChildren()) do
    Parvus.Utilities.Drawing:ItemESP(
        {Vehicle,Vehicle.Name,Vehicle.PrimaryPart},
        "AR2/ESP/Vehicles","AR2/ESP/Vehicles",Window.Flags
    )
end
for Index,Zombie in pairs(Zombies:GetChildren()) do
    if string.match(Zombie.Name,"Unique") then
        Parvus.Utilities.Drawing:ItemESP(
            {Zombie,Zombie.Name,Zombie.PrimaryPart},
            "AR2/ESP/Zombies","AR2/ESP/Zombies",Window.Flags
        )
    end
end

Loot.DescendantAdded:Connect(function(Item)
    local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
    if Item:IsA("Model") and ItemData then --print(ItemData.Parent.Name)
        Parvus.Utilities.Drawing:ItemESP(
            {Item.Parent,Item.Parent.Name,Item.Parent.Value.Position},
            "AR2/ESP/Items","AR2/ESP/Items/"..ItemData.Parent.Name,Window.Flags
        )
    end
end)
Randoms.ChildAdded:Connect(function(Place)
    if table.find(Places,Place.Name) then --print(Place.Name)
        Parvus.Utilities.Drawing:ItemESP(
            {Place,Place.Name,Place.Value.Position},
            "AR2/ESP/RandomPlaces","AR2/ESP/RandomPlaces",Window.Flags
        )
        if Window.Flags["AR2/ESP/RandomPlaces/Enabled"] then
            Parvus.Utilities.UI:Notification2({
                Title = string.format("%s spawned (~%i meters away)",Place.Name,
                GetDistanceFromCamera(Place.Value.Position) * 0.28),Duration = 20
            })
        end
    end
end)
Vehicles.ChildAdded:Connect(function(Vehicle)
    repeat task.wait() until Vehicle.PrimaryPart
    Parvus.Utilities.Drawing:ItemESP(
        {Vehicle,Vehicle.Name,Vehicle.PrimaryPart},
        "AR2/ESP/Vehicles","AR2/ESP/Vehicles",Window.Flags
    )
end)
Zombies.ChildAdded:Connect(function(Zombie)
    repeat task.wait() until Zombie.PrimaryPart
    if string.match(Zombie.Name,"Unique") then
        Parvus.Utilities.Drawing:ItemESP(
            {Zombie,Zombie.Name,Zombie.PrimaryPart},
            "AR2/ESP/Zombies","AR2/ESP/Zombies",Window.Flags
        )
    end
end)

Loot.DescendantRemoving:Connect(function(Item)
    if Item:IsA("Model") then
        Parvus.Utilities.Drawing:RemoveESP(Item.Parent)
    end
end)
Randoms.ChildRemoved:Connect(function(Place)
    Parvus.Utilities.Drawing:RemoveESP(Place)
end)
Vehicles.ChildRemoved:Connect(function(Vehicle)
    Parvus.Utilities.Drawing:RemoveESP(Vehicle)
end)
Zombies.ChildRemoved:Connect(function(Zombie)
    Parvus.Utilities.Drawing:RemoveESP(Zombie)
end)

local OldICA, OldCC = Events["Inventory Container Added\r"], Events["Container Changed\r"]
Events["Inventory Container Added\r"] = function(Id,Data,...)
    if Data.WorldPosition and Length(Data.Occupants) > 0 and not string.find(Data.Type,"Corpse") then
        Parvus.Utilities.Drawing:ItemESP({Data.Id,CIIC(Data),Data.WorldPosition},
        "AR2/ESP/Items","AR2/ESP/Items/Containers",Window.Flags)
    end return OldICA(Id,Data,...)
end
Events["Container Changed\r"] = function(Data,...)
    Parvus.Utilities.Drawing:RemoveESP(Data.Id)
    if Data.WorldPosition and Length(Data.Occupants) > 0 and not string.find(Data.Type,"Corpse") then
        Parvus.Utilities.Drawing:ItemESP({Data.Id,CIIC(Data),Data.WorldPosition},
        "AR2/ESP/Items","AR2/ESP/Items/Containers",Window.Flags)
    end return OldCC(Data,...)
end

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
