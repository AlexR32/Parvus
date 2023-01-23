local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local FrameWork = StarterPlayerScripts.FrameWork
local Functions = require(FrameWork.Functions)

local FXModule = require(FrameWork.NewModules.FXModule)
local proceedArmor = getupvalue(FXModule.ViewArmor,8)

local Window = Parvus.Utilities.UI:Window({
    Name = "Parvus Hub — "..Parvus.Game,
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
            GlobalSection:Slider({Name = "Distance",Flag = "ESP/Player/Distance",Min = 25,Max = 1000,Value = 1000,Unit = "studs"})
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
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Right"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/Player/Arrow/Filled",Value = true})
            OoVSection:Toggle({Name = "Outline",Flag = "ESP/Player/Arrow/Outline",Value = true})
            OoVSection:Slider({Name = "Width",Flag = "ESP/Player/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Height",Flag = "ESP/Player/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/Player/Arrow/Distance",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/Player/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/Player/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HighlightSection = VisualsTab:Section({Name = "Highlights",Side = "Right"}) do
            HighlightSection:Toggle({Name = "Enabled",Flag = "ESP/Player/Highlight/Enabled",Value = false})
            HighlightSection:Slider({Name = "Transparency",Flag = "ESP/Player/Highlight/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            HighlightSection:Colorpicker({Name = "Outline Color",Flag = "ESP/Player/Highlight/OutlineColor",Value = {1,1,0,0.5,false}})
        end
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local FlySection = MiscTab:Section({Name = "Fly",Side = "Left"}) do
            FlySection:Toggle({Name = "Enabled",Flag = "ST/Fly/Enabled",Value = false}):Keybind()
            FlySection:Toggle({Name = "Attach To Camera",Flag = "ST/Fly/Camera",Value = true})
            FlySection:Slider({Name = "Speed",Flag = "ST/Fly/Speed",Min = 100,Max = 500,Value = 100})
        end
        local MiscSection = MiscTab:Section({Name = "Misc",Side = "Right"}) do
            MiscSection:Toggle({Name = "XRay",Flag = "ST/XRay",Value = false,Callback = function(Bool)
                Bool = Bool and 1 or 0
                for Index,Child in pairs(Workspace:GetChildren()) do
                    if Child:FindFirstChild("Owner") and
                    Child.Owner.Value ~= LocalPlayer.Name
                    and Child.Alive.Value then
                        proceedArmor(Child,Bool,0,true)
                        Functions.DisableUpperVisuals(Child)
                    end
                end
            end}):Keybind()
        end
    end Parvus.Utilities.Misc:SettingsSection(Window,"RightShift",false)
end

function GetPlayerTank(Player)
    local Char = Player:WaitForChild("Char")
    if not Char then return end
    if not Char.Value then return end
    return Char.Value.Parent.Parent.Parent
end

Window:SetValue("Background/Offset",296)
Window:LoadDefaultConfig("Parvus")
Window:SetValue("UI/Toggle",Window.Flags["UI/OOL"])

Parvus.Utilities.Misc:SetupWatermark(Window)
Parvus.Utilities.Drawing:SetupCursor(Window.Flags)

--[[local MaxVector = Vector3.new(math.huge,math.huge,math.huge)
local BodyVelocity = Instance.new("BodyVelocity")
local BodyGyro = Instance.new("BodyGyro")
BodyGyro.P = 50000]]

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

local function PlayerFly(Enabled,Speed,EnableCamera)
    if not Enabled then return end
    local LPTank = GetPlayerTank(LocalPlayer)
    if LPTank and LPTank.PrimaryPart then
        if EnableCamera then
            LPTank:PivotTo(CFrame.new(LPTank:GetPivot().Position) * Camera.CFrame.Rotation)
        end
        LPTank.PrimaryPart.AssemblyLinearVelocity = InputToVelocity() * Speed
    end
end

local OldNamecall
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

RunService.Heartbeat:Connect(function()
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
        proceedArmor(Child,1,0,true)
        Functions.DisableUpperVisuals(Child)
    end
end

Workspace.ChildAdded:Connect(function(Child)
    if not Window.Flags["ST/XRay"] then return end
    task.wait(0.5) if Child:FindFirstChild("Owner") and
    Child.Owner.Value ~= LocalPlayer.Name then
        proceedArmor(Child,1,0,true)
        Functions.DisableUpperVisuals(Child)
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
