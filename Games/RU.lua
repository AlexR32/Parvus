--local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

repeat task.wait() until Workspace:FindFirstChild("Drops") and Workspace:FindFirstChild("Projectiles")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local SilentAim,Aimbot,Trigger = nil,false,false
local ProjectileSpeed,ProjectileGravity,GravityCorrection
= 1000,Vector3.new(0,Workspace.Gravity,0),2

local KnownBodyParts = {
    {"Head",true},{"Torso",true},
    {"Right Arm",false},{"Left Arm",false},
    {"Right Leg",false},{"Left Leg",false}
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

            --SilentAimSection:Toggle({Name = "Prediction",Flag = "SilentAim/Prediction",Value = false})

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
        VisualsSection:Toggle({Name = "Use Player Color",Flag = "ESP/Player/TeamColor",Value = false})
        VisualsSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
        VisualsSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
    end Parvus.Utilities:SettingsSection(Window,"End",false)
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

local function Raycast(Origin,Direction,Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end

local function InEnemyTeam(Enabled,Character)
    if not Enabled then return true end

    if Character and Character:FindFirstChild("Team") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Team") then
        return Character.Team.Value ~= LocalPlayer.Character.Team.Value or Character.Team.Value == "None"
    end

    return true
end
local function IsDistanceLimited(Enabled,Distance,Limit)
    if not Enabled then return end
    return Distance >= Limit
end
local function IsVisible(Enabled,Origin,Position,Character)
    if not Enabled then return true end
    return not Raycast(Origin,Position - Origin,
    {Character,LocalPlayer.Character})
end
local function CalculateTrajectory(Origin,Velocity,Time,Gravity)
    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end
local function GetClosest(Enabled,
    TeamCheck,VisibilityCheck,DistanceCheck,
    DistanceLimit,FieldOfView,Priority,BodyParts,
    PredictionEnabled
)

    if not Enabled then return end
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

local function GetKey()
    for Index,Table in pairs(getgc(true)) do
        if type(Table) == "table" and rawget(Table,"ng") then
            local Event = rawget(Table,"ng")
            if typeof(Event) ~= "RBXScriptSignal" then continue end
            local Connection = getconnections(Event)[1]
            return getupvalue(Connection.Function,1)
        end
    end
end

local function CharacterChildAdded(Character)
    Character.ChildAdded:Connect(function(Child)
        if not Child:IsA("Tool") then return end
        local Configuration = Child:WaitForChild("Configuration")
        ProjectileSpeed = Configuration:WaitForChild("BulletSpeed").Value
        ProjectileGravity = Vector3.new(0,Configuration:WaitForChild("BulletGravity").Value,0)
    end)
end

local OldNamecall = nil
OldNamecall = hookmetamethod(game,"__namecall",function(Self,...)
    local Method,Args = getnamecallmethod(),{...}

    if Self.Name == "PewRomote" and Method == "FireServer" and SilentAim
    and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        local Key = GetKey()
        local Command = string.gsub(Args[1],Key,"")

        if Command == "d" or Command == "j" then
            local Direction = SilentAim[3].Position - Args[3]
            Args[4] = Direction.Unit
            Args[8] = Vector3.zero
            Args[10] = 0

            OldNamecall(Self,unpack(Args))
            task.spawn(function() local Time = tick()
                task.wait((SilentAim[3].Position - Args[3]).Magnitude / ProjectileSpeed)
                Self:FireServer(Key .. "j ",Args[6],SilentAim[3].Position,
                SilentAim[3],tick() - Time,Direction,SilentAim[3].Size.Y)
            end)

            return
        end
    end

    return OldNamecall(Self,...)
end)

--[[local RayHit = nil
local function GetRayHit()
    for Index,Value in pairs(getgc(true)) do
        if type(Value) == "table" then
            if rawget(Value,"RayHit") then
                if type(Value.RayHit) == "table" then
                    RayHit = Value.RayHit
                end
            end
        end
    end
end

repeat task.wait() GetRayHit() until RayHit
local FastCastRedux = require(ReplicatedStorage.FastCastRedux)
local OldFastCastRedux = FastCastRedux.new
local function UpdateSilentAim() local OldFire = RayHit.Fire
    RayHit.Fire = function(Self,...) local Args = {...}
        if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
            if Args[5].Owner.Value == LocalPlayer.Name then
                local Camera = Workspace.CurrentCamera
                Args[1] = SilentAim[3]
                Args[2] = SilentAim[3].Position
                Args[3] = (SilentAim[3].Position - Camera.CFrame.Position).Unit
                Args[4] = SilentAim[3].Material
                Args[8] = (SilentAim[3].Position - Camera.CFrame.Position).Unit * 1000
                Args[9] = Vector3.zero
            end
        end return OldFire(Self,unpack(Args))
    end
end UpdateSilentAim()
FastCastRedux.new = function(...)
    local Return = OldFastCastRedux(...)
    RayHit = Return.RayHit
    UpdateSilentAim()
    print("RayHit Hook Updated")
    return Return
end]]

if LocalPlayer.Character then
    CharacterChildAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    CharacterChildAdded(Character)
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
        Window.Flags["Aimbot/Prediction"]
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
        Window.Flags["SilentAim/BodyParts"]
    )
end)
--[[Parvus.Utilities.NewThreadLoop(0,function()
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
end)]]

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
