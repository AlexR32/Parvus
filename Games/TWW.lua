local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local BackgroundGui = getrenv().shared.BackgroundGui
repeat task.wait() until BackgroundGui and BackgroundGui.Parent == nil

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

local Aimbot = false
local Regions = {}

local KnownBodyParts = {
    {"Head",true},{"UpperTorso",true},{"LowerTorso",true},

    {"RightUpperArm",false},{"RightLowerArm",false},{"RightHand",false},
    {"LeftUpperArm",false},{"LeftLowerArm",false},{"LeftHand",false},

    {"RightUpperLeg",false},{"RightLowerLeg",false},{"RightFoot",false},
    {"LeftUpperLeg",false},{"LeftLowerLeg",false},{"LeftFoot",false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212),Parvus.Game.Name),
    Position = UDim2.new(0.5,-248 * 3,0.5,-248)
}) do

    --[[local CombatTab = Window:Tab({Name = "Combat"}) do
        local AimbotSection = CombatTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            :Keybind({Flag = "Aimbot/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Thirdperson Mode",Flag = "Aimbot/Thirdperson",Value = false})
            AimbotSection:Toggle({Name = "Always Enabled",Flag = "Aimbot/AlwaysEnabled",Value = false})

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
        end
    end]]
    local VisualsSection = Parvus.Utilities:ESPSection(Window,"Visuals","ESP/Player",true,true,true,true,true,true) do
        VisualsSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
        VisualsSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
        VisualsSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = false})
        VisualsSection:Toggle({Name = "Use Team Color",Flag = "ESP/Player/TeamColor",Value = false})
        VisualsSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
        VisualsSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local TESPSection = MiscTab:Section({Name = "Thunderstruck ESP",Side = "Left"}) do
            TESPSection:Toggle({Name = "Enabled",Flag = "ESP/Thunderstruck/Enabled",Value = false})
            :Colorpicker({Flag = "ESP/Thunderstruck/Color",Value = {1,0,1,0.5,false}})
            TESPSection:Toggle({Name = "Distance Check",Flag = "ESP/Thunderstruck/DistanceCheck",Value = false})
            TESPSection:Slider({Name = "Distance",Flag = "ESP/Thunderstruck/Distance",Min = 25,Max = 5000,Value = 1000,Unit = "studs"})
        end
        local LESPSection = MiscTab:Section({Name = "Legendary ESP",Side = "Right"}) do
            LESPSection:Toggle({Name = "Enabled",Flag = "ESP/Legendary/Enabled",Value = false})
            :Colorpicker({Name = "Color",Flag = "ESP/Legendary/Color",Value = {1,0,1,0.5,false}})
            LESPSection:Toggle({Name = "Distance Check",Flag = "ESP/Legendary/DistanceCheck",Value = false})
            LESPSection:Slider({Name = "Distance",Flag = "ESP/Legendary/Distance",Min = 25,Max = 5000,Value = 1000,Unit = "studs"})
        end
    end Parvus.Utilities:SettingsSection(Window,"End",false)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
--Parvus.Utilities.Drawing.FOVCircle("Aimbot",Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

local function Raycast(Origin,Direction,Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end
local function InEnemyTeam(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
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
local function GetClosest(Enabled,
    TeamCheck,VisibilityCheck,DistanceCheck,
    DistanceLimit,FieldOfView,Priority,BodyParts
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

            local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            if not OnScreen then continue end

            local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            if Priority == "Random" then
                Priority = KnownBodyParts[math.random(#KnownBodyParts)][1]
                BodyPart = Character:FindFirstChild(Priority)
                if not BodyPart then continue end

                BodyPartPosition = BodyPart.Position
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            elseif Priority ~= "Closest" then
                BodyPart = Character:FindFirstChild(Priority)
                if not BodyPart then continue end

                BodyPartPosition = BodyPart.Position
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
        Window.Flags["Aimbot/BodyParts"]
    ),Window.Flags["Aimbot/Sensitivity"] / 100)
end)]]

-- Legendary ESP
for Index,Object in pairs(Workspace.WORKSPACE_Entities.Animals:GetChildren()) do
    if Object:WaitForChild("Health").Value > 300 then print("Adding:",Object.Name)
        Parvus.Utilities.Drawing:AddObject(Object,Object.Name,Object.PrimaryPart,
        "ESP/Legendary","ESP/Legendary",Window.Flags)
    end
end
Workspace.WORKSPACE_Entities.Animals.ChildAdded:Connect(function(Object)
    if Object:WaitForChild("Health").Value > 300 then print("Adding:",Object.Name)
        Parvus.Utilities.Drawing:AddObject(Object,Object.Name,Object.PrimaryPart,
        "ESP/Legendary","ESP/Legendary",Window.Flags)
    end
end)
Workspace.WORKSPACE_Entities.Animals.ChildRemoved:Connect(function(Object)
    Parvus.Utilities.Drawing:RemoveObject(Object)
end)

-- Thunderstruck ESP
for Index,Object in pairs(Workspace.WORKSPACE_Geometry:GetChildren()) do
    if string.find(Object.Name,"REGION_") then
        table.insert(Regions,Object)
    end
end

for Index,Object in pairs(Regions) do
    for Index,Object in pairs(Object:GetDescendants()) do
        Object = Object:FindFirstChild("Strike2",true)
        if Object then
            print(Object.Parent,Object.Parent.Parent)
            Object = Object.Parent.Parent print("Adding:",Object.Name)
            Parvus.Utilities.Drawing:AddObject(Object,Object.Name,Object.PrimaryPart,
            "ESP/Thunderstruck","ESP/Thunderstruck",Window.Flags)
        end
    end
    Object.DescendantAdded:Connect(function(Object)
        if Object:IsA("ParticleEmitter") and Object.Name == "Strike2" then
            print("Adding:",Object.Parent.Parent.Name)
            Parvus.Utilities.Drawing:AddObject(Object.Parent.Parent,
            Object.Parent.Parent.Name,Object.Parent.Parent.PrimaryPart,
            "ESP/Thunderstruck","ESP/Thunderstruck",Window.Flags)
        end
    end)
    Object.DescendantRemoving:Connect(function(Object)
        if Object:IsA("ParticleEmitter") and Object.Name == "Strike2" then
            print("Removing:",Object.Parent.Parent.Name)
            Parvus.Utilities.Drawing:RemoveObject(Object.Parent.Parent)
        end
    end)
end

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
