local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

task.spawn(function()
    for Index, Connection in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        --print("found ScriptContext error detection, removing")
        Connection:Disable()
    end
    while task.wait(1) do
        for Index, Connection in pairs(getconnections(game:GetService("ScriptContext").Error)) do
            --print("found ScriptContext error detection, removing")
            Connection:Disable()
        end
    end
end)

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Aimbot, SilentAim, Trigger = false, nil, nil

local Mannequin = ReplicatedStorage.Assets.Mannequin
local LootBins = Workspace.Map.Shared.LootBins
local Randoms = Workspace.Map.Shared.Randoms
local Vehicles = Workspace.Vehicles.Spawned
local Characters = Workspace.Characters
local Corpses = Workspace.Corpses
local Zombies = Workspace.Zombies
local Loot = Workspace.Loot

local Framework = require(ReplicatedFirst:WaitForChild("Framework"))
Framework:WaitForLoaded()

repeat task.wait() until Framework.Classes.Players.get()
local PlayerClass = Framework.Classes.Players.get()

local Globals = Framework.Configs.Globals
local World = Framework.Libraries.World
local Network = Framework.Libraries.Network
local Cameras = Framework.Libraries.Cameras
local Bullets = Framework.Libraries.Bullets
local Lighting = Framework.Libraries.Lighting
local Interface = Framework.Libraries.Interface
local Resources = Framework.Libraries.Resources
local Raycasting = Framework.Libraries.Raycasting

local Maids = Framework.Classes.Maids
local Animators = Framework.Classes.Animators
local VehicleController = Framework.Classes.VehicleControler

-- dumb krampus error below :scream:
local Firearm = nil
task.spawn(function() setthreadidentity(2) Firearm = require(ReplicatedStorage.Client.Abstracts.ItemInitializers.Firearm) end)
if not Firearm then LocalPlayer:Kick("Send this error to owner: Firearm module does not exist") return end
local CharacterCamera = Cameras:GetCamera("Character")
--local ReticleInterface = Interface:Get("Reticle")

local Events = getupvalue(Network.Add, 1)
--local EventsQueue = getupvalue(Network.Add, 2)
local GetSpreadAngle = getupvalue(Bullets.Fire, 1)
local GetSpreadVector = getupvalue(Bullets.Fire, 3)
local CastLocalBullet = getupvalue(Bullets.Fire, 4)
local GetFireImpulse = getupvalue(Bullets.Fire, 6)
local LightingState = getupvalue(Lighting.GetState, 1)
--local RenderSettings = getupvalue(World.GetDistance, 1)
local AnimatedReload = getupvalue(Firearm, 7)

local SetWheelSpeeds = getupvalue(VehicleController.Step, 2)
local SetSteerWheels = getupvalue(VehicleController.Step, 3)
--local ApplyDragForce = getupvalue(VehicleController.Step, 4)

local Effects = getupvalue(CastLocalBullet, 2)
local Sounds = getupvalue(CastLocalBullet, 3)
local ImpactEffects = getupvalue(CastLocalBullet, 6)
--local TryRicochet = getupvalue(CastLocalBullet, 10)

if type(Events) == "function" then
    Events = getupvalue(Network.Add, 2)
end

local NetworkSyncHeartbeat
local InteractHeartbeat, FindItemData
for Index, Table in pairs(getgc(true)) do
    if type(Table) == "table" and rawget(Table, "Rate") == 0.05 then
        InteractHeartbeat = Table.Action
        FindItemData = getupvalue(InteractHeartbeat, 11)
    end
end

local ProjectileSpeed = 1000
local ProjectileOrigin = Vector3.new(0, 0, 0)
local ProjectileDirection = Vector3.new(0, 0, 0)
local ProjectileSpread = Vector3.new(0, 0, 0)
local ShotMaxDistance = Globals.ShotMaxDistance
local ProjectileGravity = Globals.ProjectileGravity

local SquadData = nil
local ItemMemory = {}
local GroundPart = Instance.new("Part")
local OldBaseTime = LightingState.BaseTime
local NoClipObjects, NoClipEvent = {}, nil
local SetIdentity = setthreadidentity

local AddObject = Instance.new("BindableEvent")
AddObject.Event:Connect(function(...)
    Parvus.Utilities.Drawing:AddObject(...)
end)

local RemoveObject = Instance.new("BindableEvent")
RemoveObject.Event:Connect(function(...)
    Parvus.Utilities.Drawing:RemoveObject(...)
end)

--RenderSettings.Loot = 1
--RenderSettings.Elements = 1
--RenderSettings.Detail = -1
--RenderSettings.Terrain = 36

-- game data mess
local RandomEvents, ItemCategory, ZombieInherits, SanityBans, AdminRoles = {
    {"ATVCrashsiteRenegade01", false},
    {"BankTruckRobbery01", false},
    {"BeachedAluminumBoat01", false},
    {"BeechcraftGemBroker01", false},
    {"C-123ProviderMilitary01", true},
    {"C-123ProviderMilitary02", true},
    {"CampSovietBandit01", true},
    {"ConstructionWorksite01", false},
    {"CrashEasterBus01", true},
    {"CrashPrisonBus01", false},
    {"EasterNestEvent01", true},
    {"FuddCampsite01", false},
    {"FuneralProcession01", false},
    {"GraveFresh01", false},
    {"GraveNumberOne1", false},
    {"LifePreserverMilitary01", true},
    {"LifePreserverSoviet01", true},
    {"LifePreserverSpecOps01", true},
    {"LongswordStone01", true},
    {"MilitaryBlockade01", true},
    {"MilitaryConvoy01", true},
    {"ParamedicScene01", false},
    {"PartyTrailerDisco01", true},
    {"PartyTrailerTechnoGold", true},
    {"PartyTrailerTechnoGoldDeagleMod1", true},
    {"PirateTreasure01", true},
    {"PoliceBlockade01", false},
    {"PoolsClosed01", false},
    {"PopupCampsite01", false},
    {"PopupFishing01", false},
    {"PopupFishing02", false},
    {"RandomCrashCessna01", false},
    {"SeahawkCrashsite04", true},
    {"SeahawkCrashsite05", true},
    {"SeahawkCrashsite06", true},
    {"SeahawkCrashsite07", true},
    {"SeahawkCrashsiteRogue01", true},
    {"SedanHaul01", false},
    {"SpecialForcesCrash01", true},
    {"StashFood01", false},
    {"StashFood02", false},
    {"StashFood03", false},
    {"StashGeneral01", false},
    {"StashGeneral02", false},
    {"StashGeneral03", false},
    {"StashMedical01", false},
    {"StashMedical02", false},
    {"StashMedical03", false},
    {"StashWeaponHigh01", false},
    {"StashWeaponHigh02", false},
    {"StashWeaponHigh03", false},
    {"StashWeaponMid01", false},
    {"StashWeaponMid02", false},
    {"StashWeaponMid03", false},
    {"StrandedStation01", false},
    {"StrandedStationKeyboard01", false},
    {"ValentinesBachelor01", false}
},
{
    {"Containers", false}, {"Accessories", true}, {"Ammo", false}, {"Attachments", false},
    {"Backpacks", false}, {"Belts", true}, {"Clothing", true}, {"Consumables", true},
    {"Firearms", false}, {"Hats", true}, {"Medical", false}, {"Melees", false},
    {"Miscellaneous", false}, {"Utility", false}, {"VehicleParts", false}, {"Vests", true}
},
{
    {"Presets.Behavior Boss Level 01", true}, {"Presets.Behavior Boss Level 02", true}, {"Presets.Behavior Boss Level 03", true},
    {"Presets.Behavior Common Level 01", false}, {"Presets.Behavior Common Level 02", false}, {"Presets.Behavior Common Level 03", false},
    {"Presets.Behavior Common Thrall Level 01", false}, {"Presets.Behavior MiniBoss Level 01", false}, {"Presets.Behavior MiniBoss Level 02", false},
    {"Presets.Skin Tone Dark", false}, {"Presets.Skin Tone Dark Servant", false}, {"Presets.Skin Tone Light", false}, {"Presets.Skin Tone LightMid", false},
    {"Presets.Skin Tone LightMidDark", false}, {"Presets.Skin Tone Mid", false}, {"Presets.Skin Tone MidDark", false}, {"Presets.Skin Tone Servant", false}
},
{
    "Chat Message Send", "Ping Return", "Bullet Impact Interaction", "Crouch Audio Mute", "Zombie Pushback Force Request", "Camera CFrame Report",
    "Movestate Sync Request", "Update Character Position", "Map Icon History Sync", "Playerlist Staff Icon Get", "Request Physics State Sync",
    "Inventory Sync Request", "Wardrobe Resync Request", "Door Interact ", "Sorry Mate, Wrong Path :/"
},
{
    [110] = "Contractor",
    [120] = "Moderator",
    [125] = "Senior Moderator",
    [130] = "Administrator",
    [160] = "Chief Administrator",
    [200] = "Developer",
    [255] = "Host"
}

local KnownBodyParts = {
    {"Head", true}, {"HumanoidRootPart", true},
    {"UpperTorso", false}, {"LowerTorso", false},

    {"RightUpperArm", false}, {"RightLowerArm", false}, {"RightHand", false},
    {"LeftUpperArm", false}, {"LeftLowerArm", false}, {"LeftHand", false},

    {"RightUpperLeg", false}, {"RightLowerLeg", false}, {"RightFoot", false},
    {"LeftUpperLeg", false}, {"LeftLowerLeg", false}, {"LeftFoot", false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212), Parvus.Game.Name),
    Position = UDim2.new(0.5, -248 * 3, 0.5, -248)
}) do

    local CombatTab = Window:Tab({Name = "Combat"}) do
        local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled", Flag = "Aimbot/Enabled", Value = false})
            :Keybind({Flag = "Aimbot/Keybind", Value = "MouseButton2", Mouse = true, DisableToggle = true,
            Callback = function(Key, KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Always Enabled", Flag = "Aimbot/AlwaysEnabled", Value = false})
            AimbotSection:Toggle({Name = "Prediction", Flag = "Aimbot/Prediction", Value = true})

            AimbotSection:Toggle({Name = "Team Check", Flag = "Aimbot/TeamCheck", Value = false})
            AimbotSection:Toggle({Name = "Distance Check", Flag = "Aimbot/DistanceCheck", Value = false})
            AimbotSection:Toggle({Name = "Visibility Check", Flag = "Aimbot/VisibilityCheck", Value = false})
            AimbotSection:Slider({Name = "Sensitivity", Flag = "Aimbot/Sensitivity", Min = 0, Max = 100, Value = 20, Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View", Flag = "Aimbot/FOV/Radius", Min = 0, Max = 500, Value = 100, Unit = "r"})
            AimbotSection:Slider({Name = "Distance Limit", Flag = "Aimbot/DistanceLimit", Min = 25, Max = 10000, Value = 250, Unit = "studs"})

            local PriorityList, BodyPartsList = {{Name = "Closest", Mode = "Button", Value = true}}, {}
            for Index, Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1], Mode = "Button", Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1], Mode = "Toggle", Value = Value[2]}
            end

            AimbotSection:Dropdown({Name = "Priority", Flag = "Aimbot/Priority", List = PriorityList})
            AimbotSection:Dropdown({Name = "Body Parts", Flag = "Aimbot/BodyParts", List = BodyPartsList})
        end
        local AFOVSection = CombatTab:Section({Name = "Aimbot FOV Circle", Side = "Left"}) do
            AFOVSection:Toggle({Name = "Enabled", Flag = "Aimbot/FOV/Enabled", Value = true})
            AFOVSection:Toggle({Name = "Filled", Flag = "Aimbot/FOV/Filled", Value = false})
            AFOVSection:Colorpicker({Name = "Color", Flag = "Aimbot/FOV/Color", Value = {1, 0.66666662693024, 1, 0.25, false}})
            AFOVSection:Slider({Name = "NumSides", Flag = "Aimbot/FOV/NumSides", Min = 3, Max = 100, Value = 14})
            AFOVSection:Slider({Name = "Thickness", Flag = "Aimbot/FOV/Thickness", Min = 1, Max = 10, Value = 2})
        end
        local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled", Flag = "SilentAim/Enabled", Value = false}):Keybind({Mouse = true, Flag = "SilentAim/Keybind"})

            --SilentAimSection:Toggle({Name = "Prediction", Flag = "SilentAim/Prediction", Value = true})

            SilentAimSection:Toggle({Name = "Team Check", Flag = "SilentAim/TeamCheck", Value = false})
            SilentAimSection:Toggle({Name = "Distance Check", Flag = "SilentAim/DistanceCheck", Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check", Flag = "SilentAim/VisibilityCheck", Value = false})
            SilentAimSection:Slider({Name = "Hit Chance", Flag = "SilentAim/HitChance", Min = 0, Max = 100, Value = 100, Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View", Flag = "SilentAim/FOV/Radius", Min = 0, Max = 500, Value = 100, Unit = "r"})
            SilentAimSection:Slider({Name = "Distance Limit", Flag = "SilentAim/DistanceLimit", Min = 25, Max = 10000, Value = 250, Unit = "studs"})

            local PriorityList, BodyPartsList = {{Name = "Closest", Mode = "Button", Value = true}, {Name = "Random", Mode = "Button"}}, {}
            for Index, Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1], Mode = "Button", Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1], Mode = "Toggle", Value = Value[2]}
            end

            SilentAimSection:Dropdown({Name = "Priority", Flag = "SilentAim/Priority", List = PriorityList})
            SilentAimSection:Dropdown({Name = "Body Parts", Flag = "SilentAim/BodyParts", List = BodyPartsList})
        end
        local SAFOVSection = CombatTab:Section({Name = "Silent Aim FOV Circle", Side = "Right"}) do
            SAFOVSection:Toggle({Name = "Enabled", Flag = "SilentAim/FOV/Enabled", Value = true})
            SAFOVSection:Toggle({Name = "Filled", Flag = "SilentAim/FOV/Filled", Value = false})
            SAFOVSection:Colorpicker({Name = "Color", Flag = "SilentAim/FOV/Color",
            Value = {0.6666666865348816, 0.6666666269302368, 1, 0.25, false}})
            SAFOVSection:Slider({Name = "NumSides", Flag = "SilentAim/FOV/NumSides", Min = 3, Max = 100, Value = 14})
            SAFOVSection:Slider({Name = "Thickness", Flag = "SilentAim/FOV/Thickness", Min = 1, Max = 10, Value = 2})
        end
        local TriggerSection = CombatTab:Section({Name = "Trigger", Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled", Flag = "Trigger/Enabled", Value = false})
            :Keybind({Flag = "Trigger/Keybind", Value = "MouseButton2", Mouse = true, DisableToggle = true,
            Callback = function(Key, KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})

            TriggerSection:Toggle({Name = "Always Enabled", Flag = "Trigger/AlwaysEnabled", Value = false})
            TriggerSection:Toggle({Name = "Hold Mouse Button", Flag = "Trigger/HoldMouseButton", Value = false})
            TriggerSection:Toggle({Name = "Prediction", Flag = "Trigger/Prediction", Value = true})

            --TriggerSection:Toggle({Name = "Team Check", Flag = "Trigger/TeamCheck", Value = false})
            TriggerSection:Toggle({Name = "Distance Check", Flag = "Trigger/DistanceCheck", Value = false})
            TriggerSection:Toggle({Name = "Visibility Check", Flag = "Trigger/VisibilityCheck", Value = false})

            TriggerSection:Slider({Name = "Click Delay", Flag = "Trigger/Delay", Min = 0, Max = 1, Precise = 2, Value = 0.15, Unit = "sec"})
            TriggerSection:Slider({Name = "Distance Limit", Flag = "Trigger/DistanceLimit", Min = 25, Max = 10000, Value = 250, Unit = "studs"})
            TriggerSection:Slider({Name = "Field Of View", Flag = "Trigger/FOV/Radius", Min = 0, Max = 500, Value = 25, Unit = "r"})

            local PriorityList, BodyPartsList = {{Name = "Closest", Mode = "Button", Value = true}, {Name = "Random", Mode = "Button"}}, {}
            for Index, Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1], Mode = "Button", Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1], Mode = "Toggle", Value = Value[2]}
            end

            TriggerSection:Dropdown({Name = "Priority", Flag = "Trigger/Priority", List = PriorityList})
            TriggerSection:Dropdown({Name = "Body Parts", Flag = "Trigger/BodyParts", List = BodyPartsList})
        end
        local TFOVSection = CombatTab:Section({Name = "Trigger FOV Circle", Side = "Left"}) do
            TFOVSection:Toggle({Name = "Enabled", Flag = "Trigger/FOV/Enabled", Value = true})
            TFOVSection:Toggle({Name = "Filled", Flag = "Trigger/FOV/Filled", Value = false})
            TFOVSection:Colorpicker({Name = "Color", Flag = "Trigger/FOV/Color", Value = {0.0833333358168602, 0.6666666269302368, 1, 0.25, false}})
            TFOVSection:Slider({Name = "NumSides", Flag = "Trigger/FOV/NumSides", Min = 3, Max = 100, Value = 14})
            TFOVSection:Slider({Name = "Thickness", Flag = "Trigger/FOV/Thickness", Min = 1, Max = 10, Value = 2})
        end
    end
    local VisualsSection = Parvus.Utilities:ESPSection(Window, "Visuals", "ESP/Player", true, true, true, true, true, false) do
        VisualsSection:Colorpicker({Name = "Ally Color", Flag = "ESP/Player/Ally", Value = {0.3333333432674408, 0.6666666269302368, 1, 0, false}})
        VisualsSection:Colorpicker({Name = "Enemy Color", Flag = "ESP/Player/Enemy", Value = {1, 0.6666666269302368, 1, 0, false}})
        VisualsSection:Toggle({Name = "Team Check", Flag = "ESP/Player/TeamCheck", Value = false})
        VisualsSection:Toggle({Name = "Use Team Color", Flag = "ESP/Player/TeamColor", Value = false})
        VisualsSection:Toggle({Name = "Distance Check", Flag = "ESP/Player/DistanceCheck", Value = true})
        VisualsSection:Slider({Name = "Distance", Flag = "ESP/Player/Distance", Min = 25, Max = 10000, Value = 1000, Unit = "studs"})
    end
    local ESPTab = Window:Tab({Name = "AR2 ESP"}) do
        local ItemSection = ESPTab:Section({Name = "Item ESP", Side = "Left"}) do local Items = {}
            ItemSection:Toggle({Name = "Enabled", Flag = "AR2/ESP/Items/Enabled", Value = false})
            ItemSection:Toggle({Name = "Distance Check", Flag = "AR2/ESP/Items/DistanceCheck", Value = true})
            ItemSection:Slider({Name = "Distance", Flag = "AR2/ESP/Items/Distance", Min = 25, Max = 5000, Value = 50, Unit = "studs"})

            for Index, Data in pairs(ItemCategory) do
                local ItemFlag = "AR2/ESP/Items/" .. Data[1]
                Window.Flags[ItemFlag .. "/Enabled"] = Data[2]

                Items[#Items + 1] = {
                    Name = Data[1], Mode = "Toggle", Value = Data[2],
                    Colorpicker = {Flag = ItemFlag .. "/Color", Value = {1, 0, 1, 0.5, false}},
                    Callback = function(Selected, Option) Window.Flags[ItemFlag .. "/Enabled"] = Option.Value end
                }
            end

            ItemSection:Dropdown({Name = "ESP List", Flag = "AR2/Items", List = Items})
        end
        local CorpsesSection = ESPTab:Section({Name = "Corpses ESP", Side = "Left"}) do
            CorpsesSection:Toggle({Name = "Enabled", Flag = "AR2/ESP/Corpses/Enabled", Value = false})
            CorpsesSection:Toggle({Name = "Distance Check", Flag = "AR2/ESP/Corpses/DistanceCheck", Value = true})
            CorpsesSection:Colorpicker({Name = "Color", Flag = "AR2/ESP/Corpses/Color", Value = {1, 0, 1, 0.5, false}})
            CorpsesSection:Slider({Name = "Distance", Flag = "AR2/ESP/Corpses/Distance", Min = 25, Max = 5000, Value = 1500, Unit = "studs"})
        end
        local ZombiesSection = ESPTab:Section({Name = "Zombies ESP", Side = "Left"}) do local ZIs = {}
            ZombiesSection:Toggle({Name = "Enabled", Flag = "AR2/ESP/Zombies/Enabled", Value = false})
            ZombiesSection:Toggle({Name = "Distance Check", Flag = "AR2/ESP/Zombies/DistanceCheck", Value = true})
            ZombiesSection:Slider({Name = "Distance", Flag = "AR2/ESP/Zombies/Distance", Min = 25, Max = 5000, Value = 1500, Unit = "studs"})

            for Index, Data in pairs(ZombieInherits) do
                local Name = Data[1]:gsub("Presets.", ""):gsub(" ", "")
                local ZIFlag = "AR2/ESP/Zombies/" .. Name
                Window.Flags[ZIFlag .. "/Enabled"] = Data[2]

                ZIs[#ZIs + 1] = {
                    Name = Name, Mode = "Toggle", Value = Data[2],
                    Colorpicker = {Flag = ZIFlag .. "/Color", Value = {1, 0, 1, 0.5, false}},
                    Callback = function(Selected, Option) Window.Flags[ZIFlag .. "/Enabled"] = Option.Value end
                }
            end

            ZombiesSection:Dropdown({Name = "ESP List", Flag = "AR2/Zombies", List = ZIs})
        end
        local RESection = ESPTab:Section({Name = "Random Events ESP", Side = "Right"}) do local REs = {}
            RESection:Toggle({Name = "Enabled", Flag = "AR2/ESP/RandomEvents/Enabled", Value = false})
            RESection:Toggle({Name = "Distance Check", Flag = "AR2/ESP/RandomEvents/DistanceCheck", Value = true})
            RESection:Slider({Name = "Distance", Flag = "AR2/ESP/RandomEvents/Distance", Min = 25, Max = 5000, Value = 1500, Unit = "studs"})

            for Index, Data in pairs(RandomEvents) do
                local REFlag = "AR2/ESP/RandomEvents/" .. Data[1]
                Window.Flags[REFlag .. "/Enabled"] = Data[2]

                REs[#REs + 1] = {
                    Name = Data[1], Mode = "Toggle", Value = Data[2],
                    Colorpicker = {Flag = REFlag .. "/Color", Value = {1, 0, 1, 0.5, false}},
                    Callback = function(Selected, Option) Window.Flags[REFlag .. "/Enabled"] = Option.Value end
                }
            end

            RESection:Dropdown({Name = "ESP List", Flag = "AR2/RandomEvents", List = REs})
        end
        local VehiclesSection = ESPTab:Section({Name = "Vehicles ESP", Side = "Right"}) do
            VehiclesSection:Toggle({Name = "Enabled", Flag = "AR2/ESP/Vehicles/Enabled", Value = false})
            VehiclesSection:Toggle({Name = "Distance Check", Flag = "AR2/ESP/Vehicles/DistanceCheck", Value = true})
            VehiclesSection:Colorpicker({Name = "Color", Flag = "AR2/ESP/Vehicles/Color", Value = {1, 0, 1, 0.5, false}})
            VehiclesSection:Slider({Name = "Distance", Flag = "AR2/ESP/Vehicles/Distance", Min = 25, Max = 5000, Value = 1500, Unit = "studs"})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do local LModes = {}
        local LightingSection = MiscTab:Section({Name = "Lighting", Side = "Left"}) do
            LightingSection:Toggle({Name = "Enabled", Flag = "AR2/Lighting/Enabled", Value = false,
            Callback = function(Bool) if not Bool then LightingState.BaseTime = OldBaseTime end end})
            --LightingSection:Toggle({Name = "Positive StartTime", Flag = "AR2/Lighting/StartTime", Value = false})
            LightingSection:Slider({Name = "Time", Flag = "AR2/Lighting/Time", Min = 0, Max = 24, Precise = 1, Value = 12, Unit = "hours"})

            for Name, LightingMode in pairs(getupvalue(Lighting.GetState, 4)) do
                LModes[#LModes + 1] = {Name = Name, Mode = "Button", Value = false,
                Callback = function() Lighting:SetMode(Name) end}
            end

            LightingSection:Dropdown({Name = "Lighting Mode", Flag = "AR2/Lighting/Modes", List = LModes})
            LightingSection:Button({Name = "Reset Lighting Mode", Callback = function() Lighting:Reset() end})

        end
        local RecoilSection = MiscTab:Section({Name = "Weapon", Side = "Left"}) do
            --RecoilSection:Toggle({Name = "Instant Hit", Flag = "AR2/InstantHit", Value = false})
            RecoilSection:Toggle({Name = "Bullet Tracer", Flag = "AR2/BulletTracer/Enabled", Value = false})
            :Colorpicker({Flag = "AR2/BulletTracer/Color", Value = {1, 0.75, 1, 0, true}})
            RecoilSection:Toggle({Name = "Silent Wallbang", Flag = "AR2/MagicBullet/Enabled", Value = false}):Keybind({Flag = "AR2/MagicBullet/Keybind"})
            RecoilSection:Slider({Name = "Wallbang Depth", Flag = "AR2/MagicBullet/Depth", Min = 1, Max = 5, Value = 5, Unit = "studs"})
            RecoilSection:Divider()
            RecoilSection:Toggle({Name = "Recoil Control", Flag = "AR2/Recoil/Enabled", Value = false})
            RecoilSection:Slider({Name = "Recoil", Flag = "AR2/Recoil/Value", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Toggle({Name = "No Spread", Flag = "AR2/NoSpread", Value = false})
            --RecoilSection:Toggle({Name = "No Wobble", Flag = "AR2/NoWobble", Value = false})
            RecoilSection:Toggle({Name = "No Camera Flinch", Flag = "AR2/NoFlinch", Value = false})
            RecoilSection:Toggle({Name = "Unlock Firemodes", Flag = "AR2/UnlockFiremodes", Value = false})
            RecoilSection:Toggle({Name = "Instant Reload", Flag = "AR2/InstantReload", Value = false})
            --[[RecoilSection:Divider()
            RecoilSection:Toggle({Name = "Recoil Control", Flag = "AR2/Recoil/Enabled", Value = false})
            RecoilSection:Slider({Name = "Shift Force", Flag = "AR2/Recoil/ShiftForce", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Slider({Name = "Roll Bias", Flag = "AR2/Recoil/RollBias", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Slider({Name = "Raise Force", Flag = "AR2/Recoil/RaiseForce", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Slider({Name = "Slide Force", Flag = "AR2/Recoil/SlideForce", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Slider({Name = "KickUp Force", Flag = "AR2/Recoil/KickUpForce", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Slider({Name = "Bob Force", Flag = "AR2/Bob/Force", Min = 0, Max = 100, Value = 0, Unit = "%"})
            RecoilSection:Slider({Name = "Bob Damping", Flag = "AR2/Bob/Damping", Min = 0, Max = 100, Value = 0, Unit = "%"})]]
        end
        local VehSection = MiscTab:Section({Name = "Vehicle", Side = "Left"}) do
            VehSection:Toggle({Name = "Enabled", Flag = "AR2/Vehicle/Enabled", Value = false})
            VehSection:Toggle({Name = "No Impact", Flag = "AR2/Vehicle/Impact", Value = false})
            --VehSection:Toggle({Name = "Fly", Flag = "AR2/Vehicle/Fly", Value = false})
            VehSection:Toggle({Name = "Instant Action", Flag = "AR2/Vehicle/Instant", Value = false})
            VehSection:Slider({Name = "Max Speed", Flag = "AR2/Vehicle/MaxSpeed", Min = 0, Max = 500, Value = 100, Unit = "mph"})
            --VehSection:Slider({Name = "Steer", Flag = "AR2/Vehicle/Steer", Min = 100, Max = 500, Value = 200})
            --[[VehSection:Slider({Name = "Damping", Flag = "AR2/Vehicle/Damping", Min = 0, Max = 200, Value = 100})
            VehSection:Slider({Name = "Velocity", Flag = "AR2/Vehicle/Velocity", Min = 0, Max = 200, Value = 100})]]
        end
        --[[local TargetSection = MiscTab:Section({Name = "Target", Side = "Right"}) do
            local PlayerDropdown = TargetSection:Dropdown({Name = "Player List",
            IgnoreFlag = true, Flag = "AR2/Teleport/List"})
            PlayerDropdown:RefreshToPlayers(false)

            TargetSection:Button({Name = "Refresh", Callback = function()
                PlayerDropdown:RefreshToPlayers(false)
            end})

            TargetSection:Button({Name = "Teleport", Callback = function()
                if Window.Flags["AR2/Teleport/Loop"] then return end
                TeleportBypass = true
                while task.wait() do
                    if not Teleport(PlayerDropdown.Value[1]) then
                        Parvus.Utilities.UI:Toast({Title = "Teleport Ended", Duration = 5})
                        TeleportBypass = false break
                    end
                end
            end})

            TargetSection:Toggle({Name = "Loop Teleport", Flag = "AR2/Teleport/Loop", Value = false}):Keybind()
            TargetSection:Slider({Name = "Teleport Speed", Flag = "AR2/Teleport/Speed", Min = 1, Max = 50, Value = 20, Unit = "studs", Wide = true})
            TargetSection:Button({Name = "TP Zombies", Callback = function()
                local OldAntiZombie = Window:GetValue("AR2/AntiZombie/Enabled")
                Window:SetValue("AR2/AntiZombie/Enabled", false)

                local Closest = GetCharactersInRadius(Zombies.Mobs, 250)
                if not Closest then return end
                for Index, Character in pairs(Closest) do
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
                                local Back = TargetPlayer.Character.PrimaryPart.CFrame * Vector3.new(0, 0, 12)
                                Character.PrimaryPart.CFrame = CFrame.new(Back, TargetPlayer.Character.PrimaryPart.Position - Back)
                                if not isnetworkowner(Character.PrimaryPart) then print("teleported", Character) break end
                            end
                        end)
                    end
                end

                Window:SetValue("AR2/AntiZombie/Enabled", OldAntiZombie)
            end})
        end]]
        local CharSection = MiscTab:Section({Name = "Character", Side = "Right"}) do
            CharSection:Toggle({Name = "Fly Enabled", Flag = "AR2/Fly/Enabled", Value = false}):Keybind({Flag = "AR2/Fly/Keybind"})
            CharSection:Slider({Name = "", Flag = "AR2/Fly/Speed", Min = 0, Max = 10, Precise = 1, Value = 0.7, Unit = "studs", Wide = true})
            --CharSection:Divider()
            CharSection:Toggle({Name = "Walk Speed", Flag = "AR2/WalkSpeed/Enabled", Value = false}):Keybind({Flag = "AR2/WalkSpeed/Keybind"})
            CharSection:Slider({Name = "", Flag = "AR2/WalkSpeed/Speed", Min = 0, Max = 1.4, Precise = 1, Value = 0.7, Unit = "studs", Wide = true})
            --CharSection:Divider()
            CharSection:Toggle({Name = "Jump Height", Flag = "AR2/JumpHeight/Enabled", Value = false}):Keybind({Flag = "AR2/JumpHeight/Keybind"})
            CharSection:Toggle({Name = "Infinite Jump", Flag = "AR2/JumpHeight/NoFallCheck", Value = false})
            CharSection:Toggle({Name = "No Fall Impact", Flag = "AR2/NoFallImpact", Value = false})
            CharSection:Toggle({Name = "No Jump Debounce", Flag = "AR2/NoJumpDebounce", Value = false})
            CharSection:Slider({Name = "", Flag = "AR2/JumpHeight/Height", Min = 4.8, Max = 100, Precise = 1, Value = 4.8, Unit = "studs", Wide = true})
            --CharSection:Divider()
            CharSection:Toggle({Name = "Use In Air/Water", Flag = "AR2/UseInAir", Value = false})
            --CharSection:Toggle({Name = "Use In Water", Flag = "AR2/UseInWater", Value = false})
            CharSection:Toggle({Name = "Fast Respawn", Flag = "AR2/FastRespawn", Value = false})
            --[[CharSection:Toggle({Name = "Play Dead", Flag = "AR2/PlayDead", IgnoreFlag = true, Value = false,
            Callback = function(Bool)
                if not PlayerClass.Character then return end
                if Bool then PlayerClass.Character.Animator:PlayAnimationReplicated("Death.Standing Forwards", true)
                else PlayerClass.Character.Animator:StopAnimationReplicated("Death.Standing Forwards", true) end
            end})]]
            CharSection:Button({Name = "Respawn", Callback = function()
                task.spawn(function() SetIdentity(2)
                    PlayerClass:UnloadCharacter()
                    Interface:Hide("Reticle")
                    task.wait(0.5)
                    PlayerClass:LoadCharacter()
                end)
            end}):Tooltip("You will lose loot")
        end
        local MiscSection = MiscTab:Section({Name = "Other", Side = "Right"}) do

            -- Very basic head expander idc
            MiscSection:Toggle({Name = "Head Expander", Flag = "AR2/HeadExpander", Value = false,
            Callback = function(Bool)
                if Bool then return end
                for Index, Player in pairs(PlayerService:GetPlayers()) do
                    if Player == LocalPlayer then continue end
                    if not Player.Character then continue end
                    local Character = Player.Character
                    local Head = Character.Head

                    Head.Size = Mannequin.Head.Size
                    Head.Transparency = Mannequin.Head.Transparency
                    Head.CanCollide = Mannequin.Head.CanCollide
                end
            end})
            MiscSection:Slider({Name = "Size Mult", Flag = "AR2/HeadExpander/Value", Min = 1, Max = 20, Value = 10, Unit = "x", Wide = true})
            MiscSection:Slider({Name = "Transparency", Flag = "AR2/HeadExpander/Transparency", Min = 0, Max = 1, Value = 0.5, Precise = 1, Wide = true})
            MiscSection:Divider()
            MiscSection:Toggle({Name = "MeleeAura", Flag = "AR2/MeleeAura", Value = false})
            MiscSection:Toggle({Name = "Zombie MeleeAura", Flag = "AR2/AntiZombie/MeleeAura", Value = false})
            MiscSection:Toggle({Name = "Container Persistence", Flag = "AR2/ContainerPersistence", Value = false})
            MiscSection:Toggle({Name = "Instant Search", Flag = "AR2/InstantSearch", Value = false})
            --MiscSection:Toggle({Name = "Anti-Zombie", Flag = "AR2/AntiZombie/Enabled", Value = false}):Keybind()
            --MiscSection:Toggle({Name = "Anti-Zombie MeleeAura", Flag = "AR2/AntiZombie/MeleeAura", Value = false})
            local SpoofSCS = MiscSection:Toggle({Name = "Spoof State", Flag = "AR2/SSCS", Value = false}) SpoofSCS:Keybind()
            SpoofSCS:Tooltip("SCS - Set Character State:\nNo Fall Damage\nLess Hunger / Thirst\nWhile Sprinting")

            local MoveStates = {}
            for MoveState, Value in pairs(Framework.Configs.Character.ValidMoveStates) do
                MoveStates[#MoveStates + 1] = {Name = MoveState, Mode = "Button", Value = false}
                if MoveState == "Climbing" then MoveStates[#MoveStates].Value = true end
            end
            MiscSection:Dropdown({Name = "Move States", Flag = "AR2/MoveState", List = MoveStates})
            MiscSection:Toggle({Name = "NoClip", Flag = "AR2/NoClip", Value = false,
            Callback = function(Bool)
                if Bool and not NoClipEvent then
                    NoClipEvent = RunService.Stepped:Connect(function()
                        if not LocalPlayer.Character then return end

                        for Index, Object in pairs(LocalPlayer.Character:GetDescendants()) do
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
                    for Object, CanCollide in pairs(NoClipObjects) do
                        Object.CanCollide = CanCollide
                    end table.clear(NoClipObjects)
                end
            end}):Keybind()
            MiscSection:Toggle({Name = "Map ESP", Flag = "AR2/MapESP", Value = false})
            MiscSection:Toggle({Name = "Staff Join", Flag = "AR2/StaffJoin", Value = false})
            MiscSection:Dropdown({HideName = true, Flag = "AR2/StaffJoin/List", List = {
                {Name = "Server Hop", Mode = "Button", Value = false},
                {Name = "Notify", Mode = "Button", Value = true},
                {Name = "Kick", Mode = "Button", Value = false}
            }})
        end
    end Parvus.Utilities:SettingsSection(Window, "RightControl", true)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("SilentAim", Window.Flags)

local XZVector = Vector3.new(1, 0, 1)
local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.FilterDescendantsInstances = {
    Workspace.Effects, Workspace.Sounds,
    Workspace.Locations, Workspace.Spawns
} WallCheckParams.IgnoreWater = true

local function Raycast(Origin, Direction)
    if not table.find(WallCheckParams.FilterDescendantsInstances, LocalPlayer.Character) then
        WallCheckParams.FilterDescendantsInstances = {
            Workspace.Effects, Workspace.Sounds,
            Workspace.Locations, Workspace.Spawns,
            LocalPlayer.Character
        } --print("added character to raycast")
    end

    local RaycastResult = Workspace:Raycast(Origin, Direction, WallCheckParams)
    if RaycastResult then
        if (RaycastResult.Instance.Transparency == 1
        and RaycastResult.Instance.CanCollide == false)
        or (CollectionService:HasTag(RaycastResult.Instance, "Bullets Penetrate")
        or CollectionService:HasTag(RaycastResult.Instance, "Window Part")
        or CollectionService:HasTag(RaycastResult.Instance, "World Mesh")
        or CollectionService:HasTag(RaycastResult.Instance, "World Water Part")) then
            return true
        end
    end
end
local function InEnemyTeam(Enabled, Player)
    if not Enabled then return true end
    if SquadData and SquadData.Members then
        if table.find(SquadData.Members, Player.Name) then
            return false
        end
    end

    return true
end
local function WithinReach(Enabled, Distance, Limit)
    if not Enabled then return true end
    return Distance < Limit
end
local function ObjectOccluded(Enabled, Origin, Position, Object)
    if not Enabled then return false end
    return Raycast(Origin, Position - Origin, {Object, LocalPlayer.Character})
end
local function SolveTrajectory(Origin, Velocity, Time, Gravity)
    Gravity = Vector3.new(0, math.abs(Gravity), 0)
    return Origin + (Velocity * Time) + (Gravity * Time * Time)
end
--[[local function SolveTrajectory2(Origin, Velocity, Time, Gravity)
    Gravity = Vector3.new(0, math.abs(Gravity), 0)
    return Origin + (Gravity * Time * Time)
end]]
local function GetClosest(Enabled,
    TeamCheck, VisibilityCheck, DistanceCheck,
    DistanceLimit, FieldOfView, Priority, BodyParts,
    PredictionEnabled
)

    if not Enabled then return end
    if not PlayerClass.Character then return end
    --[[local Weapon = PlayerClass.Character.Instance.Equipped:FindFirstChildOfClass("Model")
    if not Weapon then return end

    local Muzzle = Weapon:FindFirstChild("Muzzle")
    if not Muzzle then return end]]

    local CameraPosition, Closest = Camera.CFrame.Position, nil
    for Index, Player in ipairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character = Player.Character if not Character then continue end
        if not InEnemyTeam(TeamCheck, Player) then continue end

        if Priority == "Random" then
            Priority = BodyParts[math.random(#BodyParts)]
            BodyPart = Character:FindFirstChild(Priority)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            BodyPartPosition = PredictionEnabled and SolveTrajectory(BodyPartPosition,
            BodyPart.AssemblyLinearVelocity, Distance / ProjectileSpeed, ProjectileGravity) or BodyPartPosition
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            ScreenPosition = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            if not OnScreen then continue end

            Distance = (BodyPartPosition - CameraPosition).Magnitude
            if not WithinReach(DistanceCheck, Distance, DistanceLimit) then continue end
            if ObjectOccluded(VisibilityCheck, CameraPosition, BodyPartPosition, Character) then continue end

            local Magnitude = (ScreenPosition - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            return {Player, Character, BodyPart, ScreenPosition}
        elseif Priority ~= "Closest" then
            BodyPart = Character:FindFirstChild(Priority)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            BodyPartPosition = PredictionEnabled and SolveTrajectory(BodyPartPosition,
            BodyPart.AssemblyLinearVelocity, Distance / ProjectileSpeed, ProjectileGravity) or BodyPartPosition
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            ScreenPosition = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            if not OnScreen then continue end

            Distance = (BodyPartPosition - CameraPosition).Magnitude
            if not WithinReach(DistanceCheck, Distance, DistanceLimit) then continue end
            if ObjectOccluded(VisibilityCheck, CameraPosition, BodyPartPosition, Character) then continue end

            local Magnitude = (ScreenPosition - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            return {Player, Character, BodyPart, ScreenPosition}
        end

        for Index, BodyPart in ipairs(BodyParts) do
            BodyPart = Character:FindFirstChild(BodyPart)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            BodyPartPosition = PredictionEnabled and SolveTrajectory(BodyPartPosition,
            BodyPart.AssemblyLinearVelocity, Distance / ProjectileSpeed, ProjectileGravity) or BodyPartPosition
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            ScreenPosition = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
            if not OnScreen then continue end

            Distance = (BodyPartPosition - CameraPosition).Magnitude
            if not WithinReach(DistanceCheck, Distance, DistanceLimit) then continue end
            if ObjectOccluded(VisibilityCheck, CameraPosition, BodyPartPosition, Character) then continue end

            local Magnitude = (ScreenPosition - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            FieldOfView, Closest = Magnitude, {Player, Character, BodyPart, ScreenPosition}
        end
    end

    return Closest
end
local function AimAt(Hitbox, Sensitivity)
    if not Hitbox then return end
    local MouseLocation = UserInputService:GetMouseLocation()

    mousemoverel(
        (Hitbox[4].X - MouseLocation.X) * Sensitivity,
        (Hitbox[4].Y - MouseLocation.Y) * Sensitivity
    )
end

local function CheckForAdmin(Player)
    if Window.Flags["AR2/StaffJoin"] then
        local Rank = Player:GetRankInGroup(15434910)
        if not Rank then return end

        local Role = AdminRoles[Rank]
        if not Role then return end

        local Message = ("Staff member has joined or is in your game\nName: %s\nUserId: %s\nRole: %s"):format(Player.Name, Player.UserId, Role)
        if Window.Flags["AR2/StaffJoin/List"][1] == "Kick" then
            LocalPlayer:Kick(Message)
        elseif Window.Flags["AR2/StaffJoin/List"][1] == "Server Hop" then
            LocalPlayer:Kick(Message)
            task.wait(5)
            Parvus.Utilities.ServerHop()
        elseif Window.Flags["AR2/StaffJoin/List"][1] == "Notify" then
            UI:Push({Title = Message, Duration = 20})
        end
    end
end
local function GetStates()
    if not NetworkSyncHeartbeat then print("no") return {} end
    --local Character = debug.getupvalue(NetworkSyncHeartbeat, 1)
    local Seed = debug.getupvalue(NetworkSyncHeartbeat, 6)
    --local Camera = debug.getupvalue(NetworkSyncHeartbeat, 7)

    local RandomData = {}
    local SeededRandom = Random.new(Seed)

    local Data = {
        "ServerTime", -- {"ServerTime", workspace:GetServerTimeNow()},
        "RootCFrame", -- {"RootCFrame", Self.RootPart.CFrame},
        "RootVelocity", -- {"RootVelocity", Self.RootPart.AssemblyLinearVelocity},
        "FirstPerson", -- {"FirstPerson", Character.FirstPerson},
        "InstanceCFrame", -- {"InstanceCFrame", Character.Instance.CFrame},
        "LookDirection", -- {"LookDirection", Self.LookDirectionSpring:GetGoal()},
        "MoveState", -- {"MoveState", Self.MoveState},
        "AtEaseInput", -- {"AtEaseInput", Self.AtEaseInput},
        "ShoulderSwapped", -- {"ShoulderSwapped", Self.ShoulderSwapped},
        "Zooming", -- {"Zooming", Self.Zooming},
        "BinocsActive", -- {"BinocsActive", Character.FirstPerson and not Self.BinocsAtEase},
        "Staggered", -- {"Staggered", Self.Staggered},
        "Shoving", -- {"Shoving", Self.Shoving}
    }

    local DataLength = #Data
    while #Data > 0 do
        local ToRemove = SeededRandom:NextInteger(1, DataLength)
        --print(#Data, ToRemove % #Data, ToRemove, ToRemove % #Data == 0)
        ToRemove = ToRemove % #Data == 0 and #Data or ToRemove % #Data
        local Removed = table.remove(Data, ToRemove)
        table.insert(RandomData, Removed)
    end

    return RandomData
end
--[[local function CastLocalBulletInstant(Origin, SpreadDirection, Direction)
    local Velocity = Direction * ProjectileSpeed
    local SpreadVelocity = SpreadDirection * ProjectileSpeed

    local ProjectilePosition = Origin
    local ProjectileSpreadPosition = Origin

    local ProjectileRay = nil
    local ProjectileCastInstance = nil
    local ProjectileCastPosition = Vector3.zero

    local ProjectileSpreadRay = nil
    local ProjectileSpreadCastInstance = nil
    local ProjectileSpreadCastPosition = Vector3.zero

    local Exclude = {
        Effects,
        Sounds,
        PlayerClass.Character.Instance
    }

    local Frame = 1 / 60
    local TravelTime = 0
    local Traveling = true
    local TravelDistance = 0
    local SpreadTravelDistance = 0

    while Traveling do
        TravelTime += Frame

        ProjectileRay = Ray.new(ProjectilePosition, Origin + Velocity * TravelTime + ProjectileGravity * Vector3.yAxis * TravelTime ^ 2 - ProjectilePosition)
        ProjectileSpreadRay = Ray.new(ProjectileSpreadPosition, Origin + SpreadVelocity * TravelTime + ProjectileGravity * Vector3.yAxis * TravelTime ^ 2 - ProjectileSpreadPosition)

        ProjectileCastInstance, ProjectileCastPosition = Raycasting:BulletCast(ProjectileRay, true, Exclude)
        ProjectileSpreadCastInstance, ProjectileSpreadCastPosition = Raycasting:BulletCast(ProjectileSpreadRay, true, Exclude)

        TravelDistance = TravelDistance + (ProjectilePosition - ProjectileCastPosition).Magnitude
        SpreadTravelDistance = SpreadTravelDistance + (ProjectileSpreadPosition - ProjectileSpreadCastPosition).Magnitude

        ProjectilePosition = ProjectileCastPosition
        ProjectileSpreadPosition = ProjectileSpreadCastPosition

        if ProjectileCastInstance or ShotMaxDistance < TravelDistance then
            Traveling = false
            break
        end
    end

    if ProjectileCastInstance then
        if (ProjectileSpreadCastPosition - ProjectileCastPosition).Magnitude > 5 then
            ProjectileSpreadCastPosition = ProjectileSpreadCastPosition - ((ProjectileSpreadRay.Origin - ProjectileSpreadCastPosition).Unit * -(ProjectileCastInstance.Position - ProjectileSpreadCastPosition).Magnitude)
        end

        return ProjectileSpreadCastPosition, {
            ProjectileCastInstance.CFrame:PointToObjectSpace(ProjectileSpreadRay.Origin),
            ProjectileCastInstance.CFrame:VectorToObjectSpace(ProjectileSpreadRay.Direction),
            ProjectileCastInstance.CFrame:PointToObjectSpace(ProjectileSpreadCastPosition)
        }
    end
end]]

--[[local function BulletCast(ProjectileRay, Include)
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = Include
    Params.FilterType = Enum.RaycastFilterType.Include

    local Raycast = workspace:Raycast(ProjectileRay.Origin, ProjectileRay.Direction, Params)

    if Raycast then
        return Raycast.Instance, Raycast.Position, Raycast.Normal, Raycast.Material
    end

    return nil, ProjectileRay.Origin + ProjectileRay.Direction, Vector3.yAxis, Enum.Material.Air
end]]

local function CastLocalBulletInstant(Origin, Direction, SpreadDirection)
    local Velocity = Direction * ProjectileSpeed
    local SpreadVelocity = SpreadDirection * ProjectileSpeed

    local ProjectilePosition = Origin
    local ProjectileSpreadPosition = Origin

    local ProjectileRay = nil
    local ProjectileCastInstance = nil
    local ProjectileCastPosition = Vector3.zero

    local ProjectileSpreadRay = nil

    local Frame = 1 / 60
    local TravelTime = 0
    local TravelDistance = 0
    
    local Exclude = {
        Effects,
        Sounds,
        PlayerClass.Character.Instance
    }
    
    while true do
        TravelTime += Frame

        ProjectileRay = Ray.new(ProjectilePosition, Origin + Velocity * TravelTime + ProjectileGravity * Vector3.yAxis * TravelTime ^ 2 - ProjectilePosition)
        ProjectileSpreadRay = Ray.new(ProjectileSpreadPosition, Origin + SpreadVelocity * TravelTime + ProjectileGravity * Vector3.yAxis * TravelTime ^ 2 - ProjectileSpreadPosition)

        ProjectileCastInstance, ProjectileCastPosition = Raycasting:BulletCast(ProjectileRay, true, Exclude)
        ProjectileSpreadPosition = ProjectileSpreadRay.Origin + ProjectileSpreadRay.Direction

        TravelDistance = TravelDistance + (ProjectilePosition - ProjectileCastPosition).Magnitude
        ProjectilePosition = ProjectileCastPosition

        if ProjectileCastInstance or TravelDistance > ShotMaxDistance then
            break
        end
    end

    if ProjectileCastInstance then
        local Distance = (ProjectileSpreadPosition - ProjectileCastPosition).Magnitude
        local Unit = (ProjectileSpreadPosition - ProjectileSpreadRay.Origin).Unit

        ProjectileSpreadPosition = ProjectileSpreadPosition - Unit * Distance
        Parvus.Utilities.MakeBeam(ProjectileSpreadRay.Origin, ProjectileSpreadPosition, Window.Flags["AR2/BulletTracer/Color"])

        return ProjectileSpreadPosition, {
            ProjectileCastInstance.CFrame:PointToObjectSpace(ProjectileSpreadRay.Origin),
            ProjectileCastInstance.CFrame:VectorToObjectSpace(ProjectileSpreadRay.Direction),
            ProjectileCastInstance.CFrame:PointToObjectSpace(ProjectileSpreadPosition)
        }
    end
end
local function SwingMelee(Enemies)
    local Character = PlayerClass.Character
    if not Character then return end

    local EquippedItem = Character.EquippedItem
    if not EquippedItem then return end

    if EquippedItem.Type ~= "Melee" then return end
    local AttackConfig = EquippedItem.AttackConfig[1]

    local Time = Workspace:GetServerTimeNow()
    Network:Send("Melee Swing", Time, EquippedItem.Id, 1)
    local Stopped = Character.Animator:PlayAnimation(AttackConfig.Animation, 0.05, AttackConfig.PlaybackSpeedMod)
    local Track = Character.Animator:GetTrack(AttackConfig.Animation)

    if Track then
        local Maid = Maids.new()
        Maid:Give(Track:GetMarkerReachedSignal("Swing"):Connect(function(State)
            if State ~= "Begin" then return end
            for Index, Enemy in pairs(Enemies) do
                Network:Send("Melee Hit Register", EquippedItem.Id, Time, Enemy, "Flesh", false)
                if not AttackConfig.CanHitMultipleTargets then break end
            end
            Maid:Destroy()
            Maid = nil
        end))

        Stopped:Wait()
    end
end
local function GetEnemyForMelee(CountPlayers, CountZombies)
    local PlayerCharacter = PlayerClass.Character
    if not PlayerCharacter then return end

    local Distance, Closest = 10, {}

    if CountZombies then
        for Index, Zombie in pairs(Zombies.Mobs:GetChildren()) do
            local PrimaryPart = Zombie.PrimaryPart
            if not PrimaryPart then continue end

            local Magnitude = (PrimaryPart.Position - PlayerCharacter.RootPart.Position).Magnitude
            if Distance > Magnitude then Distance = Magnitude table.insert(Closest, PrimaryPart) end
        end
    end

    if CountPlayers then
        Distance = 10
        for Index, Character in pairs(Characters:GetChildren()) do
            local Player = PlayerService:GetPlayerFromCharacter(Character)

            if Player == LocalPlayer then continue end
            if not InEnemyTeam(true, Player) then continue end

            local PrimaryPart = Character.PrimaryPart
            if not PrimaryPart then continue end

            local Magnitude = (PrimaryPart.Position - PlayerCharacter.RootPart.Position).Magnitude
            if Distance > Magnitude then Distance = Magnitude table.insert(Closest, PrimaryPart) end
        end
    end

    return Closest
end
local function GetCharactersInRadius(Path, Distance)
    local PlayerCharacter = PlayerClass.Character
    if not PlayerCharacter then return end

    local Closest = {}
    for Index, Character in pairs(Path:GetChildren()) do
        if Character == PlayerCharacter.Instance then continue end
        local PrimaryPart = Character.PrimaryPart
        if not PrimaryPart then continue end

        local Magnitude = (PrimaryPart.Position - PlayerCharacter.RootPart.Position).Magnitude
        if Distance >= Magnitude then Distance = Magnitude table.insert(Closest, Character) end
    end

    return Closest
end
local function GetItemsInRadius(Distance)
    local Closest = {}

    for Index, Item in pairs(LootBins:GetChildren()) do
        for Index, Group in pairs(Item:GetChildren()) do
            local Part = Group:FindFirstChild("Part")
            if not Part then continue end

            local Magnitude = (Part.Position - Camera.CFrame.Position).Magnitude
            if Distance >= Magnitude then table.insert(Closest, Group) end
        end
    end

    return Closest
end

local function Length(Table) local Count = 0
    for Index, Value in pairs(Table) do Count += 1 end
    return Count
end
local function CIIC(Data) -- ConcatItemsInContainer
    local Duplicates, Items = {}, {Data.DisplayName}

    for Index, Value in pairs(Data.Occupants) do
        if Duplicates[Value.Name] then
            Duplicates[Value.Name] += 1
        else
            Duplicates[Value.Name] = 1
        end
    end

    for Item, Value in pairs(Duplicates) do
        Items[#Items + 1] = Value == 1 and "[" .. Item .. "]"
        or "[" .. Item .. "] x" .. Value
    end
    return table.concat(Items, "\n")
end

local function HookCharacter(Character)
    for Index, Item in pairs(PlayerClass.Character.Maid.Items) do
        if type(Item) == "table" and rawget(Item, "Action") then
            if table.find(debug.getconstants(Item.Action), "Network sync") then
                NetworkSyncHeartbeat = Item.Action
            end
        end
    end

    local OldEquip; OldEquip = hookfunction(Character.Equip, newcclosure(function(Self, Item, ...)
        if Item.FireConfig and Item.FireConfig.MuzzleVelocity then
            ProjectileSpeed = Item.FireConfig.MuzzleVelocity * Globals.MuzzleVelocityMod
        end

        --[[if Window.Flags["AR2/NoSpread"] then
            if Item.RecoilData then
                print("SpreadBase", Item.RecoilData.SpreadBase)
                if Item.AttachmentStatMods then
                    if Item.AttachmentStatMods.HipSpread then
                        print("AttachmentStatMods.HipSpread", Item.AttachmentStatMods.HipSpread.Multiplier, Item.AttachmentStatMods.HipSpread.Bonus)
                    end
                    if Item.AttachmentStatMods.AimingSpread then
                        print("AttachmentStatMods.AimingSpread", Item.AttachmentStatMods.AimingSpread.Multiplier, Item.AttachmentStatMods.AimingSpread.Bonus)
                    end
                end
                print("SpreadAddFPSZoom", Item.RecoilData.SpreadAddFPSZoom)
                print("SpreadAddFPSHip", Item.RecoilData.SpreadAddFPSHip)
                print("SpreadAddTPSZoom", Item.RecoilData.SpreadAddTPSZoom)
                print("SpreadAddTPSHip", Item.RecoilData.SpreadAddTPSHip)
                --Item.RecoilData.SpreadBase = 0.001
            end
        end]]

        return OldEquip(Self, Item, ...)
    end))
    
    local OldJump; OldJump = hookfunction(Character.Actions.Jump, newcclosure(function(Self, ...)
        local Args = {...}

        if Window.Flags["AR2/NoJumpDebounce"] then
            Self.JumpDebounce = 0
        end

        if Args[1] == "Begin" and Window.Flags["AR2/JumpHeight/Enabled"] then
            local ReturnArgs = {OldJump(Self, ...)}

            if Self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall
            and not Window.Flags["AR2/JumpHeight/NoFallCheck"] then return end

            Self.Humanoid.UseJumpPower = false
            Self.Humanoid.JumpHeight = Window.Flags["AR2/JumpHeight/Height"]
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

            return unpack(ReturnArgs)
        end

        return OldJump(Self, ...)
    end))
    --local OldPlayReloadAnimation = Character.Animator.PlayReloadAnimation
    --print(OldPlayReloadAnimation)
    --[[for i,v in pairs(Character.Animator) do
        print(i,v)
    end]]
    --[[Character.Animator.PlayReloadAnimation = function(Self, ...)
        if Window.Flags["AR2/InstantReload"] then
            local ReturnArgs = {OldPlayReloadAnimation(Self, ...)}
            local Args = {...}

            for Index = 0, Args[3].LoopCount do
                Self.ReloadEventCallback("Commit", "Load")
            end
            Character.Animator:StopReloadAnimation(false)

            return unpack(ReturnArgs)
        end

        return OldPlayReloadAnimation(Self, ...)
    end]]
    --[[for Index, Spring in pairs({"WobblePos", "WobbleRot", "RotationVelocity", "MoveVelocity"}) do
        Spring = Character.Animator.Springs[Spring]

        local OldRetune = Spring.Retune
        Spring.Retune = function(Self, Force, ...)
            if Window.Flags["AR2/NoWobble"] then Force = 0 end
            return OldRetune(Self, Force, ...)
        end
    end]]
    local OldToolAction; OldToolAction = hookfunction(Character.Actions.ToolAction, newcclosure(function(Self, ...)
        if Window.Flags["AR2/UnlockFiremodes"] then
            if not Self.EquippedItem then return OldToolAction(Self, ...) end
            local FireModes = Self.EquippedItem.FireModes
            if not FireModes then return OldToolAction(Self, ...) end

            for Index, Mode in ipairs({"Semiautomatic", "Automatic", "Burst"}) do
                if not table.find(FireModes, Mode) then
                    setreadonly(FireModes, false)
                    table.insert(FireModes, Mode)
                    setreadonly(FireModes, true)
                end
            end
        end

        return OldToolAction(Self, ...)
    end))
end

local OldIndex, OldNamecall = nil, nil
OldIndex = hookmetamethod(game, "__index", function(Self, Index)
    if Window.Flags["AR2/HeadExpander"] and tostring(Self) == "Head" and Index == "Size" then
        return Vector3.one * 1.15
    end

    return OldIndex(Self, Index)
end)

OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()

    --[[
    if Method == "FireServer" then
        local Args = {...}
        if type(Args[1]) == "table" then
            print("framework check")
            return
        end
    end
    ]]

    if Method == "GetChildren"
    and (Self == ReplicatedFirst
    or Self == ReplicatedStorage) then
        print("crash bypass")
        wait(383961600) -- 4444 days
    end

    return OldNamecall(Self, ...)
end)

local OldSend; OldSend = hookfunction(Network.Send, newcclosure(function(Self, Name, ...)
    if table.find(SanityBans, Name) then print("bypassed", Name) return end
    if Name == "Character Jumped" and Window.Flags["AR2/SSCS"] then return end

    if Name == "Vehicle Bumper Impact" then
        if Window.Flags["AR2/Vehicle/Impact"] then
            return
        end
    end

    if Name == "Inventory Container Group Disconnect" then
        if Window.Flags["AR2/ContainerPersistence"] then
            return
        end
    end

    --[[if Name == "Bullet Fired" then
        if Window.Flags["AR2/NoSpread"] then
            local Args = {...}
            print(Args[5] == ProjectileDirection)
            Args[5] = ProjectileSpread --* Vector3.new(-1, -1, 1)
            return OldSend(Self, Name, unpack(Args))
        end
    end]]

    --[[if Name == "Bullet Impact" then
        print("bullet impact")
        if Window.Flags["AR2/NoSpread"] then
            local Args = {...}
            local Position, Table = CastLocalBulletInstant(ProjectileOrigin, ProjectileDirection2, ProjectileSpread)
            if not Position then print(Args[1], "miss") return OldSend(Self, Name, ...) end

            --Args[5] = Target
            print(Args[1], "hit")
            Args[6] = Position
            Args[7][1] = Table[1]
            Args[7][2] = Table[2]
            Args[7][3] = Table[3]

            return OldSend(Self, Name, unpack(Args))
        end
    end]]

    return OldSend(Self, Name, ...)
end))

local OldFetch; OldFetch = hookfunction(Network.Fetch, newcclosure(function(Self, Name, ...)
    if table.find(SanityBans, Name) then print("bypassed", Name) return end

    if Name == "Character State Report" then
        local RandomData = GetStates()
        local Args = {...}

        for Index = 1, #Args do
        --for Index, Value in pairs(Args) do
            --print(Index, RandomData[Index][1], Value)
            if Window.Flags["AR2/SSCS"] then
                if RandomData[Index] == "MoveState" then
                    Args[Index] = Window.Flags["AR2/MoveState"][1]
                end
            end
            if Window.Flags["AR2/NoSpread"] then
                if RandomData[Index] == "Zooming" then
                    Args[Index] = true
                elseif RandomData[Index] == "FirstPerson" then
                    Args[Index] = true
                end
            end
        end

        return OldFetch(Self, Name, unpack(Args))
    end

    return OldFetch(Self, Name, ...)
end))

setupvalue(Bullets.Fire, 1, function(Character, CCamera, Weapon, ...)
    if Window.Flags["AR2/NoSpread"] then
        local OldMoveState = Character.MoveState
        local OldZooming = Character.Zooming
        local OldFirstPerson = CCamera.FirstPerson

        Character.MoveState = "Walking"
        Character.Zooming = true
        CCamera.FirstPerson = true

        local ReturnArgs = {GetSpreadAngle(Character, CCamera, Weapon, ...)}

        Character.MoveState = OldMoveState
        Character.Zooming = OldZooming
        CCamera.FirstPerson = OldFirstPerson

        return unpack(ReturnArgs)
    end

    return GetSpreadAngle(Character, CCamera, Weapon, ...)
end)
setupvalue(CastLocalBullet, 6, function(...)
    if Window.Flags["AR2/BulletTracer/Enabled"] then
        local Args = {...}
        if not Args[7] then return ImpactEffects(...) end
        Parvus.Utilities.MakeBeam(Args[5], Args[3], Window.Flags["AR2/BulletTracer/Color"])
    end

    return ImpactEffects(...)
end)
--[[setupvalue(Bullets.Fire, 3, function(...)
    if Window.Flags["AR2/NoSpread"] then
        local Args = {...}
        
    end

    return GetSpreadVector(...)
end)]]
--[[setupvalue(Bullets.Fire, 4, function(...)
    local Args = {...}

    --ProjectileOrigin = Args[6]
    --ProjectileSpread = Args[7]

    if math.max(Args[5].FireConfig.PelletCount, 1) == 1 then
        ProjectileSpread = Args[7]
        print("projectile spread")
    end

    if Window.Flags["AR2/NoSpread"] then
        Args[7] = Args[7] + (ProjectileDirection - Args[7])
        return CastLocalBullet(unpack(Args))
    end

    return CastLocalBullet(...)
end)]]
setupvalue(Bullets.Fire, 6, function(...)
    if Window.Flags["AR2/Recoil/Enabled"] then
        local ReturnArgs = {GetFireImpulse(...)}

        for Index = 1, #ReturnArgs do
            ReturnArgs[Index] *= (Window.Flags["AR2/Recoil/Value"] / 100)
        end

        return unpack(ReturnArgs)
    end

    return GetFireImpulse(...)
end)
setupvalue(VehicleController.Step, 2, function(Self, Throttle, ...)
    if Window.Flags["AR2/Vehicle/Enabled"] then
        --[[if Window.Flags["AR2/Vehicle/Fly"] then
            local MoveDirection = Parvus.Utilities.MovementToDirection()

            Self.BasePart.AssemblyLinearVelocity = Vector3.zero
            Self.BasePart.CFrame += MoveDirection * Window.Flags["AR2/Fly/Speed"]

            return
        end]]
        if not PlayerClass.Character then return end
        Throttle = Window.Flags["AR2/Vehicle/Instant"]
        and PlayerClass.Character.MoveVector.Z or -Throttle

        for Index, Wheel in pairs(Self.Wheels:GetChildren()) do
            local DriveMotor = Wheel:FindFirstChild("Drive Motor")
            local PrimaryPart = Wheel.PrimaryPart

            if not DriveMotor or not PrimaryPart then continue end
            PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(10, 2, 0)
            DriveMotor.AngularVelocity = Throttle * (Window.Flags["AR2/Vehicle/MaxSpeed"] / (PrimaryPart.Size.Y / 2))
        end

        return
    end

    return SetWheelSpeeds(Self, Throttle, ...)
end)
setupvalue(VehicleController.Step, 3, function(Self, Steer, Throttle, ...)
    if Window.Flags["AR2/Vehicle/Enabled"] then
        if not PlayerClass.Character then return end
        Steer = Window.Flags["AR2/Vehicle/Instant"]
        and -PlayerClass.Character.MoveVector.X or -Steer

        for Index, Wheel in pairs(Self.Wheels:GetChildren()) do
            local WheelPhysics = Self.Config.Physics.Wheels[Wheel.Name]
            if not WheelPhysics or not WheelPhysics.DoesSteer then continue end

            local DriveMotor = Wheel:FindFirstChild("Drive Motor")
            if not DriveMotor then continue end

            local Attachment = Wheel.PrimaryPart:FindFirstChild("Attachment")
            local Angle = math.rad(WheelPhysics.SteerAngle * Steer)

            if Attachment then
                Angle += math.rad(Attachment.Orientation.Y)
            end

            DriveMotor.Attachment0.CFrame = CFrame.Angles(0, Angle, 0)
        end

        return
    end

    return SetSteerWheels(Self, Steer, Throttle, ...)
end)
--[[setupvalue(VehicleController.Step, 4, function(Self, Throttle, ...)
    if Window.Flags["AR2/Vehicle/Enabled"] then
        if not PlayerClass.Character then return end
        --Throttle = Window.Flags["AR2/Vehicle/Instant"]
        --and PlayerClass.Character.MoveVector.Z or -Throttle

        local Mass = 0
        for Index, Descendant in pairs(Self.Instance:GetDescendants()) do
            if not Descendant:IsA("BasePart") then continue end
            Mass += Descendant:GetMass()
        end

        --local Velocity = Self.BasePart.AssemblyLinearVelocity
        --Throttle = math.abs(Throttle) * Window.Flags["AR2/Vehicle/MaxSpeed"]
        Self.BasePart.AssemblyLinearVelocity += Vector3.new(0, -1, 0) * Mass / 200

        return
    end

    return ApplyDragForce(Self, Throttle, ...)
end)]]
setupvalue(Firearm, 7, function(...)
    if Window.Flags["AR2/InstantReload"] then
        local Args = {...}

        for Index = 0, Args[3].LoopCount do
            Args[4]("Commit", "Load")
        end

        Args[4]("Commit", "End")
        return true
    end

    return AnimatedReload(...)
end)
setupvalue(InteractHeartbeat, 11, function(...)
    if Window.Flags["AR2/InstantSearch"] then
        local ReturnArgs = {FindItemData(...)}
        if ReturnArgs[4] then ReturnArgs[4] = 0 end

        return unpack(ReturnArgs)
    end

    return FindItemData(...)
end)

local OldFire; OldFire = hookfunction(Bullets.Fire, newcclosure(function(Self, ...)
    if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        local Args = {...}
        local BodyPart = SilentAim[3]
        local BodyPartPosition = BodyPart.Position
        local Direction = BodyPartPosition - Args[4]

        if Window.Flags["AR2/MagicBullet/Enabled"] then
            local Distance = math.clamp(Direction.Magnitude, 0, Window.Flags["AR2/MagicBullet/Depth"])
            Args[4] = Args[4] + (Direction.Unit * Distance)
        end

        BodyPartPosition = Window.Flags["AR2/InstantHit"] and BodyPartPosition
        or SolveTrajectory(BodyPartPosition, BodyPart.AssemblyLinearVelocity,
        Direction.Magnitude / ProjectileSpeed, ProjectileGravity)

        --[[local BodyPartPosition2 = Window.Flags["AR2/InstantHit"] and BodyPartPosition
        or SolveTrajectory2(BodyPartPosition, BodyPart.AssemblyLinearVelocity,
        Direction.Magnitude / ProjectileSpeed, ProjectileGravity)]]

        --local BodyPartPosition = Window.Flags["AR2/InstantHit"] and SilentAim[3].Position
        --or Parvus.Utilities.Physics.SolveTrajectory(Args[4], SilentAim[3].Position,
        --SilentAim[3].AssemblyLinearVelocity, ProjectileSpeed, ProjectileGravity, 1)

        ProjectileDirection = (BodyPartPosition - Args[4]).Unit
        --ProjectileDirection2 = (BodyPartPosition2 - Args[4]).Unit
        Args[5] = ProjectileDirection --(BodyPartPosition - Args[4]).Unit

        return OldFire(Self, unpack(Args))
    end

    local Args = {...}
    ProjectileDirection = Args[5]
    --ProjectileDirection2 = Args[5]

    return OldFire(Self, ...)
end))

-- Old Recoil Control
--[[local OldPost = Animators.Post
Animators.Post = function(Self, Name, ...) local Args = {...}
    if Window.Flags["AR2/Recoil/Enabled"] and Name == "FireImpulse" then
        Args[1][1] = Args[1][1] * (Window.Flags["AR2/Recoil/ShiftForce"] / 100)
        Args[1][2] = Args[1][2] * (Window.Flags["AR2/Recoil/RollBias"] / 100)
        Args[1][3] = Args[1][3] * (Window.Flags["AR2/Recoil/RaiseForce"] / 100)
        Args[1][4] = Args[1][4] * (Window.Flags["AR2/Recoil/SlideForce"] / 100)
        Args[1][5] = Args[1][5] * (Window.Flags["AR2/Recoil/KickUpForce"] / 100)
    end return OldPost(Self, Name, unpack(Args))
end]]
local OldFlinch; OldFlinch = hookfunction(CharacterCamera.Flinch, newcclosure(function(Self, ...)
    if Window.Flags["AR2/NoFlinch"] then return end
    return OldFlinch(Self, ...)
end))
local OldCharacterGroundCast; OldCharacterGroundCast = hookfunction(Raycasting.CharacterGroundCast, newcclosure(function(Self, Position, LengthDown, ...)
    if PlayerClass.Character and Position == PlayerClass.Character.RootPart.CFrame then
        if Window.Flags["AR2/UseInAir"] then
            return GroundPart, CFrame.new(), Vector3.new(0, 1, 0)
            --LengthDown = 1022
        end
    end
    return OldCharacterGroundCast(Self, Position, LengthDown, ...)
end))
--[[local OldSwimCheckCast = Raycasting.SwimCheckCast
Raycasting.SwimCheckCast = function(Self, ...)
    if Window.Flags["AR2/UseInWater"] then return nil end
    return OldSwimCheckCast(Self, ...)
end]]
local OldPlayAnimation; OldPlayAnimation = hookfunction(Animators.PlayAnimation, newcclosure(function(Self, Path, ...)
    if Path == "Actions.Fall Impact" and Window.Flags["AR2/NoFallImpact"] then return end
    return OldPlayAnimation(Self, Path, ...)
end))
-- Old Vehicle Mod
--[[local OldVC = VehicleController.new
VehicleController.new = function(...)
    local ReturnArgs = {OldVC(...)}

    local OldStep = ReturnArgs[1].Step
    ReturnArgs[1].Step = function(Self, ...)
        if Window.Flags["AR2/Vehicle/Enabled"] then
            local MoveVector = PlayerClass.Character.MoveVector
            Self.ThrottleSolver.Position = -MoveVector.Z
            * Window.Flags["AR2/Vehicle/Speed"] / 100
            Self.SteerSolver.Position = MoveVector.X
            * Window.Flags["AR2/Vehicle/Steer"] / 100

            --Self.ThrottleSolver.Speed = Window.Flags["AR2/Vehicle/Speed"]
            --Self.ThrottleSolver.Damping = Window.Flags["AR2/Vehicle/Damping"]
            --Self.ThrottleSolver.Velocity = Window.Flags["AR2/Vehicle/Velocity"]
        end

        return OldStep(Self, ...)
    end

    return unpack(ReturnArgs)
end]]

local OldCD; OldCD = hookfunction(Events["Character Dead"], newcclosure(function(...)
    if Window.Flags["AR2/FastRespawn"] then
        task.spawn(function() SetIdentity(2)
            PlayerClass:UnloadCharacter()
            Interface:Hide("Reticle")
            task.wait(0.5)
            PlayerClass:LoadCharacter()
        end)
    end

    return OldCD(...)
end))
local OldLSU; OldLSU = hookfunction(Events["Lighting State Update"], newcclosure(function(Data, ...)
    LightingState = Data
    OldBaseTime = LightingState.BaseTime
    --print("Lighting State Updated")
    return OldLSU(Data, ...)
end))
local OldSquadUpdate; OldSquadUpdate = hookfunction(Events["Squad Update"], newcclosure(function(Data, ...)
    SquadData = Data
    --print(repr(SquadData))
    --print("Squad Updated")
    return OldSquadUpdate(Data, ...)
end))
local OldICA; OldICA = hookfunction(Events["Inventory Container Added"], newcclosure(function(Id, Data, ...)
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return OldICA(Id, Data, ...) end

    --print(Data.Type)

    if Data.Type ~= "Corpse" or Data.Type ~= "Vehicle" then
        if Data.WorldPosition and Length(Data.Occupants) > 0 then
            AddObject:Fire(Data.Id, CIIC(Data), Data.WorldPosition,
            "AR2/ESP/Items", "AR2/ESP/Items/Containers", Window.Flags)
        end
    end

    return OldICA(Id, Data, ...)
end))
local OldCC; OldCC = hookfunction(Events["Container Changed"], newcclosure(function(Data, ...)
    if not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return OldCC(Data, ...) end

    RemoveObject:Fire(Data.Id)

    if Data.Type ~= "Corpse" or Data.Type ~= "Vehicle" then
        if Data.WorldPosition and Length(Data.Occupants) > 0 then
            AddObject:Fire(Data.Id, CIIC(Data), Data.WorldPosition,
            "AR2/ESP/Items", "AR2/ESP/Items/Containers", Window.Flags)
        end
    end

    return OldCC(Data, ...)
end))

if PlayerClass.Character then
    HookCharacter(PlayerClass.Character)
end
PlayerClass.CharacterAdded:Connect(function(Character)
    HookCharacter(Character)
end)

Interface:GetVisibilityChangedSignal("Map"):Connect(function(Visible)
    if Visible and Window.Flags["AR2/MapESP"] then
        Interface:Get("Map"):EnableGodview()
    else
        Interface:Get("Map"):DisableGodview()
    end
end)

Parvus.Utilities.NewThreadLoop(0, function()
    if not (Aimbot or Window.Flags["Aimbot/AlwaysEnabled"]) then return end

    AimAt(GetClosest(
        Window.Flags["Aimbot/Enabled"],
        Window.Flags["Aimbot/TeamCheck"],
        Window.Flags["Aimbot/VisibilityCheck"],
        Window.Flags["Aimbot/DistanceCheck"],
        Window.Flags["Aimbot/DistanceLimit"],
        Window.Flags["Aimbot/FOV/Radius"],
        Window.Flags["Aimbot/Priority"][1],
        Window.Flags["Aimbot/BodyParts"],
        Window.Flags["Aimbot/Prediction"]
    ), Window.Flags["Aimbot/Sensitivity"] / 100)
end)
Parvus.Utilities.NewThreadLoop(0, function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"],
        Window.Flags["SilentAim/TeamCheck"],
        Window.Flags["SilentAim/VisibilityCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/DistanceLimit"],
        Window.Flags["SilentAim/FOV/Radius"],
        Window.Flags["SilentAim/Priority"][1],
        Window.Flags["SilentAim/BodyParts"]
    )
end)
Parvus.Utilities.NewThreadLoop(0, function()
    if not (Trigger or Window.Flags["Trigger/AlwaysEnabled"]) then return end
    if not isrbxactive() then return end

    local TriggerClosest = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/TeamCheck"],
        Window.Flags["Trigger/VisibilityCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/DistanceLimit"],
        Window.Flags["Trigger/FOV/Radius"],
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
                Window.Flags["Trigger/FOV/Radius"],
                Window.Flags["Trigger/Priority"][1],
                Window.Flags["Trigger/BodyParts"],
                Window.Flags["Trigger/Prediction"]
            ) if not TriggerClosest or not Trigger then break end
        end
    end mouse1release()
end)

Parvus.Utilities.NewThreadLoop(0, function(Delta)
    if not Window.Flags["AR2/WalkSpeed/Enabled"] then return end

    if not PlayerClass.Character then return end
    local RootPart = PlayerClass.Character.RootPart
    local MoveDirection = Parvus.Utilities.MovementToDirection() * XZVector

    RootPart.CFrame += MoveDirection * Delta * Window.Flags["AR2/WalkSpeed/Speed"] * 100
end)
Parvus.Utilities.NewThreadLoop(0, function(Delta)
    if not Window.Flags["AR2/Fly/Enabled"] then return end

    if not PlayerClass.Character then return end
    local RootPart = PlayerClass.Character.RootPart
    local MoveDirection = Parvus.Utilities.MovementToDirection()

    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.CFrame += MoveDirection * (Window.Flags["AR2/Fly/Speed"] * (Delta * 60))
end)
Parvus.Utilities.NewThreadLoop(0.1, function()
    if not Window.Flags["AR2/MeleeAura"]
    and not Window.Flags["AR2/AntiZombie/MeleeAura"] then return end

    local Enemies = GetEnemyForMelee(
        Window.Flags["AR2/MeleeAura"],
        Window.Flags["AR2/AntiZombie/MeleeAura"]
    )

    if not Enemies then return end
    if #Enemies == 0 then return end
    SwingMelee(Enemies)
end)
Parvus.Utilities.NewThreadLoop(1, function()
    if not Window.Flags["AR2/HeadExpander"] then return end
    for Index, Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if not Player.Character then continue end
        local Character = Player.Character
        local Head = Character.Head

        Head.Size = Mannequin.Head.Size * Window.Flags["AR2/HeadExpander/Value"]
        Head.Transparency = Window.Flags["AR2/HeadExpander/Transparency"]
        Head.CanCollide = true
    end
end)
Parvus.Utilities.NewThreadLoop(0.5, function()
    if not Window.Flags["AR2/Lighting/Enabled"] then return end
    local Time = LightingState.StartTime + Workspace:GetServerTimeNow()
    LightingState.BaseTime = Time + ((Window.Flags["AR2/Lighting/Time"] * (86400 / LightingState.CycleLength)) % 1440)
    --print(LightingState.StartTime, LightingState.CycleLength, LightingState.BaseTime)
end)
Parvus.Utilities.NewThreadLoop(1, function()
    if not Window.Flags["AR2/ESP/Items/Enabled"]
    and not Window.Flags["AR2/ESP/Items/Containers/Enabled"] then return end

    local Items = GetItemsInRadius(100)

    if not PlayerClass.Character
    or Interface:IsVisible("GameMenu")
    or #Items == 0 then return end

    for Index, Item in pairs(Items) do
        if Interface:IsVisible("GameMenu")
        or table.find(ItemMemory, Item) then continue end

        task.spawn(function()
            if Network:Fetch("Inventory Container Group Connect", Item) then
                Network:Send("Inventory Container Group Disconnect")
                table.insert(ItemMemory, Item)
                local Pos = #ItemMemory
                task.wait(30)
                table.remove(ItemMemory, Pos)
            end
        end)
    end
end)

for Index, Item in pairs(Loot:GetDescendants()) do
    if Item:IsA("CFrameValue") then
        local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name, true)
        if not ItemData then continue end --print(ItemData.Parent.Name)

        Parvus.Utilities.Drawing:AddObject(Item, Item.Name, Item.Value.Position,
            "AR2/ESP/Items", "AR2/ESP/Items/" .. ItemData.Parent.Name, Window.Flags
        )
    end
end
for Index, Event in pairs(Randoms:GetChildren()) do
    for Index, Data in pairs(RandomEvents) do
        if Event.Name ~= Data[1] then continue end --print(Event.Name)
        Parvus.Utilities.Drawing:AddObject(Event, Event.Name, Event.Value.Position,
            "AR2/ESP/RandomEvents", "AR2/ESP/RandomEvents/" .. Event.Name, Window.Flags
        )
    end
end
for Index, Corpse in pairs(Corpses:GetChildren()) do
    if Corpse.Name == "Zombie" then continue end
    if not Corpse.PrimaryPart then continue end

    Parvus.Utilities.Drawing:AddObject(
        Corpse, Corpse.Name, Corpse.PrimaryPart,
        "AR2/ESP/Corpses", "AR2/ESP/Corpses", Window.Flags
    )
end
for Index, Zombie in pairs(Zombies.Mobs:GetChildren()) do
    if not Zombie.PrimaryPart then continue end
    local Config = require(Zombies.Configs[Zombie.Name])

    if not Config.Inherits then continue end
    for Index, Inherit in pairs(Config.Inherits) do
        for Index, Data in pairs(ZombieInherits) do
            if Inherit ~= Data[1] then continue end --print(Inherit.Name)
            local InheritName = Inherit:gsub("Presets.", ""):gsub(" ", "")

            Parvus.Utilities.Drawing:AddObject(
                Zombie, Zombie.Name, Zombie.PrimaryPart, "AR2/ESP/Zombies",
                "AR2/ESP/Zombies/"..InheritName, Window.Flags
            )
        end
    end
end
for Index, Vehicle in pairs(Vehicles:GetChildren()) do
    if not Vehicle.PrimaryPart then continue end

    Parvus.Utilities.Drawing:AddObject(
        Vehicle, Vehicle.Name, Vehicle.PrimaryPart,
        "AR2/ESP/Vehicles", "AR2/ESP/Vehicles", Window.Flags
    )
end

Loot.DescendantAdded:Connect(function(Item)
    if Item:IsA("CFrameValue") then
        local ItemData = ReplicatedStorage.ItemData:FindFirstChild(Item.Name, true)
        if not ItemData then return end --print(ItemData.Parent.Name)

        Parvus.Utilities.Drawing:AddObject(Item, Item.Name, Item.Value.Position,
            "AR2/ESP/Items", "AR2/ESP/Items/" .. ItemData.Parent.Name, Window.Flags
        )
    end
end)
Randoms.ChildAdded:Connect(function(Event)
    for Index, Data in pairs(RandomEvents) do
        if Event.Name ~= Data[1] then continue end --print(Event.Name)
        Parvus.Utilities.Drawing:AddObject(Event, Event.Name, Event.Value.Position,
            "AR2/ESP/RandomEvents", "AR2/ESP/RandomEvents/" .. Event.Name, Window.Flags
        )

        if Window.Flags["AR2/ESP/RandomEvents/Enabled"]
        and Window.Flags["AR2/ESP/RandomEvents/" .. Event.Name] then
            local Distance = (Event.Value.Position - Camera.CFrame.Position).Magnitude
            local Title = string.format("%s spawned (~%i studs away)", Event.Name, Distance)
            Parvus.Utilities.UI:Toast({Title = Title, Duration = 20})
        end
    end
end)
Corpses.ChildAdded:Connect(function(Corpse)
    if Corpse.Name == "Zombie" then return end
    repeat task.wait() until Corpse.PrimaryPart
    Parvus.Utilities.Drawing:AddObject(
        Corpse, Corpse.Name, Corpse.PrimaryPart,
        "AR2/ESP/Corpses", "AR2/ESP/Corpses", Window.Flags
    )
end)
Zombies.Mobs.ChildAdded:Connect(function(Zombie)
    repeat task.wait() until Zombie.PrimaryPart
    local Config = require(Zombies.Configs[Zombie.Name])

    if not Config.Inherits then return end
    for Index, Inherit in pairs(Config.Inherits) do
        for Index, Data in pairs(ZombieInherits) do
            if Inherit ~= Data[1] then continue end --print(Inherit.Name)
            local InheritName = Inherit:gsub("Presets.", ""):gsub(" ", "")

            Parvus.Utilities.Drawing:AddObject(
                Zombie, Zombie.Name, Zombie.PrimaryPart, "AR2/ESP/Zombies",
                "AR2/ESP/Zombies/"..InheritName, Window.Flags
            )
        end
    end
end)
Vehicles.ChildAdded:Connect(function(Vehicle)
    repeat task.wait() until Vehicle.PrimaryPart
    --print(Vehicle.Name)

    Parvus.Utilities.Drawing:AddObject(
        Vehicle, Vehicle.Name, Vehicle.PrimaryPart,
        "AR2/ESP/Vehicles", "AR2/ESP/Vehicles", Window.Flags
    )
end)

Loot.DescendantRemoving:Connect(function(Item)
    Parvus.Utilities.Drawing:RemoveObject(Item)
end)
Randoms.ChildRemoved:Connect(function(Event)
    Parvus.Utilities.Drawing:RemoveObject(Event)
end)
Corpses.ChildRemoved:Connect(function(Corpse)
    Parvus.Utilities.Drawing:RemoveObject(Corpse)
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

for Index, Player in pairs(PlayerService:GetPlayers()) do
    if Player == LocalPlayer then continue end
    Parvus.Utilities.Drawing:AddESP(Player, "Player", "ESP/Player", Window.Flags)
    task.spawn(function() CheckForAdmin(Player) end)
end
PlayerService.PlayerAdded:Connect(function(Player)
    Parvus.Utilities.Drawing:AddESP(Player, "Player", "ESP/Player", Window.Flags)
    task.spawn(function() CheckForAdmin(Player) end)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    Parvus.Utilities.Drawing:RemoveESP(Player)
end)
