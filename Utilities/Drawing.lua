local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Declarations
local Cos = math.cos
local Rad = math.rad
local Sin = math.sin
local Tan = math.tan
local Abs = math.abs
local Deg = math.deg
local Atan2 = math.atan2
local Clamp = math.clamp
local Floor = math.floor
local Clear = table.clear

local WTVP = Camera.WorldToViewportPoint
local FindFirstChild = Workspace.FindFirstChild
local FindFirstChildOfClass = Workspace.FindFirstChildOfClass
local FindFirstChildWhichIsA = Workspace.FindFirstChildWhichIsA
local PointToObjectSpace = CFrame.identity.PointToObjectSpace

local UDimNew = UDim.new
local V2New = Vector2.new
local UDim2New = UDim2.new
local UDim2FromOffset = UDim2.fromOffset
local ColorNew = Color3.new
local RedColor = ColorNew(1,0,0)
local GreenColor = ColorNew(0,1,0)
local YellowColor = ColorNew(1,1,0)
local WhiteColor = ColorNew(1,1,1)
local BlackColor = ColorNew(0,0,0)
local LerpColor = BlackColor.Lerp
--local Fonts = Drawing.Fonts

local DrawingLibrary = {
    ESP = {},ObjectESP = {},CS = ColorSequence.new({
        ColorSequenceKeypoint.new(0,RedColor),
        ColorSequenceKeypoint.new(0.5,YellowColor),
        ColorSequenceKeypoint.new(1,GreenColor)
    })
}

local CharacterSize = nil--Vector3.new(4,5,1)
local FrameRate = 1/60 --1/30

if not RESPContainer then
    getgenv().RESPContainer = InsertService:LoadLocalAsset("rbxassetid://11313408229")
    RESPContainer.Parent = CoreGui
end

local function RESPNew()
    local RESPObject = Instance.new("Folder")
    RESPContainer.Storage.Box:Clone().Parent = RESPObject
    RESPContainer.Storage.Arrow:Clone().Parent = RESPObject
    RESPContainer.Storage.Tracer:Clone().Parent = RESPObject
    RESPContainer.Storage.HeadDot:Clone().Parent = RESPObject
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = RESPObject

    RESPObject.Name = "RESPObject"
    RESPObject.Parent = RESPContainer
    return RESPObject
end
local function DrawingNew(Type,Properties)
    local DrawingObject = Drawing.new(Type)
    for Property,Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end

    return DrawingObject
end

local function GetFlag(F,F1,F2)
    return F[F1..F2]
end
local function GetDistance(Position)
    return (Position - Camera.CFrame.Position).Magnitude
end
local function CheckDistance(Enabled,P1,P2)
    if not Enabled then return true end
    return P1 >= P2
end
local function ClampDistance(Enabled,P1,P2)
    if not Enabled then return P1 end
    return Clamp(1 / P2 * 1000,1,P1)
end
--[[local function DynamicFOV(Enabled,FOV)
    if not Enabled then return FOV end
    --return FOV / (Camera.FieldOfView / 80)
    return FOV * (1 + (80 - Camera.FieldOfView) / 100)
end]]
local function ToUDim2(Vector)
    return UDim2.fromOffset(Vector.X,Vector.Y)
end
local function AntiAliasingXY(X,Y)
    return V2New(Floor(X),Floor(Y))
end
local function AntiAliasingP(P)
    return V2New(Floor(P.X),Floor(P.Y))
end
local function WorldToScreen(WorldPosition)
    local Screen,OnScreen = WTVP(Camera,WorldPosition)
    return V2New(Screen.X,Screen.Y),OnScreen,Screen.Z
end

-- this one from devforum too
local function CalculateLine(A,B,Thickness)
	local Position = (A + B) / 2
	local Distance = (A - B).Magnitude
	local Rotation = Deg(Atan2(A.Y - B.Y,A.X - B.X))
    local Size = UDim2FromOffset(Distance,Thickness)
    Position = UDim2FromOffset(Position.X,Position.Y)
	return Position,Rotation,Size
end
-- evalCS by devforum guy
local function EvalHealth(Percent)
    local CS = DrawingLibrary.CS
	if Percent == 0 then return CS.Keypoints[1].Value end
	if Percent == 1 then return CS.Keypoints[#CS.Keypoints].Value end

	for Index = 1, #CS.Keypoints - 1 do
		local KIndex = CS.Keypoints[Index]
		local NIndex = CS.Keypoints[Index + 1]
		if Percent >= KIndex.Time and Percent < NIndex.Time then
			local Alpha = (Percent - KIndex.Time) / (NIndex.Time - KIndex.Time)
			return KIndex.Value:Lerp(NIndex.Value,Alpha)
		end
	end
end
-- this one from devforum
local RIGHT = "rbxassetid://319692151"
local LEFT = "rbxassetid://319692171"
local function CalculateTriangle(Triangle1, Triangle2, A, B, C)
	local AB,AC,BC = B - A,C - A,C - B
	local ABD,ACD,BCD = AB:Dot(AB),AC:Dot(AC),BC:Dot(BC)

	if ABD > ACD and ABD > BCD then
		C,A = A,C
	elseif ACD > BCD and ACD > ABD then
		A,B = B,A
	end

	AB,AC,BC = B - A, C - A, C - B
	local M1,M2 = (A + B) / 2,(A + C) / 2

	local Unit = BC.Unit
	local Height = Unit:Cross(AB)
	local Flip = Height >= 0

	local Theta = Deg(Atan2(Unit.Y, Unit.X)) + (Flip and 0 or 180)
	
    Triangle1.Rotation = Theta
    Triangle1.Image = Flip and LEFT or RIGHT
	Triangle1.Position = UDim2FromOffset(M2.X,M2.Y)
	Triangle1.Size = UDim2FromOffset(Abs(Unit:Dot(AC)),Height)

    Triangle2.Rotation = Theta
    Triangle2.Image = Flip and RIGHT or LEFT
	Triangle2.Position = UDim2FromOffset(M1.X,M1.Y)
	Triangle2.Size = UDim2FromOffset(Abs(Unit:Dot(AB)),Height)
end
-- CalculateBox by mickeyrbx (highly edited)
local function CalculateBox(Model,Position,Distance)
    local Size = CharacterSize or Model:GetExtentsSize()
    return Position,Size * 1 / (Distance * Tan(Rad(Camera.FieldOfView / 2)) * 2) * 1000
end
-- Offscreen Arrows by Blissful
local function GetRelative(Position)
    local Relative = PointToObjectSpace(Camera.CFrame,Position)
    return V2New(-Relative.X,-Relative.Z)
end
local function RotateVector(Vector,Radians)
    local C,S = Cos(Radians),Sin(Radians)

    return V2New(
        Vector.X * C - Vector.Y * S,
        Vector.X * S + Vector.Y * C
    )
end
local function RelativeToCenter(Size)
    return Camera.ViewportSize / 2 - Size
end

function GetCharacter(Target,Mode)
    if Mode == "Player" then
        local Character = Target.Character if not Character then return end
        return Character,FindFirstChild(Character,"HumanoidRootPart")
    else
        return Target,FindFirstChild(Target,"HumanoidRootPart")
    end
end
function GetHealth(Target,Character,Mode)
    local Humanoid = FindFirstChildOfClass(Character,"Humanoid")
    if not Humanoid then return 0,0,false end

    return Humanoid.Health,
    Humanoid.MaxHealth,
    Humanoid.Health > 0
end
function GetTeam(Target,Character,Mode)
    if Mode == "Player" then
        if Target.Neutral then return true,WhiteColor end
        return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
    else
        return true,WhiteColor
    end
end
function GetWeapon(Target,Character,Mode)
    return "N/A"
end

if game.GameId == 1168263273 or game.GameId == 3360073263 then -- Bad Business
    local TeamService = game:GetService("Teams")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Tortoiseshell = getupvalue(require(ReplicatedStorage.TS),2)
    local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter,1)

    local function GetPlayerTeam(Player)
        for Index,Team in pairs(TeamService:GetChildren()) do
            if FindFirstChild(Team.Players,Player.Name) then
                return Team.Name
            end
        end
    end

    function GetCharacter(Target,Mode)
        local Character = Characters[Target]
        if not Character or Character.Parent == nil then return end
        return Character,Character.PrimaryPart
    end
    function GetHealth(Target,Character,Mode)
        local Health = Character.Health
        return Health.Value,Health.MaxHealth.Value,Health.Value > 0
    end
    function GetTeam(Target,Character,Mode)
        local Team,LocalTeam = GetPlayerTeam(Target),GetPlayerTeam(LocalPlayer)
        return LocalTeam ~= Team or Team == "FFA",Tortoiseshell.Teams.Colors[Team]
    end
    function GetWeapon(Target,Character,Mode)
        return tostring(Character.Backpack.Equipped.Value or "Hands")
    end
elseif game.GameId == 1586272220 then -- Steel Titans
    local function GetPlayerTank(Player)
        local Character = FindFirstChild(Player,"Char")
        if not Character then return end
        if Character.Value == nil then return end
        return Character.Value.Parent.Parent.Parent
    end

    function GetCharacter(Target,Mode)
        local PlayerTank = GetPlayerTank(Target)
        if not PlayerTank then return end
        return PlayerTank,PlayerTank.PrimaryPart
    end
    function GetHealth(Target,Character,Mode)
        return Character.Stats.Health.Value,
        Character.Stats.Health.Orig.Value,
        Character.Stats.Health.Value > 0
    end
elseif game.GameId == 580765040 then -- RAGDOLL UNIVERSE
    function GetCharacter(Target,Mode)
        local Character = Target.Character
        if not Character then return end
        return Character,Character.PrimaryPart
    end
    function GetTeam(Target,Character,Mode)
        local LocalCharacter = LocalPlayer.Character
        if not LocalCharacter then return false,Character.PrimaryPart.Color end
        if FindFirstChild(LocalCharacter,"Team") and FindFirstChild(Character,"Team") then
            return Character.Team.Value ~= LocalCharacter.Team.Value
            or Character.Team.Value == "None",Character.PrimaryPart.Color
        end

        return false,Character.PrimaryPart.Color
    end
    function GetWeapon(Target,Character,Mode)
        return tostring(FindFirstChildOfClass(Character,"Tool") or "Hands")
    end
elseif game.GameId == 358276974 or game.GameId == 3495983524 then -- Apocalypse Rising 2
    CharacterSize = Vector3.new(4,5,1)
    function GetHealth(Target,Character,Mode)
        local Health = Target.Stats.Health
        local Bonus = Target.Stats.HealthBonus

        return Health.Value + Bonus.Value,
        100 + Bonus.Value,Health.Value > 0
    end

    function GetWeapon(Target,Character,Mode)
        return tostring(Character.Animator.EquippedItem.ItemName.Value or "Hands")
    end

    -- TODO: Squad GetTeam function
    --function GetTeam(Target,Character,Mode) end
elseif game.GameId == 1054526971 then -- Blackhawk Rescue Mission 5
    local function RequireModule(Name)
        for Index, Instance in pairs(getloadedmodules()) do
            if Instance.Name == Name then
                return require(Instance)
            end
        end
    end

    repeat task.wait() until RequireModule("RoundInterface")
    local RoundInterface = RequireModule("RoundInterface")

    local function GetSkirmishTeam(Player)
        for TeamName,TeamData in pairs(RoundInterface.Teams) do
            for UserId,UserData in pairs(TeamData.Players) do
                if tonumber(UserId) == Player.UserId then
                    return TeamName
                end
            end
        end
    end
    function GetTeam(Target,Character,Mode)
        if Mode == "Player" then
            return not Target.Neutral and LocalPlayer.Team ~= Target.Team
            or GetSkirmishTeam(LocalPlayer) ~= GetSkirmishTeam(Target),WhiteColor
        else
            return not FindFirstChildWhichIsA(Character,"ProximityPrompt",true),WhiteColor
        end
    end
end

function DrawingLibrary.AddObject(Self,Object,ObjectName,ObjectPosition,GlobalFlag,Flag,Flags)
    if Self.ObjectESP[Object] then return end


    --setidentity(6)
    --setthreadidentity(6)
    Self.ObjectESP[Object] = {
        Target = {Name = ObjectName,Position = ObjectPosition},
        Flag = Flag,GlobalFlag = GlobalFlag,Flags = Flags,
        IsBasePart = typeof(ObjectPosition) ~= "Vector3",

        Name = RESPContainer.Storage.ObjectName:Clone()
    }

    Self.ObjectESP[Object].Name.Parent = RESPContainer
    if Self.ObjectESP[Object].IsBasePart then
        Self.ObjectESP[Object].Target.RootPart = ObjectPosition
        Self.ObjectESP[Object].Target.Position = ObjectPosition.Position
    end
end
function DrawingLibrary.AddESP(Self,Target,Mode,Flag,Flags)
    if Self.ESP[Target] then return end

    Self.ESP[Target] = {
        Target = {},Mode = Mode,
        Flag = Flag,Flags = Flags,
        RESP = RESPNew()
    }
end

function DrawingLibrary.RemoveESP(Self,Target)
    local ESP = Self.ESP[Target]
    if not ESP then return end
    ESP.RESP:Destroy()

    Clear(Self.ESP[Target])
    Self.ESP[Target] = nil
end

function DrawingLibrary.RemoveObject(Self,Target)
    local ESP = Self.ObjectESP[Target]
    if not ESP then return end
    ESP.Name:Destroy()

    Clear(Self.ObjectESP[Target])
    Self.ObjectESP[Target] = nil
end

function DrawingLibrary.SetupCursor(Window)
    local Cursor = DrawingNew("Image",{
        Size = V2New(64,64) / 1.5,
        Data = Parvus.Cursor,
        Rounding = 0,

        Transparency = 1,
        Visible = false,
        ZIndex = 3
    })

    --local Flags = Window.Flags
    RunService.Heartbeat:Connect(function()
        Cursor.Visible = Window.Flags["Mouse/Enabled"] and Window.Enabled and UserInputService.MouseBehavior == Enum.MouseBehavior.Default
        if Cursor.Visible then Cursor.Position = UserInputService:GetMouseLocation() - Cursor.Size / 2 end
    end)
end

function DrawingLibrary.SetupCrosshair(Flags)
    local CrosshairL = DrawingNew("Line",{Thickness = 1.5,Transparency = 1,Visible = false,ZIndex = 2})
    local CrosshairR = DrawingNew("Line",{Thickness = 1.5,Transparency = 1,Visible = false,ZIndex = 2})
    local CrosshairT = DrawingNew("Line",{Thickness = 1.5,Transparency = 1,Visible = false,ZIndex = 2})
    local CrosshairB = DrawingNew("Line",{Thickness = 1.5,Transparency = 1,Visible = false,ZIndex = 2})

    RunService.Heartbeat:Connect(function()
        local CrosshairEnabled = Flags["Crosshair/Enabled"] and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
        CrosshairL.Visible,CrosshairR.Visible,CrosshairT.Visible,CrosshairB.Visible = CrosshairEnabled,CrosshairEnabled,CrosshairEnabled,CrosshairEnabled

        if CrosshairEnabled then
            local MouseLocation = UserInputService:GetMouseLocation()
            local Color = Flags["Crosshair/Color"]
            local Size = Flags["Crosshair/Size"]
            local Gap = Flags["Crosshair/Gap"]

            CrosshairL.Color = Color[6]
            CrosshairL.Transparency = 1-Color[4]
            CrosshairL.From = MouseLocation - V2New(Gap,0)
            CrosshairL.To = MouseLocation - V2New(Size + Gap,0)

            CrosshairR.Color = Color[6]
            CrosshairR.Transparency = 1-Color[4]
            CrosshairR.From = MouseLocation + V2New(Gap + 1,0)
            CrosshairR.To = MouseLocation + V2New(Size + (Gap + 1),0)

            CrosshairT.Color = Color[6]
            CrosshairT.Transparency = 1-Color[4]
            CrosshairT.From = MouseLocation - V2New(0,Gap)
            CrosshairT.To = MouseLocation - V2New(0,Size + Gap)

            CrosshairB.Color = Color[6]
            CrosshairB.Transparency = 1-Color[4]
            CrosshairB.From = MouseLocation + V2New(0,Gap + 1)
            CrosshairB.To = MouseLocation + V2New(0,Size + (Gap + 1))
        end
    end)
end

function DrawingLibrary.FOVCircle(Flag,Flags)
    local FOVCircle = DrawingNew("Circle",{ZIndex = 4})
    local Outline   = DrawingNew("Circle",{ZIndex = 3})

    RunService.Heartbeat:Connect(function()
        FOVCircle.Visible = GetFlag(Flags,Flag,"/Enabled")
        and GetFlag(Flags,Flag,"/FOVCircle/Enabled")
        Outline.Visible = FOVCircle.Visible

        if FOVCircle.Visible then
            local MouseLocation = UserInputService:GetMouseLocation()
            local Color = GetFlag(Flags,Flag,"/FOVCircle/Color")
            local FOV = GetFlag(Flags,Flag,"/FieldOfView")

            FOVCircle.Position = MouseLocation
            FOVCircle.Radius = FOV

            FOVCircle.Color = Color[6]
            FOVCircle.Transparency = 1 - Color[4]
            FOVCircle.Thickness = GetFlag(Flags,Flag,"/FOVCircle/Thickness")
            FOVCircle.NumSides = GetFlag(Flags,Flag,"/FOVCircle/NumSides")
            FOVCircle.Filled = GetFlag(Flags,Flag,"/FOVCircle/Filled")

            Outline.Transparency = FOVCircle.Transparency
            Outline.Thickness = FOVCircle.Thickness + 2
            Outline.NumSides = FOVCircle.NumSides
            Outline.Position = FOVCircle.Position
            Outline.Radius = FOVCircle.Radius
        end
    end)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

--[[RunService.Heartbeat:Connect(function()
    for Object,ESP in pairs(DrawingLibrary.ObjectESP) do
        if not GetFlag(ESP.Flags,ESP.GlobalFlag,"/Enabled")
        or not GetFlag(ESP.Flags,ESP.Flag,"/Enabled") then continue end

        ESP.Target.Position = ESP.IsBasePart and ESP.Target.RootPart.Position or ESP.Target.Position
        ESP.Target.ScreenPosition,ESP.Target.OnScreen = WorldToScreen(ESP.Target.Position)
        if ESP.Name.Visible then
            ESP.Name.Position = ToUDim2(ESP.Target.ScreenPosition)
        end
    end
end)]]

Parvus.Utilities.NewThreadLoop(FrameRate,function()
    for Object,ESP in pairs(DrawingLibrary.ObjectESP) do
        if not GetFlag(ESP.Flags,ESP.GlobalFlag,"/Enabled")
        or not GetFlag(ESP.Flags,ESP.Flag,"/Enabled") then
            ESP.Name.Visible = false continue
        end

        ESP.Target.Position = ESP.IsBasePart and ESP.Target.RootPart.Position or ESP.Target.Position
        ESP.Target.ScreenPosition,ESP.Target.OnScreen = WorldToScreen(ESP.Target.Position)

        ESP.Target.Distance = GetDistance(ESP.Target.Position)
        ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.GlobalFlag,"/DistanceCheck"),
        GetFlag(ESP.Flags,ESP.GlobalFlag,"/Distance"),ESP.Target.Distance)

        ESP.Name.Visible = (ESP.Target.OnScreen and ESP.Target.InTheRange) or false

        if ESP.Name.Visible then
            local Color = GetFlag(ESP.Flags,ESP.Flag,"/Color")
            ESP.Name.TextStrokeTransparency = math.max(Color[4],0.5)
            ESP.Name.TextTransparency = Color[4]
            ESP.Name.TextColor3 = Color[6]

            ESP.Name.Position = ToUDim2(ESP.Target.ScreenPosition)
            ESP.Name.Text = string.format("%s\n%i studs",ESP.Target.Name,ESP.Target.Distance)
        end
    end
end)

Parvus.Utilities.NewThreadLoop(FrameRate,function()
    for Target,ESP in pairs(DrawingLibrary.ESP) do
        ESP.Target.Character,ESP.Target.RootPart = GetCharacter(Target,ESP.Mode)
        if ESP.Target.Character and ESP.Target.RootPart then
            ESP.Target.ScreenPosition,ESP.Target.OnScreen = WorldToScreen(ESP.Target.RootPart.Position)

            --[[ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)
            ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.Flag,"/DistanceCheck"),GetFlag(ESP.Flags,ESP.Flag,"/Distance"),ESP.Target.Distance)
            ESP.Target.Health,ESP.Target.MaxHealth,ESP.Target.IsAlive = GetHealth(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.InEnemyTeam,ESP.Target.TeamColor = GetTeam(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.Color = GetFlag(ESP.Flags,ESP.Flag,"/TeamColor") and ESP.Target.TeamColor
            or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags,ESP.Flag,"/Enemy")[6]
            or GetFlag(ESP.Flags,ESP.Flag,"/Ally")[6])]]

            if ESP.Target.OnScreen then
                ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)
                ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.Flag,"/DistanceCheck"),GetFlag(ESP.Flags,ESP.Flag,"/Distance"),ESP.Target.Distance)
                if ESP.Target.InTheRange then
                    ESP.Target.Health,ESP.Target.MaxHealth,ESP.Target.IsAlive = GetHealth(Target,ESP.Target.Character,ESP.Mode)
                    ESP.Target.InEnemyTeam,ESP.Target.TeamColor = GetTeam(Target,ESP.Target.Character,ESP.Mode)
                    ESP.Target.Color = GetFlag(ESP.Flags,ESP.Flag,"/TeamColor") and ESP.Target.TeamColor
                    or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags,ESP.Flag,"/Enemy")[6]
                    or GetFlag(ESP.Flags,ESP.Flag,"/Ally")[6])

                    if ESP.RESP.Highlight.Enabled then
                        local OutlineColor = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/OutlineColor")
                        ESP.RESP.Highlight.DepthMode = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Occluded")
                        and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                        ESP.RESP.Highlight.Adornee = ESP.Target.Character ESP.RESP.Highlight.FillColor = ESP.Target.Color
                        ESP.RESP.Highlight.OutlineColor = OutlineColor[6] ESP.RESP.Highlight.OutlineTransparency = OutlineColor[4]
                        ESP.RESP.Highlight.FillTransparency = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Transparency")
                    end
                    if ESP.RESP.Tracer.Visible or ESP.RESP.HeadDot.Visible then
                        local Head = FindFirstChild(ESP.Target.Character,"Head",true)
                        if Head then local HeadPosition = WorldToScreen(Head.Position)
                            if ESP.RESP.Tracer.Visible then
                                local Mode = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Mode")
                                local Outline = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Outline")
                                local Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Thickness")
                                local Transparency = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Transparency")
                                Mode = (Mode[1] == "From Mouse" and UserInputService:GetMouseLocation())
                                or (Mode[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y))
                                local Position,Rotation,Size = CalculateLine(HeadPosition,Mode,Thickness)

                                ESP.RESP.Tracer.BorderSizePixel = Outline and 1 or 0
                                ESP.RESP.Tracer.BackgroundTransparency = Transparency
                                ESP.RESP.Tracer.BackgroundColor3 = ESP.Target.Color
                                ESP.RESP.Tracer.Rotation = Rotation
                                ESP.RESP.Tracer.Position = Position
                                ESP.RESP.Tracer.Size = Size
                            end
                            if ESP.RESP.HeadDot.Visible then
                                local Size = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Size")
                                local Outline = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Outline")
                                local Autoscale = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Autoscale")
                                local Smoothness = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Smoothness")
                                local Transparency = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Transparency")
                                Autoscale = ClampDistance(Autoscale,Size,ESP.Target.Distance)
                                Outline = Outline and Transparency or 1

                                ESP.RESP.HeadDot.Stroke.Transparency = Outline
                                ESP.RESP.HeadDot.BackgroundColor3 = ESP.Target.Color
                                ESP.RESP.HeadDot.BackgroundTransparency = Transparency
                                ESP.RESP.HeadDot.Corner.CornerRadius = UDimNew(Smoothness / 100,0)
                                ESP.RESP.HeadDot.Size = UDim2FromOffset(Autoscale,Autoscale)
                                ESP.RESP.HeadDot.Position = ToUDim2(HeadPosition)
                            end
                        end
                    end
                    if ESP.RESP.Box.Visible then
                        local BoxPosition,BoxSize = CalculateBox(ESP.Target.Character,ESP.Target.ScreenPosition,ESP.Target.Distance)
                        ESP.Target.HealthPercent = ESP.Target.Health / ESP.Target.MaxHealth ESP.Target.BoxTooSmall = BoxSize.Y <= 12
                        ESP.Target.Weapon = GetWeapon(Target,ESP.Target.Character,ESP.Mode)

                        local Transparency = GetFlag(ESP.Flags,ESP.Flag,"/Box/Transparency")
                        local CornerSize = GetFlag(ESP.Flags,ESP.Flag,"/Box/Corners/Size")
                        local Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Box/Thickness")
                        local Outline = GetFlag(ESP.Flags,ESP.Flag,"/Box/Outline")
                        local Filled = GetFlag(ESP.Flags,ESP.Flag,"/Box/Filled")
                        Outline = Outline and Transparency or 1
                        CornerSize = (CornerSize / 100) / 2

                        ESP.RESP.Box.BackgroundTransparency = Filled and Transparency or 1
                        ESP.RESP.Box.BackgroundColor3 = ESP.Target.Color

                        ESP.RESP.Box.Corners.Top.Left.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Top.Left.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Top.Left.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Top.Left.Size = UDim2New(CornerSize,0,0,Thickness)

                        ESP.RESP.Box.Corners.Top.Right.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Top.Right.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Top.Right.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Top.Right.Size = UDim2New(CornerSize,0,0,Thickness)

                        ESP.RESP.Box.Corners.Left.Top.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Left.Top.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Left.Top.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Left.Top.Position = UDim2New(0,0,0,-Thickness)
                        ESP.RESP.Box.Corners.Left.Top.Size = UDim2New(0,Thickness,CornerSize,Thickness * 2)

                        ESP.RESP.Box.Corners.Left.Bottom.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Left.Bottom.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Left.Bottom.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Left.Bottom.Position = UDim2New(0,0,1,Thickness)
                        ESP.RESP.Box.Corners.Left.Bottom.Size = UDim2New(0,Thickness,CornerSize,Thickness * 2)

                        ESP.RESP.Box.Corners.Bottom.Left.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Bottom.Left.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Bottom.Left.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Bottom.Left.Size = UDim2New(CornerSize,0,0,Thickness)

                        ESP.RESP.Box.Corners.Bottom.Right.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Bottom.Right.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Bottom.Right.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Bottom.Right.Size = UDim2New(CornerSize,0,0,Thickness)

                        ESP.RESP.Box.Corners.Right.Top.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Right.Top.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Right.Top.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Right.Top.Position = UDim2New(1,0,0,-Thickness)
                        ESP.RESP.Box.Corners.Right.Top.Size = UDim2New(0,Thickness,CornerSize,Thickness * 2)

                        ESP.RESP.Box.Corners.Right.Bottom.Border.BackgroundTransparency = Outline
                        ESP.RESP.Box.Corners.Right.Bottom.BackgroundTransparency = Transparency
                        ESP.RESP.Box.Corners.Right.Bottom.BackgroundColor3 = ESP.Target.Color
                        ESP.RESP.Box.Corners.Right.Bottom.Position = UDim2New(1,0,1,Thickness)
                        ESP.RESP.Box.Corners.Right.Bottom.Size = UDim2New(0,Thickness,CornerSize,Thickness * 2)

                        ESP.RESP.Box.Position = ToUDim2(BoxPosition)
                        ESP.RESP.Box.Size = ToUDim2(BoxSize)

                        if ESP.RESP.Box.HealthBar.Visible and not ESP.Target.BoxTooSmall then
                            ESP.RESP.Box.HealthBar.Stroke.Transparency = Outline
                            ESP.RESP.Box.HealthBar.Position = UDim2New(0,-(Thickness + 3),0.5,0)
                            ESP.RESP.Box.HealthBar.Size = UDim2New(0,Thickness,1,Thickness * 2)
                            ESP.RESP.Box.HealthBar.Health.BackgroundTransparency = Transparency
                            ESP.RESP.Box.HealthBar.Health.Size = UDim2New(1,0,ESP.Target.HealthPercent,0)
                            ESP.RESP.Box.HealthBar.Health.BackgroundColor3 = EvalHealth(ESP.Target.HealthPercent)
                        end

                        if ESP.RESP.Box.TextLists.Top.Title.Visible
                        or ESP.RESP.Box.TextLists.Left.Health.Visible
                        or ESP.RESP.Box.TextLists.Bottom.Distance.Visible
                        or ESP.RESP.Box.TextLists.Right.Weapon.Visible then
                            local Size = GetFlag(ESP.Flags,ESP.Flag,"/Name/Size")
                            local Autoscale = GetFlag(ESP.Flags,ESP.Flag,"/Name/Autoscale")
                            Autoscale = ClampDistance(Autoscale,Size,ESP.Target.Distance)

                            Transparency = GetFlag(ESP.Flags,ESP.Flag,"/Name/Transparency")
                            Outline = GetFlag(ESP.Flags,ESP.Flag,"/Name/Outline")
                            Outline = Outline and math.min(Transparency,0.5) or 1

                            ESP.RESP.Box.TextLists.Top.Position = UDim2New(0.5,0,0,-(Thickness + 3))
                            ESP.RESP.Box.TextLists.Left.Position = UDim2New(0,-(Thickness * 2 + 6),0.5,0)
                            ESP.RESP.Box.TextLists.Bottom.Position = UDim2New(0.5,0,1,Thickness + 3)
                            ESP.RESP.Box.TextLists.Right.Position = UDim2New(1,Thickness + 3,0.5,0)

                            if ESP.RESP.Box.TextLists.Top.Title.Visible then
                                ESP.RESP.Box.TextLists.Top.Title.TextSize = Autoscale
                                ESP.RESP.Box.TextLists.Top.Title.Size = UDim2New(1,0,0,Autoscale)
                                ESP.RESP.Box.TextLists.Top.Title.TextTransparency = Transparency
                                ESP.RESP.Box.TextLists.Top.Title.TextStrokeTransparency = Outline
                                ESP.RESP.Box.TextLists.Top.Title.Text = ESP.Mode == "Player" and Target.Name
                                or (ESP.Target.InEnemyTeam and "Enemy NPC" or "Ally NPC")
                            end
                            if ESP.RESP.Box.TextLists.Left.Health.Visible then
                                ESP.RESP.Box.TextLists.Left.Health.TextSize = Autoscale
                                ESP.RESP.Box.TextLists.Left.Health.Size = UDim2New(1,0,0,Autoscale)
                                ESP.RESP.Box.TextLists.Left.Health.TextTransparency = Transparency
                                ESP.RESP.Box.TextLists.Left.Health.TextStrokeTransparency = Outline
                                ESP.RESP.Box.TextLists.Left.Health.Text = tostring(math.floor(ESP.Target.HealthPercent * 100)) .. "%"
                            end
                            if ESP.RESP.Box.TextLists.Bottom.Distance.Visible then
                                ESP.RESP.Box.TextLists.Bottom.Distance.TextSize = Autoscale
                                ESP.RESP.Box.TextLists.Bottom.Distance.Size = UDim2New(1,0,0,Autoscale)
                                ESP.RESP.Box.TextLists.Bottom.Distance.TextTransparency = Transparency
                                ESP.RESP.Box.TextLists.Bottom.Distance.TextStrokeTransparency = Outline
                                ESP.RESP.Box.TextLists.Bottom.Distance.Text = tostring(math.floor(ESP.Target.Distance)) .. " studs"
                            end
                            if ESP.RESP.Box.TextLists.Right.Weapon.Visible then
                                ESP.RESP.Box.TextLists.Right.Weapon.TextSize = Autoscale
                                ESP.RESP.Box.TextLists.Right.Weapon.Size = UDim2New(1,0,0,Autoscale)
                                ESP.RESP.Box.TextLists.Right.Weapon.TextTransparency = Transparency
                                ESP.RESP.Box.TextLists.Right.Weapon.TextStrokeTransparency = Outline
                                ESP.RESP.Box.TextLists.Right.Weapon.Text = ESP.Target.Weapon
                            end
                        end
                    end
                end
            else
                if ESP.RESP.Arrow.Left.Visible and ESP.RESP.Arrow.Right.Visible then
                    ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)
                    ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.Flag,"/DistanceCheck"),GetFlag(ESP.Flags,ESP.Flag,"/Distance"),ESP.Target.Distance)
                    ESP.Target.Health,ESP.Target.MaxHealth,ESP.Target.IsAlive = GetHealth(Target,ESP.Target.Character,ESP.Mode)
                    ESP.Target.InEnemyTeam,ESP.Target.TeamColor = GetTeam(Target,ESP.Target.Character,ESP.Mode)
                    ESP.Target.Color = GetFlag(ESP.Flags,ESP.Flag,"/TeamColor") and ESP.Target.TeamColor
                    or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags,ESP.Flag,"/Enemy")[6]
                    or GetFlag(ESP.Flags,ESP.Flag,"/Ally")[6])

                    local Transparency = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Transparency")
                    local Direction = GetRelative(ESP.Target.RootPart.Position).Unit
                    local SideLength = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Width") / 2
                    local ArrowRadius = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Radius")
                    local Base,Radians90 = Direction * ArrowRadius,Rad(90)

                    local RTCBL = RelativeToCenter(Base + RotateVector(Direction,Radians90) * SideLength)
                    local RTCT = RelativeToCenter(Direction * (ArrowRadius + GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Height")))
                    local RTCBR = RelativeToCenter(Base + RotateVector(Direction,-Radians90) * SideLength)

                    ESP.RESP.Arrow.Left.ImageColor3 = ESP.Target.Color
                    ESP.RESP.Arrow.Right.ImageColor3 = ESP.Target.Color
                    ESP.RESP.Arrow.Left.ImageTransparency = Transparency
                    ESP.RESP.Arrow.Right.ImageTransparency = Transparency

                    CalculateTriangle(ESP.RESP.Arrow.Left,ESP.RESP.Arrow.Right,RTCBL,RTCT,RTCBR)
                end
            end
        end

        local TeamCheck = (not GetFlag(ESP.Flags,ESP.Flag,"/TeamCheck") and not ESP.Target.InEnemyTeam) or ESP.Target.InEnemyTeam
        local Visible = ESP.Target.RootPart and ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.IsAlive and TeamCheck
        local ArrowVisible = ESP.Target.RootPart and (not ESP.Target.OnScreen) and ESP.Target.InTheRange and ESP.Target.IsAlive and TeamCheck

        ESP.RESP.Highlight.Enabled = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Enabled") or false

        ESP.RESP.Box.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Enabled") or false
        ESP.RESP.Tracer.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Enabled") or false
        ESP.RESP.HeadDot.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Enabled") or false
        ESP.RESP.Arrow.Left.Visible = ArrowVisible and GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Enabled") or false
        ESP.RESP.Arrow.Right.Visible = ArrowVisible and GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Enabled") or false
        ESP.RESP.Box.HealthBar.Visible = ESP.RESP.Box.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/HealthBar") and not ESP.Target.BoxTooSmall or false

        ESP.RESP.Box.TextLists.Top.Title.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Name/Enabled") or false
        ESP.RESP.Box.TextLists.Left.Health.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Health/Enabled") or false
        ESP.RESP.Box.TextLists.Bottom.Distance.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Distance/Enabled") or false
        ESP.RESP.Box.TextLists.Right.Weapon.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Weapon/Enabled") or false
    end
end)

return DrawingLibrary
