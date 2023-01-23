local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local BackgroundGui = getrenv().shared.BackgroundGui
repeat task.wait() until BackgroundGui and BackgroundGui.Parent == nil

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local Aimbot = false

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Game,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})

    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local GlobalSection = AimAssistTab:Section({Name = "Global",Side = "Right"}) do
            GlobalSection:Toggle({Name = "Team Check",Flag = "TeamCheck",Value = false})
        end
        local AFOVSection = AimAssistTab:Section({Name = "Aimbot FOV Circle",Side = "Right"}) do
            AFOVSection:Toggle({Name = "Enabled",Flag = "Aimbot/Circle/Enabled",Value = true})
            AFOVSection:Toggle({Name = "Filled",Flag = "Aimbot/Circle/Filled",Value = false})
            AFOVSection:Colorpicker({Name = "Color",Flag = "Aimbot/Circle/Color",Value = {1,0.66666662693024,1,0.25,false}})
            AFOVSection:Slider({Name = "NumSides",Flag = "Aimbot/Circle/NumSides",Min = 3,Max = 100,Value = 14})
            AFOVSection:Slider({Name = "Thickness",Flag = "Aimbot/Circle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
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
        end Parvus.Utilities.Misc:LightingSection(VisualsTab,"Right")
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
    end Parvus.Utilities.Misc:SettingsSection(Window,"RightShift",false)
end

Window:SetValue("Background/Offset",296)
Window:LoadDefaultConfig("Parvus")
Window:SetValue("UI/Toggle",Window.Flags["UI/OOL"])

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Misc:SetupLighting(Window.Flags)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:FOVCircle("Aimbot",Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

local function Raycast(Origin,Direction,Table)
    WallCheckParams.FilterDescendantsInstances = Table
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end

local function TeamCheck(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
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

local function GetClosest(Enabled,FOV,DFOV,TC,BP,WC,DC,MD)
    -- FieldOfView,DynamicFieldOfView,TeamCheck
    -- BodyParts,WallCheck,DistanceCheck,MaxDistance

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
                if WallCheck(WC,BodyPart,Character) and DistanceCheck(DC,Distance,MD) then
                    local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPart.Position)

                    local NewFOV = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if OnScreen and NewFOV <= FOV then FOV,Closest = NewFOV,{Player,Character,BodyPart,ScreenPosition} end
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
        (Hitbox[4].X - Mouse.X) * Smoothness,
        (Hitbox[4].Y - Mouse.Y) * Smoothness
    )
end

RunService.Heartbeat:Connect(function()
    if Aimbot then
        AimAt(GetClosest(
            Window.Flags["Aimbot/Enabled"],
            Window.Flags["Aimbot/FieldOfView"],
            Window.Flags["Aimbot/DynamicFOV"],
            Window.Flags["TeamCheck"],
            Window.Flags["Aimbot/BodyParts"],
            Window.Flags["Aimbot/WallCheck"],
            Window.Flags["Aimbot/DistanceCheck"],
            Window.Flags["Aimbot/Distance"]
        ),Window.Flags["Aimbot/Smoothness"] / 100)
    end
end)

-- Thunderstruck, Legendary ESP
local Regions = {}
for Index,Instance in pairs(Workspace.WORKSPACE_Geometry:GetChildren()) do
    if string.find(Instance.Name,"REGION_") then
        table.insert(Regions,Instance)
    end
end
for Index,Instance in pairs(Workspace.WORKSPACE_Entities.Animals:GetChildren()) do
    if Instance:WaitForChild("Health").Value > 300 then print(Instance.Name)
        Parvus.Utilities.Drawing:AddObject(Instance,Instance.Name,Instance.PrimaryPart,
        "ESP/Legendary","ESP/Legendary",Window.Flags)
    end
end
Workspace.WORKSPACE_Entities.Animals.ChildAdded:Connect(function(Instance)
    if Instance:WaitForChild("Health").Value > 300 then print(Instance.Name)
        Parvus.Utilities.Drawing:AddObject(Instance,Instance.Name,Instance.PrimaryPart,
        "ESP/Legendary","ESP/Legendary",Window.Flags)
    end
end)
Workspace.WORKSPACE_Entities.Animals.ChildRemoved:Connect(function(Instance)
    Parvus.Utilities.Drawing:RemoveObject(Instance)
end)
for Index,Instance in pairs(Regions) do
    for Index,Instance in pairs(Instance.Trees:GetChildren()) do
        if Instance:FindFirstChild("Strike2",true) then print(Instance.Name)
            Parvus.Utilities.Drawing:AddObject(Instance,Instance.Name,Instance.PrimaryPart,
            "ESP/Thunderstruck","ESP/Thunderstruck",Window.Flags)
        end
    end
    for Index,Instance in pairs(Instance.Vegetation:GetChildren()) do
        if Instance:FindFirstChild("Strike2",true) then print(Instance.Name)
            Parvus.Utilities.Drawing:AddObject(Instance,Instance.Name,Instance.PrimaryPart,
            "ESP/Thunderstruck","ESP/Thunderstruck",Window.Flags)
        end
    end
    Instance.Trees.DescendantAdded:Connect(function(Instance)
        if Instance:IsA("ParticleEmitter") and Instance.Name == "Strike2" then
            print(Instance.Parent.Parent.Name)
            Parvus.Utilities.Drawing:AddObject(Instance.Parent.Parent,
            Instance.Parent.Parent.Name,Instance.Parent.Parent.PrimaryPart,
            "ESP/Thunderstruck","ESP/Thunderstruck",Window.Flags)
        end
    end)
    Instance.Vegetation.DescendantAdded:Connect(function()
        if Instance:IsA("ParticleEmitter") and Instance.Name == "Strike2" then
            print(Instance.Parent.Parent.Name)
            Parvus.Utilities.Drawing:AddObject(Instance.Parent.Parent,
            Instance.Parent.Parent.Name,Instance.Parent.Parent.PrimaryPart,
            "ESP/Thunderstruck","ESP/Thunderstruck",Window.Flags)
        end
    end)
    Instance.Trees.DescendantRemoving:Connect(function(Instance)
        if Instance:IsA("ParticleEmitter") and Instance.Name == "Strike2" then
            print(Instance.Parent.Parent.Name)
            Parvus.Utilities.Drawing:RemoveObject(Instance.Parent.Parent)
        end
    end)
    Instance.Vegetation.DescendantRemoving:Connect(function(Instance)
        if Instance:IsA("ParticleEmitter") and Instance.Name == "Strike2" then
            print(Instance.Parent.Parent.Name)
            Parvus.Utilities.Drawing:RemoveObject(Instance.Parent.Parent)
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
