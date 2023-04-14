local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

local FXModule = nil
--local Functions = nil
for Index,Value in pairs(getgc(true)) do
    if type(Value) == "table" then
        if rawget(Value,"ViewArmor") then
            FXModule = Value
        --[[elseif rawget(Value,"DisableUpperVisuals") then
            Functions = Value]]
        end
    end
end

--local XRay = getupvalue(FXModule.xray,2)
local proceedArmor = getupvalue(FXModule.ViewArmor,7)

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — " .. Parvus.Game.Name,
    Position = UDim2.new(0.05,0,0.5,-173),
    Size = UDim2.new(0,346,0,346)
}) do Window:Watermark({Enabled = true})

    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Flag = "ESP/Player/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/Player/Enemy",Value = {1,0.6666666269302368,1,0,false}})
            GlobalSection:Toggle({Name = "Team Check",Flag = "ESP/Player/TeamCheck",Value = true})
            GlobalSection:Toggle({Name = "Use Team Color",Flag = "ESP/Player/TeamColor",Value = false})
            GlobalSection:Toggle({Name = "Distance Check",Flag = "ESP/Player/DistanceCheck",Value = false})
            GlobalSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
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
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/Player/Name/Autoscale",Value = true})
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
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Right"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/Player/Arrow/Filled",Value = true})
            OoVSection:Toggle({Name = "Outline",Flag = "ESP/Player/Arrow/Outline",Value = true})
            OoVSection:Slider({Name = "Width",Flag = "ESP/Player/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Height",Flag = "ESP/Player/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/Player/Arrow/Radius",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/Player/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/Player/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local FlySection = MiscTab:Section({Name = "Fly",Side = "Left"}) do
            FlySection:Toggle({Name = "Enabled",Flag = "ST/Fly/Enabled",Value = false}):Keybind()
            FlySection:Toggle({Name = "Attach To Camera",Flag = "ST/Fly/Camera",Value = true})
            FlySection:Slider({Name = "Speed",Flag = "ST/Fly/Speed",Min = 100,Max = 500,Value = 100})
        end
        local MiscSection = MiscTab:Section({Name = "Other",Side = "Right"}) do
            MiscSection:Toggle({Name = "XRay",Flag = "ST/XRay",Value = false,Callback = function(Bool)
                local NumBool = Bool and 1 or 0
                for Index,Child in pairs(Workspace:GetChildren()) do
                    if Child:FindFirstChild("Owner") and
                    Child.Owner.Value ~= LocalPlayer.Name
                    and Child.Alive.Value then
                        proceedArmor(Child,NumBool,0)
                        --FXModule.ViewArmor(Child,NumBool,0)
                        --XRay(Child.Main.Hitboxes,Bool,1)
                        --Functions.DisableUpperVisuals(Child)
                    end
                end
            end}):Keybind()
        end
    end Parvus.Utilities:SettingsSection(Window,"RightShift",false)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)
Parvus.Utilities.Drawing:SetupCrosshair(Window.Flags)

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

local function GetPlayerTank(Player)
    local Char = Player:WaitForChild("Char")
    if not Char then return end
    if not Char.Value then return end
    return Char.Value.Parent.Parent.Parent
end

local function PlayerFly(Enabled,Speed,EnableCamera)
    if not Enabled then return end
    local LPTank = GetPlayerTank(LocalPlayer)
    if LPTank and LPTank.PrimaryPart then
        LPTank.PrimaryPart.AssemblyLinearVelocity = Parvus.Utilities.MovementToDirection() * Speed

        if not EnableCamera then return end
        LPTank.PrimaryPart.CFrame = LPTank.PrimaryPart.CFrame * Camera.CFrame.Rotation
        --LPTank:PivotTo(CFrame.new(LPTank:GetPivot().Position) * Camera.CFrame.Rotation)
    end
end

local OldNamecall = nil
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method,Args = getnamecallmethod(),{...}
    if Method == "FireServer" then
        if Self.Name == "XEvent" then
            return
        end
    --[[elseif Method == "addItem" then
        if Args[1] == BodyVelocity
        or Args[1] == BodyGyro then
            return
        end]]
    end
    return OldNamecall(Self, ...)
end)

Parvus.Utilities.NewThreadLoop(0,function()
    PlayerFly(
        Window.Flags["ST/Fly/Enabled"],
        Window.Flags["ST/Fly/Speed"],
        Window.Flags["ST/Fly/Camera"]
    )
end)

for Index,Child in pairs(Workspace:GetChildren()) do
    if not Window.Flags["ST/XRay"] then continue end
    if Child:FindFirstChild("Owner") and
    Child.Owner.Value ~= LocalPlayer.Name
    and Child.Alive.Value then
        proceedArmor(Child,1,0)
        --FXModule.ViewArmor(Child,1,0)
        --XRay(Child.Main.Hitboxes,true,1)
        --Functions.DisableUpperVisuals(Child)
    end
end

Workspace.ChildAdded:Connect(function(Child)
    if not Window.Flags["ST/XRay"] then return end
    task.wait(0.5) if Child:FindFirstChild("Owner") and
    Child.Owner.Value ~= LocalPlayer.Name then
        proceedArmor(Child,1,0)
        --FXModule.ViewArmor(Child,1,0)
        --XRay(Child.Main.Hitboxes,true,1)
        --Functions.DisableUpperVisuals(Child)
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
