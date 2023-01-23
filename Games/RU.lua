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

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
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
            AimbotSection:Slider({Name = "Distance",Flag = "Aimbot/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            AimbotSection:Dropdown({Name = "Body Parts",Flag = "Aimbot/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Torso",Mode = "Toggle"}
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
            SilentAimSection:Toggle({Name = "Prediction",Flag = "SilentAim/Prediction",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/WallCheck",Value = false})
            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Dynamic FOV",Flag = "SilentAim/DynamicFOV",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100})
            SilentAimSection:Slider({Name = "Distance",Flag = "SilentAim/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = {
                {Name = "Head",Mode = "Toggle",Value = true},
                {Name = "Torso",Mode = "Toggle"}
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
                {Name = "Torso",Mode = "Toggle"}
            }})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = true})
            GlobalSection:Toggle({Name = "Use Player Color",Flag = "ESP/Player/TeamColor",Value = false}):ToolTip("Same As Team Color")
            GlobalSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
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
        end
    end Parvus.Utilities.Misc:SettingsSection(Window,"RightShift",false)
end

Window:SetValue("Background/Offset",296)
Window:LoadDefaultConfig("Parvus")
Window:SetValue("UI/Toggle",Window.Flags["UI/OOL"])

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("SilentAim",Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

local function Raycast(Origin,Direction,Table)
    WallCheckParams.FilterDescendantsInstances = Table
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end

local function TeamCheck(Character)
    if Character and Character:FindFirstChild("Team") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Team") then
        return Character.Team.Value ~= LocalPlayer.Character.Team.Value
        or Character.Team.Value == "None"
    end
    return true
end

local function DistanceCheck(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance <= MaxDistance
end

local function WallCheck(Enabled,Hitbox,Character)
    if not Enabled then return true end
    return not Raycast(Camera.CFrame.Position,
    Hitbox.Position - Camera.CFrame.Position,
    {LocalPlayer.Character,Character})
end

local function CalculateTrajectory(Origin,Velocity,Time,Gravity)
    local PredictedPosition = Origin + Velocity * Time
    local Delta = (PredictedPosition - Origin).Magnitude
    Time = Time + Delta / ProjectileSpeed
    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end

--[[local LiveRagdolls = Workspace.LiveRagdolls
local function GetClosest(Enabled,FOV,DFOV,BP,WC,DC,MD,PE)
    -- FieldOfView,DynamicFieldOfView,BodyParts
    -- WallCheck,DistanceCheck,MaxDistance
    -- PredictionEnabled

    if not Enabled then return end local Closest = nil
    FOV = DFOV and FOV * (1 + (80 - Camera.FieldOfView) / 100) or FOV

    for Index,NPC in pairs(LiveRagdolls:GetChildren()) do
        if NPC == LocalPlayer.Character then continue end
        for Index,BodyPart in pairs(BP) do
            BodyPart = NPC:FindFirstChild(BodyPart) if not BodyPart then continue end
            local Distance = (BodyPart.Position - Camera.CFrame.Position).Magnitude
            if WallCheck(WC,Camera.CFrame,BodyPart,NPC) and DistanceCheck(DC,Distance,MD) then
                local BPPosition = PE and CalculateTrajectory(BodyPart.Position,BodyPart.AssemblyLinearVelocity,
                Distance / ProjectileSpeed,ProjectileGravity) or BodyPart.Position
                local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BPPosition)
                local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if OnScreen and Magnitude <= FOV then FOV,ClosestHitbox = Magnitude,{NPC,NPC,BodyPart,BPPosition,Distance,ScreenPosition} end
            end
        end
    end

    return ClosestHitbox
end]]

local function GetClosest(Enabled,FOV,DFOV,BP,WC,DC,MD,PE)
    -- FieldOfView,DynamicFieldOfView,BodyParts
    -- WallCheck,DistanceCheck,MaxDistance
    -- PredictionEnabled

    if not Enabled then return end local Closest = nil
    FOV = DFOV and FOV * (1 + (80 - Camera.FieldOfView) / 100) or FOV

    for Index,Player in pairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end
        local Character = Player.Character

        if Character and TeamCheck(Character) then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid then continue end if Humanoid.Health <= 0 then continue end

            for Index,BodyPart in pairs(BP) do
                BodyPart = Character:FindFirstChild(BodyPart) if not BodyPart then continue end
                local Distance = (BodyPart.Position - Camera.CFrame.Position).Magnitude
                if WallCheck(WC,BodyPart,Character) and DistanceCheck(DC,Distance,MD) then
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

local function CharacterChildAdded(Character)
    Character.ChildAdded:Connect(function(Child)
        if Child:IsA("Tool") then
            local Configuration = Child:WaitForChild("Configuration",5)
            ProjectileSpeed = Configuration:WaitForChild("BulletSpeed",5).Value
            ProjectileGravity = Configuration:WaitForChild("BulletGravity",5).Value
        end
    end)
end

if LocalPlayer.Character then
    CharacterChildAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    CharacterChildAdded(Character)
end)

-- Testing
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method,Args = getnamecallmethod(),{...}

    if Self.Name == "PewRomote" and (string.sub(Args[1],11) == "d" or string.sub(Args[1],11) == "j") and
    SilentAim and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
        local Direction = (SilentAim[4] - Args[3]) Args[4] = Direction.Unit
        Args[10] = 0 Args[8] = Vector3.zero local Thing = OldNamecall(Self,unpack(Args))
        Self:FireServer(string.sub(Args[1],1,10) .. "j ",Args[6],SilentAim[4],
        SilentAim[3],0.02,Direction.Unit * Direction.Magnitude,SilentAim[3].Size.Y)
        return Thing
    end

    return OldNamecall(Self, ...)
end)

--[[local RayHit
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
        if SilentAim and math.random(0,100) <= Window.Flags["SilentAim/HitChance"] then
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

RunService.Heartbeat:Connect(function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"],
        Window.Flags["SilentAim/FieldOfView"],
        Window.Flags["SilentAim/DynamicFOV"],
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
