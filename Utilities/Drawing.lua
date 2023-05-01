local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local DrawingLibrary = {ESP = {},ObjectESP = {}}
repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Declarations
local Cos = math.cos
local Rad = math.rad
local Sin = math.sin
local Tan = math.tan
local Clamp = math.clamp
local Floor = math.floor
local Clear = table.clear

local WTVP = Camera.WorldToViewportPoint
local FindFirstChild = Workspace.FindFirstChild
local FindFirstChildOfClass = Workspace.FindFirstChildOfClass
local FindFirstChildWhichIsA = Workspace.FindFirstChildWhichIsA
local PointToObjectSpace = CFrame.identity.PointToObjectSpace

local V2New = Vector2.new
local ColorNew = Color3.new
local RedColor = ColorNew(1,0,0)
local GreenColor = ColorNew(0,1,0)
local WhiteColor = ColorNew(1,1,1)
local BlackColor = ColorNew(0,0,0)
local LerpColor = BlackColor.Lerp
local Fonts = Drawing.Fonts

local CharacterSize = Vector3.new(4,5,1)
local FrameRate = 1/30

if not HighlightContainer then
    local CoreGui = game:GetService("CoreGui")
    getgenv().HighlightContainer = Instance.new("Folder")
    HighlightContainer.Name = "HighlightContainer"
    HighlightContainer.Parent = CoreGui
end

local function HighlightNew()
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = HighlightContainer
    return Highlight
end
local function DrawingNew(Type,Properties)
    local DrawingObject = Drawing.new(Type)
    for Property,Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end return DrawingObject
end

--[[local function GetFontFromName(FontName)
    return (FontName == "UI" and 0)
    or (FontName == "System" and 1)
    or (FontName == "Plex" and 2)
    or (FontName == "Monospace" and 3)
    or 0
end]]

local function GetFlag(F,F1,F2) return F[F1 .. F2] end
local function GetFont(Font) return Fonts[Font] end

local function GetDistance(Position)
    return (Position - Camera.CFrame.Position).Magnitude
end
local function CheckDistance(Enabled,P1,P2)
    if not Enabled then return true end
    return P1 >= P2
end
local function ClampDistance(Enabled,P1,P2)
    if not Enabled then return P1 end
    return Clamp(1 / P2 * 1000,0,P1)
end
local function DynamicFOV(Enabled,FOV)
    if not Enabled then return FOV end
    --return FOV / (Camera.FieldOfView / 80)
    return FOV * (1 + (80 - Camera.FieldOfView) / 100)
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

-- CalculateBox by mickeyrbx (highly edited)
local function CalculateBox(Model,Position,Distance) local Size = CharacterSize --Model:GetExtentsSize()
    local ScaleFactor = 1 / (Distance * Tan(Rad(Camera.FieldOfView / 2)) * 2) * 1000
    Size = AntiAliasingXY(Size.X * ScaleFactor,Size.Y * ScaleFactor)
    return AntiAliasingP(Position - Size / 2),Size
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
    return AntiAliasingP(Camera.ViewportSize / 2 - Size)
end

function GetCharacter(Target,Mode)
    if Mode == "Player" then
        local Character = Target.Character if not Character then return end
        return Character,FindFirstChild(Character,"HumanoidRootPart")
    else return Target,FindFirstChild(Target,"HumanoidRootPart") end
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
    if Target.Neutral then return true,Target.TeamColor.Color else
        return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
    end else return true,WhiteColor end
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
    function GetCharacter(Target,Mode) local Character = Characters[Target]
        if not Character or Character.Parent == nil then return end
        return Character,Character.PrimaryPart
    end
    function GetHealth(Target,Character,Mode) local Health = Character.Health
        return Health.Value,Health.MaxHealth.Value,Health.Value > 0
    end
    function GetTeam(Target,Character,Mode)
        local Team,LPTeam = GetPlayerTeam(Target),GetPlayerTeam(LocalPlayer)
        return LPTeam ~= Team or Team == "FFA",Tortoiseshell.Teams.Colors[Team]
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
        local LPCharacter = LocalPlayer.Character
        if not LPCharacter then return end
        if FindFirstChild(Character,"Team")
        and FindFirstChild(LPCharacter,"Team") then
            if Character.Team.Value ~= LPCharacter.Team.Value
            or Character.Team.Value == "None" then
                return true,Character.PrimaryPart.Color
            end
        end return false,Character.PrimaryPart.Color
    end
elseif game.GameId == 358276974 or game.GameId == 3495983524 then -- Apocalypse Rising 2
    function GetHealth(Target,Character,Mode)
        if not Character.Stats:FindFirstChild("Health") then return -15,100,false end
        local Health = Character.Stats.Health.Base
        return Health.Value,100,Health.Value > 0
    end
    --[[function GetTeam(Target,Character,Mode)
        if Mode == "Player" then
        if Target.Neutral then return true,Target.TeamColor.Color else
            return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
        end else return true,WhiteColor end
    end]]
elseif game.GameId == 1054526971 then -- Blackhawk Rescue Mission 5
    local function RequireModule(Name)
        for Index, Instance in pairs(getloadedmodules()) do
            if Instance.Name == Name then
                return require(Instance)
            end
        end
    end

    repeat task.wait() until RequireModule("SquadInterface")
    local Squads = RequireModule("SquadInterface")
    function GetTeam(Target,Character,Mode)
        if Mode == "Player" then
            if Target.Neutral then
                local LPColor = Squads._tags[LocalPlayer] and Squads._tags[LocalPlayer].Tag.TextLabel.TextColor3 or WhiteColor
                local TargetColor = Squads._tags[Target] and Squads._tags[Target].Tag.TextLabel.TextColor3 or WhiteColor
                return TargetColor == WhiteColor and true or LPColor == TargetColor,TargetColor
            else
                return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
            end
        else
            return not FindFirstChildWhichIsA(Character,"ProximityPrompt",true),WhiteColor
        end
    end
end

function DrawingLibrary:AddObject(Object,ObjectName,ObjectPosition,GlobalFlag,Flag,Flags)
    if DrawingLibrary.ObjectESP[Object] then return end

    DrawingLibrary.ObjectESP[Object] = {
        Target = {Name = ObjectName,Position = ObjectPosition},
        Flag = Flag,GlobalFlag = GlobalFlag,Flags = Flags,
        IsBasePart = typeof(ObjectPosition) ~= "Vector3",

        Name = DrawingNew("Text",{Visible = false,ZIndex = 1,Center = true,Outline = true})
    }

    if DrawingLibrary.ObjectESP[Object].IsBasePart then
        DrawingLibrary.ObjectESP[Object].Target.RootPart = ObjectPosition
        DrawingLibrary.ObjectESP[Object].Target.Position = ObjectPosition.Position
    end
end
function DrawingLibrary:AddESP(Target,Mode,Flag,Flags)
    if DrawingLibrary.ESP[Target] then return end

    DrawingLibrary.ESP[Target] = {
        Target = {},Mode = Mode,
        Flag = Flag,Flags = Flags,
        Highlight = HighlightNew(),
        Drawing = {
            BoxOutline       = DrawingNew("Square",  {Visible = false,ZIndex = 0                                                }),
            Box              = DrawingNew("Square",  {Visible = false,ZIndex = 1                                                }),
            HealthBarOutline = DrawingNew("Square",  {Visible = false,ZIndex = 0,Filled = true                                  }),
            HealthBar        = DrawingNew("Square",  {Visible = false,ZIndex = 1,Filled = true                                  }),
            TracerOutline    = DrawingNew("Line",    {Visible = false,ZIndex = 0                                                }),
            Tracer           = DrawingNew("Line",    {Visible = false,ZIndex = 1                                                }),
            HeadDotOutline   = DrawingNew("Circle",  {Visible = false,ZIndex = 0                                                }),
            HeadDot          = DrawingNew("Circle",  {Visible = false,ZIndex = 1                                                }),
            ArrowOutline     = DrawingNew("Triangle",{Visible = false,ZIndex = 0                                                }),
            Arrow            = DrawingNew("Triangle",{Visible = false,ZIndex = 1                                                }),

            Name             = DrawingNew("Text",    {Visible = false,ZIndex = 1,Center = true,Outline = true,Color = WhiteColor}),
            Distance         = DrawingNew("Text",    {Visible = false,ZIndex = 0,Center = true,Outline = true,Color = WhiteColor}),
            Health           = DrawingNew("Text",    {Visible = false,ZIndex = 0,Center = true,Outline = true,Color = WhiteColor}),
            Weapon           = DrawingNew("Text",    {Visible = false,ZIndex = 0,Center = true,Outline = true,Color = WhiteColor})
        }
    }
end

function DrawingLibrary:RemoveESP(Target)
    local ESP = DrawingLibrary.ESP[Target] if not ESP then return end
    for Index,Value in pairs(ESP.Drawing) do Value:Remove() end
    ESP.Highlight:Destroy()

    Clear(DrawingLibrary.ESP[Target])
    DrawingLibrary.ESP[Target] = nil
end

function DrawingLibrary:RemoveObject(Target)
    local ESP = DrawingLibrary.ObjectESP[Target]
    if not ESP then return end
    ESP.Name:Remove()

    Clear(DrawingLibrary.ObjectESP[Target])
    DrawingLibrary.ObjectESP[Target] = nil
end

function DrawingLibrary:SetupCursor(Flags)
    local Cursor = DrawingNew("Image",{
        Size = V2New(64,64) / 1.5,
        Data = Parvus.Cursor,
        Rounding = 0,

        Transparency = 1,
        Visible = false,
        ZIndex = 3
    })

    RunService.Heartbeat:Connect(function()
        Cursor.Visible = Flags["Mouse/Enabled"] and UserInputService.MouseBehavior == Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
        if Cursor.Visible then Cursor.Position = UserInputService:GetMouseLocation() - Cursor.Size / 2 end
    end)
end

function DrawingLibrary:SetupCrosshair(Flags)
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

function DrawingLibrary:FOVCircle(Flag,Flags)
    local FOVCircle = DrawingNew("Circle",{ZIndex = 4})
    local Outline   = DrawingNew("Circle",{ZIndex = 3})

    RunService.Heartbeat:Connect(function()
        FOVCircle.Visible = GetFlag(Flags,Flag,"/Enabled") and GetFlag(Flags,Flag,"/FOVCircle/Enabled")
        Outline.Visible = GetFlag(Flags,Flag,"/Enabled") and GetFlag(Flags,Flag,"/FOVCircle/Enabled")

        if FOVCircle.Visible then
            local FOV = GetFlag(Flags,Flag,"/FieldOfView") --DynamicFOV(GetFlag(Flags,Flag,"/DynamicFOV"),GetFlag(Flags,Flag,"/FieldOfView"))
            local MouseLocation = UserInputService:GetMouseLocation()

            local Color = GetFlag(Flags,Flag,"/FOVCircle/Color")
            FOVCircle.Transparency = 1-Color[4] FOVCircle.Color = Color[6]
            FOVCircle.Thickness = GetFlag(Flags,Flag,"/FOVCircle/Thickness")
            FOVCircle.NumSides = GetFlag(Flags,Flag,"/FOVCircle/NumSides")
            FOVCircle.Filled = GetFlag(Flags,Flag,"/FOVCircle/Filled")

            Outline.Transparency = FOVCircle.Transparency
            Outline.Thickness = FOVCircle.Thickness + 2
            Outline.NumSides = FOVCircle.NumSides

            FOVCircle.Radius = FOV
            Outline.Radius = FOV

            FOVCircle.Position = MouseLocation
            Outline.Position = MouseLocation
        end
    end)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

RunService.Heartbeat:Connect(function()
    for Object,ESP in pairs(DrawingLibrary.ObjectESP) do
        if not GetFlag(ESP.Flags,ESP.GlobalFlag,"/Enabled")
        or not GetFlag(ESP.Flags,ESP.Flag,"/Enabled") then continue end

        ESP.Target.Position = ESP.IsBasePart and ESP.Target.RootPart.Position or ESP.Target.Position
        ESP.Target.ScreenPosition,ESP.Target.OnScreen = WorldToScreen(ESP.Target.Position)
        if ESP.Name.Visible then ESP.Name.Position = ESP.Target.ScreenPosition end
    end
end)

Parvus.Utilities.NewThreadLoop(FrameRate,function()
    for Object,ESP in pairs(DrawingLibrary.ObjectESP) do
        if not GetFlag(ESP.Flags,ESP.GlobalFlag,"/Enabled")
        or not GetFlag(ESP.Flags,ESP.Flag,"/Enabled") then
            ESP.Name.Visible = false continue
        end

        ESP.Target.Distance = GetDistance(ESP.Target.Position)
        ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.GlobalFlag,"/DistanceCheck"),
        GetFlag(ESP.Flags,ESP.GlobalFlag,"/Distance"),ESP.Target.Distance)

        ESP.Name.Visible = (ESP.Target.OnScreen and ESP.Target.InTheRange) or false

        if ESP.Name.Visible then
            local Color = GetFlag(ESP.Flags,ESP.Flag,"/Color")
            ESP.Name.Transparency = 1-Color[4] ESP.Name.Color = Color[6]
            ESP.Name.Text = string.format("%s\n%i studs",ESP.Target.Name,ESP.Target.Distance)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    for Target,ESP in pairs(DrawingLibrary.ESP) do
        ESP.Target.Character,ESP.Target.RootPart = GetCharacter(Target,ESP.Mode)
        if ESP.Target.Character and ESP.Target.RootPart then
            ESP.Target.ScreenPosition,ESP.Target.OnScreen = WorldToScreen(ESP.Target.RootPart.Position)
            ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)

            ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.Flag,"/DistanceCheck"),GetFlag(ESP.Flags,ESP.Flag,"/Distance"),ESP.Target.Distance)
            ESP.Target.Health,ESP.Target.MaxHealth,ESP.Target.IsAlive = GetHealth(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.InEnemyTeam,ESP.Target.TeamColor = GetTeam(Target,ESP.Target.Character,ESP.Mode)

            if ESP.Target.OnScreen and ESP.Target.InTheRange then
                if ESP.Drawing.HeadDot.Visible or ESP.Drawing.Tracer.Visible then
                    local Head = FindFirstChild(ESP.Target.Character,"Head",true)
                    if Head then local HeadPosition = WorldToScreen(Head.Position)
                        if ESP.Drawing.HeadDot.Visible then
                            ESP.Drawing.HeadDot.Position = V2New(HeadPosition.X,HeadPosition.Y)
                            ESP.Drawing.HeadDotOutline.Position = ESP.Drawing.HeadDot.Position
                        end
                        if ESP.Drawing.Tracer.Visible then
                            local TracerMode = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Mode")
                            ESP.Drawing.Tracer.From = (TracerMode[1] == "From Mouse" and UserInputService:GetMouseLocation())
                            or (TracerMode[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y))
                            ESP.Drawing.Tracer.To = V2New(HeadPosition.X,HeadPosition.Y)
                            ESP.Drawing.TracerOutline.From = ESP.Drawing.Tracer.From
                            ESP.Drawing.TracerOutline.To = ESP.Drawing.Tracer.To
                        end
                    end
                end
                if ESP.Drawing.Box.Visible or ESP.Drawing.Name.Visible then
                    local BoxPosition,BoxSize = CalculateBox(ESP.Target.Character,ESP.Target.ScreenPosition,ESP.Target.Distance)
                    ESP.Target.HealthPercent = ESP.Target.Health / ESP.Target.MaxHealth ESP.Target.BoxTooSmall = BoxSize.Y <= 12

                    if ESP.Drawing.Box.Visible then
                        ESP.Drawing.Box.Size = BoxSize
                        ESP.Drawing.Box.Position = BoxPosition
                        ESP.Drawing.BoxOutline.Size = ESP.Drawing.Box.Size
                        ESP.Drawing.BoxOutline.Position = ESP.Drawing.Box.Position
                    end
                    if ESP.Drawing.HealthBar.Visible and not ESP.Target.BoxTooSmall then
                        ESP.Drawing.HealthBarOutline.Size = V2New(3,BoxSize.Y + 2)
                        ESP.Drawing.HealthBarOutline.Position = V2New(BoxPosition.X - ESP.Drawing.HealthBarOutline.Size.X - 2,BoxPosition.Y - 1)
                        ESP.Drawing.HealthBar.Size = V2New(ESP.Drawing.HealthBarOutline.Size.X - 2,-ESP.Target.HealthPercent * (ESP.Drawing.HealthBarOutline.Size.Y - 2))
                        ESP.Drawing.HealthBar.Position = ESP.Drawing.HealthBarOutline.Position + V2New(1,ESP.Drawing.HealthBarOutline.Size.Y - 1)
                    end
                    if ESP.Drawing.Name.Visible then
                        ESP.Drawing.Name.Position = V2New(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                    end
                end
            else
                if ESP.Drawing.Arrow.Visible then
                    local Direction = GetRelative(ESP.Target.RootPart.Position).Unit
                    local SideLength = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Width") / 2
                    local ArrowRadius = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Radius")
                    local Base,Radians90 = Direction * ArrowRadius,Rad(90)

                    local RTCBL = RelativeToCenter(Base + RotateVector(Direction,Radians90) * SideLength)
                    local RTCT = RelativeToCenter(Direction * (ArrowRadius + GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Height")))
                    local RTCBR = RelativeToCenter(Base + RotateVector(Direction,-Radians90) * SideLength)

                    ESP.Drawing.Arrow.PointA = RTCBL
                    ESP.Drawing.Arrow.PointB = RTCT
                    ESP.Drawing.Arrow.PointC = RTCBR

                    ESP.Drawing.ArrowOutline.PointA = RTCBL
                    ESP.Drawing.ArrowOutline.PointB = RTCT
                    ESP.Drawing.ArrowOutline.PointC = RTCBR
                end
            end
        end
    end
end)

Parvus.Utilities.NewThreadLoop(FrameRate,function()
    for Target,ESP in pairs(DrawingLibrary.ESP) do
        ESP.Target.Color = GetFlag(ESP.Flags,ESP.Flag,"/TeamColor") and ESP.Target.TeamColor
        or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags,ESP.Flag,"/Enemy")[6]
        or GetFlag(ESP.Flags,ESP.Flag,"/Ally")[6])

        if ESP.Target.OnScreen and ESP.Target.InTheRange then
            if ESP.Highlight.Enabled then
                local OutlineColor = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/OutlineColor")
                ESP.Highlight.DepthMode = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Occluded")
                and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                ESP.Highlight.Adornee = ESP.Target.Character ESP.Highlight.FillColor = ESP.Target.Color
                ESP.Highlight.OutlineColor = OutlineColor[6] ESP.Highlight.OutlineTransparency = OutlineColor[4]
                ESP.Highlight.FillTransparency = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Transparency")
            end
            if ESP.Drawing.HeadDot.Visible then
                ESP.Drawing.HeadDot.Color = ESP.Target.Color
                ESP.Drawing.HeadDot.Radius = ClampDistance(GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Autoscale"),
                    GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Radius"),ESP.Target.Distance)

                ESP.Drawing.HeadDot.Filled = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Filled")
                ESP.Drawing.HeadDot.NumSides = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/NumSides")
                ESP.Drawing.HeadDot.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Thickness")
                ESP.Drawing.HeadDot.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Transparency")

                ESP.Drawing.HeadDotOutline.Radius = ESP.Drawing.HeadDot.Radius
                ESP.Drawing.HeadDotOutline.NumSides = ESP.Drawing.HeadDot.NumSides
                ESP.Drawing.HeadDotOutline.Thickness = ESP.Drawing.HeadDot.Thickness + 2
                ESP.Drawing.HeadDotOutline.Transparency = ESP.Drawing.HeadDot.Transparency
            end
            if ESP.Drawing.Tracer.Visible then
                ESP.Drawing.Tracer.Color = ESP.Target.Color
                ESP.Drawing.Tracer.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Thickness")
                ESP.Drawing.Tracer.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Transparency")

                ESP.Drawing.TracerOutline.Thickness = ESP.Drawing.Tracer.Thickness + 2
                ESP.Drawing.TracerOutline.Transparency = ESP.Drawing.Tracer.Transparency
            end
            if ESP.Drawing.Box.Visible then
                ESP.Drawing.Box.Color = ESP.Target.Color
                ESP.Drawing.Box.Filled = GetFlag(ESP.Flags,ESP.Flag,"/Box/Filled")
                ESP.Drawing.Box.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Box/Thickness")
                ESP.Drawing.Box.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/Box/Transparency")

                ESP.Drawing.BoxOutline.Thickness = ESP.Drawing.Box.Thickness + 2
                ESP.Drawing.BoxOutline.Transparency = ESP.Drawing.Box.Transparency
            end
            if ESP.Drawing.HealthBar.Visible and not ESP.Target.BoxTooSmall then
                ESP.Drawing.HealthBar.Color = LerpColor(RedColor,GreenColor,ESP.Target.HealthPercent)
                ESP.Drawing.HealthBarOutline.Transparency = ESP.Drawing.Box.Transparency
                ESP.Drawing.HealthBar.Transparency = ESP.Drawing.Box.Transparency
            end
            if ESP.Drawing.Name.Visible then
                ESP.Drawing.Name.Outline = GetFlag(ESP.Flags,ESP.Flag,"/Name/Outline")
                ESP.Drawing.Name.Font = GetFont(GetFlag(ESP.Flags,ESP.Flag,"/Name/Font")[1])
                ESP.Drawing.Name.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/Name/Transparency")
                ESP.Drawing.Name.Size = ClampDistance(GetFlag(ESP.Flags,ESP.Flag,"/Name/Autoscale"),GetFlag(ESP.Flags,ESP.Flag,"/Name/Size"),ESP.Target.Distance)
                ESP.Drawing.Name.Text = string.format("%s\n%i studs",ESP.Mode == "Player" and Target.Name or (ESP.Target.InEnemyTeam and "Enemy NPC" or "Ally NPC"),ESP.Target.Distance)
            end
        else
            if ESP.Drawing.Arrow.Visible then
                ESP.Drawing.Arrow.Color = ESP.Target.Color
                ESP.Drawing.Arrow.Filled = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Filled")
                ESP.Drawing.Arrow.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Thickness")
                ESP.Drawing.Arrow.Transparency = 1 - GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Transparency")
                ESP.Drawing.ArrowOutline.Thickness = ESP.Drawing.Arrow.Thickness + 2
                ESP.Drawing.ArrowOutline.Transparency = ESP.Drawing.Arrow.Transparency
            end
        end

        local TeamCheck = (not GetFlag(ESP.Flags,ESP.Flag,"/TeamCheck") and not ESP.Target.InEnemyTeam) or ESP.Target.InEnemyTeam
        local Visible = ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.RootPart and ESP.Target.IsAlive and TeamCheck
        local ArrowVisible = not ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.RootPart and ESP.Target.IsAlive and TeamCheck

        ESP.Highlight.Enabled = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Enabled") or false

        ESP.Drawing.Box.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Enabled") or false
        ESP.Drawing.BoxOutline.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Outline") or false

        ESP.Drawing.HealthBar.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/HealthBar") and not ESP.Target.BoxTooSmall or false
        ESP.Drawing.HealthBarOutline.Visible = ESP.Drawing.HealthBar.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Outline") or false

        ESP.Drawing.Arrow.Visible = ArrowVisible and GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Enabled") or false
        ESP.Drawing.ArrowOutline.Visible = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Outline") and ESP.Drawing.Arrow.Visible or false

        ESP.Drawing.HeadDot.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Enabled") or false
        ESP.Drawing.HeadDotOutline.Visible = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Outline") and ESP.Drawing.HeadDot.Visible or false

        ESP.Drawing.Tracer.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Enabled") or false
        ESP.Drawing.TracerOutline.Visible = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Outline") and ESP.Drawing.Tracer.Visible or false

        ESP.Drawing.Name.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Name/Enabled") or false
    end
end)

--[[RunService.Heartbeat:Connect(function()
    for Target,ESP in pairs(DrawingLibrary.ESP) do
        ESP.Target.Character,ESP.Target.RootPart = GetCharacter(Target,ESP.Mode)
        if ESP.Target.Character and ESP.Target.RootPart then
            ESP.Target.ScreenPosition,ESP.Target.OnScreen = WorldToScreen(ESP.Target.RootPart.Position)
            ESP.Target.Distance = GetDistance(ESP.Target.RootPart.Position)

            ESP.Target.InTheRange = CheckDistance(GetFlag(ESP.Flags,ESP.Flag,"/DistanceCheck"),GetFlag(ESP.Flags,ESP.Flag,"/Distance"),ESP.Target.Distance)
            ESP.Target.Health,ESP.Target.MaxHealth,ESP.Target.IsAlive = GetHealth(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.InEnemyTeam,ESP.Target.TeamColor = GetTeam(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.Color = GetFlag(ESP.Flags,ESP.Flag,"/TeamColor") and ESP.Target.TeamColor
            or (ESP.Target.InEnemyTeam and GetFlag(ESP.Flags,ESP.Flag,"/Enemy")[6]
            or GetFlag(ESP.Flags,ESP.Flag,"/Ally")[6])

            if ESP.Target.OnScreen and ESP.Target.InTheRange then
                if ESP.Highlight.Enabled then
                    local OutlineColor = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/OutlineColor")
                    ESP.Highlight.DepthMode = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Occluded")
                    and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
                    ESP.Highlight.Adornee = ESP.Target.Character ESP.Highlight.FillColor = ESP.Target.Color
                    ESP.Highlight.OutlineColor = OutlineColor[6] ESP.Highlight.OutlineTransparency = OutlineColor[4]
                    ESP.Highlight.FillTransparency = GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Transparency")
                end
                if ESP.Drawing.HeadDot.Visible or ESP.Drawing.Tracer.Visible then
                    local Head = FindFirstChild(ESP.Target.Character,"Head",true)
                    if Head then local HeadPosition = WorldToScreen(Head.Position)
                        if ESP.Drawing.HeadDot.Visible then
                            ESP.Drawing.HeadDot.Color = ESP.Target.Color
                            ESP.Drawing.HeadDot.Radius = ClampDistance(GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Autoscale"),
                                GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Radius"),ESP.Target.Distance)

                            ESP.Drawing.HeadDot.Filled = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Filled")
                            ESP.Drawing.HeadDot.NumSides = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/NumSides")
                            ESP.Drawing.HeadDot.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Thickness")
                            ESP.Drawing.HeadDot.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Transparency")

                            ESP.Drawing.HeadDotOutline.Radius = ESP.Drawing.HeadDot.Radius
                            ESP.Drawing.HeadDotOutline.NumSides = ESP.Drawing.HeadDot.NumSides
                            ESP.Drawing.HeadDotOutline.Thickness = ESP.Drawing.HeadDot.Thickness + 2
                            ESP.Drawing.HeadDotOutline.Transparency = ESP.Drawing.HeadDot.Transparency

                            ESP.Drawing.HeadDot.Position = V2New(HeadPosition.X,HeadPosition.Y)
                            ESP.Drawing.HeadDotOutline.Position = ESP.Drawing.HeadDot.Position
                        end
                        if ESP.Drawing.Tracer.Visible then
                            local TracerMode = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Mode")

                            ESP.Drawing.Tracer.Color = ESP.Target.Color
                            ESP.Drawing.Tracer.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Thickness")
                            ESP.Drawing.Tracer.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Transparency")

                            ESP.Drawing.TracerOutline.Thickness = ESP.Drawing.Tracer.Thickness + 2
                            ESP.Drawing.TracerOutline.Transparency = ESP.Drawing.Tracer.Transparency

                            ESP.Drawing.Tracer.From = (TracerMode[1] == "From Mouse" and UserInputService:GetMouseLocation())
                            or (TracerMode[1] == "From Bottom" and V2New(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y))
                            ESP.Drawing.Tracer.To = V2New(HeadPosition.X,HeadPosition.Y)
                            ESP.Drawing.TracerOutline.From = ESP.Drawing.Tracer.From
                            ESP.Drawing.TracerOutline.To = ESP.Drawing.Tracer.To
                        end
                    end
                end
                if ESP.Drawing.Box.Visible or ESP.Drawing.Name.Visible then
                    local BoxPosition,BoxSize = CalculateBox(ESP.Target.Character,ESP.Target.ScreenPosition,ESP.Target.Distance)
                    ESP.Target.HealthPercent = ESP.Target.Health / ESP.Target.MaxHealth ESP.Target.BoxTooSmall = BoxSize.Y <= 12

                    if ESP.Drawing.Box.Visible then
                        ESP.Drawing.Box.Color = ESP.Target.Color
                        ESP.Drawing.Box.Filled = GetFlag(ESP.Flags,ESP.Flag,"/Box/Filled")
                        ESP.Drawing.Box.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Box/Thickness")
                        ESP.Drawing.Box.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/Box/Transparency")

                        ESP.Drawing.BoxOutline.Thickness = ESP.Drawing.Box.Thickness + 2
                        ESP.Drawing.BoxOutline.Transparency = ESP.Drawing.Box.Transparency

                        ESP.Drawing.Box.Size = BoxSize
                        ESP.Drawing.Box.Position = BoxPosition
                        ESP.Drawing.BoxOutline.Size = ESP.Drawing.Box.Size
                        ESP.Drawing.BoxOutline.Position = ESP.Drawing.Box.Position
                    end
                    if ESP.Drawing.HealthBar.Visible and not ESP.Target.BoxTooSmall then
                        ESP.Drawing.HealthBar.Color = LerpColor(RedColor,GreenColor,ESP.Target.HealthPercent)
                        ESP.Drawing.HealthBarOutline.Transparency = ESP.Drawing.Box.Transparency
                        ESP.Drawing.HealthBar.Transparency = ESP.Drawing.Box.Transparency

                        ESP.Drawing.HealthBarOutline.Size = V2New(3,BoxSize.Y + 2)
                        ESP.Drawing.HealthBarOutline.Position = V2New(BoxPosition.X - ESP.Drawing.HealthBarOutline.Size.X - 2,BoxPosition.Y - 1)
                        ESP.Drawing.HealthBar.Size = V2New(ESP.Drawing.HealthBarOutline.Size.X - 2,-ESP.Target.HealthPercent * (ESP.Drawing.HealthBarOutline.Size.Y - 2))
                        ESP.Drawing.HealthBar.Position = ESP.Drawing.HealthBarOutline.Position + V2New(1,ESP.Drawing.HealthBarOutline.Size.Y - 1)
                    end
                    if ESP.Drawing.Name.Visible then
                        ESP.Drawing.Name.Outline = GetFlag(ESP.Flags,ESP.Flag,"/Name/Outline")
                        ESP.Drawing.Name.Font = GetFont(GetFlag(ESP.Flags,ESP.Flag,"/Name/Font")[1])
                        ESP.Drawing.Name.Transparency = 1-GetFlag(ESP.Flags,ESP.Flag,"/Name/Transparency")
                        ESP.Drawing.Name.Size = ClampDistance(GetFlag(ESP.Flags,ESP.Flag,"/Name/Autoscale"),GetFlag(ESP.Flags,ESP.Flag,"/Name/Size"),ESP.Target.Distance)
                        ESP.Drawing.Name.Text = string.format("%s\n%i studs",ESP.Mode == "Player" and Target.Name or (ESP.Target.InEnemyTeam and "Enemy NPC" or "Ally NPC"),ESP.Target.Distance)
                        ESP.Drawing.Name.Position = V2New(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                    end
                end
            else
                if ESP.Drawing.Arrow.Visible then
                    local Direction = GetRelative(ESP.Target.RootPart.Position).Unit
                    local SideLength = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Width") / 2
                    local ArrowRadius = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Radius")
                    local Base,Radians90 = Direction * ArrowRadius,Rad(90)

                    local RTCBL = RelativeToCenter(Base + RotateVector(Direction,Radians90) * SideLength)
                    local RTCT = RelativeToCenter(Direction * (ArrowRadius + GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Height")))
                    local RTCBR = RelativeToCenter(Base + RotateVector(Direction,-Radians90) * SideLength)

                    ESP.Drawing.Arrow.Color = ESP.Target.Color
                    ESP.Drawing.Arrow.Filled = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Filled")
                    ESP.Drawing.Arrow.Thickness = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Thickness")
                    ESP.Drawing.Arrow.Transparency = 1 - GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Transparency")
                    ESP.Drawing.ArrowOutline.Thickness = ESP.Drawing.Arrow.Thickness + 2
                    ESP.Drawing.ArrowOutline.Transparency = ESP.Drawing.Arrow.Transparency

                    ESP.Drawing.Arrow.PointA = RTCBL
                    ESP.Drawing.Arrow.PointB = RTCT
                    ESP.Drawing.Arrow.PointC = RTCBR

                    ESP.Drawing.ArrowOutline.PointA = RTCBL
                    ESP.Drawing.ArrowOutline.PointB = RTCT
                    ESP.Drawing.ArrowOutline.PointC = RTCBR
                end
            end
        end

        local TeamCheck = (not GetFlag(ESP.Flags,ESP.Flag,"/TeamCheck") and not ESP.Target.InEnemyTeam) or ESP.Target.InEnemyTeam
        local Visible = ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.RootPart and ESP.Target.IsAlive and TeamCheck
        local ArrowVisible = not ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.RootPart and ESP.Target.IsAlive and TeamCheck

        ESP.Highlight.Enabled = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Highlight/Enabled") or false

        ESP.Drawing.Box.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Enabled") or false
        ESP.Drawing.BoxOutline.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Outline") or false

        ESP.Drawing.HealthBar.Visible = ESP.Drawing.Box.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/HealthBar") and not ESP.Target.BoxTooSmall or false
        ESP.Drawing.HealthBarOutline.Visible = ESP.Drawing.HealthBar.Visible and GetFlag(ESP.Flags,ESP.Flag,"/Box/Outline") or false

        ESP.Drawing.Arrow.Visible = ArrowVisible and GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Enabled") or false
        ESP.Drawing.ArrowOutline.Visible = GetFlag(ESP.Flags,ESP.Flag,"/Arrow/Outline") and ESP.Drawing.Arrow.Visible or false

        ESP.Drawing.HeadDot.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Enabled") or false
        ESP.Drawing.HeadDotOutline.Visible = GetFlag(ESP.Flags,ESP.Flag,"/HeadDot/Outline") and ESP.Drawing.HeadDot.Visible or false

        ESP.Drawing.Tracer.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Enabled") or false
        ESP.Drawing.TracerOutline.Visible = GetFlag(ESP.Flags,ESP.Flag,"/Tracer/Outline") and ESP.Drawing.Tracer.Visible or false

        ESP.Drawing.Name.Visible = Visible and GetFlag(ESP.Flags,ESP.Flag,"/Name/Enabled") or false
    end
end)]]

return DrawingLibrary
