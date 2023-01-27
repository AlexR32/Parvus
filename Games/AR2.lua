local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Loaded,PromptLib = false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
if identifyexecutor() ~= "Synapse X" then
    PromptLib("Unsupported executor","Synapse X only for safety measures\nIf you still want to use the script, click \"Ok\"",{
        {Text = "Ok",LayoutOrder = 0,Primary = false,Callback = function() Loaded = true end},
    }) repeat task.wait(1) until Loaded
end

local Framework = require(ReplicatedFirst.Framework) Framework:WaitForLoaded()
repeat task.wait() until Framework.Classes.Players.get()
local PlayerClass = Framework.Classes.Players.get()

for i,c in pairs(getconnections(game:GetService("ScriptContext").Error)) do c:Disable() end

local Raycasting = Framework.Libraries.Raycasting
local Interface = Framework.Libraries.Interface
local Network = Framework.Libraries.Network
local Bullets = Framework.Libraries.Bullets
local Cameras = Framework.Libraries.Cameras

local Animators = Framework.Classes.Animators
local VehicleController = Framework.Classes.VehicleControler
local CharacterCamera = Cameras.CameraList.Character

local Events = getupvalue(Network.Add,4)
local GetSpreadAngle = getupvalue(Bullets.Fire,1)
--local GetSpreadVector = getupvalue(Bullets.Fire,3)
--local CastLocalBullet = getupvalue(Bullets.Fire,4)
local FlinchCamera = getupvalue(Bullets.Fire,5)
local GetFireImpulse = getupvalue(Bullets.Fire,7)

local NullFunction = function() end
setupvalue(Network.Send,6,NullFunction)
setupvalue(Network.Fetch,6,NullFunction)

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Aimbot,SilentAim,Trigger = false,nil,nil

local ProjectileSpeed,ProjectileGravity,GravityCorrection = 1000,
Vector3.new(0,math.abs(Framework.Configs.Globals.ProjectileGravity),0),2

local LootBins = Workspace.Map.Shared.LootBins
local Randoms = Workspace.Map.Shared.Randoms
local Vehicles = Workspace.Vehicles.Spawned
local Corpses = Workspace.Corpses
local Zombies = Workspace.Zombies
local Loot = Workspace.Loot

local ItemMemory,TPActive,TPPosition,
FlyPosition,NoClipEvent,NoClipObjects
= {},false,nil,nil,nil,{}

-- game data mess
local RandomEvents,ItemCategory,ZombieInherits,SanityBans = {
"ATVCrashsiteRenegade01","CampSovietBandit01","CrashPrisonBus01",
"LifePreserverMilitary01","LifePreserverSoviet01","LifePreserverSpecOps01",
"MilitaryBlockade01","MilitaryConvoy01","PartyTrailerDisco01",
"PartyTrailerTechnoGold","PartyTrailerTechnoGoldDeagleMod1",
"PirateTreasure01","SeahawkCrashsite04","SeahawkCrashsite05",
"SeahawkCrashsite06","SeahawkCrashsite07","SpecialForcesCrash01",
"SeahawkCrashsiteRogue01","BankTruckRobbery01","StrandedStationKeyboard01",

-- Christmas Random Events
--[["SnowmanStructure02","SnowmanStructure01","ChristmasTreeHouse01",
"ChristmasTreeSpecialForces01","ChristmasTreeHouse03","ChristmasSantaSleigh03",
"ChristmasTreeHouse02","ChristmasSantaSleigh02","ChristmasSantaSleigh01",
"ChristmasSantaSleigh04","GhillieGiftBoxEvent","ChristmasSnowmanWreck01","ChristmasTreeHouse04"]]},

{"Containers","Accessories","Ammo","Attachments","Backpacks","Belts","Clothing",
"Consumables","Firearms","Hats","Medical","Melees","Utility","VehicleParts","Vests"},

{"Presets.Behavior Boss Level 01","Presets.Behavior Boss Level 02","Presets.Behavior Boss Level 03",
"Presets.Behavior Common Level 01","Presets.Behavior Common Level 02","Presets.Behavior Common Level 03",
"Presets.Behavior Common Thrall Level 01","Presets.Behavior MiniBoss Level 01","Presets.Behavior MiniBoss Level 02"},

{"Character Humanoid Update","Character Root Update","Get Player Stance Speed",
"Force Charcter Save","Update Character State","Sync Near Chunk Loot",
"Resync Character Physics","Update Character Position"}

local InteractHeartbeat,FindItemData
for Index,Table in pairs(getgc(true)) do
    if typeof(Table) == "table"
    and rawget(Table,"Rate") == 0.05 then
        InteractHeartbeat = Table.Action
        FindItemData = getupvalue(InteractHeartbeat,11)
    end
end

--[[local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
BodyVelocity.Velocity = Vector3.zero]]

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        --[[local GlobalSection = AimAssistTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Toggle({Name = "Team Check",Flag = "TeamCheck",Value = false})
        end]]
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = true})
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
                --{Name = "HeadCollider",Mode = "Toggle"},
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
            SilentAimSection:Toggle({Name = "Prediction",Flag = "SilentAim/Prediction",Value = true})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FOV",Flag = "SilentAim/DynamicFOV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100})
            SilentAimSection:Slider({Name = "Distance",Flag = "SilentAim/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                --{Name = "HeadCollider",Mode = "Toggle"},
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
            TriggerSection:Slider({Name = "Distance",Flag = "Trigger/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
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
        end Parvus.Utilities.Misc:LightingSection(VisualsTab,"Right")
    end
    local ESPTab = Window:Tab({Name = "AR2 ESP"}) do
        local ItemSection = ESPTab:Section({Name = "Item ESP",Side = "Left"}) do local Items = {}
            ItemSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Items/Enabled",Value = false})
            ItemSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Items/DistanceCheck",Value = true})
            ItemSection:Slider({Name = "Distance",Flag = "AR2/ESP/Items/Distance",Min = 25,Max = 5000,Value = 50,Unit = "studs"})
            for Index,Name in pairs(ItemCategory) do
                local ItemFlag = "AR2/ESP/Items/" .. Name Window.Flags[ItemFlag.."/Enabled"] = false
                Items[#Items + 1] = {Name = Name,Mode = "Toggle",Value = false,
                    Colorpicker = {Flag = ItemFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[ItemFlag.."/Enabled"] = Option.Value end
                }
            end ItemSection:Dropdown({Name = "ESP List",Flag = "AR2/Items",List = Items})
        end
        local ZombiesSection = ESPTab:Section({Name = "Zombies ESP",Side = "Left"}) do local ZIs = {}
            ZombiesSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Zombies/Enabled",Value = false})
            ZombiesSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Zombies/DistanceCheck",Value = true})
            ZombiesSection:Slider({Name = "Distance",Flag = "AR2/ESP/Zombies/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "studs"})

            for Index,Inherit in pairs(ZombieInherits) do
                local InheritName = Inherit:gsub("Presets.Behavior",""):gsub(" ","")
                local REFlag = "AR2/ESP/Zombies/" .. InheritName
                Window.Flags[REFlag.."/Enabled"] = false

                ZIs[#ZIs + 1] = {Name = InheritName,Mode = "Toggle",Value = true,
                    Colorpicker = {Flag = REFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[REFlag.."/Enabled"] = Option.Value end
                }
            end ZombiesSection:Dropdown({Name = "ESP List",Flag = "AR2/Zombies",List = ZIs})
        end
        --[[local ItemCSection = ESPTab:Section({Name = "Item Colors",Side = "Left"}) do
            for Index,Name in pairs(ItemCategory) do local ItemFlag = "AR2/ESP/Items/" .. Name
                ItemCSection:Colorpicker({Name = Name,Flag = ItemFlag.."/Color",Value = {1,0,1,0,false}})
            end
        end]]
        local RESection = ESPTab:Section({Name = "Random Events ESP",Side = "Right"}) do local REs = {}
            RESection:Toggle({Name = "Enabled",Flag = "AR2/ESP/RandomEvents/Enabled",Value = false})
            RESection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/RandomEvents/DistanceCheck",Value = true})
            RESection:Slider({Name = "Distance",Flag = "AR2/ESP/RandomEvents/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "studs"})
            for Index,Name in pairs(RandomEvents) do
                local REFlag = "AR2/ESP/RandomEvents/" .. Name Window.Flags[REFlag.."/Enabled"] = false
                REs[#REs + 1] = {Name = Name,Mode = "Toggle",Value = true,
                    Colorpicker = {Flag = REFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[REFlag.."/Enabled"] = Option.Value end
                }
            end RESection:Dropdown({Name = "ESP List",Flag = "AR2/RandomEvents",List = REs})
        end
        --[[local RECSection = ESPTab:Section({Name = "Random Events Colors",Side = "Right"}) do
            for Index,Name in pairs(RandomEvents) do local REFlag = "AR2/ESP/RandomEvents/" .. Name
                RECSection:Colorpicker({Name = Name,Flag = REFlag.."/Color",Value = {1,0,1,0,false}})
            end
        end]]
        local VehiclesSection = ESPTab:Section({Name = "Vehicles ESP",Side = "Right"}) do
            VehiclesSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Vehicles/Enabled",Value = false})
            VehiclesSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Vehicles/DistanceCheck",Value = true})
            VehiclesSection:Colorpicker({Name = "Color",Flag = "AR2/ESP/Vehicles/Color",Value = {1,0,1,0,false}})
            VehiclesSection:Slider({Name = "Distance",Flag = "AR2/ESP/Vehicles/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "studs"})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local RecoilSection = MiscTab:Section({Name = "Weapon",Side = "Left"}) do
            RecoilSection:Toggle({Name = "Unlock Firemodes",Flag = "AR2/Firemodes",Value = false})
            RecoilSection:Toggle({Name = "No Spread",Flag = "AR2/NoSpread",Value = false})
            RecoilSection:Toggle({Name = "No Camera Flinch",Flag = "AR2/NoFlinch",Value = false})
            RecoilSection:Divider()
            RecoilSection:Toggle({Name = "Recoil Control",Flag = "AR2/Recoil/Enabled",Value = false})
            RecoilSection:Slider({Name = "Shift Force",Flag = "AR2/Recoil/ShiftForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Roll Bias",Flag = "AR2/Recoil/RollBias",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Raise Force",Flag = "AR2/Recoil/RaiseForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Slide Force",Flag = "AR2/Recoil/SlideForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "KickUp Force",Flag = "AR2/Recoil/KickUpForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Bob Force",Flag = "AR2/Bob/Force",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Bob Damping",Flag = "AR2/Bob/Damping",Min = 0,Max = 100,Value = 0,Unit = "%"})
        end
        local VehSection = MiscTab:Section({Name = "Vehicle",Side = "Left"}) do
            VehSection:Toggle({Name = "Enabled",Flag = "AR2/Vehicle/Enabled",Value = false})
            VehSection:Slider({Name = "Speed",Flag = "AR2/Vehicle/Speed",Min = 100,Max = 500,Value = 200})
            VehSection:Slider({Name = "Steer",Flag = "AR2/Vehicle/Steer",Min = 100,Max = 500,Value = 200})
            --[[VehSection:Slider({Name = "Damping",Flag = "AR2/Vehicle/Damping",Min = 0,Max = 200,Value = 100})
            VehSection:Slider({Name = "Velocity",Flag = "AR2/Vehicle/Velocity",Min = 0,Max = 200,Value = 100})]]
        end
        --[[local TargetSection = MiscTab:Section({Name = "Target",Side = "Right"}) do
            local PlayerDropdown = TargetSection:Dropdown({Name = "Player List",IgnoreFlag = true})
            PlayerDropdown:RefreshToPlayers(false)
            TargetSection:Button({Name = "Refresh",Callback = function()
                PlayerDropdown:RefreshToPlayers(false)
            end})

            TargetSection:Button({Name = "Goto",Callback = function()
                if not PlayerClass.Character then return end
                local PlayerName = PlayerDropdown.Value[1]
                if not PlayerName then return end

                local PlayerCharacter = PlayerService[PlayerName].Character
                if not PlayerCharacter then return end

                TPPosition = PlayerCharacter.PrimaryPart.CFrame
                TPActive = true

                task.spawn(function()
                    while task.wait() do
                        PlayerClass.Character.RootPart.CFrame = TPPosition  - Vector3.new(0,10,0)
                        if not TPActive then break end
                    end
                end)

                task.wait(4)
                PlayerClass.Character.RootPart.CFrame = TPPosition
                TPActive = false
            end})]]
            --TargetSection:Button({Name = "TP Zombies",Callback = function()
                --local OldAntiZombie = Window:GetValue("AR2/AntiZombie/Enabled")
                --Window:SetValue("AR2/AntiZombie/Enabled",false)

                --local ClosestZombies = GetZombies(200)
                --for Index,Zombie in pairs(ClosestZombies) do
                    --if isnetworkowner(Zombie.PrimaryPart) then
                        --Zombie.PrimaryPart.Anchored = false
                        --Zombie.PrimaryPart.CFrame = PlayerService[PlayerDropdown.Value[1]].Character.PrimaryPart.CFrame
                    --end
                --end ClosestZombies = nil

                --Window:SetValue("AR2/AntiZombie/Enabled",OldAntiZombie)
            --end})
        --end
        local CharSection = MiscTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "Fly Enabled",Flag = "AR2/Fly/Enabled",Value = false,Callback = function(Bool)
                --[[if Bool and PlayerClass.Character then BodyVelocity.Parent = PlayerClass.Character.RootPart
                else BodyVelocity.Parent = nil end]]

                if Bool and PlayerClass.Character then FlyPosition = PlayerClass.Character.RootPart.CFrame end
            end}):Keybind({Flag = "AR2/Fly/Keybind"})
            CharSection:Slider({Name = "Fly Value",Flag = "AR2/Fly/Value",Min = 1,Max = 10,Precise = 1,Value = 1})
            CharSection:Divider()
            CharSection:Toggle({Name = "WalkSpeed Enabled",Flag = "AR2/WalkSpeed/Enabled",Value = false}):Keybind()
            CharSection:Slider({Name = "WalkSpeed Value",Flag = "AR2/WalkSpeed/Value",Min = 26,Max = 500,Value = 26})
            CharSection:Divider()
            CharSection:Toggle({Name = "JumpPower Enabled",Flag = "AR2/JumpPower/Enabled",Value = false}):Keybind()
            CharSection:Slider({Name = "JumpPower Value",Flag = "AR2/JumpPower/Value",Min = 32,Max = 500,Value = 32})
            CharSection:Divider()
            CharSection:Toggle({Name = "Equip In Air",Flag = "AR2/EquipInAir",Value = false})
            CharSection:Toggle({Name = "Equip In Water",Flag = "AR2/EquipInWater",Value = false})
            CharSection:Toggle({Name = "Equip In Vehicle",Flag = "AR2/EquipInVehicle",Value = false})
            CharSection:Toggle({Name = "No Fall Impact",Flag = "AR2/NoFallImpact",Value = false})
            CharSection:Toggle({Name = "No Jump Delay",Flag = "AR2/NoJumpDelay",Value = false})
        end
        local MiscSection = MiscTab:Section({Name = "Misc",Side = "Right"}) do
            MiscSection:Toggle({Name = "Instant Search",Flag = "AR2/InstantSearch",Value = false})
            MiscSection:Toggle({Name = "Anti-Zombie",Flag = "AR2/AntiZombie/Enabled",Value = false}):Keybind()
            --MiscSection:Toggle({Name = "Anti-Zombie KillAura",Flag = "AR2/AntiZombie/KillAura",Value = false})
            local SpoofSCS = MiscSection:Toggle({Name = "Spoof SCS",Flag = "AR2/SSCS",Value = false}) SpoofSCS:Keybind()
            SpoofSCS:ToolTip("SCS - Set Character State:\nNo Fall Damage\nLess Hunger / Thirst\nWhile Sprinting")
            --[[MiscSection:Button({Name = "TP Corpses",Callback = function()
                if not PlayerClass.Character then return end
                for Index,Item in pairs(Corpses:GetDescendants()) do
                    if Item:IsA("BasePart") then
                        if isnetworkowner(Item) then
                            print(Item)
                            Item.Parent:PivotTo(PlayerClass.Character.RootPart.CFrame)
                        end
                    end
                end
            end})
            MiscSection:Button({Name = "TP Loot",Callback = function()
                if not PlayerClass.Character then return end
                for Index,Item in pairs(Loot:GetDescendants()) do
                    if Item:IsA("Model") then
                        for i,v in pairs(Item:GetChildren()) do
                            if v:IsA("BasePart") then
                                if isnetworkowner(v) then
                                    Item:PivotTo(PlayerClass.Character.RootPart.CFrame)
                                    Item.Parent.Value = PlayerClass.Character.RootPart.CFrame
                                end
                            end
                        end
                    elseif Item:IsA("BasePart") and not Item.Parent:IsA("Model") then
                        if isnetworkowner(Item) then
                            Item.CFrame = PlayerClass.Character.RootPart.CFrame
                            Item.Parent.Value = PlayerClass.Character.RootPart.CFrame
                        end
                    end
                end
            end})]]
            MiscSection:Toggle({Name = "NoClip",Flag = "AR2/NoClip",Value = false,
            Callback = function(Bool)
                if Bool and not NoClipEvent then
                    NoClipEvent = RunService.Stepped:Connect(function()
                        if not LocalPlayer.Character then return end
                
                        for Index,Object in pairs(LocalPlayer.Character:GetDescendants()) do
                            if Object:IsA("BasePart") then
                                if NoClipObjects[Object] == nil then
                                    NoClipObjects[Object] = Object.CanCollide
                                end Object.CanCollide = false
                            end
                        end
                    end)
                elseif not Bool and NoClipEvent then
                    NoClipEvent:Disconnect()
                    NoClipEvent = nil
            
                    task.wait(0.1)
                    for Object,CanCollide in pairs(NoClipObjects) do
                        Object.CanCollide = CanCollide
                    end table.clear(NoClipObjects)
                end
            end}):Keybind()
            MiscSection:Toggle({Name = "Map ESP",Flag = "AR2/MapESP",Value = false,Callback = function(Bool)
                if Bool then Interface:Get("Map"):EnableGodview() else Interface:Get("Map"):DisableGodview() end
            end}):Keybind()
        end
    end Parvus.Utilities.Misc:SettingsSection(Window,"Period",true)
end

Window:SetValue("Background/Offset",296)
Window:LoadDefaultConfig("Parvus")
Window:SetValue("UI/Toggle",Window.Flags["UI/OOL"])

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Misc:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.FilterDescendantsInstances = {
    Workspace.Effects,Workspace.Sounds,
    Workspace.Locations,Workspace.Spawns
} WallCheckParams.IgnoreWater = true

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

local function Raycast(Origin,Direction)
    if not table.find(WallCheckParams.FilterDescendantsInstances,LocalPlayer.Character) then
        WallCheckParams.FilterDescendantsInstances = {
            Workspace.Effects,Workspace.Sounds,
            Workspace.Locations,Workspace.Spawns,
            LocalPlayer.Character
        } --print("added character to raycast")
    end

    local RaycastResult = Workspace:Raycast(Origin,Direction,WallCheckParams)
    if RaycastResult then
		if (RaycastResult.Instance.Transparency == 1
        and RaycastResult.Instance.CanCollide == false)
        or (CollectionService:HasTag(RaycastResult.Instance,"Bullets Penetrate")
        or CollectionService:HasTag(RaycastResult.Instance,"Window Part")
        or CollectionService:HasTag(RaycastResult.Instance,"World Mesh")
        or CollectionService:HasTag(RaycastResult.Instance,"World Water Part")) then
			return true
		end
    end
end

local function PlayerFly(Enabled,Speed)
    local Character = PlayerClass.Character
    if not Enabled or not Character
    or not FlyPosition then return end

    --BodyVelocity.Velocity = InputToVelocity() * Speed
    FlyPosition += InputToVelocity() * Speed
    Character.RootPart.AssemblyLinearVelocity = Vector3.zero
    Character.RootPart.CFrame = FlyPosition
end

local function GetDistanceFromCamera(Position)
    return (Position - Camera.CFrame.Position).Magnitude
end

local function TeamCheck(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
end

local function DistanceCheck(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance <= MaxDistance
end

local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    return Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position)
end

local function CalculateTrajectory(Origin,Velocity,Time,Gravity)
    --[[local PredictedPosition = Origin + Velocity * Time
    local Delta = (PredictedPosition - Origin).Magnitude
    Time = Time + Delta / ProjectileSpeed]]

    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end

local function GetClosest(Enabled,FOV,DFOV,TC,BP,WC,DC,MD,PE)
    -- FieldOfView,DynamicFieldOfView,TeamCheck
    -- BodyParts,WallCheck,DistanceCheck,MaxDistance
    -- PredictionEnabled

    if not Enabled then return end local Closest = nil
    FOV = DFOV and FOV * (1 + (80 - Camera.FieldOfView) / 100) or FOV

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end
        local Character = Player.Character

        if Character and TeamCheck(TC,Player) then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid then continue end if Humanoid.Health <= 0 then continue end

            for Index,BodyPart in pairs(BP) do
                BodyPart = Character:FindFirstChild(BodyPart) if not BodyPart then continue end
                local Distance = (BodyPart.Position - Camera.CFrame.Position).Magnitude
                if WallCheck(WC,BodyPart) and DistanceCheck(DC,Distance,MD) then
                    local BPPosition = PE and CalculateTrajectory(BodyPart.Position,
                    BodyPart.AssemblyLinearVelocity,Distance / ProjectileSpeed,
                    ProjectileGravity) or BodyPart.Position

                    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BPPosition)
                    local NewFOV = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and NewFOV <= FOV then FOV,Closest = NewFOV,{Player,Character,BodyPart,BPPosition,ScreenPosition} end
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
        (Hitbox[5].X - Mouse.X) * Smoothness,
        (Hitbox[5].Y - Mouse.Y) * Smoothness
    )
end

function GetZombies(Distance)
    local ClosestZombies = {}

    for Index,Zombie in pairs(Zombies.Mobs:GetChildren()) do
        local PrimaryPart = Zombie.PrimaryPart
        if not PrimaryPart then continue end

        if GetDistanceFromCamera(PrimaryPart.Position) <= Distance then
            ClosestZombies[#ClosestZombies + 1] = Zombie
        end
    end

    return ClosestZombies
end
local function GetItems(Distance)
    local ClosestItems = {}

    for Index,Item in pairs(LootBins:GetChildren()) do
        for Index,Group in pairs(Item:GetChildren()) do
            local Part = Group:FindFirstChild("Part")
            if not Part then continue end

            if GetDistanceFromCamera(Part.Position) <= Distance then
                ClosestItems[#ClosestItems + 1] = Group
            end
        end
    end

    return ClosestItems
end

local function Length(Table) local Count = 0
    for Index, Value in pairs(Table) do Count += 1 end
    return Count
end
local function CIIC(Data) -- ConcatItemsInContainer
    local Duplicates,Items = {},{Data.DisplayName}

    for Index,Value in pairs(Data.Occupants) do
        if Duplicates[Value.Name] then
            Duplicates[Value.Name] += 1
            --print(Value.Name,Duplicates[Value.Name])
        else
            Duplicates[Value.Name] = 1
        end
    end

    for Item,Value in pairs(Duplicates) do
        if Value == 1 then
            Items[#Items + 1] = "[" .. Item .. "]"
        else
            Items[#Items + 1] = "[" .. Item .. "] x" .. Value
        end
    end
    return table.concat(Items,"\n")
end

local function HookCharacter(Character)
    FlyPosition = Character.RootPart.CFrame
    --[[if Window.Flags["AR2/Fly/Enabled"] then
        BodyVelocity.Parent = Character.RootPart
    end]]

    -- Old Equip In Air
    --[[local OldFalling = Character.Falling.Fire
    Character.Falling.Fire = function(Self,Time,...)
        if Window.Flags["AR2/Fly/Enabled"] then
            Character.MoveState = "Walking" Time = 0
        end return OldFalling(Self,Time,...)
    end]]
    local OldEquip = Character.Equip
    Character.Equip = function(Self,Item,...)
        if Item.FireConfig and Item.FireConfig.MuzzleVelocity then
            ProjectileSpeed = Item.FireConfig.MuzzleVelocity
        end
        if Window.Flags["AR2/EquipInVehicle"] and Self.Sitting then
            local OldCanEquipInVehicles = Item.CanEquipInVehicles
            Item.CanEquipInVehicles = true Self.Sitting = false OldEquip(Self,Item,...)
            Self.Sitting = true Item.CanEquipInVehicles = OldCanEquipInVehicles return true
        end return OldEquip(Self,Item,...)
    end
    --[[local OldSetSitting = Character.SetSitting
    Character.SetSitting = function(...)
        return OldSetSitting(...)
    end]]
    local OldMoveSpeed = Character.MoveSpeedSpring.SetGoal
    Character.MoveSpeedSpring.SetGoal = function(Self,Speed,...)
        if Window.Flags["AR2/WalkSpeed/Enabled"] then
            Speed = Window.Flags["AR2/WalkSpeed/Value"]
        end
        if Window.Flags["AR2/Fly/Enabled"] then Speed = 0 end
        return OldMoveSpeed(Self,Speed,...)
    end
    local OldJumped = Character.Jumped.Fire
    Character.Jumped.Fire = function(...)
        if Window.Flags["AR2/NoJumpDelay"] then Character.JumpDebounce = 0 end
        if Window.Flags["AR2/JumpPower/Enabled"] then
            Character.Humanoid.JumpPower = Window.Flags["AR2/JumpPower/Value"]
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end return OldJumped(...)
    end
    for Index,Spring in pairs({"WobblePos","WobbleRot","RotationVelocity","MoveVelocity"}) do
        local OldSpring = Character.Animator.Springs[Spring].Retune
        Character.Animator.Springs[Spring].Retune = function(Self,Force,Damping,...)
            if Window.Flags["AR2/Recoil/Enabled"] then
                Force = Force * (Window.Flags["AR2/Bob/Force"] / 100)
                Damping = Damping * (Window.Flags["AR2/Bob/Damping"] / 100)
            end return OldSpring(Self,Force,Damping,...)
        end
    end
    local OldToolAction = Character.Actions.ToolAction
    Character.Actions.ToolAction = function(Self,...)
        if Window.Flags["AR2/Firemodes"] then
            local FireModes = Self.EquippedItem.FireModes
            if not table.find(FireModes,"Semiautomatic") then
                setreadonly(FireModes,false)
                table.insert(FireModes,"Semiautomatic")
                setreadonly(FireModes,true)
            end
            if not table.find(FireModes,"Automatic") then
                setreadonly(FireModes,false)
                table.insert(FireModes,"Automatic")
                setreadonly(FireModes,true)
            end
            if not table.find(FireModes,"Burst") then
                setreadonly(FireModes,false)
                table.insert(FireModes,"Burst")
                setreadonly(FireModes,true)
            end
        end
        return OldToolAction(Self,...)
    end
end

setupvalue(Bullets.Fire,1,function(Character,CCamera,...)
    if Window.Flags["AR2/NoSpread"] then
        return GetSpreadAngle(
            {MoveState = "Walking",Zooming = true},
            {FirstPerson = true},...
        )
    end return GetSpreadAngle(Character,CCamera,...)
end)

setupvalue(Bullets.Fire,5,function(...)
    if Window.Flags["AR2/NoFlinch"] then return end
    return FlinchCamera(...)
end)

setupvalue(Bullets.Fire,7,function(Character,Item,...)
    if Window.Flags["AR2/Recoil/Enabled"] then
        local FireImpulse = GetFireImpulse(Character,Item,...)
        FireImpulse[1] = FireImpulse[1] * (Window.Flags["AR2/Recoil/ShiftForce"] / 100)
        FireImpulse[2] = FireImpulse[2] * (Window.Flags["AR2/Recoil/RollBias"] / 100)
        FireImpulse[3] = FireImpulse[3] * (Window.Flags["AR2/Recoil/RaiseForce"] / 100)
        FireImpulse[4] = FireImpulse[4] * (Window.Flags["AR2/Recoil/SlideForce"] / 100)
        FireImpulse[5] = FireImpulse[5] * (Window.Flags["AR2/Recoil/KickUpForce"] / 100)
        return FireImpulse
    end return GetFireImpulse(Character,Item,...)
end)

setupvalue(InteractHeartbeat,11,function(...)
    if Window.Flags["AR2/InstantSearch"] then
        local Args = {FindItemData(...)}
        Args[4] = 0 return unpack(Args)
    end return FindItemData(...)
end)

local OldSend = Network.Send
Network.Send = function(Self,Name,...) local Args = {...}
    if table.find(SanityBans,Name) then return end

    if Name == "Character Jumped"
    and Window.Flags["AR2/SSCS"] then
        return
    end

    --[[if Name == "Animator State Report" then
        if Window.Flags["AR2/EquipInAir"] then
            print(repr(Args[2]))
            if Args[2].MoveState == "Falling" then
                print("Falling bypass")
                return
            end
        end
    end]]
    --[[if Name == "Animator Camera Position Report" then
        if TPActive then Args[1] = TPPosition end
    end]]

    if Name == "Set Character State" then
        if Window.Flags["AR2/SSCS"]
        or Window.Flags["AR2/Fly/Enabled"]
        or Window.Flags["AR2/WalkSpeed/Enabled"] then
            Args[1] = "Climbing"
        end
        --[[if TPActive then
            Args[1] = "Climbing"
            Args[2] = TPPosition
        end]]
        if Window.Flags["AR2/NoSpread"] then
            Args[3] = true Args[4] = true
        end
    end

    return OldSend(Self,Name,unpack(Args))
end
local OldFire = Bullets.Fire
Bullets.Fire = function(Self,...) local Args = {...}
    if SilentAim and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
        Args[5] = (SilentAim[4] - Args[4]).Unit
    end return OldFire(Self,unpack(Args))
end
-- Old Recoil Control
--[[local OldPost = Animators.Post
Animators.Post = function(Self,Name,...) local Args = {...}
    if Window.Flags["AR2/Recoil/Enabled"] and Name == "FireImpulse" then
        Args[1][1] = Args[1][1] * (Window.Flags["AR2/Recoil/ShiftForce"] / 100)
        Args[1][2] = Args[1][2] * (Window.Flags["AR2/Recoil/RollBias"] / 100)
        Args[1][3] = Args[1][3] * (Window.Flags["AR2/Recoil/RaiseForce"] / 100)
        Args[1][4] = Args[1][4] * (Window.Flags["AR2/Recoil/SlideForce"] / 100)
        Args[1][5] = Args[1][5] * (Window.Flags["AR2/Recoil/KickUpForce"] / 100)
    end return OldPost(Self,Name,unpack(Args))
end]]
local OldCharacterGroundCast = Raycasting.CharacterGroundCast
Raycasting.CharacterGroundCast = function(Self,Position,LengthDown,...)
    if PlayerClass.Character and Position == PlayerClass.Character.RootPart.CFrame then
        if Window.Flags["AR2/EquipInAir"] then LengthDown = 1e6 end
    end return OldCharacterGroundCast(Self,Position,LengthDown,...)
end
local OldConnectVehicle = CharacterCamera.ConnectVehicle
CharacterCamera.ConnectVehicle = function(...)
    if Window.Flags["AR2/EquipInVehicle"] then return end
    return OldConnectVehicle(...)
end
local OldFlinch = CharacterCamera.Flinch
CharacterCamera.Flinch = function(Self,...)
    if Window.Flags["AR2/NoFlinch"] then return end
    return OldFlinch(Self,...)
end
local OldSwimCheckCast = Raycasting.SwimCheckCast
Raycasting.SwimCheckCast = function(Self,...)
    if Window.Flags["AR2/EquipInWater"] then return nil end
    return OldSwimCheckCast(Self,...)
end
local OldPlayAnimationReplicated = Animators.PlayAnimationReplicated
Animators.PlayAnimationReplicated = function(Self,Path,...)
    if Window.Flags["AR2/NoFallImpact"] and
    Path == "Actions.Fall Impact" then return end
    return OldPlayAnimationReplicated(Self,Path,...)
end

local OldVC = VehicleController.new
VehicleController.new = function(...)
    local Return = OldVC(...) local OldStep = Return.Step Return.Step = function(Self,...)
        if Window.Flags["AR2/Vehicle/Enabled"] then
            local MoveVector = PlayerClass.Character.MoveVector
            Self.ThrottleSolver.Position = -MoveVector.Z
            * Window.Flags["AR2/Vehicle/Speed"] / 100
            Self.SteerSolver.Position = MoveVector.X
            * Window.Flags["AR2/Vehicle/Steer"] / 100

            --[[Self.ThrottleSolver.Speed = Window.Flags["AR2/Vehicle/Speed"]
            Self.ThrottleSolver.Damping = Window.Flags["AR2/Vehicle/Damping"]
            Self.ThrottleSolver.Velocity = Window.Flags["AR2/Vehicle/Velocity"]]
        end return OldStep(Self,...)
    end
end

if PlayerClass.Character then
    HookCharacter(PlayerClass.Character)
end
PlayerClass.CharacterAdded:Connect(function(Character)
    HookCharacter(Character)
end)

RunService.Heartbeat:Connect(function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"],
        Window.Flags["SilentAim/FieldOfView"],
        Window.Flags["SilentAim/DynamicFOV"],
        Window.Flags["TeamCheck"],
        Window.Flags["SilentAim/BodyParts"],
        Window.Flags["SilentAim/WallCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/Distance"],
        Window.Flags["SilentAim/Prediction"]
    )
    if Aimbot then
        AimAt(GetClosest(
            Window.Flags["Aimbot/Enabled"],
            Window.Flags["Aimbot/FieldOfView"],
            Window.Flags["Aimbot/DynamicFOV"],
            Window.Flags["TeamCheck"],
            Window.Flags["Aimbot/BodyParts"],
            Window.Flags["Aimbot/WallCheck"],
            Window.Flags["Aimbot/DistanceCheck"],
            Window.Flags["Aimbot/Distance"],
            Window.Flags["Aimbot/Prediction"]
        ),Window.Flags["Aimbot/Smoothness"] / 100)
    end
end)
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    if not Trigger then return end
    local TriggerHitbox = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/FieldOfView"],
        Window.Flags["Trigger/DynamicFOV"],
        Window.Flags["TeamCheck"],
        Window.Flags["Trigger/BodyParts"],
        Window.Flags["Trigger/WallCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/Distance"],
        Window.Flags["Trigger/Prediction"]
    )

    if TriggerHitbox then mouse1press()
        task.wait(Window.Flags["Trigger/Delay"])
        if Window.Flags["Trigger/HoldMode"] then
            while task.wait() do
                TriggerHitbox = GetClosest(
                    Window.Flags["Trigger/Enabled"],
                    Window.Flags["Trigger/FieldOfView"],
                    Window.Flags["Trigger/DynamicFOV"],
                    Window.Flags["TeamCheck"],
                    Window.Flags["Trigger/BodyParts"],
                    Window.Flags["Trigger/WallCheck"],
                    Window.Flags["Trigger/DistanceCheck"],
                    Window.Flags["Trigger/Distance"],
                    Window.Flags["Trigger/Prediction"]
                ) if not TriggerHitbox or not Trigger then break end
            end
        end mouse1release()
    end
end)

Parvus.Utilities.Misc:NewThreadLoop(0,function()
    PlayerFly(Window.Flags["AR2/Fly/Enabled"],
        Window.Flags["AR2/Fly/Value"])
end)
Parvus.Utilities.Misc:NewThreadLoop(0.1,function()
    if not Window.Flags["AR2/AntiZombie/Enabled"] then return end
    local ClosestZombies = GetZombies(50)
    for Index,Zombie in pairs(ClosestZombies) do
        Zombie.PrimaryPart.Anchored = isnetworkowner(Zombie.PrimaryPart)
        --[[local ZombieOwned = isnetworkowner(Zombie.PrimaryPart)
        if Window.Flags["AR2/AntiZombie/KillAura"] and ZombieOwned then
            --Zombie.PrimaryPart.CFrame = PlayerClass.Character.RootPart.CFrame * CFrame.new(0,0,5)
            --Zombie.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            local Melee = PlayerClass.Character.Inventory.Equipment.Melee
            if Melee then Network:Send("Melee Swing",Melee.Id,1)
                Network:Send("Melee Hit Register",Melee.Id,
                Zombie.PrimaryPart,"Flesh")
            end
        else Zombie.PrimaryPart.Anchored = ZombieOwned end]]
    end ClosestZombies = nil
end)
Parvus.Utilities.Misc:NewThreadLoop(1,function()
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"]
    or not Window.Flags["AR2/ESP/Items/Enabled"] then return end

    local Items = GetItems(100)
    if Interface:IsVisible("GameMenu")
    or not PlayerClass.Character or
    #Items == 0 then return end

    for Index,Item in pairs(Items) do
        if Interface:IsVisible("GameMenu")
        or ItemMemory[Item] then continue end

        task.spawn(function()
            --local ContainerAvailable = Network:Fetch("Inventory Container Group Connect",Item)
            --if ContainerAvailable and not Interface:IsVisible("GameMenu") then
            if Network:Fetch("Inventory Container Group Connect",Item) then
                Network:Send("Inventory Container Group Disconnect")
                ItemMemory[Item] = true task.wait(120) ItemMemory[Item] = nil
            end
        end)
    end Items = nil
end)

Events["Character Rubber Band Rest\r"] = function() end

local OldICA, OldCC = Events["Inventory Container Added\r"], Events["Container Changed\r"]
Events["Inventory Container Added\r"] = function(Id,Data,...)
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return OldICA(Id,Data,...) end
    if Data.WorldPosition and Length(Data.Occupants) > 0 and not string.find(Data.Type,"Corpse") then
        Parvus.Utilities.Drawing:AddObject(Data.Id,CIIC(Data),Data.WorldPosition,
        "AR2/ESP/Items","AR2/ESP/Items/Containers",Window.Flags)
    end return OldICA(Id,Data,...)
end
Events["Container Changed\r"] = function(Data,...)
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return OldCC(Data,...) end

    Parvus.Utilities.Drawing:RemoveObject(Data.Id)
    if Data.WorldPosition and Length(Data.Occupants) > 0 and not string.find(Data.Type,"Corpse") then
        Parvus.Utilities.Drawing:AddObject(Data.Id,CIIC(Data),Data.WorldPosition,
        "AR2/ESP/Items","AR2/ESP/Items/Containers",Window.Flags)
    end return OldCC(Data,...)
end

for Index,Item in pairs(Loot:GetDescendants()) do
    local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
    if Item:IsA("CFrameValue") and ItemData then --print(ItemData.Parent.Name)
        Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.Value.Position,
            "AR2/ESP/Items","AR2/ESP/Items/"..ItemData.Parent.Name,Window.Flags
        )
    end
end
for Index,Event in pairs(Randoms:GetChildren()) do
    if table.find(RandomEvents,Event.Name) then --print(Event.Name)
        Parvus.Utilities.Drawing:AddObject(Event,Event.Name,Event.Value.Position,
            "AR2/ESP/RandomEvents","AR2/ESP/RandomEvents/"..Event.Name,Window.Flags
        )
    end
end
for Index,Vehicle in pairs(Vehicles:GetChildren()) do
    Parvus.Utilities.Drawing:AddObject(
        Vehicle,Vehicle.Name,Vehicle.PrimaryPart,
        "AR2/ESP/Vehicles","AR2/ESP/Vehicles",Window.Flags
    )
end
for Index,Zombie in pairs(Zombies.Mobs:GetChildren()) do
    local Config = require(Zombies.Configs[Zombie.Name])

    if Config.Inherits then
        for Index,Inherit in pairs(Config.Inherits) do
            if table.find(ZombieInherits,Inherit) then
                local InheritName = Inherit:gsub("Presets.Behavior",""):gsub(" ","")
                Parvus.Utilities.Drawing:AddObject(
                    Zombie,Zombie.Name,Zombie.PrimaryPart,"AR2/ESP/Zombies",
                    "AR2/ESP/Zombies/"..InheritName,Window.Flags
                )
            end
        end
    end

    Config = nil
end

Loot.DescendantAdded:Connect(function(Item)
    local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
    if Item:IsA("CFrameValue") and ItemData then --print(ItemData.Parent.Name)
        Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.Value.Position,
            "AR2/ESP/Items","AR2/ESP/Items/"..ItemData.Parent.Name,Window.Flags
        )
    end
end)
Randoms.ChildAdded:Connect(function(Event)
    if table.find(RandomEvents,Event.Name) then --print(Event.Name)
        Parvus.Utilities.Drawing:AddObject(Event,Event.Name,Event.Value.Position,
            "AR2/ESP/RandomEvents","AR2/ESP/RandomEvents/"..Event.Name,Window.Flags
        )
        if Window.Flags["AR2/ESP/RandomEvents/Enabled"] then
            Parvus.Utilities.UI:Notification2({
                Title = string.format("%s spawned (~%i studs away)",Event.Name,
                GetDistanceFromCamera(Event.Value.Position)),Duration = 20
            })
        end
    end
end)
Vehicles.ChildAdded:Connect(function(Vehicle)
    repeat task.wait() until Vehicle.PrimaryPart
    Parvus.Utilities.Drawing:AddObject(
        Vehicle,Vehicle.Name,Vehicle.PrimaryPart,
        "AR2/ESP/Vehicles","AR2/ESP/Vehicles",Window.Flags
    )
end)
Zombies.Mobs.ChildAdded:Connect(function(Zombie)
    repeat task.wait() until Zombie.PrimaryPart
    local Config = require(Zombies.Configs[Zombie.Name])

    if Config.Inherits then
        for Index,Inherit in pairs(Config.Inherits) do
            if table.find(ZombieInherits,Inherit) then
                local InheritName = Inherit:gsub("Presets.Behavior",""):gsub(" ","")
                Parvus.Utilities.Drawing:AddObject(
                    Zombie,Zombie.Name,Zombie.PrimaryPart,"AR2/ESP/Zombies",
                    "AR2/ESP/Zombies/"..InheritName,Window.Flags
                )
            end
        end
    end

    Config = nil
end)

Loot.DescendantRemoving:Connect(function(Item)
    Parvus.Utilities.Drawing:RemoveObject(Item)
end)
Randoms.ChildRemoved:Connect(function(Event)
    Parvus.Utilities.Drawing:RemoveObject(Event)
end)
Vehicles.ChildRemoved:Connect(function(Vehicle)
    Parvus.Utilities.Drawing:RemoveObject(Vehicle)
end)
Zombies.Mobs.ChildRemoved:Connect(function(Zombie)
    Parvus.Utilities.Drawing:RemoveObject(Zombie)
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
