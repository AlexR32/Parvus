local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeamService = game:GetService("Teams")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local LoadingGui = PlayerGui:WaitForChild("LoadingGui")
repeat task.wait(0.5) until not LoadingGui.Enabled

local Loaded1,Loaded2,PromptLib = false,false,loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Roblox/main/Useful/PromptLibrary.lua"))()
--[[if identifyexecutor() ~= "Synapse X" then
    PromptLib("Unsupported executor","Synapse X only for safety measures\nIf you still want to use the script, click \"Ok\"",{
        {Text = "Ok",LayoutOrder = 0,Primary = false,Callback = function() Loaded1 = true end},
    }) repeat task.wait(0.5) until Loaded1
end]]

if game.PlaceVersion > 1407 then
    PromptLib("Unsupported game version","You are at risk of getting autoban\nAre you sure you want to load Parvus?",{
        {Text = "Yes",LayoutOrder = 0,Primary = false,Callback = function() Loaded2 = true end},
        {Text = "No",LayoutOrder = 0,Primary = true,Callback = function() end}
    }) repeat task.wait(0.5) until Loaded2
end

--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Tortoiseshell = getupvalue(require(ReplicatedStorage.TS),2)
-- // TODO: Get LocalPlayer Character

local SilentAim,Aimbot,Trigger,AutoshootHitbox = nil,false,false,nil
local Tortoiseshell,HitmarkerScripts,WeaponModel = getupvalue(require(ReplicatedStorage.TS),2),{},nil
local ProjectileSpeed,ProjectileGravity,GravityCorrection = 1600,150,2--Vector3.new(0,150,0),2
local BanCommands = {"GetUpdate","SetUpdate","GetSetting","FireProjectile","Invoke"}
local DisabledStates = {"Sprinting","SuperSprinting","Swapping","Vaulting"}
local NewRandom,JitterValue,SpinValue = Random.new(),1,0
local SetIdentity = setidentity or (syn and syn.set_thread_identity)

for Index,Connection in pairs(getconnections(Tortoiseshell.UI.Events.Hitmarker.Event)) do
    HitmarkerScripts[#HitmarkerScripts + 1] = getfenv(Connection.Function).script
end

local HandleCharacter = nil
for Index,Connection in pairs(getconnections(Tortoiseshell.Characters.CharacterAdded)) do
    local Script = getfenv(Connection.Function).script
    if Script.Name == "CharacterAnimateScript" then
        HandleCharacter = Connection.Function
    end
end

HandleCharacter = getupvalue(HandleCharacter,3)
local CharacterHandlers = getupvalue(HandleCharacter,3)
local Events = getupvalue(Tortoiseshell.Network.BindEvent,1)
local WeaponConfigs = getupvalue(Tortoiseshell.Items.GetConfig,3)
local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter,1)
local Projectiles = getupvalue(Tortoiseshell.Projectiles.InitProjectile,1)
local HeartbeatConnections = getupvalue(Tortoiseshell.Timer.BindToHeartbeat,1)
local RenderStepConnections = getupvalue(Tortoiseshell.Timer.BindToRenderStep,1)

local OldControl = HeartbeatConnections["Control"]

local Notify = Instance.new("BindableEvent")
Notify.Event:Connect(function(Text)
    Parvus.Utilities.UI:Notification2(Text)
end)

local HitSounds = {
    {"AR2 Head","2062016772"},
    {"AR2 Body","2062015952"},
    {"BB Body","4645745735"},
    {"BB Kill","2636743632"},
    {"Neverlose","8726881116"},
    {"Gamesense","4817809188"},
    {"Baimware","3124331820"},
    {"Steve","4965083997"},
    {"Skeet","4753603610"},
    {"Body","3213738472"},
    {"Ding","7149516994"},
    {"Mario","2815207981"},
    {"Minecraft","6361963422"},
    {"Among Us","5700183626"},
    {"Button","12221967"},
    {"Oof","4792539171"},
    {"Osu","7149919358"},
    {"Osu Combobreak","3547118594"},
    {"Bambi","8437203821"},
    {"Click","8053704437"},
    {"Snow","6455527632"},
    {"Stone","3581383408"},
    {"Rust","1255040462"},
    {"Splat","12222152"},
    {"Bell","6534947240"},
    {"Slime","6916371803"},
    {"Saber","8415678813"},
    {"Bat","3333907347"},
    {"Bubble","6534947588"},
    {"Pick","1347140027"},
    {"Pop","198598793"},
    {"EmptyGun","203691822"},
    {"Bamboo","3769434519"},
    {"Stomp","200632875"},
    {"Bag","364942410"},
    {"Hitmarker","8543972310"},
    {"LaserSlash","199145497"},
    {"RailGunF","199145534"},
    {"Bruh","4275842574"},
    {"Crit","296102734"},
    {"Bonk","3765689841"},
    {"Clink","711751971"},
    {"CoD","160432334"},
    {"Lazer Beam","130791043"},

    {"Windows XP Error","160715357"},
    {"Windows XP Ding","489390072"},

    {"HL Med Kit","4720445506"},
    {"HL Door","4996094887"},
    {"HL Crowbar","546410481"},
    {"HL Revolver","1678424590"},
    {"HL Elevator","237877850"},

    {"TF2 HitSound","3455144981"},
    {"TF2 Squasher","3466981613"},
    {"TF2 Retro","3466984142"},
    {"TF2 Space","3466982899"},
    {"TF2 Vortex","3466980212"},
    {"TF2 Beepo","3466987025"},
    {"TF2 Bat","3333907347"},
    {"TF2 Pow","679798995"},
    {"TF2 You Suck","1058417264"},
    {"Quake Hitsound","4868633804"},
    {"Fart","131314452"},
    {"Fart2","6367774932"},
    {"FortniteGuns","3008769599"}
}

local KnownBodyParts = {
    {"Head",true},{"Neck",false},
    {"Chest",false},{"Abdomen",false},{"Hips",false},

    {"RightArm",false},{"RightForearm",false},{"RightHand",false},
    {"LeftArm",false},{"LeftForearm",false},{"LeftHand",false},

    {"RightLeg",false},{"RightForeleg",false},{"RightFoot",false},
    {"LeftLeg",false},{"LeftForeleg",false},{"LeftFoot",false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212),Parvus.Game.Name),
    Position = UDim2.new(0.5,-248 * 3,0.5,-248)
}) do

    local LegitTab = Window:Tab({Name = "Legit"}) do
        --[[local AimbotSection = LegitTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            :Keybind({Flag = "Aimbot/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Always Enabled",Flag = "Aimbot/AlwaysEnabled",Value = false})
            AimbotSection:Toggle({Name = "Prediction",Flag = "Aimbot/Prediction",Value = false})

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
        local AFOVSection = LegitTab:Section({Name = "Aimbot FOV Circle",Side = "Left"}) do
            AFOVSection:Toggle({Name = "Enabled",Flag = "Aimbot/FOVCircle/Enabled",Value = true})
            AFOVSection:Toggle({Name = "Filled",Flag = "Aimbot/FOVCircle/Filled",Value = false})
            AFOVSection:Colorpicker({Name = "Color",Flag = "Aimbot/FOVCircle/Color",Value = {1,0.66666662693024,1,0.25,false}})
            AFOVSection:Slider({Name = "NumSides",Flag = "Aimbot/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            AFOVSection:Slider({Name = "Thickness",Flag = "Aimbot/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end]]
        local SilentAimSection = LegitTab:Section({Name = "Silent Aim",Side = "Left"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false}):Keybind({Mouse = true,Flag = "SilentAim/Keybind"})

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
        local SAFOVSection = LegitTab:Section({Name = "Silent Aim FOV Circle",Side = "Left"}) do
            SAFOVSection:Toggle({Name = "Enabled",Flag = "SilentAim/FOVCircle/Enabled",Value = true})
            SAFOVSection:Toggle({Name = "Filled",Flag = "SilentAim/FOVCircle/Filled",Value = false})
            SAFOVSection:Colorpicker({Name = "Color",Flag = "SilentAim/FOVCircle/Color",
            Value = {0.6666666865348816,0.6666666269302368,1,0.25,false}})
            SAFOVSection:Slider({Name = "NumSides",Flag = "SilentAim/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            SAFOVSection:Slider({Name = "Thickness",Flag = "SilentAim/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local TriggerSection = LegitTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Enabled",Value = false})
            :Keybind({Flag = "Trigger/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})

            TriggerSection:Toggle({Name = "Always Enabled",Flag = "Trigger/AlwaysEnabled",Value = false})
            TriggerSection:Toggle({Name = "Hold Mouse Button",Flag = "Trigger/HoldMouseButton",Value = false})
            TriggerSection:Toggle({Name = "Prediction",Flag = "Trigger/Prediction",Value = false})

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
        local TFOVSection = LegitTab:Section({Name = "Trigger FOV Circle",Side = "Right"}) do
            TFOVSection:Toggle({Name = "Enabled",Flag = "Trigger/FOVCircle/Enabled",Value = true})
            TFOVSection:Toggle({Name = "Filled",Flag = "Trigger/FOVCircle/Filled",Value = false})
            TFOVSection:Colorpicker({Name = "Color",Flag = "Trigger/FOVCircle/Color",Value = {0.0833333358168602,0.6666666269302368,1,0.25,false}})
            TFOVSection:Slider({Name = "NumSides",Flag = "Trigger/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            TFOVSection:Slider({Name = "Thickness",Flag = "Trigger/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
    end
    local RageTab = Window:Tab({Name = "Rage"}) do
        local AutoshootSection = RageTab:Section({Name = "Rage",Side = "Left"}) do
            AutoshootSection:Toggle({Name = "Autoshoot Enabled",Flag = "BB/Rage/Autoshoot/Enabled",Value = false}):Keybind({Mouse = true,Flag = "BB/Rage/Autoshoot/Keybind"})
            AutoshootSection:Toggle({Name = "Visibility Check",Flag = "BB/Rage/Autoshoot/VisibilityCheck",Value = false}):Keybind()
            AutoshootSection:Toggle({Name = "Distance Check",Flag = "BB/Rage/Autoshoot/DistanceCheck",Value = false}):Keybind()
            AutoshootSection:Slider({Name = "Distance",Flag = "BB/Rage/Autoshoot/DistanceLimit",Min = 25,Max = 1000,Value = 1000,Unit = "studs"})
            AutoshootSection:Slider({Name = "Fire Rate",Flag = "BB/Rage/Autoshoot/FireRate",Min = 1,Max = 10,Value = 1,Unit = "x"})
            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            AutoshootSection:Dropdown({Name = "Priority",Flag = "BB/Rage/Autoshoot/Priority",List = PriorityList})
            AutoshootSection:Dropdown({Name = "Body Parts",Flag = "BB/Rage/Autoshoot/BodyParts",List = BodyPartsList})
        end
        local WMSection = RageTab:Section({Name = "Weapon Modification",Side = "Left"}) do
            --WMSection:Toggle({Name = "No Bob",Flag = "BB/NoBob",Value = false})
            WMSection:Toggle({Name = "Auto FireMode",Flag = "BB/AutoFireMode",Value = false})
            WMSection:Toggle({Name = "Recoil Enabled",Flag = "BB/Recoil/Enabled",Value = false})
            WMSection:Slider({Name = "Weapon Shake",Flag = "BB/Recoil/WeaponScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Camera Shake",Flag = "BB/Recoil/CameraScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Recoil Scale",Flag = "BB/Recoil/RecoilScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WMSection:Slider({Name = "Bullet Drop",Flag = "BB/Recoil/BulletDrop",Min = 0,Max = 100,Value = 0,Unit = "%"})
            --WMSection:Slider({Name = "Bob Scale",Flag = "BB/Recoil/BobScale",Min = 0,Max = 100,Value = 0,Unit = "%"})
        end
        local MiscSection = RageTab:Section({Name = "Other",Side = "Left"}) do
            MiscSection:Toggle({Name = "Knife Aura",Flag = "BB/Rage/KnifeAura",Value = false}):Keybind()
            --MiscSection:Toggle({Name = "Tele-Grenade",Flag = "BB/Rage/TeleGrenade",Value = false}):Keybind()
            --MiscSection:Toggle({Name = "Auto Grenade",Flag = "BB/Rage/AutoGrenade",Value = false}):Keybind()
            MiscSection:Toggle({Name = "Bullet Tracer",Flag = "BB/BulletTracer/Enabled",Value = false})
            :Colorpicker({Flag = "BB/BulletTracer/Color",Value = {1,0.75,1,0,true}})
            MiscSection:Toggle({Name = "Hitmarker",Flag = "BB/Rage/Hitmarker",Value = true})
        end
        local CharacterSection = RageTab:Section({Name = "Character",Side = "Right"}) do
            CharacterSection:Toggle({Name = "ThirdPerson Load Outfit",Flag = "BB/ThirdPerson/Outfit",Value = false})
            CharacterSection:Toggle({Name = "ThirdPerson",Flag = "BB/ThirdPerson/Enabled",Value = false,Callback = function(Bool)
                local LPCharacter = Characters[LocalPlayer]
                if not LPCharacter or not WeaponModel then return end

                if Window.Flags["BB/ThirdPerson/Outfit"] then
                    task.spawn(function() SetIdentity(2)
                        if not CharacterHandlers[LPCharacter] then
                            HandleCharacter(LPCharacter,LocalPlayer)
                        end
                    end)
                end

                for Index,Value in pairs(Workspace.Arms:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = Bool and 1 or 0
                    end
                end
                for Index,Value in pairs(WeaponModel:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = Bool and 1 or 0
                    end
                end
                for Index,Value in pairs(LPCharacter:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = Bool and 0 or 1
                    end
                end
            end}):Keybind({Flag = "BB/ThirdPerson/Keybind"})
            CharacterSection:Toggle({Name = "NoClip",Flag = "BB/NoClip/Enabled",Value = false,Callback = function(Bool)
                local LPCharacter = Characters[LocalPlayer]
                if LPCharacter and LPCharacter.PrimaryPart then LPCharacter.PrimaryPart.CanCollide = not Bool end
            end}):Keybind({Flag = "BB/NoClip/Keybind"})
            CharacterSection:Toggle({Name = "Fly",Flag = "BB/Fly/Enabled",Value = false}):Keybind({Flag = "BB/Fly/Keybind"})
            CharacterSection:Slider({Name = "Fly Speed",Flag = "BB/Fly/Speed",Min = 1,Max = 2,Precise = 1,Value = 2,Unit = "studs",Wide = true})
            CharacterSection:Slider({Name = "ThirdPerson FOV",Flag = "BB/ThirdPerson/FOV",Min = 1,Max = 79,Value = 15,Unit = "studs",Wide = true})
        end
        local AASection = RageTab:Section({Name = "Anti-Aim",Side = "Right"}) do
            AASection:Toggle({Name = "Enabled",Flag = "BB/AntiAim/Enabled",Value = false}):Keybind({Flag = "BB/AntiAim/Keybind"})
            AASection:Slider({Name = "Refresh Rate",Flag = "BB/AntiAim/RefreshRate",Min = 0,Max = 1,Precise = 2,Value = 0.05,Wide = true})
            AASection:Slider({Name = "Pitch",Flag = "BB/AntiAim/Pitch/Value",Min = -2,Max = 2,Precise = 2,Value = -2})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Pitch/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
            AASection:Slider({Name = "Lean",Flag = "BB/AntiAim/Lean/Value",Min = -1.5,Max = 1.5,Precise = 2,Value = 0})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Lean/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
            AASection:Slider({Name = "Roll",Flag = "BB/AntiAim/Roll/Value",Min = -1,Max = 1,Precise = 2,Value = 1})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Roll/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
            AASection:Slider({Name = "Yaw",Flag = "BB/AntiAim/Yaw/Value",Min = -1,Max = 1,Precise = 2,Value = 1})
            AASection:Dropdown({HideName = true,Flag = "BB/AntiAim/Yaw/Mode",List = {
                {Name = "Static",Value = true},{Name = "Random"},{Name = "Jitter"},{Name = "Spin"}
            }})
        end
    end
    local VisualsSection = Parvus.Utilities:ESPSection(Window,"Visuals","ESP/Player",true,true,true,true,true,false) do
        VisualsSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
        VisualsSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
        VisualsSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = true})
        VisualsSection:Toggle({Name = "Use Player Color",Flag = "ESP/Player/TeamColor",Value = false})
        VisualsSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
        VisualsSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local WCSection = MiscTab:Section({Name = "Weapon Customization",Side = "Left"}) do
            WCSection:Toggle({Name = "Enabled",Flag = "BB/WC/Enabled",Value = false})
            :Colorpicker({Flag = "BB/WC/Color",Value = {1,0.75,1,0.5,true}})
            WCSection:Toggle({Name = "Hide Textures",Flag = "BB/WC/Texture",Value = true})
            WCSection:Slider({Name = "Reflectance",Flag = "BB/WC/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            WCSection:Dropdown({Name = "Material",Flag = "BB/WC/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local CCSection = MiscTab:Section({Name = "Character Customization",Side = "Left"}) do
            CCSection:Toggle({Name = "Enabled",Flag = "BB/CC/Enabled",Value = false})
            :Colorpicker({Flag = "BB/CC/Color",Value = {1,0.75,1,0.5,true}})
            CCSection:Toggle({Name = "Hide Textures",Flag = "BB/CC/Texture",Value = true})
            CCSection:Slider({Name = "Reflectance",Flag = "BB/CC/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            CCSection:Dropdown({Name = "Material",Flag = "BB/CC/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        --[[local MiscSection = MiscTab:Section({Name = "Other",Side = "Left"}) do
            MiscSection:Button({Name = "Redeem Codes",Callback = function()
                local Codes = ""
                local Success,Error = pcall(function()
                    Codes = game:HttpGet("https://roblox-bad-business.fandom.com/wiki/Codes")
                end)

                if Success then
                    for Code in Codes:gmatch("<td>([%w\n_]*)</td>") do
                        Tortoiseshell.Network:Invoke("Codes","Redeem",Code:gsub("\n",""))
                        --Code = Code:gsub("\n","")
                        --print(Code,Tortoiseshell.Network:Invoke("Codes","Redeem",Code))
                    end task.wait(0.05)
                    firesignal(LocalPlayer.PlayerGui.MenuGui.ClaimedFrame.CloseButton.MouseButton1Click)
                    firesignal(LocalPlayer.PlayerGui.MenuGui.PurchasedFrame.CloseButton.MouseButton1Click)
                    Parvus.Utilities.UI:Notification({Title = "Parvus Hub",Description = "All available codes are claimed!",Duration = 5})
                else
                    Parvus.Utilities.UI:Notification({Title = "Parvus Hub",Description = "Failed to get the codes:\n" .. Error,Duration = 5})
                end
            end})
        end]]
        local ACSection = MiscTab:Section({Name = "Arms Customization",Side = "Right"}) do
            ACSection:Toggle({Name = "Enabled",Flag = "BB/AC/Enabled",Value = false})
            :Colorpicker({Flag = "BB/AC/Color",Value = {1,0,1,1,false}})
            ACSection:Toggle({Name = "Hide Textures",Flag = "BB/AC/Texture",Value = true})
            ACSection:Slider({Name = "Reflectance",Flag = "BB/AC/Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = 0})
            ACSection:Dropdown({Name = "Material",Flag = "BB/AC/Material",List = {
                {Name = "SmoothPlastic",Mode = "Button"},
                {Name = "ForceField",Mode = "Button"},
                {Name = "Neon",Mode = "Button",Value = true},
                {Name = "Glass",Mode = "Button"}
            }})
        end
        local HitSoundSection = MiscTab:Section({Name = "HitSound Customization",Side = "Right"}) do

            local HitSoundsList = {}
            for Index,Sound in pairs(HitSounds) do
                HitSoundsList[#HitSoundsList + 1] = {
                    Name = Sound[1],Mode = "Button",
                    Callback = function()
                        local HitSound = nil
                        for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                            HitmarkerScript.HeadshotSound.Volume = 0
                            HitSound = HitmarkerScript.HitmarkerSound
                            HitSound.SoundId = "rbxassetid://" .. Sound[2]
                        end HitSound:Play()
                    end
                }
            end

            HitSoundSection:Button({Name = "Reset To Defaults",Callback = function()
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitmarkerScript.HeadshotSound.Volume = 0.7
                    HitmarkerScript.HitmarkerSound.Volume = 3.5
                    HitmarkerScript.HitmarkerSound.PlaybackSpeed = 1.4
                    HitmarkerScript.HitmarkerSound.SoundId = "rbxassetid://4645745735"
                end
            end})
            HitSoundSection:Slider({Name = "Volume",Flag = "BB/HitSound/Volume",Min = 0,Max = 5,Precise = 1,Value = 3.5,
            Callback = function(Value)
                local HitSound = nil
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitSound = HitmarkerScript.HitmarkerSound
                    HitSound.Volume = Value
                end HitSound:Play()
            end})
            HitSoundSection:Slider({Name = "Pitch",Flag = "BB/HitSound/Pitch",Min = 0,Max = 5,Precise = 1,Value = 1.4,
            Callback = function(Value)
                local HitSound = nil
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitSound = HitmarkerScript.HitmarkerSound
                    HitSound.PlaybackSpeed = Value
                end HitSound:Play()
            end})
            HitSoundSection:Dropdown({HideName = true,Flag = "BB/HitSound/Sound",List = HitSoundsList})
        end
        local KillSoundSection = MiscTab:Section({Name = "KillSound Customization",Side = "Right"}) do

            local KillSoundsList = {}
            for Index,Sound in pairs(HitSounds) do
                KillSoundsList[#KillSoundsList + 1] = {
                    Name = Sound[1],Mode = "Button",
                    Callback = function()
                        local KillSound = nil
                        for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                            HitmarkerScript.MedalSound.Volume = 0
                            KillSound = HitmarkerScript.KillSound
                            KillSound.SoundId = "rbxassetid://" .. Sound[2]
                        end KillSound:Play()
                    end
                }
            end

            KillSoundSection:Button({Name = "Reset To Defaults",Callback = function()
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    HitmarkerScript.MedalSound.Volume = 0.8
                    HitmarkerScript.KillSound.Volume = 1
                    HitmarkerScript.KillSound.PlaybackSpeed = 1.5
                    HitmarkerScript.KillSound.SoundId = "rbxassetid://2636743632"
                end
            end})
            KillSoundSection:Slider({Name = "Volume",Flag = "BB/KillSound/Volume",Min = 0,Max = 5,Precise = 1,Value = 1,
            Callback = function(Value)
                local KillSound = nil
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    KillSound = HitmarkerScript.KillSound
                    KillSound.Volume = Value
                end KillSound:Play()
            end})
            KillSoundSection:Slider({Name = "Pitch",Flag = "BB/KillSound/Pitch",Min = 0,Max = 5,Precise = 1,Value = 1.5,
            Callback = function(Value)
                local KillSound = nil
                for Index,HitmarkerScript in pairs(HitmarkerScripts) do
                    KillSound = HitmarkerScript.KillSound
                    KillSound.PlaybackSpeed = Value
                end KillSound:Play()
            end})
            KillSoundSection:Dropdown({HideName = true,Flag = "BB/KillSound/Sound",List = KillSoundsList})
        end
    end Parvus.Utilities:SettingsSection(Window,"End",false)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
--Parvus.Utilities.Drawing.FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("SilentAim",Window.Flags)

do
    --[[for Index,Value in pairs(getgc(true)) do
        if type(Value) ~= "table" then continue end
        if rawget(Value,"Maid") and rawget(Value,"Payload") and rawget(Value,"Console") and rawget(Value,"Mobile") and rawget(Value,"Math")
        and rawget(Value,"Timer") and rawget(Value,"Raycast") and rawget(Value,"Network") and rawget(Value,"Input") and rawget(Value,"Players")
        and rawget(Value,"UI") and rawget(Value,"Camera") and rawget(Value,"Projectiles") and rawget(Value,"Effects") and rawget(Value,"Teams")
        and rawget(Value,"Damage") and rawget(Value,"Items") and rawget(Value,"Characters") and rawget(Value,"Clothing") and rawget(Value,"Levels")
        and rawget(Value,"Skins") and rawget(Value,"Charms") and rawget(Value,"Stickers") and rawget(Value,"Profiles") and rawget(Value,"Menu") then
            if Value.Network.TS then continue end
            table.clear(Value)
        end
    end]]

    local OldNamecall = nil
    OldNamecall = hookmetamethod(game,"__namecall",function(Self,A,B,...)
        if checkcaller() then return OldNamecall(Self,A,B,...) end
        local Method = getnamecallmethod()

        if Method == "FireServer" then
            --local Args = {...}
            if type(A) == "string"
            and table.find(BanCommands,A) then
                print("blocked",B) return
            end
        end

        if Method == "Destroy" and Self.Parent == LocalPlayer.Character then
            if os.clock() - getupvalue(OldControl,3) <= 1 then
                print("int check",Self.Name)
            else
                print("blocked",Self.Name)
                return
            end
        end

        return OldNamecall(Self,A,B,...)
    end)
    --[[local OldTaskSpawn = nil
    OldTaskSpawn = hookfunction(getrenv().task.spawn,function(...)
        if checkcaller() then return OldTaskSpawn(...) end

        local Args = {...}
        if type(Args[1]) == "function" then
            local Constants = getconstants(Args[1])
            if table.find(Constants,"wait")
            and not (table.find(Constants,"thread error ")
            or table.find(Constants,"Item_Paintball")
            or table.find(Constants,0.5)) then
                print("blocked wtd crash")
                --print(repr(Constants))
                wait(31536000) -- 365 days
            end
        end

        return OldTaskSpawn(...)
    end)]]
end

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Whitelist
WallCheckParams.IgnoreWater = true

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
local function GetPlayerTeam(Player)
    for Index,Team in pairs(TeamService:GetChildren()) do
        if Team.Players:FindFirstChild(Player.Name) then
            return Team.Name
        end
    end
end

local function Raycast(Origin,Direction,Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end
local function InEnemyTeam(Player)
    local Team = GetPlayerTeam(Player)
    local LPTeam = GetPlayerTeam(LocalPlayer)
    return LPTeam ~= Team or Team == "FFA"
end
local function IsDistanceLimited(Enabled,Distance,Limit)
    if not Enabled then return end
    return Distance >= Limit
end
local function IsVisible(Enabled,Origin,Position)
    if not Enabled then return true end
    return not Raycast(Origin,Position - Origin,
    {Workspace.Geometry,Workspace.Terrain})
end

--[[local function FindWeaponModel()
    for Index,Instance in pairs(Workspace:GetChildren()) do
        if Instance:FindFirstChild("AnimationController") then
            return Instance
        end
    end
end]]
local function GetPlayerBody(Player)
    local Character = Characters[Player]

    if not Character then return end
    if Character.Parent == nil then return end
    return Character,Character:FindFirstChild("Body")
end
local function IsCharacterInShield(Character)
    local Health = Character:FindFirstChild("Health")
    return Health and not Health:FindFirstChild("Shield")
end
local function GetBodyPart(Body,Name)
    for Index,Part in pairs(Body:GetChildren()) do
        if Part.Name ~= Name then continue end
        local WeldConstraint = Part:FindFirstChildOfClass("WeldConstraint")
        if not WeldConstraint then continue end
        return WeldConstraint.Part0
    end
end
--[[local function GetEquippedController()
    local Controllers = Tortoiseshell.Items:GetControllers()
    for Weapon,Controller in pairs(Controllers) do
        if Controller.Equipped then
            return Controller
        end
    end
end]]
local function GetEquippedWeapon()
    local Controllers = Tortoiseshell.Items:GetControllers()
    for Weapon,Controller in pairs(Controllers) do
        if Controller.Equipped then
            return Weapon,WeaponConfigs[Weapon]
        end
    end
end
--[[local function GetGrenade()
    local Controllers = Tortoiseshell.Items:GetControllers()
    for Weapon,Controller in pairs(Controllers) do
        local Config = WeaponConfigs[Weapon]
        if Config.Category == "Grenade" then
            return Weapon,Config
        end
    end
end]]
local function GetAntiAimValue(Value,Mode)
    if Mode == "Random" then
        Value = math.abs(Value)
        return NewRandom:NextNumber(-Value,Value)
    elseif Mode == "Jitter" then
        Value = Value * JitterValue
    elseif Mode == "Spin" then
        Value = Value * SpinValue
    end
    return Value
end
local function ToggleShoot(Toggle)
    Tortoiseshell.Input[Toggle and "AutomateBegan"
    or "AutomateEnded"](Tortoiseshell.Input,"Shoot")
end
local function CustomizeWeapon(Enabled,HideTextures,Color,Reflectance,Material)
    if not Enabled then return end
    if not WeaponModel then return end
    if WeaponModel.Parent == nil then return end

    for Index,Instance in pairs(WeaponModel.Body:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart")
        and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Color[6]
            Instance.Transparency = Color[4] > 0.95 and 0.95 or Color[4]
            Instance.Reflectance = Reflectance
            Instance.Material = Material
        end
    end
end
local function CustomizeArms(Enabled,HideTextures,Color,Reflectance,Material)
    if not Enabled then return end

    for Index,Instance in pairs(Workspace.Arms:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart")
        and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Color[6]
            Instance.LocalTransparencyModifier = Color[4]
            Instance.Reflectance = Reflectance
            Instance.Material = Material
        end
    end
end
local function CustomizeCharacter(Enabled,HideTextures,Color,Reflectance,Material)
    if not Enabled then return end

    local LPCharacter = Characters[LocalPlayer]
    if not LPCharacter then return end

    for Index,Instance in pairs(LPCharacter:GetDescendants()) do
        if HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart")
        and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Color[6]
            Instance.LocalTransparencyModifier = Color[4]
            Instance.Reflectance = Reflectance
            Instance.Material = Material
        end
    end
end
local function GetReticlePosition(Hitbox)
    local ReticlePosition = Camera.CFrame.Position
    local LookVector = (Hitbox.Position - ReticlePosition).Unit

    local Distance = 3
    local Part,Position = Tortoiseshell.Raycast:CastGeometryAndEnemies(ReticlePosition,LookVector * Distance,LocalPlayer)
    if Part then Distance = (ReticlePosition - Position).Magnitude - 0.1 end

    return ReticlePosition + LookVector * Distance
end
local function ComputeProjectiles(Config,Hitbox)
    --local ReticlePosition = Tortoiseshell.Input.Reticle:GetPosition()
    --[[local HitboxPosition = Hitbox.Position + Vector3.new(
        NewRandom:NextNumber(-(Hitbox.Size.X / 4),Hitbox.Size.X / 4),
        NewRandom:NextNumber(-(Hitbox.Size.Y / 4),Hitbox.Size.Y / 4),
        NewRandom:NextNumber(-(Hitbox.Size.Z / 4),Hitbox.Size.Z / 4)
    )]]

    local ReticlePosition = GetReticlePosition(Hitbox)
    local LookVector = Hitbox.Position - ReticlePosition
    local RayResult = Raycast(ReticlePosition,LookVector,{Hitbox})
    if not RayResult then return end

    local ShootProjectiles = {}
    for Index = 1,Config.Projectile.Amount do
        table.insert(ShootProjectiles,{
            (LookVector.Unit + Vector3.new(0,Config.Projectile.GravityCorrection / 1000,0)).Unit,
            Tortoiseshell.Projectiles:GetID()
        })
    end

    return ShootProjectiles,ReticlePosition,
    RayResult.Position,RayResult.Normal
end
local function Autoshoot(Hitbox,FireRate)
    if not Hitbox then return end
    local Weapon,Config = GetEquippedWeapon()

    if Weapon and Config and Config.Controller == "Paintball" then
        local State = Weapon.State

        local Ammo = State.Ammo.Server
        local AmmoValue = Ammo.Value

        --local Health = Hitbox[2].Health
        --local HealthValue = Health.Value

        if AmmoValue > 0 then
            local FireMode = State.FireMode.Server

            local FireModeFromList = Config.FireModeList[FireMode.Value]
            local CurrentFireMode = Config.FireModes[FireModeFromList]

            local ShootProjectiles,ReticlePosition,RayPosition,
            RayNormal = ComputeProjectiles(Config,Hitbox[3])
            if not ShootProjectiles then return end

            task.spawn(function()
                Tortoiseshell.Network:Fire("Item_Paintball",
                "Shoot",Weapon,ReticlePosition,ShootProjectiles)

                task.wait((RayPosition - ReticlePosition).Magnitude
                / Projectiles[Config.Projectile.Template].Speed)

                for Index,Projectile in pairs(ShootProjectiles) do
                    Tortoiseshell.Network:Fire("Projectiles","__Hit",
                    Projectile[2],RayPosition,Hitbox[3],RayNormal,Hitbox[2])
                end
            end)

            Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
            task.wait(60/(CurrentFireMode.FireRate*FireRate))

            if (AmmoValue - Ammo.Value) >= 1 then
                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Hit %s | Ammo %s"):format(
                        Hitbox[1].Name,Ammo.Value
                    ),Color = Color3.new(1,0.5,0.25),Duration = 3
                })

                if Window.Flags["BB/Rage/Hitmarker"] then
                    Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3],RayPosition,#ShootProjectiles > 3)
                end
            end
        else
            local Reloading = State.Reloading.Server
            if not Reloading.Value then
                local ReloadTime = Config.Magazine.ReloadTime
                local Milliseconds = (ReloadTime % 1) * 10
                local Seconds = ReloadTime % 60

                Tortoiseshell.Network:Fire("Item_Paintball","Reload",Weapon)
                Parvus.Utilities.UI:Notification2({
                    Title = ("Autoshoot | Reloading | Approx Time: %d.%d sec."):format(Seconds,Milliseconds),
                    Color = Color3.new(1,0.25,0.25),Duration = 3
                }) task.wait(ReloadTime)
            end
        end
    end
end
local function KnifeAura(Hitbox,FireRate)
    if not Hitbox then return end
    local Weapon,Config = GetEquippedWeapon()

    if Weapon and Config then
        if Config.Controller == "Melee" then
            if (Hitbox[3].Position - Camera.CFrame.Position).Magnitude <= 15 then
                Tortoiseshell.Network:Fire("Item_Melee","StabBegin",Weapon)
                Tortoiseshell.Network:Fire("Item_Melee","Stab",Weapon,Hitbox[3],
                Hitbox[3].Position,Hitbox[3].Position - Camera.CFrame.Position)

                if Window.Flags["BB/BulletTracer/Enabled"] then
                    Parvus.Utilities.MakeBeam(Camera.CFrame.Position - Vector3.new(0,1,0),Hitbox[3].Position,Window.Flags["BB/BulletTracer/Color"])
                end
                if Window.Flags["BB/Rage/Hitmarker"] then
                    Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3])
                end

                Parvus.Utilities.UI:Notification2({
                    Title = ("Knife Aura | Stab %s"):format(Hitbox[1].Name),
                    Color = Color3.new(1,0.5,0.25),Duration = 3
                }) task.wait(1/(Config.Melee.Speed*FireRate))
            end
        end
    end
end
--[[local function AutoGrenade()
    local Weapon,Config = GetEquippedWeapon()
    local Grenade,GrenadeConfig = GetGrenade()
    if Weapon and Grenade then
        local State = Grenade:WaitForChild("State")

        if State.Ammo.Server.Value > 0 then
            Tortoiseshell.Network:Fire("Item","Equip",Grenade)
            Tortoiseshell.Network:Fire("Item_Throwable","Cook",Grenade)
            Tortoiseshell.Network:Fire("Item_Throwable","Throw",Grenade,
                Camera.CFrame.Position,Camera.CFrame.LookVector
            ) Tortoiseshell.Network:Fire("Item","Equip",Weapon)
            task.wait(GrenadeConfig.Throwable.CookTime)
        end
    end
end]]
local function GetClosestAllFOV(Enabled,
    VisibilityCheck,DistanceCheck,
    DistanceLimit,Priority,BodyParts
)

    if not Enabled then return end
    local Distance,Closest = math.huge,nil
    local CameraPosition = Camera.CFrame.Position

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if not InEnemyTeam(Player) then continue end

        local Character,Body = GetPlayerBody(Player)
        if not Character or not Body then continue end

        local Shield = IsCharacterInShield(Character)
        if not Shield then continue end

        for Index,BodyPart in ipairs(BodyParts) do
            BodyPart = GetBodyPart(Body,BodyPart)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position

            local Magnitude = (BodyPartPosition - CameraPosition).Magnitude
            if IsDistanceLimited(DistanceCheck,Magnitude,DistanceLimit) then continue end
            if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition) then continue end
            if Magnitude >= Distance then continue end

            if Priority == "Random" then
                Priority = KnownBodyParts[math.random(#KnownBodyParts)][1]
                BodyPart = GetBodyPart(Body,Priority)
                if not BodyPart then continue end
            elseif Priority ~= "Closest" then
                BodyPart = GetBodyPart(Body,Priority)
                if not BodyPart then continue end
            end

            Distance,Closest = Magnitude,{Player,Character,BodyPart}
        end
    end

    return Closest
end

local function GetClosest(Enabled,VisibilityCheck,DistanceCheck,
    DistanceLimit,FieldOfView,Priority,BodyParts,PredictionEnabled
)

    if not Enabled then return end
    local LPCharacter,Closest = Characters[LocalPlayer],nil
    if not (LPCharacter and LPCharacter.PrimaryPart) then return end
    local CameraPosition = Camera.CFrame.Position

    for Index,Player in ipairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character,Body = GetPlayerBody(Player)
        if not Character or not Body then continue end

        if not InEnemyTeam(Player) then continue end

        for Index,BodyPart in ipairs(BodyParts) do
            if Priority == "Random" then
                local PriorityPart = KnownBodyParts[math.random(#KnownBodyParts)][1]
                BodyPart = GetBodyPart(Body,PriorityPart) if not BodyPart then continue end

                local BodyPartPosition = BodyPart.Position
                local Distance = (BodyPartPosition - CameraPosition).Magnitude
                if IsDistanceLimited(DistanceCheck,Distance,DistanceLimit) then continue end
                if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition) then continue end

                BodyPartPosition = PredictionEnabled and Parvus.Utilities.Physics.SolveTrajectory(Camera.CFrame.Position,
                BodyPart.Position,BodyPart.AssemblyLinearVelocity,ProjectileSpeed,ProjectileGravity,GravityCorrection) or BodyPart.Position
                local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
                if not OnScreen then continue end

                local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if Magnitude >= FieldOfView then continue end

                FieldOfView,Closest = Magnitude,{Player,Character,BodyPart,ScreenPosition}
                continue
            elseif Priority ~= "Closest" then
                BodyPart = GetBodyPart(Body,Priority) if not BodyPart then continue end

                local BodyPartPosition = BodyPart.Position
                local Distance = (BodyPartPosition - CameraPosition).Magnitude
                if IsDistanceLimited(DistanceCheck,Distance,DistanceLimit) then continue end
                if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition) then continue end

                BodyPartPosition = PredictionEnabled and Parvus.Utilities.Physics.SolveTrajectory(Camera.CFrame.Position,
                BodyPart.Position,BodyPart.AssemblyLinearVelocity,ProjectileSpeed,ProjectileGravity,GravityCorrection) or BodyPart.Position
                local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
                if not OnScreen then continue end

                local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if Magnitude >= FieldOfView then continue end

                FieldOfView,Closest = Magnitude,{Player,Character,BodyPart,ScreenPosition}
                continue
            end

            BodyPart = GetBodyPart(Body,BodyPart)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            if IsDistanceLimited(DistanceCheck,Distance,DistanceLimit) then continue end
            if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition) then continue end

            BodyPartPosition = PredictionEnabled and Parvus.Utilities.Physics.SolveTrajectory(CameraPosition,BodyPartPosition,
            BodyPart.AssemblyLinearVelocity,ProjectileSpeed,ProjectileGravity,GravityCorrection) or BodyPartPosition
            local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            if not OnScreen then continue end

            local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            FieldOfView,Closest = Magnitude,{Player,Character,BodyPart,ScreenPosition}
        end
    end

    return Closest
end
--[[local function AimAt(Hitbox,Sensitivity)
    if not Hitbox then return end
    if Window.Flags["BB/ThirdPerson/Enabled"] then
        mousemoverel(Hitbox[3].Position,true,Sensitivity)
        return
    end

    local MouseLocation = UserInputService:GetMouseLocation()
    mousemoverel(Vector2.new(
        (Hitbox[4].X - MouseLocation.X) * Sensitivity,
        (Hitbox[4].Y - MouseLocation.Y) * Sensitivity
    ))
end]]

Parvus.Utilities.FixUpValue(Tortoiseshell.Network.Fire,function(Old,Self,...)
    local Args = {...}

    if Args[2] == "Shoot" then
        if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
            task.spawn(function()
                local Hitbox = SilentAim
                local Weapon,Config = GetEquippedWeapon()
                local ShootProjectiles,ReticlePosition,RayPosition,
                RayNormal = ComputeProjectiles(Config,Hitbox[3])
                if not ShootProjectiles then return end

                Old(Self,"Item_Paintball","Shoot",
                Weapon,ReticlePosition,ShootProjectiles)

                task.wait((RayPosition - ReticlePosition).Magnitude
                / Projectiles[Config.Projectile.Template].Speed)

                for Index,Projectile in pairs(ShootProjectiles) do
                    Old(Self,"Projectiles","__Hit",Projectile[2],
                    RayPosition,Hitbox[3],RayNormal,Hitbox[2])
                end

                Tortoiseshell.UI.Events.Hitmarker:Fire(Hitbox[3],RayPosition,#ShootProjectiles > 3)

                if Window.Flags["BB/BulletTracer/Enabled"] then
                    Parvus.Utilities.MakeBeam(Camera.CFrame.Position - Vector3.new(0,1,0),RayPosition,Window.Flags["BB/BulletTracer/Color"])
                end
            end)

            return
        end
    elseif Args[2] == "__Hit" then
        if SilentAim then return end
        if Window.Flags["BB/BulletTracer/Enabled"] then
            Parvus.Utilities.MakeBeam(Camera.CFrame.Position - Vector3.new(0,1,0),Args[4],Window.Flags["BB/BulletTracer/Color"])
        end
    --[[elseif Args[2] == "Throw" then
        if (SilentAim and not Window.Flags["BB/Rage/Autoshoot/Enabled"])
        and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
            Args[5] = (SilentAim[3].Position - Camera.CFrame.Position).Unit
            Tortoiseshell.UI.Events.Hitmarker:Fire(
            SilentAim[3],SilentAim[3].Position)
            return Old(Self,unpack(Args))
        end]]
    elseif Args[2] == "State" then
        --[[
        Old(Self,"Character","State","Aiming",true)
        Old(Self,"Character","State","Climbing",true)
        Old(Self,"Character","State","Grounded",true)
        Old(Self,"Character","State","InWater",true)
        Old(Self,"Character","State","Sliding",true)
        Old(Self,"Character","State","Sprinting",true)
        Old(Self,"Character","State","SuperSprinting",true)
        Old(Self,"Character","State","Swapping",true)
        Old(Self,"Character","State","Vaulting",true)
        Old(Self,"Character","State","Stance","Stand") -- "Crouch","Prone"
        ]]

        if Window.Flags["BB/Rage/Autoshoot/Enabled"] and table.find(DisabledStates,Args[3]) then Args[4] = false end
        if Window.Flags["BB/AntiAim/Enabled"] and Args[3] == "Look" then
            local Pitch = GetAntiAimValue(Window.Flags["BB/AntiAim/Pitch/Value"],Window.Flags["BB/AntiAim/Pitch/Mode"][1])
            local Lean = GetAntiAimValue(Window.Flags["BB/AntiAim/Lean/Value"],Window.Flags["BB/AntiAim/Lean/Mode"][1])
            Args[4] = Pitch Old(Self,"Character","State","Lean",Lean)
        end

        return Old(Self,unpack(Args))
    end

    return Old(Self,...)
end)

Parvus.Utilities.FixUpValue(Tortoiseshell.Projectiles.InitProjectile,function(Old,Self,A,B,C,D,...)
    if D == LocalPlayer then
        ProjectileSpeed = Projectiles[A].Speed
        ProjectileGravity = Projectiles[A].Gravity
    end

    return Old(Self,A,B,C,D,...)
end)

Parvus.Utilities.FixUpValue(Tortoiseshell.Raycast.CastGeometryAndEnemies,function(Old,Self,...)
    if Window.Flags["BB/Recoil/Enabled"] then
        local Args = {...} if Args[4] and Args[4].Gravity then
            Args[4].Gravity = Args[4].Gravity * (Window.Flags["BB/Recoil/BulletDrop"] / 100)
            return Old(Self,unpack(Args))
        end
    end

    return Old(Self,...)
end)

Parvus.Utilities.FixUpValue(Tortoiseshell.Items.GetAnimator,function(Old,Self,A,B,C,...)
    if A then WeaponModel = C
        if Window.Flags["BB/ThirdPerson/Enabled"] then
            task.spawn(function() task.wait(0.5)
                for Index,Value in pairs(Workspace.Arms:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = 1
                    end
                end
                for Index,Value in pairs(WeaponModel:GetDescendants()) do
                    if Value:IsA("BasePart") then
                        Value.LocalTransparencyModifier = 1
                    end
                end
            end)
        end
    end

    return Old(Self,A,B,C,...)
end,true)

-- Old Config Mod
--[[Parvus.Utilities.FixUpValue(Tortoiseshell.Items.GetConfig,function(Old,Self,...)
    local Args = {Old(Self,...)} local Config = Args[1]
    if Window.Flags["BB/Recoil/Enabled"]
    and (Config and Config.Recoil and Config.Recoil.Default) then
        Config.Recoil.Default.WeaponScale = 
        Config.Recoil.Default.WeaponScale * (Window.Flags["BB/Recoil/WeaponScale"] / 100)

        Config.Recoil.Default.CameraScale = 
        Config.Recoil.Default.CameraScale * (Window.Flags["BB/Recoil/CameraScale"] / 100)

        Config.Recoil.Default.RecoilScale = 
        Config.Recoil.Default.RecoilScale * (Window.Flags["BB/Recoil/RecoilScale"] / 100)
    end return unpack(Args)
end)]]

local OldCamera = RenderStepConnections["Camera"]
RenderStepConnections["Camera"] = function(...)
    if Window.Flags["BB/ThirdPerson/Enabled"] then
        local Args = {OldCamera(...)}

        local LPCharacter = Characters[LocalPlayer]
        if LPCharacter and LPCharacter.Parent then
            Camera.CFrame = Camera.CFrame * CFrame.new(0,0,Window.Flags["BB/ThirdPerson/FOV"])
        end

        return unpack(Args)
    end

    return OldCamera(...)
end

local OldFirstPerson = RenderStepConnections["FirstPerson"]
RenderStepConnections["FirstPerson"] = function(...)
    if Window.Flags["BB/ThirdPerson/Enabled"] then return end
    --setupvalue(OldFirstPerson,9,0) -- No Bob (shit)
    return OldFirstPerson(...)
end

HeartbeatConnections["Control"] = function(Delta,...)
    local LPCharacter = Characters[LocalPlayer]
    if LPCharacter and LPCharacter.Parent and LPCharacter.PrimaryPart then
        local Args = {OldControl(Delta,...)}

        if Window.Flags["BB/Fly/Enabled"] then
            local MoveVector = Parvus.Utilities.MovementToDirection()
            LPCharacter.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            LPCharacter.PrimaryPart.CFrame += MoveVector * Window.Flags["BB/Fly/Speed"] * (Delta * 60)
        end
        if Window.Flags["BB/AntiAim/Enabled"] then
            local Roll = GetAntiAimValue(Window.Flags["BB/AntiAim/Roll/Value"],Window.Flags["BB/AntiAim/Roll/Mode"][1])
            local Yaw = GetAntiAimValue(Window.Flags["BB/AntiAim/Yaw/Value"],Window.Flags["BB/AntiAim/Yaw/Mode"][1])
            LPCharacter.PrimaryPart.CFrame *= CFrame.Angles(math.rad(180 * Roll),math.rad(180 * Yaw),0)
        end

        return unpack(Args)
    end

    return OldControl(Delta,...)
end

--[[for Index,Event in pairs(Events) do
    if Event.Event == "Item_Throwable" then
        local OldCallback = Event.Callback
        Event.Callback = function(...)
            local Args = {...}

            Parvus.Utilities.NewThreadLoop(0,function()
                if Args[2].Parent == nil then return "break" end
                if AutoshootHitbox and Window.Flags["BB/Rage/TeleGrenade"] then
                    print(Args[2].PrimaryPart)
                    Args[2].PrimaryPart.Position = AutoshootHitbox[3].Position
                end
            end)

            return OldCallback(...)
        end
    end
end]]

--[[Parvus.Utilities.NewThreadLoop(0,function()
    if not (Aimbot or Window.Flags["Aimbot/AlwaysEnabled"]) then return end

    AimAt(GetClosest(
        Window.Flags["Aimbot/Enabled"],
        Window.Flags["Aimbot/VisibilityCheck"],
        Window.Flags["Aimbot/DistanceCheck"],
        Window.Flags["Aimbot/DistanceLimit"],
        Window.Flags["Aimbot/FieldOfView"],
        Window.Flags["Aimbot/Priority"][1],
        Window.Flags["Aimbot/BodyParts"],
        Window.Flags["Aimbot/Prediction"]
    ),Window.Flags["Aimbot/Sensitivity"] / 100)
end)]]
Parvus.Utilities.NewThreadLoop(0,function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"] and not
        Window.Flags["BB/Rage/Autoshoot/Enabled"],
        Window.Flags["SilentAim/VisibilityCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/DistanceLimit"],
        Window.Flags["SilentAim/FieldOfView"],
        Window.Flags["SilentAim/Priority"][1],
        Window.Flags["SilentAim/BodyParts"]
    )
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not (Trigger or Window.Flags["Trigger/AlwaysEnabled"]) then return end

    local TriggerClosest = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/VisibilityCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/DistanceLimit"],
        Window.Flags["Trigger/FieldOfView"],
        Window.Flags["Trigger/Priority"][1],
        Window.Flags["Trigger/BodyParts"],
        Window.Flags["Trigger/Prediction"]
    ) if not TriggerClosest then return end

    task.wait(Window.Flags["Trigger/Delay"])
    Tortoiseshell.Input:AutomateBegan("Shoot")
    if Window.Flags["Trigger/HoldMouseButton"] then
        while task.wait() do
            TriggerClosest = GetClosest(
                Window.Flags["Trigger/Enabled"],
                Window.Flags["Trigger/VisibilityCheck"],
                Window.Flags["Trigger/DistanceCheck"],
                Window.Flags["Trigger/DistanceLimit"],
                Window.Flags["Trigger/FieldOfView"],
                Window.Flags["Trigger/Priority"][1],
                Window.Flags["Trigger/BodyParts"],
                Window.Flags["Trigger/Prediction"]
            )

            if not (Trigger or Window.Flags["Trigger/AlwaysEnabled"])
            or not TriggerClosest then break end
        end
    end Tortoiseshell.Input:AutomateEnded("Shoot")
end)

Parvus.Utilities.NewThreadLoop(0.5,function()
    local Weapon,Config = GetEquippedWeapon()
    if Weapon and Config then
        if Config.Projectile and Config.Projectile.GravityCorrection then
            GravityCorrection = Config.Projectile.GravityCorrection
        end
        if Window.Flags["BB/AutoFireMode"]
        and (Config.FireModeList and Config.FireModes) then
            Config.FireModes = {Auto = {FireRate = Config.FireModes[Config.FireModeList[1]].FireRate}}
            Config.FireModeList = {"Auto"}
        end
        if Window.Flags["BB/Recoil/Enabled"] and
        (Config.Recoil and Config.Recoil.Default) then
            Config.Recoil.Default.WeaponScale = 
            Config.Recoil.Default.WeaponScale * (Window.Flags["BB/Recoil/WeaponScale"] / 100)

            Config.Recoil.Default.CameraScale = 
            Config.Recoil.Default.CameraScale * (Window.Flags["BB/Recoil/CameraScale"] / 100)

            Config.Recoil.Default.RecoilScale = 
            Config.Recoil.Default.RecoilScale * (Window.Flags["BB/Recoil/RecoilScale"] / 100)
        end
    end
end)
Parvus.Utilities.NewThreadLoop(1/10,function()
    CustomizeWeapon(
        Window.Flags["BB/WC/Enabled"]
        and not Window.Flags["BB/ThirdPerson/Enabled"],
        Window.Flags["BB/WC/Texture"],
        Window.Flags["BB/WC/Color"],
        Window.Flags["BB/WC/Reflectance"],
        Window.Flags["BB/WC/Material"][1]
    )
    CustomizeArms(
        Window.Flags["BB/AC/Enabled"]
        and not Window.Flags["BB/ThirdPerson/Enabled"],
        Window.Flags["BB/AC/Texture"],
        Window.Flags["BB/AC/Color"],
        Window.Flags["BB/AC/Reflectance"],
        Window.Flags["BB/AC/Material"][1]
    )
    CustomizeCharacter(
        Window.Flags["BB/CC/Enabled"]
        and Window.Flags["BB/ThirdPerson/Enabled"],
        Window.Flags["BB/CC/Texture"],
        Window.Flags["BB/CC/Color"],
        Window.Flags["BB/CC/Reflectance"],
        Window.Flags["BB/CC/Material"][1]
    )
end)
Parvus.Utilities.NewThreadLoop(0,function()
    AutoshootHitbox = GetClosestAllFOV(
        Window.Flags["BB/Rage/Autoshoot/Enabled"]
        --or Window.Flags["BB/Rage/TeleGrenade"]
        or Window.Flags["BB/Rage/KnifeAura"],
        Window.Flags["BB/Rage/Autoshoot/VisibilityCheck"],
        Window.Flags["BB/Rage/Autoshoot/DistanceCheck"],
        Window.Flags["BB/Rage/Autoshoot/DistanceLimit"],
        Window.Flags["BB/Rage/Autoshoot/Priority"][1],
        Window.Flags["BB/Rage/Autoshoot/BodyParts"]
    )
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["BB/Rage/Autoshoot/Enabled"] then return end
    Autoshoot(AutoshootHitbox,Window.Flags["BB/Rage/Autoshoot/FireRate"])
end)
Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["BB/Rage/KnifeAura"] then return end
    KnifeAura(AutoshootHitbox,Window.Flags["BB/Rage/Autoshoot/FireRate"])
end)
--[[Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["BB/Rage/AutoGrenade"] then return end
    AutoGrenade()
end)]]
Parvus.Utilities.NewThreadLoop(0,function()
    if not Window.Flags["BB/AntiAim/Enabled"] then return end

    JitterValue = JitterValue == -1 and 1 or -1
    SpinValue = SpinValue >= 2 and 0 or SpinValue + 0.1

    task.wait(Window.Flags["BB/AntiAim/RefreshRate"])
end)

Workspace.Characters.ChildAdded:Connect(function(Child)
    if Child.Name ~= LocalPlayer.Name then return end
    repeat task.wait() until Child.PrimaryPart

    Child.PrimaryPart.CanCollide = not Window.Flags["BB/NoClip"]

    if Window.Flags["BB/ThirdPerson/Enabled"] then
        if Window.Flags["BB/ThirdPerson/Outfit"] then
            task.spawn(function() SetIdentity(2)
                if not CharacterHandlers[Child] then
                    HandleCharacter(Child,LocalPlayer)
                end
            end)
        end

        for Index,Value in pairs(Child:GetDescendants()) do
            if Value:IsA("BasePart") then
                Value.LocalTransparencyModifier = 0
            end
        end
    end
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
