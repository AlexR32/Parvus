local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Loaded,PromptLib = false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
if identifyexecutor() ~= "Synapse X" then
    PromptLib("Unsupported executor","Synapse X only for safety measures\nYou are at risk of getting autoban\nAre you sure you want to load Parvus?",{
        {Text = "Yes",LayoutOrder = 0,Primary = false,Callback = function() Loaded = true end},
    }) repeat task.wait(1) until Loaded
end

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Aimbot,SilentAim,Trigger = false,nil,nil

local LootBins = Workspace.Map.Shared.LootBins
local Randoms = Workspace.Map.Shared.Randoms
local Vehicles = Workspace.Vehicles.Spawned
local Characters = Workspace.Characters
--local Corpses = Workspace.Corpses
local Zombies = Workspace.Zombies
local Loot = Workspace.Loot

local Framework = require(ReplicatedFirst.Framework) Framework:WaitForLoaded()
repeat task.wait() until Framework.Classes.Players.get()
local PlayerClass = Framework.Classes.Players.get()

local Globals = Framework.Configs.Globals

local World = Framework.Libraries.World
local Network = Framework.Libraries.Network
local Cameras = Framework.Libraries.Cameras
local Bullets = Framework.Libraries.Bullets
local Interface = Framework.Libraries.Interface
local Raycasting = Framework.Libraries.Raycasting

local Maids = Framework.Classes.Maids
local Animators = Framework.Classes.Animators
local VehicleController = Framework.Classes.VehicleControler

--local ReticleModule = Interface:Get("Reticle")
local CharacterCamera = Cameras.CameraList.Character

local Events = getupvalue(Network.Add,1)
local GetSpreadAngle = getupvalue(Bullets.Fire,1)
--local CastLocalBullet = getupvalue(Bullets.Fire,4)
local FlinchCamera = getupvalue(Bullets.Fire,5)
local GetFireImpulse = getupvalue(Bullets.Fire,7)
local RenderSettings = getupvalue(World.GetDistance,1)

--local Effects = getupvalue(CastLocalBullet,2)
--local Sounds = getupvalue(CastLocalBullet,3)
--local IsNetworkableHit = getupvalue(CastLocalBullet,12)

if type(Events) == "function" then Events = getupvalue(Network.Add,2) end

local InteractHeartbeat,FindItemData
for Index,Table in pairs(getgc(true)) do
    if typeof(Table) == "table"
    and rawget(Table,"Rate") == 0.05 then
        InteractHeartbeat = Table.Action
        FindItemData = getupvalue(InteractHeartbeat,11)
    end
end

--[[local function RenameCharacter(Player)
    if not Player.Character then return end
    Player.Character.Name = ("%s (%s)"):format(Player.Name,Player.DisplayName)
end
for Index,Player in pairs(PlayerService:GetPlayers()) do
    RenameCharacter(Player)
    Player.CharacterAdded:Connect(function()
        RenameCharacter(Player)
    end)
end
PlayerService.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        RenameCharacter(Player)
    end)
end)]]

local ProjectileSpeed,ProjectileGravity = 1000,math.abs(Globals.ProjectileGravity)
local ItemMemory,NoClipEvent,NoClipObjects,TeleportBypass = {},nil,{},false
local SetIdentity = setidentity or (syn and syn.set_thread_identity)

--RenderSettings.Loot = 1
--RenderSettings.Elements = 1
--RenderSettings.Detail = -1
--RenderSettings.Terrain = 36

-- game data mess
local RandomEvents,ItemCategory,ZombieInherits,SanityBans,InfectedScripts = {
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
"Presets.Behavior Common Thrall Level 01","Presets.Behavior MiniBoss Level 01","Presets.Behavior MiniBoss Level 02",
"Presets.Skin Tone Dark","Presets.Skin Tone Dark Servant","Presets.Skin Tone Light","Presets.Skin Tone LightMid",
"Presets.Skin Tone LightMidDark","Presets.Skin Tone Mid","Presets.Skin Tone MidDark","Presets.Skin Tone Servant"},

{"Character Humanoid Update","Character Root Update","Get Player Stance Speed",
"Force Charcter Save","Update Character State","Sync Near Chunk Loot","Sorry Mate, Wrong Path :/",
"Resync Character Physics","Update Character Position"},

{"Characters","Network","World"}

local KnownBodyParts = {
    {"Head",true},{"HumanoidRootPart",true},
    {"UpperTorso",false},{"LowerTorso",false},

    {"RightUpperArm",false},{"RightLowerArm",false},{"RightHand",false},
    {"LeftUpperArm",false},{"LeftLowerArm",false},{"LeftHand",false},

    {"RightUpperLeg",false},{"RightLowerLeg",false},{"RightFoot",false},
    {"LeftUpperLeg",false},{"LeftLowerLeg",false},{"LeftFoot",false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — " .. Parvus.Game.Name,
    Position = UDim2.new(0.05,0,0.5,-248)
}) do Window:Watermark({Enabled = true})

    local CombatTab = Window:Tab({Name = "Combat"}) do
        local AimbotSection = CombatTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            :Keybind({Flag = "Aimbot/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Always Enabled",Flag = "Aimbot/AlwaysEnabled",Value = false})
            AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = true})

            --AimbotSection:Toggle({Name = "Team Check",Flag = "Aimbot/TeamCheck",Value = false})
            AimbotSection:Toggle({Name = "Distance Check",Flag = "Aimbot/DistanceCheck",Value = false})
            AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/VisibilityCheck",Value = false})
            AimbotSection:Slider({Name = "Sensitivity",Flag = "Aimbot/Sensitivity",Min = 0,Max = 100,Value = 20,Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View",Flag = "Aimbot/FieldOfView",Min = 0,Max = 500,Value = 100,Unit = "r"})
            AimbotSection:Slider({Name = "Distance Limit",Flag = "Aimbot/DistanceLimit",Min = 25,Max = 10000,Value = 250,Unit = "studs"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            AimbotSection:Dropdown({Name = "Priority",Flag = "Aimbot/Priority",List = PriorityList})
            AimbotSection:Dropdown({Name = "Body Parts",Flag = "Aimbot/BodyParts",List = BodyPartsList})
        end
        local AFOVSection = CombatTab:Section({Name = "Aimbot FOV Circle",Side = "Left"}) do
            AFOVSection:Toggle({Name = "Enabled",Flag = "Aimbot/FOVCircle/Enabled",Value = true})
            AFOVSection:Toggle({Name = "Filled",Flag = "Aimbot/FOVCircle/Filled",Value = false})
            AFOVSection:Colorpicker({Name = "Color",Flag = "Aimbot/FOVCircle/Color",Value = {1,0.66666662693024,1,0.25,false}})
            AFOVSection:Slider({Name = "NumSides",Flag = "Aimbot/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            AFOVSection:Slider({Name = "Thickness",Flag = "Aimbot/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local TFOVSection = CombatTab:Section({Name = "Trigger FOV Circle",Side = "Left"}) do
            TFOVSection:Toggle({Name = "Enabled",Flag = "Trigger/FOVCircle/Enabled",Value = true})
            TFOVSection:Toggle({Name = "Filled",Flag = "Trigger/FOVCircle/Filled",Value = false})
            TFOVSection:Colorpicker({Name = "Color",Flag = "Trigger/FOVCircle/Color",Value = {0.0833333358168602,0.6666666269302368,1,0.25,false}})
            TFOVSection:Slider({Name = "NumSides",Flag = "Trigger/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            TFOVSection:Slider({Name = "Thickness",Flag = "Trigger/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local SilentAimSection = CombatTab:Section({Name = "Silent Aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false}):Keybind({Mouse = true,Flag = "SilentAim/Keybind"})

            SilentAimSection:Toggle({Name = "Prediction",Flag = "SilentAim/Prediction",Value = true})

            --SilentAimSection:Toggle({Name = "Team Check",Flag = "SilentAim/TeamCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/VisibilityCheck",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100,Unit = "r"})
            SilentAimSection:Slider({Name = "Distance Limit",Flag = "SilentAim/DistanceLimit",Min = 25,Max = 10000,Value = 250,Unit = "studs"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            SilentAimSection:Dropdown({Name = "Priority",Flag = "SilentAim/Priority",List = PriorityList})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = BodyPartsList})
        end
        local SAFOVSection = CombatTab:Section({Name = "Silent Aim FOV Circle",Side = "Right"}) do
            SAFOVSection:Toggle({Name = "Enabled",Flag = "SilentAim/FOVCircle/Enabled",Value = true})
            SAFOVSection:Toggle({Name = "Filled",Flag = "SilentAim/FOVCircle/Filled",Value = false})
            SAFOVSection:Colorpicker({Name = "Color",Flag = "SilentAim/FOVCircle/Color",
            Value = {0.6666666865348816,0.6666666269302368,1,0.25,false}})
            SAFOVSection:Slider({Name = "NumSides",Flag = "SilentAim/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            SAFOVSection:Slider({Name = "Thickness",Flag = "SilentAim/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local TriggerSection = CombatTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Enabled",Value = false})
            :Keybind({Flag = "Trigger/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})

            TriggerSection:Toggle({Name = "Always Enabled",Flag = "Trigger/AlwaysEnabled",Value = false})
            TriggerSection:Toggle({Name = "Hold Mouse Button",Flag = "Trigger/HoldMouseButton",Value = false})
            TriggerSection:Toggle({Name = "Prediction",Flag = "Trigger/Prediction",Value = true})

            --TriggerSection:Toggle({Name = "Team Check",Flag = "Trigger/TeamCheck",Value = false})
            TriggerSection:Toggle({Name = "Distance Check",Flag = "Trigger/DistanceCheck",Value = false})
            TriggerSection:Toggle({Name = "Visibility Check",Flag = "Trigger/VisibilityCheck",Value = false})

            TriggerSection:Slider({Name = "Click Delay",Flag = "Trigger/Delay",Min = 0,Max = 1,Precise = 2,Value = 0.15,Unit = "sec"})
            TriggerSection:Slider({Name = "Distance Limit",Flag = "Trigger/DistanceLimit",Min = 25,Max = 10000,Value = 250,Unit = "studs"})
            TriggerSection:Slider({Name = "Field Of View",Flag = "Trigger/FieldOfView",Min = 0,Max = 500,Value = 25,Unit = "r"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            TriggerSection:Dropdown({Name = "Priority",Flag = "Trigger/Priority",List = PriorityList})
            TriggerSection:Dropdown({Name = "Body Parts",Flag = "Trigger/BodyParts",List = BodyPartsList})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = false})
            GlobalSection:Toggle({Name = "Use Team Color",Flag = "ESP/Player/TeamColor",Value = false})
            GlobalSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = true})
            GlobalSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 10000,Value = 1000,Unit = "studs"})
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
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Name/Autoscale",Value = false})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/Player/Name/Font",List = {
                {Name = "UI",Mode = "Button",Value = true},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button"}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/Player/Name/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/Player/Name/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local ChamSection = VisualsTab:Section({Name = "Chams",Side = "Left"}) do
            ChamSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Highlight/Enabled",Value = false})
            ChamSection:Toggle({Name = "Occluded",Flag = "ESP/Player/Highlight/Occluded",Value = false})
            ChamSection:Slider({Name = "Transparency",Flag = "ESP/Player/Highlight/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            ChamSection:Colorpicker({Name = "Outline Color",Flag = "ESP/Player/Highlight/OutlineColor",Value = {1,1,0,0.5,false}})
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
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Right"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/Player/Arrow/Filled",Value = true})
            OoVSection:Toggle({Name = "Outline",Flag = "ESP/Player/Arrow/Outline",Value = true})
            OoVSection:Slider({Name = "Width",Flag = "ESP/Player/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Height",Flag = "ESP/Player/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/Player/Arrow/Radius",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/Player/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/Player/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end Parvus.Utilities:LightingSection(VisualsTab,"Left")
    end
    local ESPTab = Window:Tab({Name = "AR2 ESP"}) do
        local ItemSection = ESPTab:Section({Name = "Item ESP",Side = "Left"}) do local Items = {}
            ItemSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Items/Enabled",Value = false})
            ItemSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Items/DistanceCheck",Value = true})
            ItemSection:Slider({Name = "Distance",Flag = "AR2/ESP/Items/Distance",Min = 25,Max = 5000,Value = 50,Unit = "studs"})
            for Index,Name in pairs(ItemCategory) do
                local ItemFlag = "AR2/ESP/Items/" .. Name Window.Flags[ItemFlag .. "/Enabled"] = false
                Items[#Items + 1] = {Name = Name,Mode = "Toggle",Value = false,
                    Colorpicker = {Flag = ItemFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[ItemFlag .. "/Enabled"] = Option.Value end
                }
            end ItemSection:Dropdown({Name = "ESP List",Flag = "AR2/Items",List = Items})
        end
        local ZombiesSection = ESPTab:Section({Name = "Zombies ESP",Side = "Left"}) do local ZIs = {}
            ZombiesSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Zombies/Enabled",Value = false})
            ZombiesSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Zombies/DistanceCheck",Value = true})
            ZombiesSection:Slider({Name = "Distance",Flag = "AR2/ESP/Zombies/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "studs"})

            for Index,Inherit in pairs(ZombieInherits) do
                local InheritName = Inherit:gsub("Presets.",""):gsub(" ","")
                local REFlag = "AR2/ESP/Zombies/" .. InheritName
                Window.Flags[REFlag .. "/Enabled"] = false

                ZIs[#ZIs + 1] = {Name = InheritName,Mode = "Toggle",Value = true,
                    Colorpicker = {Flag = REFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[REFlag .. "/Enabled"] = Option.Value end
                }
            end ZombiesSection:Dropdown({Name = "ESP List",Flag = "AR2/Zombies",List = ZIs})
        end
        local RESection = ESPTab:Section({Name = "Random Events ESP",Side = "Right"}) do local REs = {}
            RESection:Toggle({Name = "Enabled",Flag = "AR2/ESP/RandomEvents/Enabled",Value = false})
            RESection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/RandomEvents/DistanceCheck",Value = true})
            RESection:Slider({Name = "Distance",Flag = "AR2/ESP/RandomEvents/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "studs"})
            for Index,Name in pairs(RandomEvents) do
                local REFlag = "AR2/ESP/RandomEvents/" .. Name Window.Flags[REFlag .. "/Enabled"] = false
                REs[#REs + 1] = {Name = Name,Mode = "Toggle",Value = true,
                    Colorpicker = {Flag = REFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[REFlag .. "/Enabled"] = Option.Value end
                }
            end RESection:Dropdown({Name = "ESP List",Flag = "AR2/RandomEvents",List = REs})
        end
        local VehiclesSection = ESPTab:Section({Name = "Vehicles ESP",Side = "Right"}) do
            VehiclesSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Vehicles/Enabled",Value = false})
            VehiclesSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Vehicles/DistanceCheck",Value = true})
            VehiclesSection:Colorpicker({Name = "Color",Flag = "AR2/ESP/Vehicles/Color",Value = {1,0,1,0,false}})
            VehiclesSection:Slider({Name = "Distance",Flag = "AR2/ESP/Vehicles/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "studs"})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local RecoilSection = MiscTab:Section({Name = "Weapon",Side = "Left"}) do
            --RecoilSection:Toggle({Name = "Instant Hit",Flag = "AR2/InstantHit",Value = false})
            RecoilSection:Toggle({Name = "Silent Wallbang",Flag = "AR2/MagicBullet/Enabled",Value = false})
            RecoilSection:Slider({Name = "Wallbang Depth",Flag = "AR2/MagicBullet/Depth",Min = 1,Max = 5,Value = 5,Unit = "studs"})
            RecoilSection:Divider()
            RecoilSection:Toggle({Name = "No Recoil",Flag = "AR2/NoRecoil",Value = false})
            RecoilSection:Toggle({Name = "No Spread",Flag = "AR2/NoSpread",Value = false})
            RecoilSection:Toggle({Name = "No Wobble",Flag = "AR2/NoWobble",Value = false})
            RecoilSection:Toggle({Name = "No Camera Flinch",Flag = "AR2/NoFlinch",Value = false})
            RecoilSection:Toggle({Name = "Unlock Firemodes",Flag = "AR2/UnlockFiremodes",Value = false})
            RecoilSection:Toggle({Name = "Instant Reload",Flag = "AR2/InstantReload",Value = false})
            --[[RecoilSection:Divider()
            RecoilSection:Toggle({Name = "Recoil Control",Flag = "AR2/Recoil/Enabled",Value = false})
            RecoilSection:Slider({Name = "Shift Force",Flag = "AR2/Recoil/ShiftForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Roll Bias",Flag = "AR2/Recoil/RollBias",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Raise Force",Flag = "AR2/Recoil/RaiseForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Slide Force",Flag = "AR2/Recoil/SlideForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "KickUp Force",Flag = "AR2/Recoil/KickUpForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Bob Force",Flag = "AR2/Bob/Force",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Bob Damping",Flag = "AR2/Bob/Damping",Min = 0,Max = 100,Value = 0,Unit = "%"})]]
        end
        local VehSection = MiscTab:Section({Name = "Vehicle",Side = "Left"}) do
            VehSection:Toggle({Name = "Enabled",Flag = "AR2/Vehicle/Enabled",Value = false})
            VehSection:Slider({Name = "Speed",Flag = "AR2/Vehicle/Speed",Min = 100,Max = 500,Value = 200})
            VehSection:Slider({Name = "Steer",Flag = "AR2/Vehicle/Steer",Min = 100,Max = 500,Value = 200})
            --[[VehSection:Slider({Name = "Damping",Flag = "AR2/Vehicle/Damping",Min = 0,Max = 200,Value = 100})
            VehSection:Slider({Name = "Velocity",Flag = "AR2/Vehicle/Velocity",Min = 0,Max = 200,Value = 100})]]
        end
        local TargetSection = MiscTab:Section({Name = "Target",Side = "Right"}) do
            local PlayerDropdown = TargetSection:Dropdown({Name = "Player List",
            IgnoreFlag = true,Flag = "AR2/Teleport/List"})
            PlayerDropdown:RefreshToPlayers(false)

            TargetSection:Button({Name = "Refresh",Callback = function()
                PlayerDropdown:RefreshToPlayers(false)
            end})

            TargetSection:Button({Name = "Teleport",Callback = function()
                if Window.Flags["AR2/Teleport/Loop"] then return end
                TeleportBypass = true
                while task.wait() do
                    if not Teleport(PlayerDropdown.Value[1]) then
                        Parvus.Utilities.UI:Notification2({Title = "Teleport Ended",Duration = 5})
                        TeleportBypass = false break
                    end
                end
            end})

            TargetSection:Toggle({Name = "Loop Teleport",Flag = "AR2/Teleport/Loop",Value = false}):Keybind()
            TargetSection:Slider({Name = "Teleport Speed",Flag = "AR2/Teleport/Speed",Min = 1,Max = 50,Value = 20,Unit = "studs",Wide = true})
            --[[TargetSection:Button({Name = "TP Zombies",Callback = function()
                local OldAntiZombie = Window:GetValue("AR2/AntiZombie/Enabled")
                Window:SetValue("AR2/AntiZombie/Enabled",false)

                local Closest = GetCharactersInRadius(Zombies.Mobs,250)
                if not Closest then return end
                for Index,Character in pairs(Closest) do
                    if isnetworkowner(Character.PrimaryPart) then
                        task.spawn(function()
                            while task.wait() do
                                if not Character then print("no char") break end
                                if not Character.PrimaryPart then print("no char pp") break end
                                Character.PrimaryPart.Anchored = false

                                if not PlayerDropdown.Value[1] then print("no plr") break end
                                local TargetPlayer = PlayerService:FindFirstChild(PlayerDropdown.Value[1])
                                if not TargetPlayer then print("no plr obj") break end
                                if not TargetPlayer.Character then print("no plr char") break end
                                local Back = TargetPlayer.Character.PrimaryPart.CFrame * Vector3.new(0,0,12)
                                Character.PrimaryPart.CFrame = CFrame.new(Back,TargetPlayer.Character.PrimaryPart.Position - Back)
                                if not isnetworkowner(Character.PrimaryPart) then print("teleported",Character) break end
                            end
                        end)
                    end
                end

                Window:SetValue("AR2/AntiZombie/Enabled",OldAntiZombie)
            end})]]
        end
        local CharSection = MiscTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "Fly Enabled",Flag = "AR2/Fly/Enabled",Value = false}):Keybind({Flag = "AR2/Fly/Keybind"})
            CharSection:Slider({Name = "",Flag = "AR2/Fly/Speed",Min = 1,Max = 50,Value = 5,Unit = "studs",Wide = true})
            --CharSection:Divider()
            CharSection:Toggle({Name = "Walk Speed",Flag = "AR2/WalkSpeed/Enabled",Value = false}):Keybind()
            CharSection:Slider({Name = "",Flag = "AR2/WalkSpeed/Speed",Min = 0,Max = 20,Precise = 1,Value = 2.5,Unit = "studs",Wide = true})
            --CharSection:Divider()
            CharSection:Toggle({Name = "Jump Height",Flag = "AR2/JumpHeight/Enabled",Value = false}):Keybind()
            CharSection:Toggle({Name = "No Fall Check",Flag = "AR2/JumpHeight/NoFallCheck",Value = true})
            CharSection:Toggle({Name = "No Fall Impact",Flag = "AR2/NoFallImpact",Value = false})
            CharSection:Toggle({Name = "No Jump Debounce",Flag = "AR2/JumpHeight/NoJumpDebounce",Value = false})
            CharSection:Slider({Name = "",Flag = "AR2/JumpHeight/Height",Min = 4.8,Max = 20,Precise = 1,Value = 4.8,Unit = "studs",Wide = true})
            --CharSection:Divider()
            CharSection:Toggle({Name = "Use In Air",Flag = "AR2/UseInAir",Value = false})
            CharSection:Toggle({Name = "Use In Water",Flag = "AR2/UseInWater",Value = false})
            CharSection:Toggle({Name = "Fast Respawn",Flag = "AR2/FastRespawn",Value = false})
            CharSection:Toggle({Name = "Play Dead",Flag = "AR2/PlayDead",IgnoreFlag = true,Value = false,
            Callback = function(Bool)
                if not PlayerClass.Character then return end
                if Bool then PlayerClass.Character.Animator:PlayAnimationReplicated("Death.Standing Forwards",true)
                else PlayerClass.Character.Animator:StopAnimationReplicated("Death.Standing Forwards",true) end
            end})
            CharSection:Button({Name = "Respawn",Callback = function()
                task.spawn(function() SetIdentity(2)
                    PlayerClass:LoadCharacter()
                end)
            end}):ToolTip("You will lose loot")
        end
        local MiscSection = MiscTab:Section({Name = "Other",Side = "Right"}) do
            MiscSection:Toggle({Name = "MeleeAura",Flag = "AR2/MeleeAura",Value = false})
            MiscSection:Toggle({Name = "Instant Search",Flag = "AR2/InstantSearch",Value = false})
            MiscSection:Toggle({Name = "Anti-Zombie",Flag = "AR2/AntiZombie/Enabled",Value = false}):Keybind()
            MiscSection:Toggle({Name = "Anti-Zombie MeleeAura",Flag = "AR2/AntiZombie/MeleeAura",Value = false})
            local SpoofSCS = MiscSection:Toggle({Name = "Spoof SCS",Flag = "AR2/SSCS",Value = false}) SpoofSCS:Keybind()
            SpoofSCS:ToolTip("SCS - Set Character State:\nNo Fall Damage\nLess Hunger / Thirst\nWhile Sprinting")
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
    end Parvus.Utilities:SettingsSection(Window,"Period",true)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:SetupCrosshair(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)

local XZVector = Vector3.new(1,0,1)
local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.FilterDescendantsInstances = {
    Workspace.Effects,Workspace.Sounds,
    Workspace.Locations,Workspace.Spawns
} WallCheckParams.IgnoreWater = true

-- Fly Logic
--[[local XZ,YPlus,YMinus = Vector3.new(1,0,1),Vector3.new(0,1,0),Vector3.new(0,-1,0)
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
end]]

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
local function InEnemyTeam(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
end
local function IsDistanceLimited(Enabled,Distance,Limit)
    if not Enabled then return end
    return Distance >= Limit
end
local function IsVisible(Enabled,Origin,Position)
    if not Enabled then return true end
    return not Raycast(Origin,Position - Origin)
end
local function GetClosest(Enabled,
    TeamCheck,VisibilityCheck,DistanceCheck,
    DistanceLimit,FieldOfView,Priority,BodyParts,
    PredictionEnabled
)

    if not Enabled then return end
    if not PlayerClass.Character then return end
    local Weapon = PlayerClass.Character.Instance.Equipped:FindFirstChildOfClass("Model")
    if not Weapon then return end

    local Muzzle = Weapon:FindFirstChild("Muzzle")
    if not Muzzle then return end


    local CameraPosition,Closest = Camera.CFrame.Position,nil
    for Index,Player in ipairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character = Player.Character if not Character then continue end
        if not InEnemyTeam(TeamCheck,Player) then continue end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then continue end if Humanoid.Health <= 0 then continue end

        for Index,BodyPart in ipairs(BodyParts) do
            BodyPart = Character:FindFirstChild(BodyPart)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            if IsDistanceLimited(DistanceCheck,Distance,DistanceLimit) then continue end
            if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition) then continue end

            BodyPartPosition = PredictionEnabled and Parvus.Utilities.Physics.SolveTrajectory(Muzzle.Position,
            BodyPartPosition,BodyPart.AssemblyLinearVelocity,ProjectileSpeed,ProjectileGravity) or BodyPartPosition
            local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            if not OnScreen then continue end

            local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            if Priority == "Random" then
                Priority = KnownBodyParts[math.random(#KnownBodyParts)][1]
                BodyPart = Character:FindFirstChild(Priority) if not BodyPart then continue end
                BodyPartPosition = PredictionEnabled and Parvus.Utilities.Physics.SolveTrajectory(Muzzle.Position,
                BodyPartPosition,BodyPart.AssemblyLinearVelocity,ProjectileSpeed,ProjectileGravity) or BodyPartPosition
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            elseif Priority ~= "Closest" then
                BodyPart = Character:FindFirstChild(Priority) if not BodyPart then continue end
                BodyPartPosition = PredictionEnabled and Parvus.Utilities.Physics.SolveTrajectory(Muzzle.Position,
                BodyPartPosition,BodyPart.AssemblyLinearVelocity,ProjectileSpeed,ProjectileGravity) or BodyPartPosition
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            end

            FieldOfView,Closest = Magnitude,{Player,Character,BodyPart,BodyPartPosition,ScreenPosition}
        end
    end

    return Closest
end
local function AimAt(Hitbox,Sensitivity)
    if not Hitbox then return end
    local MouseLocation = UserInputService:GetMouseLocation()

    mousemoverel(
        (Hitbox[5].X - MouseLocation.X) * Sensitivity,
        (Hitbox[5].Y - MouseLocation.Y) * Sensitivity
    )
end

local function ProjectileBeam(Origin,Direction,Color)
    local Beam = Instance.new("Part")

    Beam.BottomSurface = Enum.SurfaceType.Smooth
    Beam.TopSurface = Enum.SurfaceType.Smooth
    Beam.Material = Enum.Material.SmoothPlastic
    Beam.Color = Color

    Beam.CanCollide = false
    Beam.CanTouch = false
    Beam.CanQuery = false
    Beam.Anchored = true

    Beam.Size = Vector3.new(0.1,0.1,(Origin - Direction).Magnitude)
    Beam.CFrame = CFrame.new(Origin,Direction) * CFrame.new(0,0,-Beam.Size.Z / 2)

    Beam.Parent = Workspace

    task.spawn(function()
        local Time = 60 * 1
        for Index = 1,Time do
            RunService.Heartbeat:Wait()
            Beam.Transparency = Index / Time
            --Beam.Color = Color3.new(0,0,1)
        end Beam:Destroy()
    end)

    return Beam
end

local function SwingMelee(Target)
    local Character = PlayerClass.Character
    if not Character then return end

    local EquippedItem = Character.EquippedItem
    if not EquippedItem then return end

    if EquippedItem.Type ~= "Melee" then return end
    if (Target.Position - Character.RootPart.Position).Magnitude >= 10 then return end

    Network:Send("Melee Swing",EquippedItem.Id,1)

    local Maid = Maids.new()
    local AttackConfig = EquippedItem.AttackConfig[1]
    local AnimationPlaying = Character.Animator:PlayAnimationReplicated(AttackConfig.Animation,0.05,AttackConfig.PlaybackSpeedMod)
	local Track = Character.Animator:GetTrack(AttackConfig.Animation)

	if Track then
		Maid:Give(Track:GetMarkerReachedSignal("Swing"):Connect(function(State)
            if State ~= "Begin" then return end
            Network:Send("Melee Hit Register",
            EquippedItem.Id,Target,"Flesh")
		end))
	end

	if AnimationPlaying then
		AnimationPlaying:Wait()
	end

	Maid:Destroy()
    Maid = nil
end
function GetCharactersInRadius(Path,Distance)
    local PlayerCharacter = PlayerClass.Character
    if not PlayerCharacter then return end

    local Closest = {}
    for Index,Character in pairs(Path:GetChildren()) do
        if Character == PlayerCharacter.Instance then continue end
        local PrimaryPart = Character.PrimaryPart
        if not PrimaryPart then continue end

        local Magnitude = (PrimaryPart.Position - PlayerCharacter.RootPart.Position).Magnitude
        if Distance >= Magnitude then Distance = Magnitude table.insert(Closest,Character) end
    end

    return Closest
end
local function GetItemsInRadius(Distance)
    local Closest = {}

    for Index,Item in pairs(LootBins:GetChildren()) do
        for Index,Group in pairs(Item:GetChildren()) do
            local Part = Group:FindFirstChild("Part")
            if not Part then continue end

            local Magnitude = (Part.Position - Camera.CFrame.Position).Magnitude
            if Distance >= Magnitude then table.insert(Closest,Group) end
        end
    end

    return Closest
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
        Items[#Items + 1] = Value == 1 and "[" .. Item .. "]"
        or "[" .. Item .. "] x" .. Value
    end
    return table.concat(Items,"\n")
end

function Teleport(TargetName)
    if Window.Flags["AR2/Fly/Enabled"] then return end

    if not TargetName then return end
    if not PlayerClass.Character then return end

    local TargetPlayer = PlayerService:FindFirstChild(TargetName)
    if not TargetPlayer then return end

    local TargetCharacter = TargetPlayer.Character
    if not TargetCharacter then return end
    if TargetCharacter.Parent == nil then return end

    local TargetRootPart = TargetCharacter.PrimaryPart
    local RootPart = PlayerClass.Character.RootPart

    local DeltaPosition = TargetRootPart.Position - RootPart.Position

    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.CFrame += DeltaPosition.Unit * math.clamp(
        Window.Flags["AR2/Teleport/Speed"],0,DeltaPosition.Magnitude
    )

    if (TargetRootPart.Position - RootPart.Position).Magnitude <= 5 then return end
    return true
end
local function PlayerFly()
    if not PlayerClass.Character then return end
    local RootPart = PlayerClass.Character.RootPart

    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.CFrame += Parvus.Utilities.MovementToDirection() * Window.Flags["AR2/Fly/Speed"]
end
local function PlayerWalkSpeed()
    if not PlayerClass.Character then return end
    local RootPart = PlayerClass.Character.RootPart
    local MoveDirection = Parvus.Utilities.MovementToDirection() * XZVector

    --RootPart.AssemblyLinearVelocity += MoveDirection * Window.Flags["AR2/WalkSpeed/Speed"]
    RootPart.CFrame += MoveDirection * Window.Flags["AR2/WalkSpeed/Speed"]
end

local function HookCharacter(Character)
    local OldEquip = Character.Equip
    Character.Equip = function(Self,Item,...)
        if Item.FireConfig and Item.FireConfig.MuzzleVelocity then
            ProjectileSpeed = Item.FireConfig.MuzzleVelocity
        end

        return OldEquip(Self,Item,...)
    end
    local OldJump = Character.Actions.Jump
    Character.Actions.Jump = function(Self,...)
        local Args = {...}

        if Window.Flags["AR2/JumpHeight/NoJumpDebounce"] then
            Self.JumpDebounce = 0
        end

        if Args[1] == "Begin" and Window.Flags["AR2/JumpHeight/Enabled"] then
            if Self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall
            and not Window.Flags["AR2/JumpHeight/NoFallCheck"] then return end

            Self.Humanoid.UseJumpPower = false
            Self.Humanoid.JumpHeight = Window.Flags["AR2/JumpHeight/Height"]
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        return OldJump(Self,...)
    end
    local OldPlayReloadAnimation = Character.Animator.PlayReloadAnimation
    Character.Animator.PlayReloadAnimation = function(Self,...)
        local ReturnArgs,Args = {OldPlayReloadAnimation(Self,...)},{...}

        if Window.Flags["AR2/InstantReload"] then
            for Index = 0,Args[3].LoopCount do
                Self.ReloadEventCallback("Commit","Load")
            end
            Character.Animator:StopReloadAnimation(false)
        end

        return unpack(ReturnArgs)
    end
    for Index,Spring in pairs({"WobblePos","WobbleRot","RotationVelocity","MoveVelocity"}) do
        Spring = Character.Animator.Springs[Spring]

        local OldRetune = Spring.Retune
        Spring.Retune = function(Self,Force,...)
            if Window.Flags["AR2/NoWobble"] then Force = 0 end
            return OldRetune(Self,Force,...)
        end
    end
    local OldToolAction = Character.Actions.ToolAction
    Character.Actions.ToolAction = function(Self,...)
        if Window.Flags["AR2/UnlockFiremodes"] then
            if not Self.EquippedItem then return OldToolAction(Self,...) end
            local FireModes = Self.EquippedItem.FireModes
            if not FireModes then return OldToolAction(Self,...) end

            for Index,Mode in ipairs({"Semiautomatic","Automatic","Burst"}) do
                if not table.find(FireModes,Mode) then
                    setreadonly(FireModes,false)
                    table.insert(FireModes,Mode)
                    setreadonly(FireModes,true)
                end
            end
        end

        return OldToolAction(Self,...)
    end
end

local OldNamecall = nil
OldNamecall = hookmetamethod(game,"__namecall",function(Self,...)
    local Method = getnamecallmethod()

    if Method == "GetChildren"
    and (Self == ReplicatedFirst
    or Self == ReplicatedStorage) then
        --print("crash bypass")
        wait(383961600) -- 4444 days
    end

    return OldNamecall(Self,...)
end)
Parvus.Utilities.FixUpValue(Network.Send,function(Old,Self,Name,...) local Args = {...}
    if table.find(SanityBans,Name) and not table.find(SanityBans,Args[1]) then return end
    if Name == "Character Jumped" and Window.Flags["AR2/SSCS"] then return end

    if Name == "Set Character State" then
        if TeleportBypass
        or Window.Flags["AR2/SSCS"]
        or Window.Flags["AR2/Fly/Enabled"]
        or Window.Flags["AR2/Teleport/Loop"]
        or Window.Flags["AR2/WalkSpeed/Enabled"] then
            Args[1] = "Climbing"
        end

        if Window.Flags["AR2/NoSpread"] then
            Args[3] = true Args[4] = true
        end
    end

    return Old(Self,Name,unpack(Args))
end)
--[[Parvus.Utilities.FixUpValue(Network.Bounce,function(Old,Self,Name,...) local Args = {...}
    print(Name)
    return Old(Self,Name,unpack(Args))
end)
Parvus.Utilities.FixUpValue(Network.Fetch,function(Old,Self,Name,...) local Args = {...}
    print(Name)
    return Old(Self,Name,unpack(Args))
end)]]
setupvalue(Bullets.Fire,1,function(Character,CCamera,...)
    if Window.Flags["AR2/NoSpread"] then
        return GetSpreadAngle(
            {MoveState = "Walking",Zooming = true},
            {FirstPerson = true},...
        )
    end

    return GetSpreadAngle(Character,CCamera,...)
end)
--[[setupvalue(Bullets.Fire,4,function(...)
    if Window.Flags["AR2/InstantHit"] then
        local Args = {...}

        local Velocity = (Args[7] * Args[5].FireConfig.MuzzleVelocity) * Globals.MuzzleVelocityMod
        local IsTraveling,TravelTime,TravelDelta,TravelOrigin = true,0,0,Args[6]
        local Blacklist = {Effects,Sounds,Args[4].Instance}
        local _Ray,_Instance,Position = nil,nil,nil
        local FrameRate = 1 / 60

        while IsTraveling do
            while TravelDelta > FrameRate do
                TravelDelta -= FrameRate TravelTime += FrameRate
                _Ray = Ray.new(TravelOrigin,(Args[6] + (Velocity * TravelTime)) - TravelOrigin)
                _Instance,Position = Raycasting:BulletCast(_Ray,true,Blacklist)
                TravelOrigin = Position

                if _Instance then IsTraveling = false break end
            end
            TravelDelta += RunService.Heartbeat:Wait()
        end

        if _Instance and IsNetworkableHit(_Instance) then
            ProjectileBeam(Args[6],Position,Color3.new(1,0,0))
            Network:Send("Bullet Impact",Args[1],Args[5].Id,Args[2],Args[3],_Instance,Position,{
                _Instance.CFrame:PointToObjectSpace(_Ray.Origin),
                _Instance.CFrame:VectorToObjectSpace(_Ray.Direction),
                _Instance.CFrame:PointToObjectSpace(Position)
            })
        end

        return
    end

    return CastLocalBullet(...)
end)]]
setupvalue(Bullets.Fire,5,function(...)
    if Window.Flags["AR2/NoFlinch"] then return end
    return FlinchCamera(...)
end)
setupvalue(Bullets.Fire,7,function(...)
    local ReturnArgs = {GetFireImpulse(...)}
    if Window.Flags["AR2/NoRecoil"] then
        for Index = 1,#ReturnArgs[1] do
            ReturnArgs[1][Index] *= 0
        end
    end return unpack(ReturnArgs)
end)
setupvalue(InteractHeartbeat,11,function(...)
    if Window.Flags["AR2/InstantSearch"] then
        local Args = {FindItemData(...)}
        Args[4] = 0 return unpack(Args)
    end return FindItemData(...)
end)
--[[local OldGetFirearmTargetInfo = Reticle.GetFirearmTargetInfo
Reticle.GetFirearmTargetInfo = function(Self,...)
    local ReturnArgs = {OldGetFirearmTargetInfo(Self,...)}
    local Script = tostring(getcallingscript())

    if Script == "Client Main" and SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        if Window.Flags["AR2/MagicBullet/Enabled"] then
            local Direction = ReturnArgs[1] - SilentAim[3].Position
            local Distance = math.clamp(Direction.Magnitude,0,Window.Flags["AR2/MagicBullet/Depth"])
            ReturnArgs[1] = ReturnArgs[1] - Direction.Unit * Distance
        end

        ReturnArgs[2] = (SilentAim[4] - ReturnArgs[1]).Unit
        ProjectileBeam(ReturnArgs[1],SilentAim[4],Color3.new(0,0,1))
    end

    return unpack(ReturnArgs)
end]]
local OldFire = Bullets.Fire
Bullets.Fire = function(Self,...)
    local Args = {...}

    if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        if Window.Flags["AR2/MagicBullet/Enabled"] then
            local Direction = Args[4] - SilentAim[3].Position
            local Distance = math.clamp(Direction.Magnitude,0,Window.Flags["AR2/MagicBullet/Depth"])
            Args[4] = Args[4] - Direction.Unit * Distance
        end

        Args[5] = (SilentAim[4] - Args[4]).Unit
        --ProjectileBeam(Args[4],SilentAim[4],Color3.new(0,0,1))
    end

    return OldFire(Self,unpack(Args))
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
local OldFlinch = CharacterCamera.Flinch
CharacterCamera.Flinch = function(Self,...)
    if Window.Flags["AR2/NoFlinch"] then return end
    return OldFlinch(Self,...)
end
local OldCharacterGroundCast = Raycasting.CharacterGroundCast
Raycasting.CharacterGroundCast = function(Self,Position,LengthDown,...)
    if PlayerClass.Character and Position == PlayerClass.Character.RootPart.CFrame then
        if Window.Flags["AR2/UseInAir"] then LengthDown = 1e6 end
    end return OldCharacterGroundCast(Self,Position,LengthDown,...)
end
local OldSwimCheckCast = Raycasting.SwimCheckCast
Raycasting.SwimCheckCast = function(Self,...)
    if Window.Flags["AR2/UseInWater"] then return nil end
    return OldSwimCheckCast(Self,...)
end
local OldPlayAnimationReplicated = Animators.PlayAnimationReplicated
Animators.PlayAnimationReplicated = function(Self,Path,...)
    if Path == "Actions.Fall Impact"
    and Window.Flags["AR2/NoFallImpact"] then return end
    return OldPlayAnimationReplicated(Self,Path,...)
end
local OldVC = VehicleController.new
VehicleController.new = function(...)
    local ReturnArgs = {OldVC(...)}

    local OldStep = ReturnArgs[1].Step
    ReturnArgs[1].Step = function(Self,...)
        if Window.Flags["AR2/Vehicle/Enabled"] then
            local MoveVector = PlayerClass.Character.MoveVector
            Self.ThrottleSolver.Position = -MoveVector.Z
            * Window.Flags["AR2/Vehicle/Speed"] / 100
            Self.SteerSolver.Position = MoveVector.X
            * Window.Flags["AR2/Vehicle/Steer"] / 100

            --[[Self.ThrottleSolver.Speed = Window.Flags["AR2/Vehicle/Speed"]
            Self.ThrottleSolver.Damping = Window.Flags["AR2/Vehicle/Damping"]
            Self.ThrottleSolver.Velocity = Window.Flags["AR2/Vehicle/Velocity"]]
        end

        return OldStep(Self,...)
    end

    return unpack(ReturnArgs)
end
local OldCD = Events["Character Dead"]
if OldCD then
    Events["Character Dead"] = function(...)
        if Window.Flags["AR2/FastRespawn"] then
            task.spawn(function() SetIdentity(2)
                PlayerClass:UnloadCharacter()
                Interface:Hide("Reticle")
                task.wait(0.5)
                PlayerClass:LoadCharacter()
            end)
        end

        return OldCD(...)
    end
end
local OldICA = Events["Inventory Container Added"]
Events["Inventory Container Added"] = function(Id,Data,...)
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return OldICA(Id,Data,...) end
    if Data.WorldPosition and Length(Data.Occupants) > 0 and not string.find(Data.Type,"Corpse") then
        Parvus.Utilities.Drawing:AddObject(Data.Id,CIIC(Data),Data.WorldPosition,
        "AR2/ESP/Items","AR2/ESP/Items/Containers",Window.Flags)
    end return OldICA(Id,Data,...)
end
local OldCC = Events["Container Changed"]
Events["Container Changed"] = function(Data,...)
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return OldCC(Data,...) end

    Parvus.Utilities.Drawing:RemoveObject(Data.Id)
    if Data.WorldPosition and Length(Data.Occupants) > 0 and not string.find(Data.Type,"Corpse") then
        Parvus.Utilities.Drawing:AddObject(Data.Id,CIIC(Data),Data.WorldPosition,
        "AR2/ESP/Items","AR2/ESP/Items/Containers",Window.Flags)
    end return OldCC(Data,...)
end

if PlayerClass.Character then
    HookCharacter(PlayerClass.Character)
end
PlayerClass.CharacterAdded:Connect(function(Character)
    HookCharacter(Character)
end)

Parvus.Utilities.NewThreadLoop(0,function()
    if not (Aimbot or Window.Flags["Aimbot/AlwaysEnabled"]) then return end

    AimAt(GetClosest(
        Window.Flags["Aimbot/Enabled"],
        Window.Flags["Aimbot/TeamCheck"],
        Window.Flags["Aimbot/VisibilityCheck"],
        Window.Flags["Aimbot/DistanceCheck"],
        Window.Flags["Aimbot/DistanceLimit"],
        Window.Flags["Aimbot/FieldOfView"],
        Window.Flags["Aimbot/Priority"][1],
        Window.Flags["Aimbot/BodyParts"],
        Window.Flags["Aimbot/Prediction"]
    ),Window.Flags["Aimbot/Sensitivity"] / 100)
end)
Parvus.Utilities.NewThreadLoop(0,function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"],
        Window.Flags["SilentAim/TeamCheck"],
        Window.Flags["SilentAim/VisibilityCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/DistanceLimit"],
        Window.Flags["SilentAim/FieldOfView"],
        Window.Flags["SilentAim/Priority"][1],
        Window.Flags["SilentAim/BodyParts"],
        Window.Flags["SilentAim/Prediction"]
    )
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not (Trigger or Window.Flags["Trigger/AlwaysEnabled"]) then return end
    if not iswindowactive() then return end

    local TriggerClosest = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/TeamCheck"],
        Window.Flags["Trigger/VisibilityCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/DistanceLimit"],
        Window.Flags["Trigger/FieldOfView"],
        Window.Flags["Trigger/Priority"][1],
        Window.Flags["Trigger/BodyParts"],
        Window.Flags["Trigger/Prediction"]
    ) if not TriggerClosest then return end

    task.wait(Window.Flags["Trigger/Delay"]) mouse1press()
    if Window.Flags["Trigger/HoldMouseButton"] then
        while task.wait() do
            TriggerClosest = GetClosest(
                Window.Flags["Trigger/Enabled"],
                Window.Flags["Trigger/TeamCheck"],
                Window.Flags["Trigger/VisibilityCheck"],
                Window.Flags["Trigger/DistanceCheck"],
                Window.Flags["Trigger/DistanceLimit"],
                Window.Flags["Trigger/FieldOfView"],
                Window.Flags["Trigger/Priority"][1],
                Window.Flags["Trigger/BodyParts"],
                Window.Flags["Trigger/Prediction"]
            ) if not TriggerClosest or not Trigger then break end
        end
    end mouse1release()
end)

Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["AR2/Teleport/Loop"] then return end
    Teleport(Window.Flags["AR2/Teleport/List"][1])
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["AR2/Fly/Enabled"] then return end
    PlayerFly()
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["AR2/WalkSpeed/Enabled"] then return end
    PlayerWalkSpeed()
end)

Parvus.Utilities.NewThreadLoop(0.1,function()
    local Closest = GetCharactersInRadius(Zombies.Mobs,100)
    if not Closest then return end

    for Index,Character in pairs(Closest) do
        local PrimaryPart = Character.PrimaryPart
        if not PrimaryPart then continue end

        PrimaryPart.Anchored = Window.Flags["AR2/AntiZombie/Enabled"]
        and isnetworkowner(PrimaryPart)

        if Window.Flags["AR2/AntiZombie/MeleeAura"] then
            SwingMelee(PrimaryPart)
        end
    end
end)

Parvus.Utilities.NewThreadLoop(0.1,function()
    if not Window.Flags["AR2/MeleeAura"] then return end
    local Closest = GetCharactersInRadius(Characters,20)
    if not Closest then return end

    for Index,Character in pairs(Closest) do
        local PrimaryPart = Character.PrimaryPart
        if not PrimaryPart then continue end
        SwingMelee(PrimaryPart)
    end
end)
Parvus.Utilities.NewThreadLoop(1,function()
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"]
    or not Window.Flags["AR2/ESP/Items/Enabled"] then return end

    local Items = GetItemsInRadius(100)

    if not PlayerClass.Character
    or Interface:IsVisible("GameMenu")
    or #Items == 0 then return end

    for Index,Item in pairs(Items) do
        if Interface:IsVisible("GameMenu")
        or table.find(ItemMemory,Item) then continue end

        task.spawn(function()
            if Network:Fetch("Inventory Container Group Connect",Item) then
                Network:Send("Inventory Container Group Disconnect")
                table.insert(ItemMemory,Item)
                task.wait(30)
                table.remove(ItemMemory,Item)
                print(table.find(ItemMemory,Item))
            end
        end)
    end
end)

for Index,Item in pairs(Loot:GetDescendants()) do
    if Item:IsA("CFrameValue") then
        local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
        if not ItemData then continue end --print(ItemData.Parent.Name)

        Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.Value.Position,
            "AR2/ESP/Items","AR2/ESP/Items/" .. ItemData.Parent.Name,Window.Flags
        )
    end
end
for Index,Event in pairs(Randoms:GetChildren()) do
    if table.find(RandomEvents,Event.Name) then --print(Event.Name)
        Parvus.Utilities.Drawing:AddObject(Event,Event.Name,Event.Value.Position,
            "AR2/ESP/RandomEvents","AR2/ESP/RandomEvents/" .. Event.Name,Window.Flags
        )
    end
end
for Index,Zombie in pairs(Zombies.Mobs:GetChildren()) do
    local Config = require(Zombies.Configs[Zombie.Name])

    if not Config.Inherits then continue end
    for Index,Inherit in pairs(Config.Inherits) do
        if table.find(ZombieInherits,Inherit) then
            local InheritName = Inherit:gsub(" ",""):gsub("Presets.","")
            Parvus.Utilities.Drawing:AddObject(
                Zombie,Zombie.Name,Zombie.PrimaryPart,"AR2/ESP/Zombies",
                "AR2/ESP/Zombies/"..InheritName,Window.Flags
            )
        end
    end
end
for Index,Vehicle in pairs(Vehicles:GetChildren()) do
    Parvus.Utilities.Drawing:AddObject(
        Vehicle,Vehicle.Name,Vehicle.PrimaryPart,
        "AR2/ESP/Vehicles","AR2/ESP/Vehicles",Window.Flags
    )
end

Loot.DescendantAdded:Connect(function(Item)
    if Item:IsA("CFrameValue") then
        local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
        if not ItemData then return end --print(ItemData.Parent.Name)

        Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.Value.Position,
            "AR2/ESP/Items","AR2/ESP/Items/" .. ItemData.Parent.Name,Window.Flags
        )
    end
end)
Randoms.ChildAdded:Connect(function(Event)
    if table.find(RandomEvents,Event.Name) then --print(Event.Name)
        Parvus.Utilities.Drawing:AddObject(Event,Event.Name,Event.Value.Position,
            "AR2/ESP/RandomEvents","AR2/ESP/RandomEvents/" .. Event.Name,Window.Flags
        )

        if Window.Flags["AR2/ESP/RandomEvents/Enabled"]
        and Window.Flags["AR2/ESP/RandomEvents/" .. Event.Name] then
            local Distance = (Event.Value.Position - Camera.CFrame.Position).Magnitude
            local Title = string.format("%s spawned (~%i studs away)",Event.Name,Distance)
            Parvus.Utilities.UI:Notification2({Title = Title,Duration = 20})
        end
    end
end)
Zombies.Mobs.ChildAdded:Connect(function(Zombie)
    repeat task.wait() until Zombie.PrimaryPart
    local Config = require(Zombies.Configs[Zombie.Name])

    if not Config.Inherits then return end
    for Index,Inherit in pairs(Config.Inherits) do
        if table.find(ZombieInherits,Inherit) then
            local InheritName = Inherit:gsub(" ",""):gsub("Presets.","")
            Parvus.Utilities.Drawing:AddObject(
                Zombie,Zombie.Name,Zombie.PrimaryPart,"AR2/ESP/Zombies",
                "AR2/ESP/Zombies/" .. InheritName,Window.Flags
            )
        end
    end
end)
Vehicles.ChildAdded:Connect(function(Vehicle)
    repeat task.wait() until Vehicle.PrimaryPart
    --print(Vehicle.Name)

    Parvus.Utilities.Drawing:AddObject(
        Vehicle,Vehicle.Name,Vehicle.PrimaryPart,
        "AR2/ESP/Vehicles","AR2/ESP/Vehicles",Window.Flags
    )
end)

Loot.DescendantRemoving:Connect(function(Item)
    Parvus.Utilities.Drawing:RemoveObject(Item)
end)
Randoms.ChildRemoved:Connect(function(Event)
    Parvus.Utilities.Drawing:RemoveObject(Event)
end)
Zombies.Mobs.ChildRemoved:Connect(function(Zombie)
    Parvus.Utilities.Drawing:RemoveObject(Zombie)
end)
Vehicles.ChildRemoved:Connect(function(Vehicle)
    Parvus.Utilities.Drawing:RemoveObject(Vehicle)
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
