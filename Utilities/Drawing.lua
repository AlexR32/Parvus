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
local Max = math.max
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
local RedColor = ColorNew(1, 0, 0)
local GreenColor = ColorNew(0, 1, 0)
local YellowColor = ColorNew(1, 1, 0)
local WhiteColor = ColorNew(1, 1, 1)
local BlackColor = ColorNew(0, 0, 0)
local LerpColor = BlackColor.Lerp
local Fonts = Drawing.Fonts

local DrawingLibrary = {
    ESP = {},--setmetatable({}, { __mode = "kv" }),
    ObjectESP = {},--setmetatable({}, { __mode = "kv" }),
    CharacterSize = Vector3.new(4, 5, 1),

    CS = ColorSequence.new({
        ColorSequenceKeypoint.new(0, RedColor),
        ColorSequenceKeypoint.new(0.5, YellowColor),
        ColorSequenceKeypoint.new(1, GreenColor)
    })
}

local function AddDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)

    if Properties then
        for Property, Value in pairs(Properties) do
            DrawingObject[Property] = Value
        end
    end

    return DrawingObject
end
local function ClearDrawing(Table)
    for Index, Value in pairs(Table) do
        if type(Value) == "table" then
            ClearDrawing(Value)
        elseif typeof(Value) == "DrawingObject" then
            Value:Destroy()
        end
    end
end

local function GetFlag(Flags, Flag, Option)
    return Flags[Flag .. Option]
end
local function GetDistance(Position)
    return (Position - Camera.CFrame.Position).Magnitude
end
local function IsWithinReach(Enabled, Limit, Distance)
    if not Enabled then return true end
    return Distance < Limit
end
local function GetScaleFactor(Enabled, Size, Distance)
    if not Enabled then return Size end
    return Max(1, Size / (Distance * Tan(Rad(Camera.FieldOfView / 2)) * 10) * 1000)
end
--[[local function DynamicFOV(Enabled, FOV)
    if not Enabled then return FOV end
    --return FOV / (Camera.FieldOfView / 80)
    return FOV * (1 + (80 - Camera.FieldOfView) / 100)
end]]
local function AntiAliasingXY(X, Y)
    return V2New(Floor(X), Floor(Y))
end
local function AntiAliasingP(P)
    return V2New(Floor(P.X), Floor(P.Y))
end
local function WorldToScreen(WorldPosition)
    local Screen, OnScreen = WTVP(Camera, WorldPosition)
    return V2New(Screen.X, Screen.Y), OnScreen--, Screen.Z
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
            return KIndex.Value:Lerp(NIndex.Value, Alpha)
        end
    end
end
-- CalculateBox by mickeyrbx (highly edited)
local function CalculateBoxSize(Model, Distance)
    local Size = Model:GetExtentsSize()
    --Size = V2New(Size.X, Size.Y)
    --local Size = DrawingLibrary.CharacterSize
    Size = Size / (Distance * Tan(Rad(Camera.FieldOfView / 2)) * 2) * 1000
    return AntiAliasingXY(Size.X, Size.Y)
end
-- Offscreen Arrows by Blissful
local function GetRelative(Position)
    local Relative = PointToObjectSpace(Camera.CFrame, Position)
    return V2New(-Relative.X, -Relative.Z)
end
local function RotateVector(Vector, Radians)
    local C, S = Cos(Radians), Sin(Radians)

    return V2New(
        Vector.X * C - Vector.Y * S,
        Vector.X * S + Vector.Y * C
    )
end
local function RelativeToCenter(Size)
    return Camera.ViewportSize / 2 - Size
end

--[[function HighlightNew(Target, Parent)
    local Highlight = Instance.new("Highlight")
    Highlight.Adornee = Target
    Highlight.Parent = Parent
    return Highlight
end]]
function GetCharacter(Target, Mode)
    if Mode == "Player" then
        local Character = Target.Character if not Character then return end
        return Character, FindFirstChild(Character, "HumanoidRootPart")
    else
        return Target, FindFirstChild(Target, "HumanoidRootPart")
    end
end
function GetHealth(Target, Character, Mode)
    local Humanoid = FindFirstChildOfClass(Character, "Humanoid")
    if not Humanoid then return 100, 100, true end
    return Humanoid.Health, Humanoid.MaxHealth, Humanoid.Health > 0
end
function GetTeam(Target, Character, Mode)
    if Mode == "Player" then
        if Target.Neutral then return true, WhiteColor end
        return LocalPlayer.Team ~= Target.Team, Target.TeamColor.Color
    else
        return true, WhiteColor
    end
end
function GetWeapon(Target, Character, Mode)
    return "N/A"
end

if game.GameId == 1168263273 or game.GameId == 3360073263 then -- Bad Business
    DrawingLibrary.CharacterSize = Vector3.new(2.05, 7.3, 1.35)
    local TeamService = game:GetService("Teams")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Tortoiseshell = getupvalue(require(ReplicatedStorage.TS), 1)
    local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter, 1)
    local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

    local function GetPlayerTeam(Player)
        for Index, Team in pairs(TeamService:GetChildren()) do
            if FindFirstChild(Team.Players, Player.Name) then
                return Team.Name
            end
        end
    end
    --[[local function FindHighlightForCharacter(Character)
        for Index, Highlight in pairs(PlayerGui:GetChildren()) do
            if not Highlight:IsA("Highlight") then continue end
            if Highlight.Adornee == Character then
                return Highlight
            end
        end
    end]]

    --[[function HighlightNew(Target, Parent)
        local Character = Characters[Target]
        return FindHighlightForCharacter(Character)
    end]]
    function GetCharacter(Target, Mode)
        local Character = Characters[Target]
        if not Character or Character.Parent == nil then return end
        --DrawingLibrary.ESP[Target].Highlight = FindHighlightForCharacter(Character)
        return Character, Character.PrimaryPart
    end
    function GetHealth(Target, Character, Mode)
        local Health = Character.Health
        return Health.Value, Health.MaxHealth.Value, Health.Value > 0
    end
    function GetTeam(Target, Character, Mode)
        local Team, LocalTeam = GetPlayerTeam(Target), GetPlayerTeam(LocalPlayer)
        return LocalTeam ~= Team or Team == "FFA", Tortoiseshell.Teams.Colors[Team]
    end
    function GetWeapon(Target, Character, Mode)
        return tostring(Character.Backpack.Equipped.Value or "Hands")
    end
elseif game.GameId == 358276974 or game.GameId == 3495983524 then -- Apocalypse Rising 2
    function GetHealth(Target, Character, Mode)
        local Health = Target.Stats.Health
        local Bonus = Target.Stats.HealthBonus

        return Health.Value + Bonus.Value,
        100 + Bonus.Value, Health.Value > 0
    end

    function GetWeapon(Target, Character, Mode)
        local Equipped = Character.Equipped:GetChildren()
        return Equipped[1] and Equipped[1].Name or "Hands"
    end

    -- TODO: Squad GetTeam function
    --function GetTeam(Target, Character, Mode) end
elseif game.GameId == 1054526971 then -- Blackhawk Rescue Mission 5
    local function RequireModule(Name)
        for Index, Instance in pairs(getmodules()) do
            if Instance.Name == Name then
                return require(Instance)
            end
        end
    end

    repeat task.wait() until RequireModule("RoundInterface")
    local RoundInterface = RequireModule("RoundInterface")

    local function GetSkirmishTeam(Player)
        for TeamName, TeamData in pairs(RoundInterface.Teams) do
            for UserId, UserData in pairs(TeamData.Players) do
                if tonumber(UserId) == Player.UserId then
                    return TeamName
                end
            end
        end
    end
    function GetTeam(Target, Character, Mode)
        if Mode == "Player" then
            return not Target.Neutral and LocalPlayer.Team ~= Target.Team
            or GetSkirmishTeam(LocalPlayer) ~= GetSkirmishTeam(Target), WhiteColor
        else
            return not FindFirstChildWhichIsA(Character, "ProximityPrompt", true), WhiteColor
        end
    end
elseif game.GameId == 580765040 then -- RAGDOLL UNIVERSE
    function GetCharacter(Target, Mode)
        local Character = Target.Character
        if not Character then return end
        return Character, Character.PrimaryPart
    end
    function GetTeam(Target, Character, Mode)
        local LocalCharacter = LocalPlayer.Character
        if not LocalCharacter then return false, Character.PrimaryPart.Color end
        if FindFirstChild(LocalCharacter, "Team") and FindFirstChild(Character, "Team") then
            return Character.Team.Value ~= LocalCharacter.Team.Value
            or Character.Team.Value == "None", Character.PrimaryPart.Color
        end

        return false, Character.PrimaryPart.Color
    end
    function GetWeapon(Target, Character, Mode)
        return tostring(FindFirstChildOfClass(Character, "Tool") or "Hands")
    end
elseif game.GameId == 1586272220 then -- Steel Titans
    local function GetPlayerTank(Player)
        local Character = FindFirstChild(Player, "Char")
        if not Character then return end
        if Character.Value == nil then return end
        return Character.Value.Parent.Parent.Parent
    end

    function GetCharacter(Target, Mode)
        local PlayerTank = GetPlayerTank(Target)
        if not PlayerTank then return end
        return PlayerTank, PlayerTank.PrimaryPart
    end
    function GetHealth(Target, Character, Mode)
        return Character.Stats.Health.Value,
        Character.Stats.Health.Orig.Value,
        Character.Stats.Health.Value > 0
    end
end

function DrawingLibrary.Update(ESP, Target)
    local Textboxes = ESP.Drawing.Textboxes
    local Mode, Flag, Flags = ESP.Mode, ESP.Flag, ESP.Flags

    local Character, RootPart = nil, nil
    local ScreenPosition, OnScreen = Vector2.zero, false
    local Distance, InTheRange, BoxTooSmall = 0, false, false
    local Health, MaxHealth, IsAlive = 100, 100, false
    local InEnemyTeam, TeamColor = true, WhiteColor
    local Color = WhiteColor

    Character, RootPart = GetCharacter(Target, Mode)
    if Character and RootPart then
        ScreenPosition, OnScreen = WorldToScreen(RootPart.Position)

        if OnScreen then
            Distance = GetDistance(RootPart.Position)
            InTheRange = IsWithinReach(GetFlag(Flags, Flag, "/DistanceCheck"), GetFlag(Flags, Flag, "/Distance"), Distance)

            if InTheRange then
                Health, MaxHealth, IsAlive = GetHealth(Target, Character, Mode)
                InEnemyTeam, TeamColor = GetTeam(Target, Character, Mode)
                Color = GetFlag(Flags, Flag, "/TeamColor") and TeamColor
                or (InEnemyTeam and GetFlag(Flags, Flag, "/Enemy")[6]
                or GetFlag(Flags, Flag, "/Ally")[6])

                -- if ESP.Highlight and ESP.Highlight.Enabled then
                --     local OutlineColor = GetFlag(Flags, Flag, "/Highlight/OutlineColor")
                --     ESP.Highlight.DepthMode = GetFlag(Flags, Flag, "/Highlight/Occluded")
                --     and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                --     --ESP.Highlight.Adornee = Character
                --     ESP.Highlight.FillColor = Color
                --     ESP.Highlight.OutlineColor = OutlineColor[6]
                --     ESP.Highlight.OutlineTransparency = OutlineColor[4]
                --     ESP.Highlight.FillTransparency = GetFlag(Flags, Flag, "/Highlight/Transparency")
                -- end

                if ESP.Drawing.Tracer.Main.Visible or ESP.Drawing.HeadDot.Main.Visible then
                    local Head = FindFirstChild(Character, "Head", true)

                    if Head then
                        local HeadPosition = WorldToScreen(Head.Position)

                        if ESP.Drawing.Tracer.Main.Visible then
                            local FromPosition = GetFlag(Flags, Flag, "/Tracer/Mode")
                            local Thickness = GetFlag(Flags, Flag, "/Tracer/Thickness")
                            local Transparency = 1 - GetFlag(Flags, Flag, "/Tracer/Transparency")
                            FromPosition = (FromPosition[1] == "From Mouse" and UserInputService:GetMouseLocation())
                            or (FromPosition[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y))

                            ESP.Drawing.Tracer.Main.Color = Color

                            ESP.Drawing.Tracer.Main.Thickness = Thickness
                            ESP.Drawing.Tracer.Outline.Thickness = Thickness + 2

                            ESP.Drawing.Tracer.Main.Transparency = Transparency
                            ESP.Drawing.Tracer.Outline.Transparency = Transparency

                            ESP.Drawing.Tracer.Main.From = FromPosition
                            ESP.Drawing.Tracer.Outline.From = FromPosition

                            ESP.Drawing.Tracer.Main.To = HeadPosition
                            ESP.Drawing.Tracer.Outline.To = HeadPosition
                        end
                        if ESP.Drawing.HeadDot.Main.Visible then
                            local Filled = GetFlag(Flags, Flag, "/HeadDot/Filled")
                            local Radius = GetFlag(Flags, Flag, "/HeadDot/Radius")
                            local NumSides = GetFlag(Flags, Flag, "/HeadDot/NumSides")
                            local Thickness = GetFlag(Flags, Flag, "/HeadDot/Thickness")
                            local Autoscale = GetFlag(Flags, Flag, "/HeadDot/Autoscale")
                            local Transparency = 1 - GetFlag(Flags, Flag, "/HeadDot/Transparency")
                            Radius = GetScaleFactor(Autoscale, Radius, Distance)

                            ESP.Drawing.HeadDot.Main.Color = Color

                            ESP.Drawing.HeadDot.Main.Transparency = Transparency
                            ESP.Drawing.HeadDot.Outline.Transparency = Transparency

                            ESP.Drawing.HeadDot.Main.NumSides = NumSides
                            ESP.Drawing.HeadDot.Outline.NumSides = NumSides

                            ESP.Drawing.HeadDot.Main.Radius = Radius
                            ESP.Drawing.HeadDot.Outline.Radius = Radius

                            ESP.Drawing.HeadDot.Main.Thickness = Thickness
                            ESP.Drawing.HeadDot.Outline.Thickness = Thickness + 2

                            ESP.Drawing.HeadDot.Main.Filled = Filled

                            ESP.Drawing.HeadDot.Main.Position = HeadPosition
                            ESP.Drawing.HeadDot.Outline.Position = HeadPosition
                        end
                    end
                end
                if ESP.Drawing.Box.Visible then
                    local BoxSize = CalculateBoxSize(Character, Distance)
                    local HealthPercent = Health / MaxHealth
                    BoxTooSmall = BoxSize.Y < 18

                    local Transparency = 1 - GetFlag(Flags, Flag, "/Box/Transparency")
                    local CornerSize = GetFlag(Flags, Flag, "/Box/CornerSize")
                    local Thickness = GetFlag(Flags, Flag, "/Box/Thickness")
                    local Filled = GetFlag(Flags, Flag, "/Box/Filled")

                    local ThicknessAdjust = Floor(Thickness / 2)
                    CornerSize = V2New(
                        (BoxSize.X / 2) * (CornerSize / 100),
                        (BoxSize.Y / 2) * (CornerSize / 100)
                    )

                    local From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    local To = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        (ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                    )

                    ESP.Drawing.Box.LineLT.Main.Color = Color
                    ESP.Drawing.Box.LineLT.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineLT.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineLT.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineLT.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineLT.Main.From = From - V2New(0, ThicknessAdjust)
                    ESP.Drawing.Box.LineLT.Outline.From = From - V2New(0, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineLT.Main.To = To
                    ESP.Drawing.Box.LineLT.Outline.To = To + V2New(0, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineTL.Main.Color = Color
                    ESP.Drawing.Box.LineTL.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineTL.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineTL.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineTL.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineTL.Main.From = From - V2New(ThicknessAdjust, 0)
                    ESP.Drawing.Box.LineTL.Outline.From = From - V2New(ThicknessAdjust + 1, 0)
                    ESP.Drawing.Box.LineTL.Main.To = To
                    ESP.Drawing.Box.LineTL.Outline.To = To + V2New(1, 0)

                    From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        (ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                    )

                    ESP.Drawing.Box.LineLB.Main.Color = Color
                    ESP.Drawing.Box.LineLB.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineLB.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineLB.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineLB.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineLB.Main.From = From + V2New(0, ThicknessAdjust)
                    ESP.Drawing.Box.LineLB.Outline.From = From + V2New(0, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineLB.Main.To = To
                    ESP.Drawing.Box.LineLB.Outline.To = To - V2New(0, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X - (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineBL.Main.Color = Color
                    ESP.Drawing.Box.LineBL.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineBL.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineBL.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineBL.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineBL.Main.From = From - V2New(ThicknessAdjust, 1)
                    ESP.Drawing.Box.LineBL.Outline.From = From - V2New(ThicknessAdjust + 1, 1)
                    ESP.Drawing.Box.LineBL.Main.To = To - V2New(0, 1)
                    ESP.Drawing.Box.LineBL.Outline.To = To - V2New(-1, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        (ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                    )

                    ESP.Drawing.Box.LineRT.Main.Color = Color
                    ESP.Drawing.Box.LineRT.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineRT.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineRT.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineRT.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineRT.Main.From = From - V2New(1, ThicknessAdjust)
                    ESP.Drawing.Box.LineRT.Outline.From = From - V2New(1, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineRT.Main.To = To - V2New(1, 0)
                    ESP.Drawing.Box.LineRT.Outline.To = To + V2New(-1, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                        ScreenPosition.Y - (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineTR.Main.Color = Color
                    ESP.Drawing.Box.LineTR.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineTR.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineTR.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineTR.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineTR.Main.From = From + V2New(ThicknessAdjust, 0)
                    ESP.Drawing.Box.LineTR.Outline.From = From + V2New(ThicknessAdjust + 1, 0)
                    ESP.Drawing.Box.LineTR.Main.To = To
                    ESP.Drawing.Box.LineTR.Outline.To = To - V2New(1, 0)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        (ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                    )

                    ESP.Drawing.Box.LineRB.Main.Color = Color
                    ESP.Drawing.Box.LineRB.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineRB.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineRB.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineRB.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineRB.Main.From = From + V2New(-1, ThicknessAdjust)
                    ESP.Drawing.Box.LineRB.Outline.From = From + V2New(-1, ThicknessAdjust + 1)
                    ESP.Drawing.Box.LineRB.Main.To = To - V2New(1, 0)
                    ESP.Drawing.Box.LineRB.Outline.To = To - V2New(1, 1)

                    From = AntiAliasingXY(
                        ScreenPosition.X + (BoxSize.X / 2),
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )
                    To = AntiAliasingXY(
                        (ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                        ScreenPosition.Y + (BoxSize.Y / 2)
                    )

                    ESP.Drawing.Box.LineBR.Main.Color = Color
                    ESP.Drawing.Box.LineBR.Main.Thickness = Thickness
                    ESP.Drawing.Box.LineBR.Outline.Thickness = Thickness + 2
                    ESP.Drawing.Box.LineBR.Main.Transparency = Transparency
                    ESP.Drawing.Box.LineBR.Outline.Transparency = Transparency
                    ESP.Drawing.Box.LineBR.Main.From = From + V2New(ThicknessAdjust, -1)
                    ESP.Drawing.Box.LineBR.Outline.From = From + V2New(ThicknessAdjust + 1, -1)
                    ESP.Drawing.Box.LineBR.Main.To = To - V2New(0, 1)
                    ESP.Drawing.Box.LineBR.Outline.To = To - V2New(1, 1)

                    if ESP.Drawing.HealthBar.Main.Visible then
                        ESP.Drawing.HealthBar.Main.Color = EvalHealth(HealthPercent)
                        ESP.Drawing.HealthBar.Main.Transparency = Transparency
                        ESP.Drawing.HealthBar.Outline.Transparency = Transparency

                        ESP.Drawing.HealthBar.Outline.Size = AntiAliasingXY(Thickness + 2, BoxSize.Y + (Thickness + 1))
                        ESP.Drawing.HealthBar.Outline.Position = AntiAliasingXY(
                            (ScreenPosition.X - (BoxSize.X / 2)) - Thickness - ThicknessAdjust - 4,
                            ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                        )
                        ESP.Drawing.HealthBar.Main.Size = V2New(ESP.Drawing.HealthBar.Outline.Size.X - 2, -HealthPercent * (ESP.Drawing.HealthBar.Outline.Size.Y - 2))
                        ESP.Drawing.HealthBar.Main.Position = ESP.Drawing.HealthBar.Outline.Position + V2New(1, ESP.Drawing.HealthBar.Outline.Size.Y - 1)
                    end

                    if Textboxes.Name.Visible
                    or Textboxes.Health.Visible
                    or Textboxes.Distance.Visible
                    or Textboxes.Weapon.Visible then
                        local Size = GetFlag(Flags, Flag, "/Name/Size")
                        local Autoscale = GetFlag(Flags, Flag, "/Name/Autoscale")
                        --local Font = GetFont(GetFlag(ESP.Flags, ESP.Flag, "/Name/Font")[1])
                        Autoscale = Floor(GetScaleFactor(Autoscale, Size, Distance))

                        Transparency = 1 - GetFlag(Flags, Flag, "/Name/Transparency")
                        Outline = GetFlag(Flags, Flag, "/Name/Outline")

                        if Textboxes.Name.Visible then
                            Textboxes.Name.Outline = Outline
                            --Textboxes.Name.Font = Font
                            Textboxes.Name.Transparency = Transparency
                            Textboxes.Name.Size = Autoscale
                            Textboxes.Name.Text = Mode == "Player" and Target.Name
                            or (InEnemyTeam and "Enemy NPC" or "Ally NPC")

                            Textboxes.Name.Position = AntiAliasingXY(
                                ScreenPosition.X,
                                ScreenPosition.Y - (BoxSize.Y / 2) - Textboxes.Name.TextBounds.Y - ThicknessAdjust - 2
                            )
                        end
                        if Textboxes.Health.Visible then
                            Textboxes.Health.Outline = Outline
                            --Textboxes.Health.Font = Font
                            Textboxes.Health.Transparency = Transparency
                            Textboxes.Health.Size = Autoscale
                            Textboxes.Health.Text = tostring(math.floor(HealthPercent * 100)) .. "%"

                            local HealthPositionX = ESP.Drawing.HealthBar.Main.Visible and ((ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - (Thickness + ThicknessAdjust + 5)) or ((ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - ThicknessAdjust - 2)
                            Textboxes.Health.Position = AntiAliasingXY(
                                HealthPositionX,
                                (ScreenPosition.Y - (BoxSize.Y / 2)) - ThicknessAdjust - 1
                            )

                            --ESP.Drawing.Test.Position = Textboxes.Health.Position
                            --ESP.Drawing.Test.Size = V2New(Textboxes.Health.TextBounds.X, Textboxes.Health.TextBounds.Y)
                        end
                        if Textboxes.Distance.Visible then
                            Textboxes.Distance.Outline = Outline
                            --Textboxes.Distance.Font = Font
                            Textboxes.Distance.Transparency = Transparency
                            Textboxes.Distance.Size = Autoscale
                            Textboxes.Distance.Text = tostring(math.floor(Distance)) .. " studs"

                            Textboxes.Distance.Position = AntiAliasingXY(
                                ScreenPosition.X,
                                (ScreenPosition.Y + (BoxSize.Y / 2)) + ThicknessAdjust + 2
                            )

                            --ESP.Drawing.Test.Position = Textboxes.Distance.Position
                            --ESP.Drawing.Test.Size = V2New(Textboxes.Distance.TextBounds.X, Textboxes.Distance.TextBounds.Y)
                        end
                        if Textboxes.Weapon.Visible then
                            local Weapon = GetWeapon(Target, Character, Mode)

                            Textboxes.Weapon.Outline = Outline
                            --Textboxes.Weapon.Font = Font
                            Textboxes.Weapon.Transparency = Transparency
                            Textboxes.Weapon.Size = Autoscale
                            Textboxes.Weapon.Text = Weapon

                            Textboxes.Weapon.Position = AntiAliasingXY(
                                (ScreenPosition.X + (BoxSize.X / 2)) + ThicknessAdjust + 2,
                                ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                            )

                            --ESP.Drawing.Test.Position = Textboxes.Weapon.Position
                            --ESP.Drawing.Test.Size = V2New(Textboxes.Weapon.TextBounds.X, Textboxes.Weapon.TextBounds.Y)
                        end
                    end
                end
            end
        else
            if ESP.Drawing.Arrow.Main.Visible then
                Distance = GetDistance(RootPart.Position)
                InTheRange = IsWithinReach(GetFlag(Flags, Flag, "/DistanceCheck"), GetFlag(Flags, Flag, "/Distance"), Distance)
                Health, MaxHealth, IsAlive = GetHealth(Target, Character, Mode)
                InEnemyTeam, TeamColor = GetTeam(Target, Character, Mode)
                Color = GetFlag(Flags, Flag, "/TeamColor") and TeamColor
                or (InEnemyTeam and GetFlag(Flags, Flag, "/Enemy")[6]
                or GetFlag(Flags, Flag, "/Ally")[6])

                local Direction = GetRelative(RootPart.Position).Unit
                local SideLength = GetFlag(Flags, Flag, "/Arrow/Width") / 2
                local ArrowRadius = GetFlag(Flags, Flag, "/Arrow/Radius")
                local Base, Radians90 = Direction * ArrowRadius, Rad(90)

                local PointA = RelativeToCenter(Base + RotateVector(Direction, Radians90) * SideLength)
                local PointB = RelativeToCenter(Direction * (ArrowRadius + GetFlag(Flags, Flag, "/Arrow/Height")))
                local PointC = RelativeToCenter(Base + RotateVector(Direction, -Radians90) * SideLength)

                local Filled = GetFlag(Flags, Flag, "/Arrow/Filled")
                local Thickness = GetFlag(Flags, Flag, "/Arrow/Thickness")
                local Transparency = 1 - GetFlag(Flags, Flag, "/Arrow/Transparency")

                ESP.Drawing.Arrow.Main.Color = Color

                ESP.Drawing.Arrow.Main.Filled = Filled

                ESP.Drawing.Arrow.Main.Thickness = Thickness
                ESP.Drawing.Arrow.Outline.Thickness = Thickness + 2

                ESP.Drawing.Arrow.Main.Transparency = Transparency
                ESP.Drawing.Arrow.Outline.Transparency = Transparency

                ESP.Drawing.Arrow.Main.PointA = PointA
                ESP.Drawing.Arrow.Outline.PointA = PointA
                ESP.Drawing.Arrow.Main.PointB = PointB
                ESP.Drawing.Arrow.Outline.PointB = PointB
                ESP.Drawing.Arrow.Main.PointC = PointC
                ESP.Drawing.Arrow.Outline.PointC = PointC
            end
        end
    end

    local TeamCheck = (not GetFlag(Flags, Flag, "/TeamCheck") and not InEnemyTeam) or InEnemyTeam
    local Visible = RootPart and OnScreen and InTheRange and IsAlive and TeamCheck
    local ArrowVisible = RootPart and (not OnScreen) and InTheRange and IsAlive and TeamCheck

    -- if ESP.Highlight then
    --     ESP.Highlight.Enabled = Visible and GetFlag(Flags, Flag, "/Highlight/Enabled") or false
    -- end

    ESP.Drawing.Box.Visible = Visible and GetFlag(Flags, Flag, "/Box/Enabled") or false
    ESP.Drawing.Box.OutlineVisible = ESP.Drawing.Box.Visible and GetFlag(Flags, Flag, "/Box/Outline") or false

    for Index, Line in pairs(ESP.Drawing.Box) do
        if type(Line) ~= "table" then continue end
        Line.Main.Visible = ESP.Drawing.Box.Visible
        Line.Outline.Visible = ESP.Drawing.Box.OutlineVisible
    end

    ESP.Drawing.HealthBar.Main.Visible = ESP.Drawing.Box.Visible and GetFlag(Flags, Flag, "/Box/HealthBar") and not BoxTooSmall or false
    ESP.Drawing.HealthBar.Outline.Visible = ESP.Drawing.HealthBar.Main.Visible and GetFlag(Flags, Flag, "/Box/Outline") or false

    ESP.Drawing.Arrow.Main.Visible = ArrowVisible and GetFlag(Flags, Flag, "/Arrow/Enabled") or false
    ESP.Drawing.Arrow.Outline.Visible = GetFlag(Flags, Flag, "/Arrow/Outline") and ESP.Drawing.Arrow.Main.Visible or false

    ESP.Drawing.HeadDot.Main.Visible = Visible and GetFlag(Flags, Flag, "/HeadDot/Enabled") or false
    ESP.Drawing.HeadDot.Outline.Visible = GetFlag(Flags, Flag, "/HeadDot/Outline") and ESP.Drawing.HeadDot.Main.Visible or false

    ESP.Drawing.Tracer.Main.Visible = Visible and GetFlag(Flags, Flag, "/Tracer/Enabled") or false
    ESP.Drawing.Tracer.Outline.Visible = GetFlag(Flags, Flag, "/Tracer/Outline") and ESP.Drawing.Tracer.Main.Visible or false

    ESP.Drawing.Textboxes.Name.Visible = Visible and GetFlag(Flags, Flag, "/Name/Enabled") or false
    ESP.Drawing.Textboxes.Health.Visible = Visible and GetFlag(Flags, Flag, "/Health/Enabled") or false
    ESP.Drawing.Textboxes.Distance.Visible = Visible and GetFlag(Flags, Flag, "/Distance/Enabled") or false
    ESP.Drawing.Textboxes.Weapon.Visible = Visible and GetFlag(Flags, Flag, "/Weapon/Enabled") or false
end

--[[function DrawingLibrary.InitRender(Self, Target, Mode, Flag, Flags)
    local ESP = Self.ESP[Target]
    local Textboxes = ESP.Drawing.Textboxes

    local Character, RootPart = nil, nil
    local ScreenPosition, OnScreen = Vector2.zero, false
    local Distance, InTheRange, BoxTooSmall = 0, false, false
    local Health, MaxHealth, IsAlive = 100, 100, false
    local InEnemyTeam, TeamColor = true, WhiteColor
    local Color = WhiteColor

    return RunService.RenderStepped:Connect(function()
        debug.profilebegin("PARVUS_DRAWING")
        Character, RootPart = GetCharacter(Target, Mode)
        if Character and RootPart then
            ScreenPosition, OnScreen = WorldToScreen(RootPart.Position)

            if OnScreen then
                Distance = GetDistance(RootPart.Position)
                InTheRange = IsWithinReach(GetFlag(Flags, Flag, "/DistanceCheck"), GetFlag(Flags, Flag, "/Distance"), Distance)

                if InTheRange then
                    Health, MaxHealth, IsAlive = GetHealth(Target, Character, Mode)
                    InEnemyTeam, TeamColor = GetTeam(Target, Character, Mode)
                    Color = GetFlag(Flags, Flag, "/TeamColor") and TeamColor
                    or (InEnemyTeam and GetFlag(Flags, Flag, "/Enemy")[6]
                    or GetFlag(Flags, Flag, "/Ally")[6])

                    -- if ESP.Highlight and ESP.Highlight.Enabled then
                    --     local OutlineColor = GetFlag(Flags, Flag, "/Highlight/OutlineColor")
                    --     ESP.Highlight.DepthMode = GetFlag(Flags, Flag, "/Highlight/Occluded")
                    --     and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                    --     --ESP.Highlight.Adornee = Character
                    --     ESP.Highlight.FillColor = Color
                    --     ESP.Highlight.OutlineColor = OutlineColor[6]
                    --     ESP.Highlight.OutlineTransparency = OutlineColor[4]
                    --     ESP.Highlight.FillTransparency = GetFlag(Flags, Flag, "/Highlight/Transparency")
                    -- end

                    if ESP.Drawing.Tracer.Main.Visible or ESP.Drawing.HeadDot.Main.Visible then
                        local Head = FindFirstChild(Character, "Head", true)

                        if Head then
                            local HeadPosition = WorldToScreen(Head.Position)

                            if ESP.Drawing.Tracer.Main.Visible then
                                local FromPosition = GetFlag(Flags, Flag, "/Tracer/Mode")
                                local Thickness = GetFlag(Flags, Flag, "/Tracer/Thickness")
                                local Transparency = 1 - GetFlag(Flags, Flag, "/Tracer/Transparency")
                                FromPosition = (FromPosition[1] == "From Mouse" and UserInputService:GetMouseLocation())
                                or (FromPosition[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y))

                                ESP.Drawing.Tracer.Main.Color = Color

                                ESP.Drawing.Tracer.Main.Thickness = Thickness
                                ESP.Drawing.Tracer.Outline.Thickness = Thickness + 2

                                ESP.Drawing.Tracer.Main.Transparency = Transparency
                                ESP.Drawing.Tracer.Outline.Transparency = Transparency

                                ESP.Drawing.Tracer.Main.From = FromPosition
                                ESP.Drawing.Tracer.Outline.From = FromPosition

                                ESP.Drawing.Tracer.Main.To = HeadPosition
                                ESP.Drawing.Tracer.Outline.To = HeadPosition
                            end
                            if ESP.Drawing.HeadDot.Main.Visible then
                                local Filled = GetFlag(Flags, Flag, "/HeadDot/Filled")
                                local Radius = GetFlag(Flags, Flag, "/HeadDot/Radius")
                                local NumSides = GetFlag(Flags, Flag, "/HeadDot/NumSides")
                                local Thickness = GetFlag(Flags, Flag, "/HeadDot/Thickness")
                                local Autoscale = GetFlag(Flags, Flag, "/HeadDot/Autoscale")
                                local Transparency = 1 - GetFlag(Flags, Flag, "/HeadDot/Transparency")
                                Radius = GetScaleFactor(Autoscale, Radius, Distance)

                                ESP.Drawing.HeadDot.Main.Color = Color

                                ESP.Drawing.HeadDot.Main.Transparency = Transparency
                                ESP.Drawing.HeadDot.Outline.Transparency = Transparency

                                ESP.Drawing.HeadDot.Main.NumSides = NumSides
                                ESP.Drawing.HeadDot.Outline.NumSides = NumSides

                                ESP.Drawing.HeadDot.Main.Radius = Radius
                                ESP.Drawing.HeadDot.Outline.Radius = Radius

                                ESP.Drawing.HeadDot.Main.Thickness = Thickness
                                ESP.Drawing.HeadDot.Outline.Thickness = Thickness + 2

                                ESP.Drawing.HeadDot.Main.Filled = Filled

                                ESP.Drawing.HeadDot.Main.Position = HeadPosition
                                ESP.Drawing.HeadDot.Outline.Position = HeadPosition
                            end
                        end
                    end
                    if ESP.Drawing.Box.Visible then
                        local BoxSize = CalculateBoxSize(Character, Distance)
                        local HealthPercent = Health / MaxHealth
                        BoxTooSmall = BoxSize.Y < 18

                        local Transparency = 1 - GetFlag(Flags, Flag, "/Box/Transparency")
                        local CornerSize = GetFlag(Flags, Flag, "/Box/CornerSize")
                        local Thickness = GetFlag(Flags, Flag, "/Box/Thickness")
                        local Filled = GetFlag(Flags, Flag, "/Box/Filled")

                        local ThicknessAdjust = Floor(Thickness / 2)
                        CornerSize = V2New(
                            (BoxSize.X / 2) * (CornerSize / 100),
                            (BoxSize.Y / 2) * (CornerSize / 100)
                        )

                        local From = AntiAliasingXY(
                            ScreenPosition.X - (BoxSize.X / 2),
                            ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        local To = AntiAliasingXY(
                            ScreenPosition.X - (BoxSize.X / 2),
                            (ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                        )

                        ESP.Drawing.Box.LineLT.Main.Color = Color
                        ESP.Drawing.Box.LineLT.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineLT.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineLT.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineLT.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineLT.Main.From = From - V2New(0, ThicknessAdjust)
                        ESP.Drawing.Box.LineLT.Outline.From = From - V2New(0, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineLT.Main.To = To
                        ESP.Drawing.Box.LineLT.Outline.To = To + V2New(0, 1)

                        From = AntiAliasingXY(
                            ScreenPosition.X - (BoxSize.X / 2),
                            ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                            ScreenPosition.Y - (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineTL.Main.Color = Color
                        ESP.Drawing.Box.LineTL.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineTL.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineTL.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineTL.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineTL.Main.From = From - V2New(ThicknessAdjust, 0)
                        ESP.Drawing.Box.LineTL.Outline.From = From - V2New(ThicknessAdjust + 1, 0)
                        ESP.Drawing.Box.LineTL.Main.To = To
                        ESP.Drawing.Box.LineTL.Outline.To = To + V2New(1, 0)

                        From = AntiAliasingXY(
                            ScreenPosition.X - (BoxSize.X / 2),
                            ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            ScreenPosition.X - (BoxSize.X / 2),
                            (ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                        )

                        ESP.Drawing.Box.LineLB.Main.Color = Color
                        ESP.Drawing.Box.LineLB.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineLB.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineLB.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineLB.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineLB.Main.From = From + V2New(0, ThicknessAdjust)
                        ESP.Drawing.Box.LineLB.Outline.From = From + V2New(0, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineLB.Main.To = To
                        ESP.Drawing.Box.LineLB.Outline.To = To - V2New(0, 1)

                        From = AntiAliasingXY(
                            ScreenPosition.X - (BoxSize.X / 2),
                            ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                            ScreenPosition.Y + (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineBL.Main.Color = Color
                        ESP.Drawing.Box.LineBL.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineBL.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineBL.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineBL.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineBL.Main.From = From - V2New(ThicknessAdjust, 1)
                        ESP.Drawing.Box.LineBL.Outline.From = From - V2New(ThicknessAdjust + 1, 1)
                        ESP.Drawing.Box.LineBL.Main.To = To - V2New(0, 1)
                        ESP.Drawing.Box.LineBL.Outline.To = To - V2New(-1, 1)

                        From = AntiAliasingXY(
                            ScreenPosition.X + (BoxSize.X / 2),
                            ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            ScreenPosition.X + (BoxSize.X / 2),
                            (ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                        )

                        ESP.Drawing.Box.LineRT.Main.Color = Color
                        ESP.Drawing.Box.LineRT.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineRT.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineRT.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineRT.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineRT.Main.From = From - V2New(1, ThicknessAdjust)
                        ESP.Drawing.Box.LineRT.Outline.From = From - V2New(1, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineRT.Main.To = To - V2New(1, 0)
                        ESP.Drawing.Box.LineRT.Outline.To = To + V2New(-1, 1)

                        From = AntiAliasingXY(
                            ScreenPosition.X + (BoxSize.X / 2),
                            ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                            ScreenPosition.Y - (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineTR.Main.Color = Color
                        ESP.Drawing.Box.LineTR.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineTR.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineTR.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineTR.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineTR.Main.From = From + V2New(ThicknessAdjust, 0)
                        ESP.Drawing.Box.LineTR.Outline.From = From + V2New(ThicknessAdjust + 1, 0)
                        ESP.Drawing.Box.LineTR.Main.To = To
                        ESP.Drawing.Box.LineTR.Outline.To = To - V2New(1, 0)

                        From = AntiAliasingXY(
                            ScreenPosition.X + (BoxSize.X / 2),
                            ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            ScreenPosition.X + (BoxSize.X / 2),
                            (ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                        )

                        ESP.Drawing.Box.LineRB.Main.Color = Color
                        ESP.Drawing.Box.LineRB.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineRB.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineRB.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineRB.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineRB.Main.From = From + V2New(-1, ThicknessAdjust)
                        ESP.Drawing.Box.LineRB.Outline.From = From + V2New(-1, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineRB.Main.To = To - V2New(1, 0)
                        ESP.Drawing.Box.LineRB.Outline.To = To - V2New(1, 1)

                        From = AntiAliasingXY(
                            ScreenPosition.X + (BoxSize.X / 2),
                            ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                            ScreenPosition.Y + (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineBR.Main.Color = Color
                        ESP.Drawing.Box.LineBR.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineBR.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineBR.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineBR.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineBR.Main.From = From + V2New(ThicknessAdjust, -1)
                        ESP.Drawing.Box.LineBR.Outline.From = From + V2New(ThicknessAdjust + 1, -1)
                        ESP.Drawing.Box.LineBR.Main.To = To - V2New(0, 1)
                        ESP.Drawing.Box.LineBR.Outline.To = To - V2New(1, 1)

                        if ESP.Drawing.HealthBar.Main.Visible then
                            ESP.Drawing.HealthBar.Main.Color = EvalHealth(HealthPercent)
                            ESP.Drawing.HealthBar.Main.Transparency = Transparency
                            ESP.Drawing.HealthBar.Outline.Transparency = Transparency

                            ESP.Drawing.HealthBar.Outline.Size = AntiAliasingXY(Thickness + 2, BoxSize.Y + (Thickness + 1))
                            ESP.Drawing.HealthBar.Outline.Position = AntiAliasingXY(
                                (ScreenPosition.X - (BoxSize.X / 2)) - Thickness - ThicknessAdjust - 4,
                                ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                            )
                            ESP.Drawing.HealthBar.Main.Size = V2New(ESP.Drawing.HealthBar.Outline.Size.X - 2, -HealthPercent * (ESP.Drawing.HealthBar.Outline.Size.Y - 2))
                            ESP.Drawing.HealthBar.Main.Position = ESP.Drawing.HealthBar.Outline.Position + V2New(1, ESP.Drawing.HealthBar.Outline.Size.Y - 1)
                        end

                        if Textboxes.Name.Visible
                        or Textboxes.Health.Visible
                        or Textboxes.Distance.Visible
                        or Textboxes.Weapon.Visible then
                            local Size = GetFlag(Flags, Flag, "/Name/Size")
                            local Autoscale = GetFlag(Flags, Flag, "/Name/Autoscale")
                            --local Font = GetFont(GetFlag(ESP.Flags, ESP.Flag, "/Name/Font")[1])
                            Autoscale = Floor(GetScaleFactor(Autoscale, Size, Distance))

                            Transparency = 1 - GetFlag(Flags, Flag, "/Name/Transparency")
                            Outline = GetFlag(Flags, Flag, "/Name/Outline")

                            if Textboxes.Name.Visible then
                                Textboxes.Name.Outline = Outline
                                --Textboxes.Name.Font = Font
                                Textboxes.Name.Transparency = Transparency
                                Textboxes.Name.Size = Autoscale
                                Textboxes.Name.Text = Mode == "Player" and Target.Name
                                or (InEnemyTeam and "Enemy NPC" or "Ally NPC")

                                Textboxes.Name.Position = AntiAliasingXY(
                                    ScreenPosition.X,
                                    ScreenPosition.Y - (BoxSize.Y / 2) - Textboxes.Name.TextBounds.Y - ThicknessAdjust - 2
                                )
                            end
                            if Textboxes.Health.Visible then
                                Textboxes.Health.Outline = Outline
                                --Textboxes.Health.Font = Font
                                Textboxes.Health.Transparency = Transparency
                                Textboxes.Health.Size = Autoscale
                                Textboxes.Health.Text = tostring(math.floor(HealthPercent * 100)) .. "%"

                                local HealthPositionX = ESP.Drawing.HealthBar.Main.Visible and ((ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - (Thickness + ThicknessAdjust + 5)) or ((ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - ThicknessAdjust - 2)
                                Textboxes.Health.Position = AntiAliasingXY(
                                    HealthPositionX,
                                    (ScreenPosition.Y - (BoxSize.Y / 2)) - ThicknessAdjust - 1
                                )

                                --ESP.Drawing.Test.Position = Textboxes.Health.Position
                                --ESP.Drawing.Test.Size = V2New(Textboxes.Health.TextBounds.X, Textboxes.Health.TextBounds.Y)
                            end
                            if Textboxes.Distance.Visible then
                                Textboxes.Distance.Outline = Outline
                                --Textboxes.Distance.Font = Font
                                Textboxes.Distance.Transparency = Transparency
                                Textboxes.Distance.Size = Autoscale
                                Textboxes.Distance.Text = tostring(math.floor(Distance)) .. " studs"

                                Textboxes.Distance.Position = AntiAliasingXY(
                                    ScreenPosition.X,
                                    (ScreenPosition.Y + (BoxSize.Y / 2)) + ThicknessAdjust + 2
                                )

                                --ESP.Drawing.Test.Position = Textboxes.Distance.Position
                                --ESP.Drawing.Test.Size = V2New(Textboxes.Distance.TextBounds.X, Textboxes.Distance.TextBounds.Y)
                            end
                            if Textboxes.Weapon.Visible then
                                local Weapon = GetWeapon(Target, Character, Mode)

                                Textboxes.Weapon.Outline = Outline
                                --Textboxes.Weapon.Font = Font
                                Textboxes.Weapon.Transparency = Transparency
                                Textboxes.Weapon.Size = Autoscale
                                Textboxes.Weapon.Text = Weapon

                                Textboxes.Weapon.Position = AntiAliasingXY(
                                    (ScreenPosition.X + (BoxSize.X / 2)) + ThicknessAdjust + 2,
                                    ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                                )

                                --ESP.Drawing.Test.Position = Textboxes.Weapon.Position
                                --ESP.Drawing.Test.Size = V2New(Textboxes.Weapon.TextBounds.X, Textboxes.Weapon.TextBounds.Y)
                            end
                        end
                    end
                end
            else
                if ESP.Drawing.Arrow.Main.Visible then
                    Distance = GetDistance(RootPart.Position)
                    InTheRange = IsWithinReach(GetFlag(Flags, Flag, "/DistanceCheck"), GetFlag(Flags, Flag, "/Distance"), Distance)
                    Health, MaxHealth, IsAlive = GetHealth(Target, Character, Mode)
                    InEnemyTeam, TeamColor = GetTeam(Target, Character, Mode)
                    Color = GetFlag(Flags, Flag, "/TeamColor") and TeamColor
                    or (InEnemyTeam and GetFlag(Flags, Flag, "/Enemy")[6]
                    or GetFlag(Flags, Flag, "/Ally")[6])

                    local Direction = GetRelative(RootPart.Position).Unit
                    local SideLength = GetFlag(Flags, Flag, "/Arrow/Width") / 2
                    local ArrowRadius = GetFlag(Flags, Flag, "/Arrow/Radius")
                    local Base, Radians90 = Direction * ArrowRadius, Rad(90)

                    local PointA = RelativeToCenter(Base + RotateVector(Direction, Radians90) * SideLength)
                    local PointB = RelativeToCenter(Direction * (ArrowRadius + GetFlag(Flags, Flag, "/Arrow/Height")))
                    local PointC = RelativeToCenter(Base + RotateVector(Direction, -Radians90) * SideLength)

                    local Filled = GetFlag(Flags, Flag, "/Arrow/Filled")
                    local Thickness = GetFlag(Flags, Flag, "/Arrow/Thickness")
                    local Transparency = 1 - GetFlag(Flags, Flag, "/Arrow/Transparency")

                    ESP.Drawing.Arrow.Main.Color = Color

                    ESP.Drawing.Arrow.Main.Filled = Filled

                    ESP.Drawing.Arrow.Main.Thickness = Thickness
                    ESP.Drawing.Arrow.Outline.Thickness = Thickness + 2

                    ESP.Drawing.Arrow.Main.Transparency = Transparency
                    ESP.Drawing.Arrow.Outline.Transparency = Transparency

                    ESP.Drawing.Arrow.Main.PointA = PointA
                    ESP.Drawing.Arrow.Outline.PointA = PointA
                    ESP.Drawing.Arrow.Main.PointB = PointB
                    ESP.Drawing.Arrow.Outline.PointB = PointB
                    ESP.Drawing.Arrow.Main.PointC = PointC
                    ESP.Drawing.Arrow.Outline.PointC = PointC
                end
            end
        end

        local TeamCheck = (not GetFlag(Flags, Flag, "/TeamCheck") and not InEnemyTeam) or InEnemyTeam
        local Visible = RootPart and OnScreen and InTheRange and IsAlive and TeamCheck
        local ArrowVisible = RootPart and (not OnScreen) and InTheRange and IsAlive and TeamCheck

        -- if ESP.Highlight then
        --     ESP.Highlight.Enabled = Visible and GetFlag(Flags, Flag, "/Highlight/Enabled") or false
        -- end

        ESP.Drawing.Box.Visible = Visible and GetFlag(Flags, Flag, "/Box/Enabled") or false
        ESP.Drawing.Box.OutlineVisible = ESP.Drawing.Box.Visible and GetFlag(Flags, Flag, "/Box/Outline") or false

        for Index, Line in pairs(ESP.Drawing.Box) do
            if type(Line) ~= "table" then continue end
            Line.Main.Visible = ESP.Drawing.Box.Visible
            Line.Outline.Visible = ESP.Drawing.Box.OutlineVisible
        end

        ESP.Drawing.HealthBar.Main.Visible = ESP.Drawing.Box.Visible and GetFlag(Flags, Flag, "/Box/HealthBar") and not BoxTooSmall or false
        ESP.Drawing.HealthBar.Outline.Visible = ESP.Drawing.HealthBar.Main.Visible and GetFlag(Flags, Flag, "/Box/Outline") or false

        ESP.Drawing.Arrow.Main.Visible = ArrowVisible and GetFlag(Flags, Flag, "/Arrow/Enabled") or false
        ESP.Drawing.Arrow.Outline.Visible = GetFlag(Flags, Flag, "/Arrow/Outline") and ESP.Drawing.Arrow.Main.Visible or false

        ESP.Drawing.HeadDot.Main.Visible = Visible and GetFlag(Flags, Flag, "/HeadDot/Enabled") or false
        ESP.Drawing.HeadDot.Outline.Visible = GetFlag(Flags, Flag, "/HeadDot/Outline") and ESP.Drawing.HeadDot.Main.Visible or false

        ESP.Drawing.Tracer.Main.Visible = Visible and GetFlag(Flags, Flag, "/Tracer/Enabled") or false
        ESP.Drawing.Tracer.Outline.Visible = GetFlag(Flags, Flag, "/Tracer/Outline") and ESP.Drawing.Tracer.Main.Visible or false

        ESP.Drawing.Textboxes.Name.Visible = Visible and GetFlag(Flags, Flag, "/Name/Enabled") or false
        ESP.Drawing.Textboxes.Health.Visible = Visible and GetFlag(Flags, Flag, "/Health/Enabled") or false
        ESP.Drawing.Textboxes.Distance.Visible = Visible and GetFlag(Flags, Flag, "/Distance/Enabled") or false
        ESP.Drawing.Textboxes.Weapon.Visible = Visible and GetFlag(Flags, Flag, "/Weapon/Enabled") or false

        debug.profileend()
    end)
end]]

function DrawingLibrary.AddObject(Self, Object, ObjectName, ObjectPosition, GlobalFlag, Flag, Flags)
    if Self.ObjectESP[Object] then return end

    Self.ObjectESP[Object] = {
        Target = {Name = ObjectName, Position = ObjectPosition},
        Flag = Flag, GlobalFlag = GlobalFlag, Flags = Flags,
        IsBasePart = typeof(ObjectPosition) ~= "Vector3",

        Name = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = true, Outline = true, Color = WhiteColor, Font = Fonts.Plex })
    }

    if Self.ObjectESP[Object].IsBasePart then
        Self.ObjectESP[Object].Target.RootPart = ObjectPosition
        Self.ObjectESP[Object].Target.Position = ObjectPosition.Position
    end
end
function DrawingLibrary.AddESP(Self, Target, Mode, Flag, Flags)
    if Self.ESP[Target] then return end

    -- Things with Visible = false, ZIndex = 0 properties table can be removed
    Self.ESP[Target] = {
        Target = {}, Mode = Mode,
        Flag = Flag, Flags = Flags,
        Drawing = {
            Box = {
                Visible = false,
                OutlineVisible = false,
                LineLT = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineTL = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineLB = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineBL = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineRT = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineTR = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineRB = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                },
                LineBR = {
                    Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                    Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 })
                }
            },
            HealthBar = {
                Main = AddDrawing("Square", { Visible = false, ZIndex = 1, Filled = true }),
                Outline = AddDrawing("Square", { Visible = false, ZIndex = 0, Filled = true })
            },
            Tracer = {
                Main = AddDrawing("Line", { Visible = false, ZIndex = 1 }),
                Outline = AddDrawing("Line", { Visible = false, ZIndex = 0 }),
            },
            HeadDot = {
                Main = AddDrawing("Circle", { Visible = false, ZIndex = 1 }),
                Outline = AddDrawing("Circle", { Visible = false, ZIndex = 0 }),
            },
            Arrow = {
                Main = AddDrawing("Triangle", { Visible = false, ZIndex = 1 }),
                Outline = AddDrawing("Triangle", { Visible = false, ZIndex = 0 }),
            },
            Textboxes = {
                Name = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = true, Outline = true, Color = WhiteColor, Font = Fonts.Plex }),
                Distance = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = true, Outline = true, Color = WhiteColor, Font = Fonts.Plex }),
                Health = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = false, Outline = true, Color = WhiteColor, Font = Fonts.Plex }),
                Weapon = AddDrawing("Text", { Visible = false, ZIndex = 0, Center = false, Outline = true, Color = WhiteColor, Font = Fonts.Plex })
            },
            --Test = AddDrawing("Square", { Visible = true, ZIndex = -1, Filled = true })
        }
    }

    --Self.ESP[Target].Connection = Self:InitRender(Target, Mode, Flag, Flags)
    --Self.ESP[Target].Highlight = HighlightNew(Target, Self.ESP[Target].RESP)
end

function DrawingLibrary.RemoveESP(Self, Target)
    local ESP = Self.ESP[Target]
    if not ESP then return end

    --ESP.Connection:Disconnect()
    ClearDrawing(ESP.Drawing)

    Clear(Self.ESP[Target])
    Self.ESP[Target] = nil
end

function DrawingLibrary.RemoveObject(Self, Target)
    local ESP = Self.ObjectESP[Target]
    if not ESP then return end
    ESP.Name:Destroy()

    Clear(Self.ObjectESP[Target])
    Self.ObjectESP[Target] = nil
end

function DrawingLibrary.SetupCursor(Window)
    local Cursor = AddDrawing("Image", {
        Size = V2New(64, 64) / 1.5,
        Data = Parvus.Cursor,
        --Rounding = 0,

        --Transparency = 1,
        --Visible = false,
        ZIndex = 3
    })

    RunService.Heartbeat:Connect(function()
        Cursor.Visible = Window.Flags["Mouse/Enabled"] and Window.Enabled and UserInputService.MouseBehavior == Enum.MouseBehavior.Default
        if Cursor.Visible then Cursor.Position = UserInputService:GetMouseLocation() - Cursor.Size / 2 end
    end)
end

function DrawingLibrary.SetupCrosshair(Flags)
    local CrosshairL = AddDrawing("Line", { Thickness = 1.5, Transparency = 1, Visible = false, ZIndex = 2 })
    local CrosshairR = AddDrawing("Line", { Thickness = 1.5, Transparency = 1, Visible = false, ZIndex = 2 })
    local CrosshairT = AddDrawing("Line", { Thickness = 1.5, Transparency = 1, Visible = false, ZIndex = 2 })
    local CrosshairB = AddDrawing("Line", { Thickness = 1.5, Transparency = 1, Visible = false, ZIndex = 2 })

    RunService.Heartbeat:Connect(function()
        local CrosshairEnabled = Flags["Crosshair/Enabled"] and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
        CrosshairL.Visible, CrosshairR.Visible, CrosshairT.Visible, CrosshairB.Visible = CrosshairEnabled, CrosshairEnabled, CrosshairEnabled, CrosshairEnabled

        if CrosshairEnabled then
            local MouseLocation = UserInputService:GetMouseLocation()
            local Color = Flags["Crosshair/Color"]
            local Size = Flags["Crosshair/Size"]
            local Gap = Flags["Crosshair/Gap"]
            local Transparency = 1 - Color[4]
            Color = Color[6]

            CrosshairL.Color = Color
            CrosshairL.Transparency = Transparency
            CrosshairL.From = MouseLocation - V2New(Gap, 0)
            CrosshairL.To = MouseLocation - V2New(Size + Gap, 0)

            CrosshairR.Color = Color
            CrosshairR.Transparency = Transparency
            CrosshairR.From = MouseLocation + V2New(Gap + 1, 0)
            CrosshairR.To = MouseLocation + V2New(Size + (Gap + 1), 0)

            CrosshairT.Color = Color
            CrosshairT.Transparency = Transparency
            CrosshairT.From = MouseLocation - V2New(0, Gap)
            CrosshairT.To = MouseLocation - V2New(0, Size + Gap)

            CrosshairB.Color = Color
            CrosshairB.Transparency = Transparency
            CrosshairB.From = MouseLocation + V2New(0, Gap + 1)
            CrosshairB.To = MouseLocation + V2New(0, Size + (Gap + 1))
        end
    end)
end

function DrawingLibrary.SetupFOV(Flag, Flags)
    local FOV = AddDrawing("Circle", { ZIndex = 4 })
    local FOVOutline = AddDrawing("Circle", { ZIndex = 3 })

    RunService.Heartbeat:Connect(function()
        local Visible = GetFlag(Flags, Flag, "/Enabled")
        and GetFlag(Flags, Flag, "/FOV/Enabled")

        FOV.Visible = Visible
        FOVOutline.Visible = Visible

        if Visible then
            local MouseLocation = UserInputService:GetMouseLocation()
            local Thickness = GetFlag(Flags, Flag, "/FOV/Thickness")
            local NumSides = GetFlag(Flags, Flag, "/FOV/NumSides")
            local Filled = GetFlag(Flags, Flag, "/FOV/Filled")
            local Radius = GetFlag(Flags, Flag, "/FOV/Radius")
            local Color = GetFlag(Flags, Flag, "/FOV/Color")
            local Transparency = 1 - Color[4]
            Color = Color[6]

            FOV.Color = Color

            FOV.Transparency = Transparency
            FOVOutline.Transparency = Transparency

            FOV.Thickness = Thickness
            FOVOutline.Thickness = Thickness + 2
            
            FOV.NumSides = NumSides
            FOVOutline.NumSides = NumSides

            FOV.Filled = Filled
            --FOVOutline.Filled = Filled

            FOV.Radius = Radius
            FOVOutline.Radius = Radius

            FOV.Position = MouseLocation
            FOVOutline.Position = MouseLocation
        end
    end)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

DrawingLibrary.Connection = RunService.RenderStepped:Connect(function()
    debug.profilebegin("PARVUS_DRAWING")
    for Target, ESP in pairs(DrawingLibrary.ESP) do
        DrawingLibrary.Update(ESP, Target)
    end
    for Object, ESP in pairs(DrawingLibrary.ObjectESP) do
        --DrawingLibrary.UpdateObject(ESP, Object)
        if not GetFlag(ESP.Flags, ESP.GlobalFlag, "/Enabled")
        or not GetFlag(ESP.Flags, ESP.Flag, "/Enabled") then
            ESP.Name.Visible = false
            continue
        end

        ESP.Target.Position = ESP.IsBasePart and ESP.Target.RootPart.Position or ESP.Target.Position
        ESP.Target.ScreenPosition, ESP.Target.OnScreen = WorldToScreen(ESP.Target.Position)

        ESP.Target.Distance = GetDistance(ESP.Target.Position)
        ESP.Target.InTheRange = IsWithinReach(GetFlag(ESP.Flags, ESP.GlobalFlag, "/DistanceCheck"),
        GetFlag(ESP.Flags, ESP.GlobalFlag, "/Distance"), ESP.Target.Distance)

        ESP.Name.Visible = (ESP.Target.OnScreen and ESP.Target.InTheRange) or false

        if ESP.Name.Visible then
            local Color = GetFlag(ESP.Flags, ESP.Flag, "/Color")
            ESP.Name.Transparency = 1 - Color[4]
            ESP.Name.Color = Color[6]

            ESP.Name.Position = ESP.Target.ScreenPosition
            ESP.Name.Text = string.format("%s\n%i studs", ESP.Target.Name, ESP.Target.Distance)
        end
    end
    debug.profileend()
end)

--[[DrawingLibrary.Connection = RunService.RenderStepped:Connect(function()
    debug.profilebegin("PARVUS_DRAWING")
    for Target, ESP in pairs(DrawingLibrary.ESP) do
        ESP.Target.Character, ESP.Target.RootPart = GetCharacter(Target, ESP.Mode)
        if ESP.Target.Character and ESP.Target.RootPart then
            ESP.Target.ScreenPosition, ESP.Target.OnScreen = WorldToScreen(ESP.Target.RootPart.Position)

            if ESP.Target.OnScreen then
                ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)
                ESP.Target.InTheRange = IsWithinReach(GetFlag(ESP.Flags, ESP.Flag, "/DistanceCheck"), GetFlag(ESP.Flags, ESP.Flag, "/Distance"), ESP.Target.Distance)

                if ESP.Target.InTheRange then
                    ESP.Target.Health, ESP.Target.MaxHealth, ESP.Target.IsAlive = GetHealth(Target, ESP.Target.Character, ESP.Mode)
                    ESP.Target.InEnemyTeam, ESP.Target.TeamColor = GetTeam(Target, ESP.Target.Character, ESP.Mode)
                    ESP.Target.Color = GetFlag(ESP.Flags, ESP.Flag, "/TeamColor") and ESP.Target.TeamColor
                    or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags, ESP.Flag, "/Enemy")[6]
                    or GetFlag(ESP.Flags, ESP.Flag, "/Ally")[6])

                    -- if ESP.Highlight and ESP.Highlight.Enabled then
                    --     local OutlineColor = GetFlag(ESP.Flags, Flag, "/Highlight/OutlineColor")
                    --     ESP.Highlight.DepthMode = GetFlag(ESP.Flags, Flag, "/Highlight/Occluded")
                    --     and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                    --     --ESP.Highlight.Adornee = Character
                    --     ESP.Highlight.FillColor = ESP.Target.Color
                    --     ESP.Highlight.OutlineColor = OutlineColor[6]
                    --     ESP.Highlight.OutlineTransparency = OutlineColor[4]
                    --     ESP.Highlight.FillTransparency = GetFlag(ESP.Flags, Flag, "/Highlight/Transparency")
                    -- end

                    if ESP.Drawing.Tracer.Main.Visible or ESP.Drawing.HeadDot.Main.Visible then
                        local Head = FindFirstChild(ESP.Target.Character, "Head", true)

                        if Head then
                            local HeadPosition = WorldToScreen(Head.Position)

                            if ESP.Drawing.Tracer.Main.Visible then
                                local FromPosition = GetFlag(ESP.Flags, ESP.Flag, "/Tracer/Mode")
                                local Thickness = GetFlag(ESP.Flags, ESP.Flag, "/Tracer/Thickness")
                                local Transparency = 1 - GetFlag(ESP.Flags, ESP.Flag, "/Tracer/Transparency")
                                FromPosition = (FromPosition[1] == "From Mouse" and UserInputService:GetMouseLocation())
                                or (FromPosition[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y))

                                ESP.Drawing.Tracer.Main.Color = ESP.Target.Color

                                ESP.Drawing.Tracer.Main.Thickness = Thickness
                                ESP.Drawing.Tracer.Outline.Thickness = Thickness + 2

                                ESP.Drawing.Tracer.Main.Transparency = Transparency
                                ESP.Drawing.Tracer.Outline.Transparency = Transparency

                                ESP.Drawing.Tracer.Main.From = FromPosition
                                ESP.Drawing.Tracer.Outline.From = FromPosition

                                ESP.Drawing.Tracer.Main.To = HeadPosition
                                ESP.Drawing.Tracer.Outline.To = HeadPosition
                            end
                            if ESP.Drawing.HeadDot.Main.Visible then
                                local Filled = GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Filled")
                                local Radius = GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Radius")
                                local NumSides = GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/NumSides")
                                local Thickness = GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Thickness")
                                local Autoscale = GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Autoscale")
                                local Transparency = 1 - GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Transparency")
                                Radius = GetScaleFactor(Autoscale, Radius, ESP.Target.Distance)

                                ESP.Drawing.HeadDot.Main.Color = ESP.Target.Color

                                ESP.Drawing.HeadDot.Main.Transparency = Transparency
                                ESP.Drawing.HeadDot.Outline.Transparency = Transparency

                                ESP.Drawing.HeadDot.Main.NumSides = NumSides
                                ESP.Drawing.HeadDot.Outline.NumSides = NumSides

                                ESP.Drawing.HeadDot.Main.Radius = Radius
                                ESP.Drawing.HeadDot.Outline.Radius = Radius

                                ESP.Drawing.HeadDot.Main.Thickness = Thickness
                                ESP.Drawing.HeadDot.Outline.Thickness = Thickness + 2

                                ESP.Drawing.HeadDot.Main.Filled = Filled

                                ESP.Drawing.HeadDot.Main.Position = HeadPosition
                                ESP.Drawing.HeadDot.Outline.Position = HeadPosition
                            end
                        end
                    end
                    if ESP.Drawing.Box.Visible then
                        local BoxSize = CalculateBoxSize(ESP.Target.Character, ESP.Target.Distance)
                        local HealthPercent = ESP.Target.Health / ESP.Target.MaxHealth
                        local Textboxes = ESP.Drawing.Textboxes
                        ESP.Target.BoxTooSmall = BoxSize.Y < 18

                        local Transparency = 1 - GetFlag(ESP.Flags, ESP.Flag, "/Box/Transparency")
                        local CornerSize = GetFlag(ESP.Flags, ESP.Flag, "/Box/CornerSize")
                        local Thickness = GetFlag(ESP.Flags, ESP.Flag, "/Box/Thickness")
                        local Filled = GetFlag(ESP.Flags, ESP.Flag, "/Box/Filled")

                        local ThicknessAdjust = Floor(Thickness / 2)
                        CornerSize = V2New(
                            (BoxSize.X / 2) * (CornerSize / 100),
                            (BoxSize.Y / 2) * (CornerSize / 100)
                        )

                        local From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X - (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        local To = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X - (BoxSize.X / 2),
                            (ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                        )

                        ESP.Drawing.Box.LineLT.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineLT.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineLT.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineLT.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineLT.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineLT.Main.From = From - V2New(0, ThicknessAdjust)
                        ESP.Drawing.Box.LineLT.Outline.From = From - V2New(0, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineLT.Main.To = To
                        ESP.Drawing.Box.LineLT.Outline.To = To + V2New(0, 1)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X - (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ESP.Target.ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                            ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineTL.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineTL.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineTL.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineTL.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineTL.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineTL.Main.From = From - V2New(ThicknessAdjust, 0)
                        ESP.Drawing.Box.LineTL.Outline.From = From - V2New(ThicknessAdjust + 1, 0)
                        ESP.Drawing.Box.LineTL.Main.To = To
                        ESP.Drawing.Box.LineTL.Outline.To = To + V2New(1, 0)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X - (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X - (BoxSize.X / 2),
                            (ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                        )

                        ESP.Drawing.Box.LineLB.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineLB.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineLB.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineLB.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineLB.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineLB.Main.From = From + V2New(0, ThicknessAdjust)
                        ESP.Drawing.Box.LineLB.Outline.From = From + V2New(0, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineLB.Main.To = To
                        ESP.Drawing.Box.LineLB.Outline.To = To - V2New(0, 1)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X - (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ESP.Target.ScreenPosition.X - (BoxSize.X / 2)) + CornerSize.X,
                            ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineBL.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineBL.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineBL.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineBL.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineBL.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineBL.Main.From = From - V2New(ThicknessAdjust, 1)
                        ESP.Drawing.Box.LineBL.Outline.From = From - V2New(ThicknessAdjust + 1, 1)
                        ESP.Drawing.Box.LineBL.Main.To = To - V2New(0, 1)
                        ESP.Drawing.Box.LineBL.Outline.To = To - V2New(-1, 1)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X + (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X + (BoxSize.X / 2),
                            (ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)) + CornerSize.Y
                        )

                        ESP.Drawing.Box.LineRT.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineRT.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineRT.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineRT.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineRT.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineRT.Main.From = From - V2New(1, ThicknessAdjust)
                        ESP.Drawing.Box.LineRT.Outline.From = From - V2New(1, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineRT.Main.To = To - V2New(1, 0)
                        ESP.Drawing.Box.LineRT.Outline.To = To + V2New(-1, 1)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X + (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ESP.Target.ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                            ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineTR.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineTR.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineTR.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineTR.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineTR.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineTR.Main.From = From + V2New(ThicknessAdjust, 0)
                        ESP.Drawing.Box.LineTR.Outline.From = From + V2New(ThicknessAdjust + 1, 0)
                        ESP.Drawing.Box.LineTR.Main.To = To
                        ESP.Drawing.Box.LineTR.Outline.To = To - V2New(1, 0)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X + (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X + (BoxSize.X / 2),
                            (ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)) - CornerSize.Y
                        )

                        ESP.Drawing.Box.LineRB.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineRB.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineRB.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineRB.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineRB.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineRB.Main.From = From + V2New(-1, ThicknessAdjust)
                        ESP.Drawing.Box.LineRB.Outline.From = From + V2New(-1, ThicknessAdjust + 1)
                        ESP.Drawing.Box.LineRB.Main.To = To - V2New(1, 0)
                        ESP.Drawing.Box.LineRB.Outline.To = To - V2New(1, 1)

                        From = AntiAliasingXY(
                            ESP.Target.ScreenPosition.X + (BoxSize.X / 2),
                            ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)
                        )
                        To = AntiAliasingXY(
                            (ESP.Target.ScreenPosition.X + (BoxSize.X / 2)) - CornerSize.X,
                            ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)
                        )

                        ESP.Drawing.Box.LineBR.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.LineBR.Main.Thickness = Thickness
                        ESP.Drawing.Box.LineBR.Outline.Thickness = Thickness + 2
                        ESP.Drawing.Box.LineBR.Main.Transparency = Transparency
                        ESP.Drawing.Box.LineBR.Outline.Transparency = Transparency
                        ESP.Drawing.Box.LineBR.Main.From = From + V2New(ThicknessAdjust, -1)
                        ESP.Drawing.Box.LineBR.Outline.From = From + V2New(ThicknessAdjust + 1, -1)
                        ESP.Drawing.Box.LineBR.Main.To = To - V2New(0, 1)
                        ESP.Drawing.Box.LineBR.Outline.To = To - V2New(1, 1)

                        if ESP.Drawing.HealthBar.Main.Visible then
                            ESP.Drawing.HealthBar.Main.Color = EvalHealth(HealthPercent)
                            ESP.Drawing.HealthBar.Main.Transparency = Transparency
                            ESP.Drawing.HealthBar.Outline.Transparency = Transparency

                            ESP.Drawing.HealthBar.Outline.Size = AntiAliasingXY(Thickness + 2, BoxSize.Y + (Thickness + 1))
                            ESP.Drawing.HealthBar.Outline.Position = AntiAliasingXY(
                                (ESP.Target.ScreenPosition.X - (BoxSize.X / 2)) - Thickness - ThicknessAdjust - 4,
                                ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                            )
                            ESP.Drawing.HealthBar.Main.Size = V2New(ESP.Drawing.HealthBar.Outline.Size.X - 2, -HealthPercent * (ESP.Drawing.HealthBar.Outline.Size.Y - 2))
                            ESP.Drawing.HealthBar.Main.Position = ESP.Drawing.HealthBar.Outline.Position + V2New(1, ESP.Drawing.HealthBar.Outline.Size.Y - 1)
                        end

                        if Textboxes.Name.Visible
                        or Textboxes.Health.Visible
                        or Textboxes.Distance.Visible
                        or Textboxes.Weapon.Visible then
                            local Size = GetFlag(ESP.Flags, ESP.Flag, "/Name/Size")
                            local Autoscale = GetFlag(ESP.Flags, ESP.Flag, "/Name/Autoscale")
                            --local Font = GetFont(GetFlag(ESP.ESP.Flags, ESP.ESP.Flag, "/Name/Font")[1])
                            Autoscale = Floor(GetScaleFactor(Autoscale, Size, ESP.Target.Distance))

                            Transparency = 1 - GetFlag(ESP.Flags, ESP.Flag, "/Name/Transparency")
                            Outline = GetFlag(ESP.Flags, ESP.Flag, "/Name/Outline")

                            if Textboxes.Name.Visible then
                                Textboxes.Name.Outline = Outline
                                --Textboxes.Name.Font = Font
                                Textboxes.Name.Transparency = Transparency
                                Textboxes.Name.Size = Autoscale
                                Textboxes.Name.Text = ESP.Mode == "Player" and Target.Name
                                or (InEnemyTeam and "Enemy NPC" or "Ally NPC")

                                Textboxes.Name.Position = AntiAliasingXY(
                                    ESP.Target.ScreenPosition.X,
                                    ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2) - Textboxes.Name.TextBounds.Y - ThicknessAdjust - 2
                                )
                            end
                            if Textboxes.Health.Visible then
                                Textboxes.Health.Outline = Outline
                                --Textboxes.Health.Font = Font
                                Textboxes.Health.Transparency = Transparency
                                Textboxes.Health.Size = Autoscale
                                Textboxes.Health.Text = tostring(math.floor(HealthPercent * 100)) .. "%"

                                local HealthPositionX = ESP.Drawing.HealthBar.Main.Visible and ((ESP.Target.ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - (Thickness + ThicknessAdjust + 5)) or ((ESP.Target.ScreenPosition.X - (BoxSize.X / 2)) - Textboxes.Health.TextBounds.X - ThicknessAdjust - 2)
                                Textboxes.Health.Position = AntiAliasingXY(
                                    HealthPositionX,
                                    (ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2)) - ThicknessAdjust - 1
                                )

                                --ESP.Drawing.Test.Position = Textboxes.Health.Position
                                --ESP.Drawing.Test.Size = V2New(Textboxes.Health.TextBounds.X, Textboxes.Health.TextBounds.Y)
                            end
                            if Textboxes.Distance.Visible then
                                Textboxes.Distance.Outline = Outline
                                --Textboxes.Distance.Font = Font
                                Textboxes.Distance.Transparency = Transparency
                                Textboxes.Distance.Size = Autoscale
                                Textboxes.Distance.Text = tostring(math.floor(ESP.Target.Distance)) .. " studs"

                                Textboxes.Distance.Position = AntiAliasingXY(
                                    ESP.Target.ScreenPosition.X,
                                    (ESP.Target.ScreenPosition.Y + (BoxSize.Y / 2)) + ThicknessAdjust + 2
                                )

                                --ESP.Drawing.Test.Position = Textboxes.Distance.Position
                                --ESP.Drawing.Test.Size = V2New(Textboxes.Distance.TextBounds.X, Textboxes.Distance.TextBounds.Y)
                            end
                            if Textboxes.Weapon.Visible then
                                local Weapon = GetWeapon(Target, Character, ESP.Mode)

                                Textboxes.Weapon.Outline = Outline
                                --Textboxes.Weapon.Font = Font
                                Textboxes.Weapon.Transparency = Transparency
                                Textboxes.Weapon.Size = Autoscale
                                Textboxes.Weapon.Text = Weapon

                                Textboxes.Weapon.Position = AntiAliasingXY(
                                    (ESP.Target.ScreenPosition.X + (BoxSize.X / 2)) + ThicknessAdjust + 2,
                                    ESP.Target.ScreenPosition.Y - (BoxSize.Y / 2) - ThicknessAdjust - 1
                                )

                                --ESP.Drawing.Test.Position = Textboxes.Weapon.Position
                                --ESP.Drawing.Test.Size = V2New(Textboxes.Weapon.TextBounds.X, Textboxes.Weapon.TextBounds.Y)
                            end
                        end
                    end
                end
            else
                if ESP.Drawing.Arrow.Main.Visible then
                    ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)
                    ESP.Target.InTheRange = IsWithinReach(GetFlag(ESP.Flags, ESP.Flag, "/DistanceCheck"), GetFlag(ESP.Flags, ESP.Flag, "/Distance"), ESP.Target.Distance)
                    ESP.Target.Health, ESP.Target.MaxHealth, ESP.Target.IsAlive = GetHealth(Target, ESP.Target.Character, ESP.Mode)
                    ESP.Target.InEnemyTeam, ESP.Target.TeamColor = GetTeam(Target, ESP.Target.Character, ESP.Mode)
                    ESP.Target.Color = GetFlag(ESP.Flags, ESP.Flag, "/TeamColor") and ESP.Target.TeamColor
                    or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags, ESP.Flag, "/Enemy")[6]
                    or GetFlag(ESP.Flags, ESP.Flag, "/Ally")[6])

                    local Direction = GetRelative(ESP.Target.RootPart.Position).Unit
                    local SideLength = GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Width") / 2
                    local ArrowRadius = GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Radius")
                    local Base, Radians90 = Direction * ArrowRadius, Rad(90)

                    local PointA = RelativeToCenter(Base + RotateVector(Direction, Radians90) * SideLength)
                    local PointB = RelativeToCenter(Direction * (ArrowRadius + GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Height")))
                    local PointC = RelativeToCenter(Base + RotateVector(Direction, -Radians90) * SideLength)

                    local Filled = GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Filled")
                    local Thickness = GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Thickness")
                    local Transparency = 1 - GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Transparency")

                    ESP.Drawing.Arrow.Main.Color = ESP.Target.Color

                    ESP.Drawing.Arrow.Main.Filled = Filled

                    ESP.Drawing.Arrow.Main.Thickness = Thickness
                    ESP.Drawing.Arrow.Outline.Thickness = Thickness + 2

                    ESP.Drawing.Arrow.Main.Transparency = Transparency
                    ESP.Drawing.Arrow.Outline.Transparency = Transparency

                    ESP.Drawing.Arrow.Main.PointA = PointA
                    ESP.Drawing.Arrow.Outline.PointA = PointA
                    ESP.Drawing.Arrow.Main.PointB = PointB
                    ESP.Drawing.Arrow.Outline.PointB = PointB
                    ESP.Drawing.Arrow.Main.PointC = PointC
                    ESP.Drawing.Arrow.Outline.PointC = PointC
                end
            end
        end

        local TeamCheck = (not GetFlag(ESP.Flags, ESP.Flag, "/TeamCheck") and not ESP.Target.InEnemyTeam) or ESP.Target.InEnemyTeam
        local Visible = ESP.Target.RootPart and ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.IsAlive and TeamCheck
        local ArrowVisible = ESP.Target.RootPart and (not ESP.Target.OnScreen) and ESP.Target.InTheRange and ESP.Target.IsAlive and TeamCheck

        -- if ESP.Highlight then
        --     ESP.Highlight.Enabled = Visible and GetFlag(ESP.Flags, ESP.Flag, "/Highlight/Enabled") or false
        -- end

        ESP.Drawing.Box.Visible = Visible and GetFlag(ESP.Flags, ESP.Flag, "/Box/Enabled") or false
        ESP.Drawing.Box.OutlineVisible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Box/Outline") or false

        for Index, Line in pairs(ESP.Drawing.Box) do
            if type(Line) ~= "table" then continue end
            Line.Main.Visible = ESP.Drawing.Box.Visible
            Line.Outline.Visible = ESP.Drawing.Box.OutlineVisible
        end

        ESP.Drawing.HealthBar.Main.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Box/HealthBar") and not ESP.Target.BoxTooSmall or false
        ESP.Drawing.HealthBar.Outline.Visible = ESP.Drawing.HealthBar.Main.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Box/Outline") or false

        ESP.Drawing.Arrow.Main.Visible = ArrowVisible and GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Enabled") or false
        ESP.Drawing.Arrow.Outline.Visible = GetFlag(ESP.Flags, ESP.Flag, "/Arrow/Outline") and ESP.Drawing.Arrow.Main.Visible or false

        ESP.Drawing.HeadDot.Main.Visible = Visible and GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Enabled") or false
        ESP.Drawing.HeadDot.Outline.Visible = GetFlag(ESP.Flags, ESP.Flag, "/HeadDot/Outline") and ESP.Drawing.HeadDot.Main.Visible or false

        ESP.Drawing.Tracer.Main.Visible = Visible and GetFlag(ESP.Flags, ESP.Flag, "/Tracer/Enabled") or false
        ESP.Drawing.Tracer.Outline.Visible = GetFlag(ESP.Flags, ESP.Flag, "/Tracer/Outline") and ESP.Drawing.Tracer.Main.Visible or false

        ESP.Drawing.Textboxes.Name.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Name/Enabled") or false
        ESP.Drawing.Textboxes.Health.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Health/Enabled") or false
        ESP.Drawing.Textboxes.Distance.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Distance/Enabled") or false
        ESP.Drawing.Textboxes.Weapon.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags, ESP.Flag, "/Weapon/Enabled") or false
    end
    debug.profileend()
end)]]

return DrawingLibrary
