local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local SilentAim, Aimbot, Trigger = nil, false, false
local ProjectileSpeed, ProjectileGravity, GravityCorrection = 1000, 196.2, 2

local KnownBodyParts = {
    {"Head", true}, {"HumanoidRootPart", true},
    {"Torso", false}, {"UpperTorso", false}, {"LowerTorso", false},

    {"Right Arm", false}, {"RightUpperArm", false}, {"RightLowerArm", false}, {"RightHand", false},
    {"Left Arm", false}, {"LeftUpperArm", false}, {"LeftLowerArm", false}, {"LeftHand", false},

    {"Right Leg", false}, {"RightUpperLeg", false}, {"RightLowerLeg", false}, {"RightFoot", false},
    {"Left Leg", false}, {"LeftUpperLeg", false}, {"LeftLowerLeg", false}, {"LeftFoot", false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212), Parvus.Game.Name),
    Position = UDim2.new(0.5, -248 * 3, 0.5, -248)
}) do

    local CombatTab = Window:Tab({Name = "Combat"}) do
        local PredictionSection = CombatTab:Section({Name = "Prediction", Side = "Left"}) do
            PredictionSection:Slider({Name = "Velocity", Flag = "Prediction/Velocity", Min = 1, Max = 10000, Value = 1000, Callback = function(Number)
                ProjectileSpeed = Number
            end})
            PredictionSection:Slider({Name = "Gravity", Flag = "Prediction/Gravity", Min = 0, Max = 1000, Precise = 1, Value = 196.2, Callback = function(Number)
                ProjectileGravity = Number
            end})
            PredictionSection:Slider({Name = "Gravity Correction", Flag = "Prediction/Gravity", Min = 1, Max = 5, Value = 2, Callback = function(Number)
                GravityCorrection = Number
            end})
        end
        local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled", Flag = "Aimbot/Enabled", Value = false})
            :Keybind({Flag = "Aimbot/Keybind", Value = "MouseButton2", Mouse = true, DisableToggle = true,
            Callback = function(Key, KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Always Enabled", Flag = "Aimbot/AlwaysEnabled", Value = false})
            AimbotSection:Toggle({Name = "Prediction", Flag = "Aimbot/Prediction", Value = false})

            AimbotSection:Toggle({Name = "Team Check", Flag = "Aimbot/TeamCheck", Value = false})
            AimbotSection:Toggle({Name = "Distance Check", Flag = "Aimbot/DistanceCheck", Value = false})
            AimbotSection:Toggle({Name = "Visibility Check", Flag = "Aimbot/VisibilityCheck", Value = false})
            AimbotSection:Slider({Name = "Sensitivity", Flag = "Aimbot/Sensitivity", Min = 0, Max = 100, Value = 20, Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View", Flag = "Aimbot/FOV/Radius", Min = 0, Max = 500, Value = 100, Unit = "r"})
            AimbotSection:Slider({Name = "Distance Limit", Flag = "Aimbot/DistanceLimit", Min = 25, Max = 1000, Value = 250, Unit = "studs"})

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
            SilentAimSection:Dropdown({HideName = true, Flag = "SilentAim/Mode", List = {
                {Name = "FindPartOnRayWithIgnoreList", Mode = "Toggle"},
                {Name = "FindPartOnRayWithWhitelist", Mode = "Toggle"},
                {Name = "WorldToViewportPoint", Mode = "Toggle"},
                {Name = "WorldToScreenPoint", Mode = "Toggle"},
                {Name = "ViewportPointToRay", Mode = "Toggle"},
                {Name = "ScreenPointToRay", Mode = "Toggle"},
                {Name = "FindPartOnRay", Mode = "Toggle"},
                {Name = "Raycast", Mode = "Toggle"},
                {Name = "Target", Mode = "Toggle"},
                {Name = "Hit", Mode = "Toggle"}
            }})

            SilentAimSection:Toggle({Name = "Enabled", Flag = "SilentAim/Enabled", Value = false}):Keybind({Mouse = true, Flag = "SilentAim/Keybind"})

            SilentAimSection:Toggle({Name = "Prediction", Flag = "SilentAim/Prediction", Value = false})

            SilentAimSection:Toggle({Name = "Team Check", Flag = "SilentAim/TeamCheck", Value = false})
            SilentAimSection:Toggle({Name = "Distance Check", Flag = "SilentAim/DistanceCheck", Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check", Flag = "SilentAim/VisibilityCheck", Value = false})
            SilentAimSection:Slider({Name = "Hit Chance", Flag = "SilentAim/HitChance", Min = 0, Max = 100, Value = 100, Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View", Flag = "SilentAim/FOV/Radius", Min = 0, Max = 500, Value = 100, Unit = "r"})
            SilentAimSection:Slider({Name = "Distance Limit", Flag = "SilentAim/DistanceLimit", Min = 25, Max = 1000, Value = 250, Unit = "studs"})

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
            TriggerSection:Toggle({Name = "Prediction", Flag = "Trigger/Prediction", Value = false})

            TriggerSection:Toggle({Name = "Team Check", Flag = "Trigger/TeamCheck", Value = false})
            TriggerSection:Toggle({Name = "Distance Check", Flag = "Trigger/DistanceCheck", Value = false})
            TriggerSection:Toggle({Name = "Visibility Check", Flag = "Trigger/VisibilityCheck", Value = false})

            TriggerSection:Slider({Name = "Click Delay", Flag = "Trigger/Delay", Min = 0, Max = 1, Precise = 2, Value = 0.15, Unit = "sec"})
            TriggerSection:Slider({Name = "Distance Limit", Flag = "Trigger/DistanceLimit", Min = 25, Max = 1000, Value = 250, Unit = "studs"})
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
    local VisualsSection = Parvus.Utilities:ESPSection(Window, "Visuals", "ESP/Player", true, true, true, true, true, true) do
        VisualsSection:Colorpicker({Name = "Ally Color", Flag = "ESP/Player/Ally", Value = {0.3333333432674408, 0.6666666269302368, 1, 0, false}})
        VisualsSection:Colorpicker({Name = "Enemy Color", Flag = "ESP/Player/Enemy", Value = {1, 0.6666666269302368, 1, 0, false}})
        VisualsSection:Toggle({Name = "Team Check", Flag = "ESP/Player/TeamCheck", Value = false})
        VisualsSection:Toggle({Name = "Use Team Color", Flag = "ESP/Player/TeamColor", Value = false})
        VisualsSection:Toggle({Name = "Distance Check", Flag = "ESP/Player/DistanceCheck", Value = false})
        VisualsSection:Slider({Name = "Distance", Flag = "ESP/Player/Distance", Min = 25, Max = 1000, Value = 250, Unit = "studs"})
    end
    Parvus.Utilities:SettingsSection(Window, "RightShift", false)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("SilentAim", Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

local function Raycast(Origin, Direction, Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin, Direction, WallCheckParams)
end
local function InEnemyTeam(Enabled, Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
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
    return Origin + Velocity * Time + Gravity * Time * Time / GravityCorrection
end
local function GetClosest(Enabled,
    TeamCheck, VisibilityCheck, DistanceCheck,
    DistanceLimit, FieldOfView, Priority, BodyParts,
    PredictionEnabled
)

    if not Enabled then return end
    local CameraPosition, Closest = Camera.CFrame.Position, nil
    for Index, Player in ipairs(PlayerService:GetPlayers()) do
        if Player == LocalPlayer then continue end

        local Character = Player.Character if not Character then continue end
        if not InEnemyTeam(TeamCheck, Player) then continue end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then continue end if Humanoid.Health <= 0 then continue end

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

local OldIndex = nil
OldIndex = hookmetamethod(game, "__index", function(Self, Index)
    if checkcaller() then return OldIndex(Self, Index) end

    if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        local Mode = Window.Flags["SilentAim/Mode"]
        if Self == Mouse then
            if Index == "Target" and table.find(Mode, Index) then
                return SilentAim[3]
            elseif Index== "Hit" and table.find(Mode, Index) then
                return SilentAim[3].CFrame
            end
        end
    end

    return OldIndex(Self, Index)
end)

local OldNamecall = nil
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    if checkcaller() then return OldNamecall(Self, ...) end

    if SilentAim and math.random(100) <= Window.Flags["SilentAim/HitChance"] then
        local Args, Method, Mode = {...}, getnamecallmethod(), Window.Flags["SilentAim/Mode"]

        if Self == Workspace then
            if Method == "Raycast" and table.find(Mode, Method) then
                Args[2] = SilentAim[3].Position - Args[1]
                return OldNamecall(Self, unpack(Args))
            elseif (Method == "FindPartOnRayWithIgnoreList" and table.find(Mode, Method))
            or (Method == "FindPartOnRayWithWhitelist" and table.find(Mode, Method))
            or (Method == "FindPartOnRay" and table.find(Mode, Method)) then
                Args[1] = Ray.new(Args[1].Origin, SilentAim[3].Position - Args[1].Origin)
                return OldNamecall(Self, unpack(Args))
            end
        elseif Self == Camera then
            if (Method == "ScreenPointToRay" and table.find(Mode, Method))
            or (Method == "ViewportPointToRay" and table.find(Mode, Method)) then
                return Ray.new(SilentAim[3].Position, SilentAim[3].Position - Camera.CFrame.Position)
            elseif (Method == "WorldToScreenPoint" and table.find(Mode, Method))
            or (Method == "WorldToViewportPoint" and table.find(Mode, Method)) then
                Args[1] = SilentAim[3].Position return OldNamecall(Self, unpack(Args))
            end
        end
    end

    return OldNamecall(Self, ...)
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
        Window.Flags["SilentAim/BodyParts"],
        Window.Flags["SilentAim/Prediction"]
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
    )

    if not TriggerClosest then return end
    task.wait(Window.Flags["Trigger/Delay"])
    mouse1press()

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
            )

            if not TriggerClosest or not Trigger then break end
        end
    end

    mouse1release()
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

for Index, Player in pairs(PlayerService:GetPlayers()) do
    if Player == LocalPlayer then continue end
    Parvus.Utilities.Drawing:AddESP(Player, "Player", "ESP/Player", Window.Flags)
end
PlayerService.PlayerAdded:Connect(function(Player)
    Parvus.Utilities.Drawing:AddESP(Player, "Player", "ESP/Player", Window.Flags)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    Parvus.Utilities.Drawing:RemoveESP(Player)
end)
