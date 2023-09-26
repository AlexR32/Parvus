local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

if game.PlaceId == 2916899287 then
    Parvus.Utilities.UI:Notification({Title = "Parvus Hub",Description = "Please join the game"})
    return
end

--repeat task.wait() until Workspace:FindFirstChild("Bots")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Events = ReplicatedStorage:WaitForChild("Events")
local RemoteEvent = Events:WaitForChild("RemoteEvent")

-- Temporary method
--local OldIdentity = getthreadidentity()
--setthreadidentity(2)
local Server = require(Packages:WaitForChild("server"))
ServerSettings = Server._cache
--setthreadidentity(OldIdentity)

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

local SilentAim,Aimbot,Trigger = nil,false,false
local Actors,RoundInterface,Network,NPCFolder,RaycastFolder = nil,nil,nil,Workspace:WaitForChild("Bots"),Workspace:WaitForChild("Raycast")
local ProjectileSpeed,ProjectileGravity,GravityCorrection = 1000,Vector3.new(0,Workspace.Gravity,0),2
local GroundTip,AircraftTip,NoClipEvent,NoClipObjects,WhiteColor = nil,nil,nil,{},Color3.new(1,1,1)

local Teleports = {
    {"Forward Operating Base", Vector3.new(-3993,64,757)     },
    {"Communications Tower",   Vector3.new(-1800,785,-4140)  },
    {"Department Of Utilities",Vector3.new(-54,63,-3645)     },
    {"Vietnama Village",       Vector3.new(739,118,-92)      },
    {"Fort Ronograd",          Vector3.new(6359,190,-1468)   },
    {"Ronograd City",          Vector3.new(3478,176,1073)    },
    {"Sochraina City",         Vector3.new(93,26,3630)       },
    {"El Chara",               Vector3.new(-4768,108,5218)   },
    {"Naval Docks",            Vector3.new(6174,130,2099)    },
    {"Quarry",                 Vector3.new(331,86,2598)      },
    {"Nuclear Silo",           Vector3.new(1024,44,-5148)    }
}

local KnownBodyParts = {
    {"Head",true},{"HumanoidRootPart",true},
    {"UpperTorso",false},{"LowerTorso",false},

    {"RightUpperArm",false},{"RightLowerArm",false},{"RightHand",false},
    {"LeftUpperArm",false},{"LeftLowerArm",false},{"LeftHand",false},

    {"RightUpperLeg",false},{"RightLowerLeg",false},{"RightFoot",false},
    {"LeftUpperLeg",false},{"LeftLowerLeg",false},{"LeftFoot",false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212),Parvus.Game.Name),
    Position = UDim2.new(0.5,-248 * 3,0.5,-248)
}) do

    local CombatTab = Window:Tab({Name = "Combat"}) do
        --[[local AimbotSection = CombatTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            :Keybind({Flag = "Aimbot/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Thirdperson Mode",Flag = "Aimbot/Thirdperson",Value = false})
            AimbotSection:Toggle({Name = "Always Enabled",Flag = "Aimbot/AlwaysEnabled",Value = false})
            AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = false})

            AimbotSection:Toggle({Name = "Team Check",Flag = "Aimbot/TeamCheck",Value = false})
            AimbotSection:Toggle({Name = "Distance Check",Flag = "Aimbot/DistanceCheck",Value = false})
            AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/VisibilityCheck",Value = false})
            AimbotSection:Slider({Name = "Sensitivity",Flag = "Aimbot/Sensitivity",Min = 0,Max = 100,Value = 20,Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View",Flag = "Aimbot/FieldOfView",Min = 0,Max = 500,Value = 100,Unit = "r"})
            AimbotSection:Slider({Name = "Distance Limit",Flag = "Aimbot/DistanceLimit",Min = 25,Max = 1000,Value = 250,Unit = "studs"})

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
        end]]
        local SilentAimSection = CombatTab:Section({Name = "Silent Aim",Side = "Left"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false}):Keybind({Mouse = true,Flag = "SilentAim/Keybind"})

            SilentAimSection:Toggle({Name = "Prediction",Flag = "SilentAim/Prediction",Value = false})

            SilentAimSection:Toggle({Name = "Team Check",Flag = "SilentAim/TeamCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/VisibilityCheck",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100,Unit = "r"})
            SilentAimSection:Slider({Name = "Distance Limit",Flag = "SilentAim/DistanceLimit",Min = 25,Max = 1000,Value = 250,Unit = "studs"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            SilentAimSection:Dropdown({Name = "Priority",Flag = "SilentAim/Priority",List = PriorityList})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = BodyPartsList})
        end
        local MiscSection = CombatTab:Section({Name = "Other",Side = "Right"}) do
            MiscSection:Toggle({Name = "NPC Mode",Flag = "BRM5/NPCMode",Value = true})
        end
        local SAFOVSection = CombatTab:Section({Name = "Silent Aim FOV Circle",Side = "Right"}) do
            SAFOVSection:Toggle({Name = "Enabled",Flag = "SilentAim/FOVCircle/Enabled",Value = true})
            SAFOVSection:Toggle({Name = "Filled",Flag = "SilentAim/FOVCircle/Filled",Value = false})
            SAFOVSection:Colorpicker({Name = "Color",Flag = "SilentAim/FOVCircle/Color",
            Value = {0.6666666865348816,0.6666666269302368,1,0.25,false}})
            SAFOVSection:Slider({Name = "NumSides",Flag = "SilentAim/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            SAFOVSection:Slider({Name = "Thickness",Flag = "SilentAim/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        --[[local TriggerSection = CombatTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Enabled",Value = false})
            :Keybind({Flag = "Trigger/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})

            TriggerSection:Toggle({Name = "Always Enabled",Flag = "Trigger/AlwaysEnabled",Value = false})
            TriggerSection:Toggle({Name = "Hold Mouse Button",Flag = "Trigger/HoldMouseButton",Value = false})
            TriggerSection:Toggle({Name = "Prediction",Flag = "Trigger/Prediction",Value = false})

            TriggerSection:Toggle({Name = "Team Check",Flag = "Trigger/TeamCheck",Value = false})
            TriggerSection:Toggle({Name = "Distance Check",Flag = "Trigger/DistanceCheck",Value = false})
            TriggerSection:Toggle({Name = "Visibility Check",Flag = "Trigger/VisibilityCheck",Value = false})

            TriggerSection:Slider({Name = "Click Delay",Flag = "Trigger/Delay",Min = 0,Max = 1,Precise = 2,Value = 0.15,Unit = "sec"})
            TriggerSection:Slider({Name = "Distance Limit",Flag = "Trigger/DistanceLimit",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            TriggerSection:Slider({Name = "Field Of View",Flag = "Trigger/FieldOfView",Min = 0,Max = 500,Value = 25,Unit = "r"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            TriggerSection:Dropdown({Name = "Priority",Flag = "Trigger/Priority",List = PriorityList})
            TriggerSection:Dropdown({Name = "Body Parts",Flag = "Trigger/BodyParts",List = BodyPartsList})
        end
        local TFOVSection = CombatTab:Section({Name = "Trigger FOV Circle",Side = "Right"}) do
            TFOVSection:Toggle({Name = "Enabled",Flag = "Trigger/FOVCircle/Enabled",Value = true})
            TFOVSection:Toggle({Name = "Filled",Flag = "Trigger/FOVCircle/Filled",Value = false})
            TFOVSection:Colorpicker({Name = "Color",Flag = "Trigger/FOVCircle/Color",Value = {0.0833333358168602,0.6666666269302368,1,0.25,false}})
            TFOVSection:Slider({Name = "NumSides",Flag = "Trigger/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            TFOVSection:Slider({Name = "Thickness",Flag = "Trigger/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end]]
    end
    local VisualsSection = Parvus.Utilities:ESPSection(Window,"Visuals","ESP/Player",true,true,true,true,true,false) do
        VisualsSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
        VisualsSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
        VisualsSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = true})
        VisualsSection:Toggle({Name = "Use Team Color",Flag = "ESP/Player/TeamColor",Value = false})
        VisualsSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
        VisualsSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 5000,Value = 250,Unit = "studs"})
        --[[GlobalSection:Button({Name = "Load all Players",Callback = function()
            for Index,Player in pairs(PlayerService:GetPlayers()) do
                if Player == LocalPlayer then continue end
                Parvus.Utilities.Drawing:AddESP(Player,"Player","ESP/Player",Window.Flags)
            end
        end}):ToolTip("VERY RISKY\nYOU MIGHT CRASH")]]
    end
        
    local NPCVisualsSection = Parvus.Utilities:ESPSection(Window,"NPC Visuals","ESP/NPC",true,true,true,true,true,false) do
        NPCVisualsSection:Colorpicker({Name = "Civilian Color",Flag = "ESP/NPC/Ally",Value = {0.33333334326744,0.75,1,0,false}})
        NPCVisualsSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/NPC/Enemy",Value = {1,0.75,1,0,false}})
        NPCVisualsSection:Toggle({Name = "Hide Civilians",Flag = "ESP/NPC/TeamCheck",Value = true})
        NPCVisualsSection:Toggle({Name = "Distance Check",Flag = "ESP/NPC/DistanceCheck",Value = true})
        NPCVisualsSection:Slider({Name = "Distance",Flag = "ESP/NPC/Distance",Min = 25,Max = 5000,Value = 250,Unit = "studs"})
        --[[NPCVisualsSection:Button({Name = "Load All NPCs",Callback = function()
            for Index,NPC in pairs(NPCFolder:GetChildren()) do
                task.spawn(function()
                    if NPC:WaitForChild("HumanoidRootPart",5)
                    and NPC.HumanoidRootPart:WaitForChild("AlignOrientation",5) then
                        Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
                    end
                end)
            end
        end}):ToolTip("VERY RISKY\nYOU MIGHT CRASH")]]
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local EnvSection = MiscTab:Section({Name = "Environment"}) do
            EnvSection:Toggle({Name = "Enabled",Flag = "BRM5/Lighting/Enabled",Value = false})
            EnvSection:Toggle({Name = "Brightness",Flag = "BRM5/Lighting/Brightness",Value = false,Callback = function(Bool)
                Lighting.GlobalShadows = not Bool
            end})
            EnvSection:Slider({Name = "Clock Time",Flag = "BRM5/Lighting/Time",Min = 0,Max = 24,Value = 12})
            EnvSection:Slider({Name = "Fog Density",Flag = "BRM5/Lighting/Fog",Min = 0,Max = 1,Precise = 3,Value = 0.255})
        end
        local IntelSection = MiscTab:Section({Name = "Intel ESP",Side = "Left"}) do
            IntelSection:Toggle({Name = "Enabled",Flag = "BRM5/ESP/Intel/Enabled",Value = false})
            :Colorpicker({Flag = "BRM5/ESP/Intel/Color",Value = {1,0,1,0.5,false}})
            IntelSection:Toggle({Name = "Distance Check",Flag = "BRM5/ESP/Intel/DistanceCheck",Value = false})
            IntelSection:Slider({Name = "Distance",Flag = "BRM5/ESP/Intel/Distance",Min = 25,Max = 5000,Value = 1000,Unit = "studs"})
            --[[IntelSection:Button({Name = "Load all Intels",Callback = function()
                for Index,Item in pairs(RaycastFolder:GetChildren()) do
                    if not Item:GetAttribute("Compound") then continue end
                
                    Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.PrimaryPart,"BRM5/ESP/Intel","BRM5/ESP/Intel",Window.Flags)
                end
            end}):ToolTip("VERY RISKY\nYOU MIGHT CRASH")]]
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
            CharSection:Toggle({Name = "No NVG Effect",Flag = "BRM5/DisableNVG",Value = false})
            CharSection:Toggle({Name = "No NVG Shape",Flag = "BRM5/NVGShape",Value = false})
            CharSection:Toggle({Name = "No Camera Bob",Flag = "BRM5/NoBob",Value = false})
            CharSection:Toggle({Name = "No Stamina Loss",Flag = "BRM5/NoStamina",Value = false})
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
            VehSection:Toggle({Name = "Enabled",Flag = "BRM5/Vehicle/Enabled",Value = false}):Keybind({Flag = "BRM5/Vehicle/Keybind"})
            VehSection:Slider({Name = "Speed",Flag = "BRM5/Vehicle/Speed",Min = 0,Max = 1000,Value = 100})
            VehSection:Slider({Name = "Acceleration",Flag = "BRM5/Vehicle/Acceleration",Min = 1,Max = 50,Value = 1})
            :ToolTip("lower = faster")
        end
        local HeliSection = MiscTab:Section({Name = "Helicopter"}) do
            HeliSection:Toggle({Name = "Enabled",Flag = "BRM5/Helicopter/Enabled",Value = false}):Keybind({Flag = "BRM5/Helicopter/Keybind"})
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
                Network:FireServer("CallInteraction", "Fire", "Canopy")

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

                Parvus.Utilities.UI:Notification({
                    Title = "Parvus Hub",
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
                if Aircraft._handler and Aircraft._handler._controller then
                    CameraMod:Mount(Aircraft._handler._controller, "Character")
                    CameraMod._handler._zoom = 128
                end
            end})
        end
        local MiscSection = MiscTab:Section({Name = "Other",Side = "Left"}) do
            MiscSection:Toggle({Name = "FirstPerson Locked",Flag = "BRM5/Misc/FPLocked",
            Value = ServerSettings["FIRSTPERSON_LOCKED"],Callback = function(Value)
                ServerSettings["FIRSTPERSON_LOCKED"] = Value
            end})

            MiscSection:Button({Name = "Enable Fake RGE",Callback = function()
                if not ServerSettings.CHEATS_ENABLED then
                    ServerSettings.CHEATS_ENABLED = true
                    for Index,Connection in pairs(getconnections(RemoteEvent.OnClientEvent)) do
                        Connection.Function("InitRGE")
                    end
                end
            end})
            MiscSection:Button({Name = "Force Reset Character",Callback = function()
                Network:FireServer("ResetCharacter")
            end})
        end
    end Parvus.Utilities:SettingsSection(Window,"End",true)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
--Parvus.Utilities.Drawing.FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("SilentAim",Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
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
--[[local function toScale(value, inputMin, inputMax, outputMin, outputMax)
    local scaledOutput = outputMax - outputMin
    local percentage = value / (inputMax - inputMin)
    return percentage * scaledOutput + outputMin
end]]

local function Raycast(Origin,Direction,Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end
local function GetTeam(Player)
    for TeamName,TeamData in pairs(RoundInterface.Teams) do
        for UserId,UserData in pairs(TeamData.Players) do
            if tonumber(UserId) == Player.UserId then
                return TeamName
            end
        end
    end
end
local function InEnemyTeam(Enabled,Player)
    if not Enabled then return true end
    return not Player.Neutral
    and LocalPlayer.Team ~= Player.Team
    or GetTeam(LocalPlayer) ~= GetTeam(Player)

    --[[if Player.Neutral then
        local LPColor = Squads._tags[LocalPlayer] and Squads._tags[LocalPlayer].Tag.TextLabel.TextColor3 or WhiteColor
        local TargetColor = Squads._tags[Player] and Squads._tags[Player].Tag.TextLabel.TextColor3 or WhiteColor
        return LPColor ~= TargetColor
    else
        return LocalPlayer.Team ~= Player.Team
    end]]
end
local function IsDistanceLimited(Enabled,Distance,Limit)
    if not Enabled then return end
    return Distance >= Limit
end
local function IsVisible(Enabled,Origin,Position,Character)
    if not Enabled then return true end
    return not Raycast(Origin,Position - Origin,
    {Character,RaycastFolder,LocalPlayer.Character})
end
local function CalculateTrajectory(Origin,Velocity,Time,Gravity)
    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end
local function GetClosest(Enabled,
    TeamCheck,VisibilityCheck,DistanceCheck,
    DistanceLimit,FieldOfView,Priority,BodyParts,
    PredictionEnabled,NPCMode
)

    if not Enabled then return end
    local CameraPosition,Closest = Camera.CFrame.Position,nil
    for Index,Actor in pairs(Actors) do local Player = Actor.Player
        if Player == LocalPlayer then continue end

        local Character = Actor.Character
        local Humanoid = Actor.Humanoid
        local RootPart = Actor.RootPart

        if Humanoid.Health <= 0 then continue end

        if NPCMode then
            if Actor._isPlayer then continue end
            local RootRigAttachment = RootPart:FindFirstChild("RootRigAttachment")

            if not RootRigAttachment then continue end
            if not RootPart:FindFirstChild("AlignOrientation") then continue end
            if RootRigAttachment:FindFirstChildOfClass("ProximityPrompt") then continue end
        else
            if not Actor._isPlayer then continue end
            if not InEnemyTeam(TeamCheck,Player) then continue end
        end

        for Index,BodyPart in ipairs(BodyParts) do
            BodyPart = Character:FindFirstChild(BodyPart)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            if IsDistanceLimited(DistanceCheck,Distance,DistanceLimit) then continue end
            if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition,Character) then continue end

            BodyPartPosition = PredictionEnabled and CalculateTrajectory(BodyPartPosition,
            BodyPart.AssemblyLinearVelocity,Distance / ProjectileSpeed,ProjectileGravity) or BodyPartPosition
            local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            if not OnScreen then continue end

            local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            if Priority == "Random" then
                Priority = KnownBodyParts[math.random(#KnownBodyParts)][1]
                BodyPart = Character:FindFirstChild(Priority)
                if not BodyPart then continue end

                BodyPartPosition = BodyPart.Position
                BodyPartPosition = PredictionEnabled and CalculateTrajectory(BodyPartPosition,
                BodyPart.AssemblyLinearVelocity,Distance / ProjectileSpeed,ProjectileGravity) or BodyPartPosition
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            elseif Priority ~= "Closest" then
                BodyPart = Character:FindFirstChild(Priority)
                if not BodyPart then continue end

                BodyPartPosition = BodyPart.Position
                BodyPartPosition = PredictionEnabled and CalculateTrajectory(BodyPartPosition,
                BodyPart.AssemblyLinearVelocity,Distance / ProjectileSpeed,ProjectileGravity) or BodyPartPosition
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            end

            FieldOfView,Closest = Magnitude,{Player,Character,BodyPart,ScreenPosition}
        end
    end

    return Closest
end
--[[local function AimAt(Hitbox,Sensitivity)
    if not Hitbox then return end
    if Window.Flags["Aimbot/Thirdperson"] then
        mousemoverel(Hitbox[3].Position,true,Sensitivity)
        return
    end

    local MouseLocation = UserInputService:GetMouseLocation()
    mousemoverel(Vector2.new(
        (Hitbox[4].X - MouseLocation.X) * Sensitivity,
        (Hitbox[4].Y - MouseLocation.Y) * Sensitivity
    ))
end]]

function RequireModule(Name)
    for Index, Instance in pairs(getloadedmodules()) do
        if Instance.Name == Name then
            return require(Instance)
        end
    end
end
local function HookFunction(ModuleName,Function,Hook)
    local Module,Old = nil,nil

    while task.wait() do
        Module = RequireModule(ModuleName)
        if Module and Module[Function] then
            Old = Module[Function]
            break
        end
    end

    Module[Function] = function(...)
        return Hook(Old,...)
    end
end
local function HookSignal(Signal,Index,Hook)
    local Connection = getconnections(Signal)[Index]
    if not Connection then return end

    local OldConnection = Connection.Function
    if not OldConnection then return end

    Connection:Disable()
    Signal:Connect(function(...)
        return Hook(OldConnection,...)
    end)
end

local function AircraftFly(Self,Enabled,Speed,CameraControl)
    if not Enabled then return end

    Self._force.MaxForce = Vector3.new(1, 1, 1) * 40000000
    Self._force.Velocity = InputToVelocity() * Speed

    if CameraControl then
        Self._gyro.MaxTorque = Vector3.new(1, 1, 1) * 4000
        Self._gyro.CFrame = Camera.CFrame * CFrame.Angles(0,math.pi,0)
    end
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

    local OldNC = Window:GetValue("BRM5/NoClip")
    Window:SetValue("BRM5/NoClip",true)

    LocalPlayer.Character.Humanoid.Sit = true
    PrimaryPart.CFrame = CFrame.new(PrimaryPart.Position + Vector3.new(0,500,0))
    local TP = Teleport(Position + Vector3.new(0,500,0),500)
    TP:Destroy() PrimaryPart.CFrame = CFrame.new(Position)
    LocalPlayer.Character.Humanoid.Sit = false

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

--[[local OldRecoilValue = Window.Flags["BRM5/Recoil/Value"]
local RecoilFunction = RequireModule("CharacterCamera").Recoil
setconstant(RecoilFunction,6,toScale(OldRecoilValue,0,100,250,100))]]

repeat task.wait() until RequireModule("RoundInterface")
RoundInterface = RequireModule("RoundInterface")
repeat task.wait() until RequireModule("ActorService")
Actors = RequireModule("ActorService")._actors
--repeat task.wait() until RequireModule("SquadInterface")
--Squads = RequireModule("SquadInterface")

--[[local ChunkService = RequireModule("ChunkService")
ChunkService.LODEnabled = false

local function ResetWaste()
    local ChunkService = RequireModule("ChunkService")
    local _loaded = ChunkService._loaded

	for key, val in pairs(_loaded) do
		if key:GetAttribute("Waste") == nil then continue end
		val[4] = false
		val[5] = nil

		for _, child in pairs(key:GetChildren()) do
			if not ChunkService._leaves[child] then continue end
			ChunkService._leaves[child].Node:Destroy()
			ChunkService._leaves[child] = nil
		end

		key:Destroy()
		_loaded[key] = nil
	end

	ChunkService._chunk = ""
end

ResetWaste()]]

HookFunction("ControllerClass","LateUpdate",function(Old,Self,...)
    if Window.Flags["BRM5/WalkSpeed/Enabled"] then
        Self.Speed = Window.Flags["BRM5/WalkSpeed/Value"]
    end

    return Old(Self,...)
end)
--[[HookFunction("MovementService","Mount",function(Old,...)
    return Old(...)
end)]]
HookFunction("ViewmodelClass","Update",function(Old,Self,...)
    local Args = {...}

    if Window.Flags["BRM5/WalkSpeed/Enabled"] and Args[2] then
        Args[2] = CFrame.new(Args[2].Position)
    end

    return Old(Self,unpack(Args))
end)
--[[HookFunction("CameraService","Activate",function(Old,Self,...)
    local Args = {...}

    if Window.Flags["BRM5/Recoil/Enabled"] and Args[1] == "Recoil" then
        local RecoilValue = Window.Flags["BRM5/Recoil/Value"]
        Args[2] = Args[2] * (RecoilValue / 100)
        if OldRecoilValue ~= RecoilValue then
            OldRecoilValue = RecoilValue
            setconstant(RecoilFunction,6,
            toScale(RecoilValue,0,100,250,100))
        end
    end

    return Old(Self,unpack(Args))
end)]]
HookFunction("CharacterCamera","Update",function(Old,Self,...)
    if Window.Flags["BRM5/NoBob"] then
        Self._bob = 0
    end

    if Window.Flags["BRM5/Recoil/Enabled"] then
        Self._recoil.Velocity *= Window.Flags["BRM5/Recoil/Value"] / 100
    end
    
    return Old(Self,...)
end)
HookFunction("FirearmInventory","_firemode",function(Old,Self,...)
    if Window.Flags["BRM5/Firemodes"] then
        local Config = Self._config

        if not table.find(Config.Tune.Firemodes,1) then
            table.insert(Config.Tune.Firemodes,1)
        end
        if not table.find(Config.Tune.Firemodes,2) then
            table.insert(Config.Tune.Firemodes,2)
        end
        if not table.find(Config.Tune.Firemodes,3) then
            table.insert(Config.Tune.Firemodes,3)
        end
    end

    return Old(Self,...)
end)
HookFunction("FirearmInventory","_discharge",function(Old,Self,...)
    if Window.Flags["BRM5/RapidFire/Enabled"] then
        Self._config.Tune.RPM = Window.Flags["BRM5/RapidFire/Value"]
    end
    if Window.Flags["BRM5/BulletDrop"] then
        Self._velocity = 1e6
        Self._range = 1e6
    end

    ProjectileSpeed = Self._velocity
    return Old(Self,...)
end)
HookFunction("CharacterMovement","Update",function(Old,Self,...)
    if Window.Flags["BRM5/NoStamina"] then
        Self._exhausted = 0
    end

    return Old(Self,...)
end)
HookFunction("TurretMovement","_discharge",function(Old,Self,...)
    if Window.Flags["BRM5/BulletDrop"] then
        Self._tune.Velocity = 1e6
        Self._tune.Range = 1e6
    end

    ProjectileSpeed = Self._tune.Velocity
    GroundTip = Self._tip
    return Old(Self,...)
end)
HookFunction("AircraftMovement","_discharge",function(Old,Self,...)
    if Window.Flags["BRM5/BulletDrop"] then
        Self._tune.Velocity = 1e6
        Self._tune.Range = 1e6
    end

    ProjectileSpeed = Self._tune.Velocity
    AircraftTip = Self._tip
    return Old(Self,...)
end)
HookFunction("GroundMovement","Update",function(Old,Self,...)
    if Window.Flags["BRM5/Vehicle/Enabled"] then
        Self._tune.Speed = Window.Flags["BRM5/Vehicle/Speed"]
        Self._tune.Accelerate = Window.Flags["BRM5/Vehicle/Acceleration"]
    end

    return Old(Self,...)
end)
HookFunction("HelicopterMovement","Update",function(Old,Self,...)
    if Window.Flags["BRM5/Helicopter/Enabled"] then
        Self._tune.Speed = Window.Flags["BRM5/Helicopter/Speed"]
    end

    return Old(Self,...)
end)
HookFunction("AircraftMovement","Update",function(Old,Self,...)
    if Window.Flags["BRM5/Aircraft/Enabled"] then
        --[[Args[1]._speed = 1
        Args[1]._gyro.CFrame = Args[1]._gyro.CFrame * CFrame.Angles(math.rad(-Args[3].Y * Args[4] * 50), 0, math.rad(Args[3].X * Args[4] * 50));
        Args[1]._gyro.MaxTorque = Vector3.new(1, 1, 1) * 4000
        Args[1]._force.MaxForce = Vector3.new(1, 1, 1) * 40000000 * Args[1]._speed 
        Args[1]._force.Velocity = Args[1]._main.CFrame.LookVector * -Window.Flags["BRM5/Aircraft/Speed"]]
        Self._model.RPM.Value = Window.Flags["BRM5/Aircraft/Speed"]
    end

    AircraftFly(Self,
        Window.Flags["BRM5/Aircraft/FlyEnabled"],
        Window.Flags["BRM5/Aircraft/FlySpeed"],
        Window.Flags["BRM5/Aircraft/Camera"]
    )

    return Old(Self,...)
end)
HookFunction("EnvironmentService","Update",function(Old,Self,...)
    if Window.Flags["BRM5/Lighting/Enabled"] then
        Self._atmospheres.Default.Density = Window.Flags["BRM5/Lighting/Fog"]
        if Self._atmospheres.Desert and Self._atmospheres.Snow then
            Self._atmospheres.Desert.Density = Window.Flags["BRM5/Lighting/Fog"]
            Self._atmospheres.Snow.Density = Window.Flags["BRM5/Lighting/Fog"]
        end
    end
    
    return Old(Self,...)
end)

HookSignal(RemoteEvent.OnClientEvent,1,function(Old,...)
    local Args = {...}

    if Args[1] == "ReplicateNVG" then
        if Window.Flags["BRM5/DisableNVG"] then
            Args[2] = false
        end
        if Window.Flags["BRM5/NVGShape"] then
            Args[3] = ""
        end
    end

    return Old(unpack(Args))
end)

task.spawn(function()
    for Index,Table in pairs(getgc(true)) do
        if typeof(Table) == "table"
        and rawget(Table,"FireServer")
        and rawget(Table,"InvokeServer") then
            Network = Table
            break
        end
    end
end)

local OldNamecall = nil
OldNamecall = hookmetamethod(game,"__namecall",function(Self,...)
    if SilentAim and getnamecallmethod() == "Raycast" then
        if math.random(100) <= Window.Flags["SilentAim/HitChance"] then
            local Args = {...}

            if Args[1] == Camera.CFrame.Position then
                Args[2] = SilentAim[3].Position - Camera.CFrame.Position
            elseif AircraftTip and Args[1] == AircraftTip.WorldCFrame.Position then
                Args[2] = SilentAim[3].Position - AircraftTip.WorldCFrame.Position
            elseif GroundTip and Args[1] == GroundTip.WorldCFrame.Position then
                Args[2] = SilentAim[3].Position - GroundTip.WorldCFrame.Position
            end

            return OldNamecall(Self,unpack(Args))
        end
    end

    return OldNamecall(Self,...)
end)

--[[Parvus.Utilities.NewThreadLoop(0,function()
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
        Window.Flags["Aimbot/Prediction"],
        Window.Flags["BRM5/NPCMode"]
    ),Window.Flags["Aimbot/Sensitivity"] / 100)
end)]]
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
        Window.Flags["SilentAim/Prediction"],
        Window.Flags["BRM5/NPCMode"]
    )
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not (Trigger or Window.Flags["Trigger/AlwaysEnabled"]) then return end
    --if not iswindowactive() then return end

    local TriggerClosest = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/TeamCheck"],
        Window.Flags["Trigger/VisibilityCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/DistanceLimit"],
        Window.Flags["Trigger/FieldOfView"],
        Window.Flags["Trigger/Priority"][1],
        Window.Flags["Trigger/BodyParts"],
        Window.Flags["Trigger/Prediction"],
        Window.Flags["BRM5/NPCMode"]
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
                Window.Flags["Trigger/Prediction"],
                Window.Flags["BRM5/NPCMode"]
            ) if not TriggerClosest or not Trigger then break end
        end
    end mouse1release()
end)

Lighting.Changed:Connect(function(Property)
    if Property == "OutdoorAmbient" and
    Window.Flags["BRM5/Lighting/Brightness"] and
    Lighting.OutdoorAmbient ~= WhiteColor then
        Lighting.OutdoorAmbient = WhiteColor
    end
    if Property == "ClockTime" and
    Window.Flags["BRM5/Lighting/Enabled"] and
    Lighting.ClockTime ~= Window.Flags["BRM5/Lighting/Time"] then
        Lighting.ClockTime = Window.Flags["BRM5/Lighting/Time"]
    end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

for Index,Item in pairs(RaycastFolder:GetChildren()) do
    if not Item:GetAttribute("Compound") then continue end

    Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.PrimaryPart,
    "BRM5/ESP/Intel","BRM5/ESP/Intel",Window.Flags)
end
RaycastFolder.ChildAdded:Connect(function(Item) task.wait(1)
    if not Item:GetAttribute("Compound") then return end

    Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.PrimaryPart,
    "BRM5/ESP/Intel","BRM5/ESP/Intel",Window.Flags)
end)
RaycastFolder.ChildRemoved:Connect(function(Item)
    Parvus.Utilities.Drawing:RemoveObject(Item)
end)

for Index,NPC in pairs(NPCFolder:GetChildren()) do
    task.spawn(function()
        if NPC:WaitForChild("HumanoidRootPart",5)
        and NPC.HumanoidRootPart:WaitForChild("AlignOrientation",5) then
            Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
        end
    end)
end
NPCFolder.ChildAdded:Connect(function(NPC)
    if NPC:WaitForChild("HumanoidRootPart",5)
    and NPC.HumanoidRootPart:WaitForChild("AlignOrientation",5) then
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
