local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = PlayerService.LocalPlayer
local Aimbot,SilentAim,Trigger,
PredictedVelocity,PredictedGravity
= false,nil,nil,1050,30.901500701904297

local Framework = require(ReplicatedFirst.Framework) Framework:WaitForLoaded()
repeat task.wait() until Framework.Classes.Players.get()
local PlayerClass = Framework.Classes.Players.get()

local Raycasting = Framework.Libraries.Raycasting
local Interface = Framework.Libraries.Interface
local Network = Framework.Libraries.Network
local Bullets = Framework.Libraries.Bullets
local Cameras = Framework.Libraries.Cameras

local VehicleController = Framework.Classes.VehicleControler
local Animators = Framework.Classes.Animators

local Events = getupvalue(Network.Add,4)
--[[local GetSpreadAngle = getupvalue(Bullets.Fire,1)
local GetSpreadVector = getupvalue(Bullets.Fire,2)]]
PredictedGravity = getupvalue(Events["Gravity Debug\r"],1)

local NullFunction = function() end
setupvalue(Network.Send,6,NullFunction)
setupvalue(Network.Fetch,6,NullFunction)

local LootBins = Workspace.Map.Shared.LootBins
local Randoms = Workspace.Map.Shared.Randoms
local Vehicles = Workspace.Vehicles.Spawned
local Zombies = Workspace.Zombies.Mobs
local Loot = Workspace.Loot

-- game data mess
local RandomEvents,ItemCategory,SanityBans,ItemMemory,FlyPosition,NoClipEvent = {
"ATVCrashsiteRenegade01","CampSovietBandit01","CrashPrisonBus01",
"LifePreserverMilitary01","LifePreserverSoviet01","LifePreserverSpecOps01",
"MilitaryBlockade01","MilitaryConvoy01","PartyTrailerDisco01",
"PartyTrailerTechnoGold","PartyTrailerTechnoGoldDeagleMod1",
"PirateTreasure01","SeahawkCrashsite04","SeahawkCrashsite05",
"SeahawkCrashsite06","SeahawkCrashsite07","SpecialForcesCrash01",
"SeahawkCrashsiteRogue01","BankTruckRobbery01","StrandedStationKeyboard01"
--[["CrashPrisonBus01","PoolsClosed01","PoliceBlockade01","SeahawkCrashsite04",
"SeahawkCrashsite06","SeahawkCrashsite07","SeahawkCrashsite05","ATVCrashsiteRenegade01",
"MilitaryBlockade01","GraveFresh01","LifePreserverSoviet01","PopupFishing01",
"LifePreserverMilitary01","SedanHaul01","LifePreserverSpecOps01","GraveNumberOne1",
"PopupCampsite01","FuneralProcession01","ConstructionWorksite01","ParamedicScene01",
"MilitaryConvoy01","CampSovietBandit01","SpecialForcesCrash01","PirateTreasure01",
"PartyTrailerTechnoGoldDeagleMod1","PartyTrailerTechnoGold","StrandedStationKeyboard01","BeechcraftGemBroker01",
"BankTruckRobbery01","RandomCrashCessna01","SeahawkCrashsiteRogue01","StashWeaponMid03","StashGeneral03",
"StashWeaponHigh02","StashMedical03","StashFood03","StashWeaponHigh03","StashWeaponMid02","StashGeneral02",
"StashMedical02","StashFood02","StashWeaponHigh01","StashFood01","StashMedical01","StashGeneral01",
"StashWeaponMid01","PopupFishing02","StrandedStation01","BeachedAluminumBoat01","PartyTrailerDisco01"]]
},{"Containers","Accessories","Ammo","Attachments","Backpacks","Belts","Clothing",
"Consumables","Firearms","Hats","Medical","Melees","Utility","VehicleParts","Vests"},
{"Character Humanoid Update","Character Root Update","Get Player Stance Speed",
"Force Charcter Save","Update Character State","Sync Near Chunk Loot"},{},nil,nil

local InteractHeartbeat,FindItemData
for Index,Table in pairs(getgc(true)) do
    if typeof(Table) == "table"
    and rawget(Table,"Rate") == 0.05 then
        InteractHeartbeat = Table.Action
        FindItemData = getupvalue(InteractHeartbeat,11)
    end
end

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local GlobalSection = AimAssistTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Toggle({Name = "Team Check",Flag = "TeamCheck",Value = false})
        end
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            --AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = false})
            AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/WallCheck",Value = false})
            AimbotSection:Toggle({Name = "Distance Check",Flag = "Aimbot/DistanceCheck",Value = false})
            AimbotSection:Toggle({Name = "Dynamic FOV",Flag = "Aimbot/DynamicFOV",Value = false})
            AimbotSection:Keybind({Name = "Keybind",Flag = "Aimbot/Keybind",Value = "MouseButton2",
            Mouse = true,Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})
            AimbotSection:Slider({Name = "Smoothness",Flag = "Aimbot/Smoothness",Min = 0,Max = 100,Value = 25,Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View",Flag = "Aimbot/FieldOfView",Min = 0,Max = 500,Value = 100})
            AimbotSection:Slider({Name = "Distance",Flag = "Aimbot/Distance",Min = 25,Max = 1000,Value = 250,Unit = "meters"})
            AimbotSection:Dropdown({Name = "Body Parts",Flag = "Aimbot/BodyParts",List = {
                {Name = "Head",Mode = "Toggle"},
                {Name = "HeadCollider",Mode = "Toggle",Value = true},
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
                {Name = "Head",Mode = "Toggle"},
                {Name = "HeadCollider",Mode = "Toggle",Value = true},
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
        end Parvus.Utilities.Misc:LightingSection(VisualsTab,"Right")
    end
    local ESPTab = Window:Tab({Name = "AR2 ESP"}) do
        local ItemSection = ESPTab:Section({Name = "Item ESP",Side = "Left"}) do local Items = {}
            ItemSection:Toggle({Name = "Enabled",Flag = "AR2/ESP/Items/Enabled",Value = false})
            ItemSection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/Items/DistanceCheck",Value = true})
            ItemSection:Slider({Name = "Distance",Flag = "AR2/ESP/Items/Distance",Min = 25,Max = 5000,Value = 50,Unit = "meters"})
            for Index,Name in pairs(ItemCategory) do
                local ItemFlag = "AR2/ESP/Items/" .. Name .. "/Enabled" Window.Flags[ItemFlag] = false
                Items[#Items + 1] = {Name = Name,Mode = "Toggle",Value = false,
                    --Colorpicker = {Flag = ItemFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[ItemFlag] = Option.Value end
                }
            end ItemSection:Dropdown({Name = "ESP List",Flag = "AR2/Items",List = Items})
        end
        local ItemCSection = ESPTab:Section({Name = "Item Colors",Side = "Left"}) do
            for Index,Name in pairs(ItemCategory) do local ItemFlag = "AR2/ESP/Items/" .. Name
                ItemCSection:Colorpicker({Name = Name,Flag = ItemFlag.."/Color",Value = {1,0,1,0,false}})
            end
        end
        local RESection = ESPTab:Section({Name = "Random Events ESP",Side = "Right"}) do local REs = {}
            RESection:Toggle({Name = "Enabled",Flag = "AR2/ESP/RandomEvents/Enabled",Value = false})
            RESection:Toggle({Name = "Distance Check",Flag = "AR2/ESP/RandomEvents/DistanceCheck",Value = true})
            RESection:Slider({Name = "Distance",Flag = "AR2/ESP/RandomEvents/Distance",Min = 25,Max = 5000,Value = 1500,Unit = "meters"})
            for Index,Name in pairs(RandomEvents) do
                local REFlag = "AR2/ESP/RandomEvents/" .. Name .. "/Enabled" Window.Flags[REFlag] = false
                REs[#REs + 1] = {Name = Name,Mode = "Toggle",Value = true,
                    --Colorpicker = {Flag = REFlag .. "/Color",Value = {1,0,1,0,false}},
                    Callback = function(Selected,Option) Window.Flags[REFlag] = Option.Value end
                }
            end RESection:Dropdown({Name = "ESP List",Flag = "AR2/Items",List = REs})
        end
        local RECSection = ESPTab:Section({Name = "Random Events Colors",Side = "Right"}) do
            for Index,Name in pairs(RandomEvents) do local REFlag = "AR2/ESP/RandomEvents/" .. Name
                RECSection:Colorpicker({Name = Name,Flag = REFlag.."/Color",Value = {1,0,1,0,false}})
            end
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
        local RecoilSection = MiscTab:Section({Name = "Weapon",Side = "Left"}) do
            RecoilSection:Toggle({Name = "Unlock Firemodes",Flag = "AR2/Firemodes",Value = false})
            RecoilSection:Divider()
            RecoilSection:Toggle({Name = "Recoil Enabled",Flag = "AR2/Recoil/Enabled",Value = false})
            RecoilSection:Slider({Name = "Gun Bob A",Flag = "AR2/Recoil/BobA",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Gun Bob B",Flag = "AR2/Recoil/BobB",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Shift Force",Flag = "AR2/Recoil/ShiftForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Recoil Random",Flag = "AR2/Recoil/RandomInt",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Raise Force",Flag = "AR2/Recoil/RaiseForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "Slide Force",Flag = "AR2/Recoil/SlideForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
            RecoilSection:Slider({Name = "KickUp Force",Flag = "AR2/Recoil/KickUpForce",Min = 0,Max = 100,Value = 0,Unit = "%"})
        end
        local VehSection = MiscTab:Section({Name = "Vehicle",Side = "Left"}) do
            VehSection:Toggle({Name = "Enabled",Flag = "AR2/Vehicle/Enabled",Value = false})
            VehSection:Slider({Name = "Speed",Flag = "AR2/Vehicle/Speed",Min = 100,Max = 500,Value = 200})
            VehSection:Slider({Name = "Steer",Flag = "AR2/Vehicle/Steer",Min = 100,Max = 500,Value = 200})
            --[[VehSection:Slider({Name = "Damping",Flag = "AR2/Vehicle/Damping",Min = 0,Max = 200,Value = 100})
            VehSection:Slider({Name = "Velocity",Flag = "AR2/Vehicle/Velocity",Min = 0,Max = 200,Value = 100})]]
        end
        local CharSection = MiscTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "Fly Enabled",Flag = "AR2/Fly/Enabled",Value = false,Callback = function(Bool)
                if Bool and PlayerClass.Character then FlyPosition = PlayerClass.Character.RootPart.CFrame end
            end}):Keybind({Flag = "AR2/Fly/Keybind"})
            CharSection:Slider({Name = "Fly Value",Flag = "AR2/Fly/Value",Min = 1,Max = 10,Precise = 1,Value = 1})
            CharSection:Divider()
            CharSection:Toggle({Name = "WalkSpeed Enabled",Flag = "AR2/WalkSpeed/Enabled",Value = false}):Keybind()
            CharSection:Slider({Name = "WalkSpeed Value",Flag = "AR2/WalkSpeed/Value",Min = 26,Max = 500,Value = 32})
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
            local SpoofSCS = MiscSection:Toggle({Name = "Spoof SCS",Flag = "AR2/SSCS",Value = false}) SpoofSCS:Keybind()
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
            MenuSection:Colorpicker({Name = "Color",Flag = "UI/Color",Value = {0.4541666507720947,0.20942406356334686,0.7490196228027344,0,false},
            Callback = function(HSVAR,Color) Window:SetColor(Color) end})
        end
        SettingsTab:AddConfigSection("Parvus","Left")
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
                {Name = "Halloween",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://11113209821"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Christmas",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://11711560928"
                    Window.Flags["Background/CustomImage"] = ""
                end,Value = true}
            }})
            BackgroundSection:Textbox({Name = "Custom Image",Flag = "Background/CustomImage",Placeholder = "rbxassetid://ImageId",
            Callback = function(String) if string.gsub(String," ","") ~= "" then Window.Background.Image = String end end})
            BackgroundSection:Colorpicker({Name = "Color",Flag = "Background/Color",Value = {0.12000000476837158,0.10204081237316132,0.9607843160629272,0.5,false},
            Callback = function(HSVAR,Color) Window.Background.ImageColor3 = Color Window.Background.ImageTransparency = HSVAR[4] end})
            BackgroundSection:Slider({Name = "Tile Offset",Flag = "Background/Offset",Min = 74,Max = 296,Value = 74,
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

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Misc:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)
Window:SetValue("Background/Offset",296)
Window:LoadDefaultConfig("Parvus")
Window:SetValue("UI/Toggle",
Window.Flags["UI/OOL"])

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.FilterDescendantsInstances = {
    Workspace.Effects,
    Workspace.Sounds,
    Workspace.Locations,
    Workspace.Spawns
} WallCheckParams.IgnoreWater = true

local function Raycast(Origin,Direction)
    WallCheckParams.FilterDescendantsInstances = {
        Workspace.Effects,Workspace.Sounds,
        Workspace.Locations,Workspace.Spawns,
        LocalPlayer.Character
    }
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
    Velocities[6] = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and Vector3.new(0,-1,0) or Vector3.zero
    return FixUnit(Velocities[1] + Velocities[2] + Velocities[3] + Velocities[4] + Velocities[5] + Velocities[6])
end

local function PlayerFly(Config)
    local Character = PlayerClass.Character
    if not Config.Enabled or not Character
    or not FlyPosition then return end

    FlyPosition += InputToVelocity() * Config.Speed
    Character.RootPart.AssemblyLinearVelocity = Vector3.zero
    Character.RootPart.CFrame = FlyPosition
end

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
    --[[local OldFalling = Character.Falling.Fire
    Character.Falling.Fire = function(Self,Time,...)
        if Window.Flags["AR2/Fly/Enabled"] then
            Character.MoveState = "Walking" Time = 0
        end return OldFalling(Self,Time,...)
    end]]
    local OldEquip = Character.Equip
    Character.Equip = function(Self,Item,...)
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
        Character.Animator.Springs[Spring].Retune = function(Self,A,B,...)
            if Window.Flags["AR2/Recoil/Enabled"] then
                A = A * (Window.Flags["AR2/Recoil/BobA"] / 100)
                B = B * (Window.Flags["AR2/Recoil/BobB"] / 100)
            end
            return OldSpring(Self,A,B,...)
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

local OldSend = Network.Send
Network.Send = function(Self,Name,...) local Args = {...}
    if table.find(SanityBans,Name) then return end
    if (Window.Flags["AR2/SSCS"]
    or Window.Flags["AR2/Fly/Enabled"]
    or Window.Flags["AR2/WalkSpeed/Enabled"])
    and Name == "Set Character State" then
        Args[1] = "Climbing"
    end return OldSend(Self,Name,unpack(Args))
end
local OldFire = Bullets.Fire
Bullets.Fire = function(Self,...) local Args = {...}
    PredictedVelocity = Args[3].FireConfig.MuzzleVelocity
    if SilentAim and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
        local Camera = Workspace.CurrentCamera
        Args[4] = Camera.CFrame.Position + Camera.CFrame.LookVector
        Args[5] = (SilentAim[3].Position - Args[4]).Unit
    end
    return OldFire(Self,unpack(Args))
end
local OldPost = Animators.Post
Animators.Post = function(Self,Name,...) local Args = {...}
    if Window.Flags["AR2/Recoil/Enabled"] and Name == "FireImpulse" then
        Args[1][1] = Args[1][1] * (Window.Flags["AR2/Recoil/ShiftForce"] / 100)
        Args[1][2] = Args[1][2] * (Window.Flags["AR2/Recoil/RandomInt"] / 100)
        Args[1][3] = Args[1][3] * (Window.Flags["AR2/Recoil/RaiseForce"] / 100)
        Args[1][4] = Args[1][4] * (Window.Flags["AR2/Recoil/SlideForce"] / 100)
        Args[1][5] = Args[1][5] * (Window.Flags["AR2/Recoil/KickUpForce"] / 100)
    end
    return OldPost(Self,Name,unpack(Args))
end
local OldCharacterGroundCast = Raycasting.CharacterGroundCast
Raycasting.CharacterGroundCast = function(Self,Position,LengthDown,...)
    if PlayerClass.Character and Position == PlayerClass.Character.RootPart.CFrame then
        if Window.Flags["AR2/EquipInAir"] then LengthDown = 1e6 end
    end return OldCharacterGroundCast(Self,Position,LengthDown,...)
end
local OldConnectVehicle = Cameras.CameraList.Character.ConnectVehicle
Cameras.CameraList.Character.ConnectVehicle = function(...)
    if Window.Flags["AR2/EquipInVehicle"] then return end
    return OldConnectVehicle(...)
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

setupvalue(InteractHeartbeat,11,function(...)
    local Args = {FindItemData(...)}
    if Window.Flags["AR2/InstantSearch"] then
        Args[4] = 0
    end return unpack(Args)
end)

if PlayerClass.Character then
    HookCharacter(PlayerClass.Character)
end
PlayerClass.CharacterAdded:Connect(function(Character)
    HookCharacter(Character)
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
Parvus.Utilities.Misc:NewThreadLoop(0,function()
    PlayerFly({
        Enabled = Window.Flags["AR2/Fly/Enabled"],
        Speed = Window.Flags["AR2/Fly/Value"]
    })
end)
Parvus.Utilities.Misc:NewThreadLoop(1,function()
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return end
    local Items = GetItemsAllFOV({Distance = 100})

    if #Items > 0 and LocalPlayer.Character and not Interface:IsVisible("GameMenu") then
        for Index,Item in pairs(Items) do
            if not Interface:IsVisible("GameMenu") and not ItemMemory[Item] then
                local ContainerAvailable = Network:Fetch("Inventory Container Group Connect",Item)
                if ContainerAvailable and not Interface:IsVisible("GameMenu") then
                    Network:Send("Inventory Container Group Disconnect") ItemMemory[Item] = true
                    task.spawn(function() task.wait(120) ItemMemory[Item] = nil end)
                end
            end
        end
    end
end)

for Index,Item in pairs(Loot:GetDescendants()) do
    local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name,true)
    if Item:IsA("CFrameValue") and ItemData then --print(ItemData.Parent.Name)
        Parvus.Utilities.Drawing:ItemESP({Item,Item.Name,Item.Value.Position},
            "AR2/ESP/Items","AR2/ESP/Items/"..ItemData.Parent.Name,Window.Flags
        )
    end
end
for Index,Event in pairs(Randoms:GetChildren()) do
    if table.find(RandomEvents,Event.Name) then --print(Event.Name)
        Parvus.Utilities.Drawing:ItemESP({Event,Event.Name,Event.Value.Position},
            "AR2/ESP/RandomEvents","AR2/ESP/RandomEvents/"..Event.Name,Window.Flags
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
    if Item:IsA("CFrameValue") and ItemData then --print(ItemData.Parent.Name)
        Parvus.Utilities.Drawing:ItemESP({Item,Item.Name,Item.Value.Position},
            "AR2/ESP/Items","AR2/ESP/Items/"..ItemData.Parent.Name,Window.Flags
        )
    end
end)
Randoms.ChildAdded:Connect(function(Event)
    if table.find(RandomEvents,Event.Name) then --print(Event.Name)
        Parvus.Utilities.Drawing:ItemESP({Event,Event.Name,Event.Value.Position},
            "AR2/ESP/RandomEvents","AR2/ESP/RandomEvents/"..Event.Name,Window.Flags
        )
        if Window.Flags["AR2/ESP/RandomEvents/Enabled"] then
            Parvus.Utilities.UI:Notification2({
                Title = string.format("%s spawned (~%i meters away)",Event.Name,
                GetDistanceFromCamera(Event.Value.Position) * 0.28),Duration = 20
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
    Parvus.Utilities.Drawing:RemoveESP(Item.Parent)
end)
Randoms.ChildRemoved:Connect(function(Event)
    Parvus.Utilities.Drawing:RemoveESP(Event)
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
