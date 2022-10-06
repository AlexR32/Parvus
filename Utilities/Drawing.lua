local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
--local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeamService = game:GetService("Teams")
local CoreGui = game:GetService("CoreGui")

repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local DrawingLibrary = {ESPContainer = {}}

if not HighlightContainer then
    getgenv().HighlightContainer = Instance.new("Folder")
    HighlightContainer.Name = "HighlightContainer"
    Parvus.Utilities.Misc:HideObject(HighlightContainer)
    --HighlightContainer.Parent = CoreGui
end

local function GetFontFromName(FontName)
    if FontName == "UI" then
        return 0
    elseif FontName == "System" then
        return 1
    elseif FontName == "Plex" then
        return 2
    elseif FontName == "Monospace" then
        return 3
    else
        return 0
    end
end

local function GetDistanceFromCamera(Position)
    local Camera = Workspace.CurrentCamera
    return (Position - Camera.CFrame.Position).Magnitude
end
local function CheckDistance(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance <= MaxDistance
end
local function ClampDistance(Enabled,Clamp,Distance)
    --Distance = type(Distance) == "number" and
    --Distance or GetDistanceFromCamera(Distance.Position)
    return Enabled and math.clamp(1 / Distance * 1000,0,Clamp) or Clamp
end
local function DynamicFOV(Enabled,FOV)
    local Camera = Workspace.CurrentCamera
    return Enabled and((120 - Camera.FieldOfView) * 4) + FOV or FOV
end

function GetCharacter(Target,Mode)
    if Mode == "Player" then
        if not Target.Character then return end local Character = Target.Character
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        return Character,HumanoidRootPart
    else
        return Target,Target:FindFirstChild("HumanoidRootPart")
    end
end
function GetHealth(Target,Character,Mode)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    return Humanoid.Health,Humanoid.MaxHealth,Humanoid.Health > 0
end
function GetTeam(Target,Character,Mode)
    if Mode == "Player" then
        if Target.Neutral then
            return true,Target.TeamColor.Color
        else
            return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
        end
    else
        return true,Color3.new()
    end
end

local function AddHighlight()
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = HighlightContainer
    return Highlight
end
local function AddDrawing(Type,Properties)
    local Drawing = Drawing.new(Type)
    if not Properties then return Drawing end
    for Property,Value in pairs(Properties) do
        Drawing[Property] = Value
    end return Drawing
end
local function RemoveDrawing(Table)
    for Index,Drawing in pairs(Table) do
        if Drawing.Remove then Drawing:Remove()
        else RemoveDrawing(Drawing) end
    end
end

--[[local function CalculateBox(Model,Orientation,ScreenPosition)
    local Camera = Workspace.CurrentCamera
    local Size = Model:GetExtentsSize()
    --local Orientation, Size = Model:GetBoundingBox()
    --local ScreenPosition = Camera:WorldToViewportPoint(Orientation.Position)

    local CornerTable = {
        TopLeft = Camera:WorldToViewportPoint(Vector3.new(Orientation.X - Size.X / 2, Orientation.Y + Size.Y / 2, Orientation.Z)),
        TopRight = Camera:WorldToViewportPoint(Vector3.new(Orientation.X + Size.X / 2, Orientation.Y + Size.Y / 2, Orientation.Z)),
        BottomLeft = Camera:WorldToViewportPoint(Vector3.new(Orientation.X - Size.X / 2, Orientation.Y - Size.Y / 2, Orientation.Z)),
        --BottomRight = Camera:WorldToViewportPoint(Vector3.new(Orientation.X + Size.X / 2, Orientation.Y - Size.Y / 2, Orientation.Z))
    }

    local ScreenSize = Vector2.new(
        (CornerTable.TopLeft - CornerTable.TopRight).Magnitude,
        (CornerTable.TopLeft - CornerTable.BottomLeft).Magnitude
    )

    return Vector2.new(ScreenPosition.X - ScreenSize.X / 2, ScreenPosition.Y - ScreenSize.Y / 2), ScreenSize
end
local function CalculateBox(Model,Orientation,ScreenPosition)
    local Camera = Workspace.CurrentCamera
    local Size = Model:GetExtentsSize()

    local Height = (Camera.CFrame - Camera.CFrame.Position) * Vector3.new(0, Size.Y / 2, 0)
    Height = math.abs(Camera:WorldToViewportPoint(Orientation + Height).Y - Camera:WorldToViewportPoint(Orientation - Height).Y)
    Size = Vector2.new(Height / 2, Height)
    return Vector2.new(ScreenPosition.X - Size.X / 2, ScreenPosition.Y - Size.Y / 2), Size
end]]

local function AntiAliasingXY(X,Y)
    return Vector2.new(math.round(X),math.round(Y))
end
local function AntiAliasingP(Position)
    return Vector2.new(math.round(Position.X),math.round(Position.Y))
end
local function CalculateBox(Model,Position) -- CalculateBox by mickeyrbx
    local Camera,Size = Workspace.CurrentCamera,Model:GetExtentsSize()
    local ScaleFactor = 1 / (Position.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
    Size = AntiAliasingXY(ScaleFactor * Size.X,ScaleFactor * Size.Y)
    Position = Vector2.new(Position.X,Position.Y)
    return AntiAliasingP(Position - Size / 2),Size
end

local function GetRelative(Position) -- Offscreen Arrows by Blissful
    local Camera = Workspace.CurrentCamera
    local Relative = Camera.CFrame:PointToObjectSpace(Position)
    return Vector2.new(-Relative.X, -Relative.Z)
end
local function RotateDirection(Direction, Radius) Radius = math.rad(Radius)
    local X = Direction.X * math.cos(Radius) - Direction.Y * math.sin(Radius)
    local Y = Direction.X * math.sin(Radius) + Direction.Y * math.cos(Radius)
    return Vector2.new(X,Y)
end
local function RelativeToCenter(Size)
    local Camera = Workspace.CurrentCamera
    return AntiAliasingP(Camera.ViewportSize / 2 - Size)
end

if game.GameId == 580765040 then
    function GetCharacter(Target,Mode)
        if not Target.Character then return end
        local Character = Target.Character
        return Character,Character.PrimaryPart
    end
    function GetTeam(Target,Character,Mode)
        local LPCharacter = LocalPlayer.Character
        if not LPCharacter then return end
        local InEnemyTeam = false
        if Character:FindFirstChild("Team") and LPCharacter:FindFirstChild("Team") then
            if Character.Team.Value ~= LPCharacter.Team.Value or Character.Team.Value == "None" then
                InEnemyTeam = true
            end
        end
        return InEnemyTeam,Character.PrimaryPart.Color
    end
elseif game.GameId == 1054526971 then
    function GetTeam(Target,Character,Mode)
        if Mode == "Player" then
            if Target.Neutral then
                return true,Target.TeamColor.Color
            else
                return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
            end
        else
            return not Character:FindFirstChildWhichIsA("ProximityPrompt",true),Color3.new()
        end
    end
elseif game.GameId == 1168263273 then
    repeat task.wait() until ReplicatedStorage:FindFirstChild("TS")
    local Tortoiseshell = require(ReplicatedStorage.TS)
    local Characters = getupvalue(Tortoiseshell.Characters.GetCharacter,1)

    local function GetPlayerTeam(Player)
        for Index,Team in pairs(TeamService:GetChildren()) do
            if Team.Players:FindFirstChild(Player.Name) then
                return Team.Name
            end
        end
    end
    function GetCharacter(Target,Mode) local Character = Characters[Target]
        if not Character or Character.Parent == nil then return end
        return Character,Character.PrimaryPart
    end
    function GetHealth(Target,Character,Mode)
        local Health = Character.Health
        return Health.Value,Health.MaxHealth.Value,Health.Value > 0
    end
    function GetTeam(Target,Character,Mode)
        local Team,LPTeam = GetPlayerTeam(Target),GetPlayerTeam(LocalPlayer)
        return LPTeam ~= Team or Team == "FFA",Tortoiseshell.Teams.Colors[Team]
    end
elseif game.GameId == 1586272220 then
    local function GetPlayerTank(Player)
        local Character = Player:FindFirstChild("Char")
        if not Character then return end
        if not Character.Value then return end
        return Character.Value.Parent.Parent.Parent
    end
    function GetCharacter(Target,Mode)
        local PlayerTank = GetPlayerTank(Target)
        if not PlayerTank then return end
        return PlayerTank,PlayerTank.PrimaryPart or false
    end
    function GetHealth(Target,Character,Mode)
        return Character.Stats.Health.Value,
        Character.Stats.Health.Orig.Value,
        Character.Stats.Health.Value > 0
    end
end

local function ItemESP(Item,ESP,IsBasePart)
    local ScreenPosition,OnScreen,InTheRange
    local function ConcatFlag(Flag)
        return ESP.Config[ESP.FlagConcat .. Flag]
    end
    local function GlobalFlag(Flag)
        return ESP.Config[ESP.GlobalFlag .. Flag]
    end

    return RunService.Heartbeat:Connect(function() local Camera = Workspace.CurrentCamera
        ScreenPosition,OnScreen = Camera:WorldToViewportPoint(IsBasePart and Item[3].Position or Item[3])
        local Distance = GetDistanceFromCamera(IsBasePart and Item[3].Position or Item[3]) * 0.28
        InTheRange = CheckDistance(GlobalFlag("/DistanceCheck"),Distance,GlobalFlag("/Distance"))
        if OnScreen and InTheRange then
            if ESP.Drawing.Text.Visible then
                local Color = ConcatFlag("/Color")
                ESP.Drawing.Text.Color = Color[6]
                ESP.Drawing.Text.Transparency = 1-Color[4]

                ESP.Drawing.Text.Text = string.format("%s\n%i meters",Item[2],Distance)
                ESP.Drawing.Text.Position = Vector2.new(ScreenPosition.X,ScreenPosition.Y)
            end
        end ESP.Drawing.Text.Visible = OnScreen and InTheRange and ConcatFlag("/Enabled") or false
    end)
end

local function PlayerESP(Target,ESP)
    local ScreenPosition,OnScreen,
    InTheRange,BoxTooSmall

    local Character,PrimaryPart = nil,nil
    local Health,MaxHealth,IsAlive = 100,100,false
    local InEnemyTeam,TeamColor = false,Color3.new()
    local function ConcatFlag(Flag)
        return ESP.Config[ESP.FlagConcat .. Flag]
    end

    return RunService.Heartbeat:Connect(function()
        Character,PrimaryPart = GetCharacter(Target,ESP.Mode)
        if Character and PrimaryPart then local Camera = Workspace.CurrentCamera
            ScreenPosition,OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)

            local ESPColor = ConcatFlag("/TeamColor") and TeamColor
            or (InEnemyTeam and ConcatFlag("/Enemy")[6] or ConcatFlag("/Ally")[6])
            local Distance = GetDistanceFromCamera(PrimaryPart.Position) * 0.28
            InTheRange = CheckDistance(ConcatFlag("/DistanceCheck"),
            Distance,ConcatFlag("/Distance"))

            if OnScreen and InTheRange then
                Health,MaxHealth,IsAlive = GetHealth(Target,Character,ESP.Mode)
                InEnemyTeam,TeamColor = GetTeam(Target,Character,ESP.Mode)

                if ESP.Highlight.Enabled then
                    ESP.Highlight.Adornee = Character
                    ESP.Highlight.FillColor = ESPColor
                    ESP.Highlight.FillTransparency = ConcatFlag("/Highlight/Transparency")
                    ESP.Highlight.OutlineColor = ConcatFlag("/Highlight/OutlineColor")[6]
                    ESP.Highlight.OutlineTransparency = ConcatFlag("/Highlight/OutlineColor")[4]
                end
                if ESP.Drawing.Head.Main.Visible or ESP.Drawing.Tracer.Visible then
                    local Head = Character:FindFirstChild("Head",true)
                    local HeadPosition = Head and Camera:WorldToViewportPoint(Head.Position) or Vector3.zero
                    if ESP.Drawing.Head.Main.Visible then
                        ESP.Drawing.Head.Main.Color = ESPColor
                        ESP.Drawing.Head.Main.Radius = ClampDistance(ConcatFlag("/Head/Autoscale"),ConcatFlag("/Head/Radius"),Distance)
                        ESP.Drawing.Head.Main.Filled = ConcatFlag("/Head/Filled")
                        ESP.Drawing.Head.Main.NumSides = ConcatFlag("/Head/NumSides")
                        ESP.Drawing.Head.Main.Thickness = ConcatFlag("/Head/Thickness")
                        ESP.Drawing.Head.Main.Transparency = 1-ConcatFlag("/Head/Transparency")
                        ESP.Drawing.Head.Outline.Radius = ESP.Drawing.Head.Main.Radius
                        ESP.Drawing.Head.Outline.NumSides = ESP.Drawing.Head.Main.NumSides
                        ESP.Drawing.Head.Outline.Thickness = ESP.Drawing.Head.Main.Thickness + 2
                        ESP.Drawing.Head.Outline.Transparency = ESP.Drawing.Head.Main.Transparency

                        ESP.Drawing.Head.Main.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                        ESP.Drawing.Head.Outline.Position = ESP.Drawing.Head.Main.Position
                    end
                    if ESP.Drawing.Tracer.Visible then
                        local TracerMode = ConcatFlag("/Tracer/Mode")
                        ESP.Drawing.Tracer.Color = ESPColor
                        ESP.Drawing.Tracer.Thickness = ConcatFlag("/Tracer/Thickness")
                        ESP.Drawing.Tracer.Transparency = 1-ConcatFlag("/Tracer/Transparency")
                        ESP.Drawing.Tracer.From = TracerMode[1] == "From Mouse" and UserInputService:GetMouseLocation()
                        or TracerMode[1] == "From Bottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
                        ESP.Drawing.Tracer.To = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                end
                if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Text.Visible then
                    local BoxPosition, BoxSize = CalculateBox(Character,ScreenPosition)
                    BoxTooSmall = BoxSize.Magnitude <= 20
                    if ESP.Drawing.Box.Main.Visible then
                        ESP.Drawing.Box.Main.Color = ESPColor
                        ESP.Drawing.Box.Main.Filled = ConcatFlag("/Box/Filled")
                        ESP.Drawing.Box.Main.Thickness = ConcatFlag("/Box/Thickness")
                        ESP.Drawing.Box.Main.Transparency = 1-ConcatFlag("/Box/Transparency")
                        ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
                        ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                        ESP.Drawing.Box.Main.Size = BoxSize
                        ESP.Drawing.Box.Main.Position = BoxPosition
                        ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                        ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                    end
                    if ESP.Drawing.Healthbar.Main.Visible and not BoxTooSmall then
                        ESP.Drawing.Healthbar.Main.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0),Health / MaxHealth)

                        ESP.Drawing.Healthbar.Outline.Size = Vector2.new(3,BoxSize.Y + 2)

                        ESP.Drawing.Healthbar.Outline.Position = Vector2.new(
                        BoxPosition.X - ESP.Drawing.Healthbar.Outline.Size.X - 2,BoxPosition.Y - 1)

                        ESP.Drawing.Healthbar.Main.Size = Vector2.new(ESP.Drawing.Healthbar.Outline.Size.X - 2,
                        -Health / MaxHealth * (ESP.Drawing.Healthbar.Outline.Size.Y - 2))

                        ESP.Drawing.Healthbar.Main.Position = ESP.Drawing.Healthbar.Outline.Position
                        + Vector2.new(1,ESP.Drawing.Healthbar.Outline.Size.Y - 1)
                    end
                    if ESP.Drawing.Box.Text.Visible then
                        ESP.Drawing.Box.Text.Size = ClampDistance(ConcatFlag("/Text/Autoscale"),ConcatFlag("/Text/Size"),Distance)
                        ESP.Drawing.Box.Text.Outline = ConcatFlag("/Text/Outline")
                        ESP.Drawing.Box.Text.Font = GetFontFromName(ConcatFlag("/Text/Font")[1])
                        ESP.Drawing.Box.Text.Transparency = 1-ConcatFlag("/Text/Transparency")
                        ESP.Drawing.Box.Text.Text = string.format("%s\n%i meters",ESP.Mode == "Player" and Target.Name
                        or (InEnemyTeam and "Enemy NPC" or "Ally NPC"),Distance)
                        ESP.Drawing.Box.Text.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                    end
                end
            else
                if ESP.Drawing.Arrow.Main.Visible then
                    local Relative = GetRelative(PrimaryPart.Position)
                    local Direction = Relative.Unit
                    local Base = Direction * ConcatFlag("/Arrow/Distance")
                    local SideLength = ConcatFlag("/Arrow/Width") / 2
                    local BaseL = Base + RotateDirection(Direction,90) * SideLength
                    local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                    local Tip = Direction * (ConcatFlag("/Arrow/Distance") + ConcatFlag("/Arrow/Height"))

                    local RTCBL = RelativeToCenter(BaseL)
                    local RTCBR = RelativeToCenter(BaseR)
                    local RTCT = RelativeToCenter(Tip)

                    ESP.Drawing.Arrow.Main.Color = ESPColor
                    ESP.Drawing.Arrow.Main.Filled = ConcatFlag("/Arrow/Filled")
                    ESP.Drawing.Arrow.Main.Thickness = ConcatFlag("/Arrow/Thickness")
                    ESP.Drawing.Arrow.Main.Transparency = 1 - ConcatFlag("/Arrow/Transparency")
                    ESP.Drawing.Arrow.Outline.Thickness = ESP.Drawing.Arrow.Main.Thickness + 1
                    ESP.Drawing.Arrow.Outline.Transparency = ESP.Drawing.Arrow.Main.Transparency

                    ESP.Drawing.Arrow.Main.PointA = RTCBL
                    ESP.Drawing.Arrow.Main.PointB = RTCBR
                    ESP.Drawing.Arrow.Main.PointC = RTCT
                    ESP.Drawing.Arrow.Outline.PointA = RTCBL
                    ESP.Drawing.Arrow.Outline.PointB = RTCBR
                    ESP.Drawing.Arrow.Outline.PointC = RTCT
                end
            end
        end

        local Visible = OnScreen and InTheRange and PrimaryPart and IsAlive and (not ConcatFlag("/TeamCheck") and not InEnemyTeam or InEnemyTeam)
        local ArrowVisible = not OnScreen and InTheRange and PrimaryPart and IsAlive and (not ConcatFlag("/TeamCheck") and not InEnemyTeam or InEnemyTeam)

        ESP.Highlight.Enabled = Visible and ConcatFlag("/Highlight/Enabled") or false

        ESP.Drawing.Box.Main.Visible = Visible and ConcatFlag("/Box/Enabled") or false
        ESP.Drawing.Box.Outline.Visible = ConcatFlag("/Box/Outline")
        and ESP.Drawing.Box.Main.Visible or false
        ESP.Drawing.Box.Text.Visible = Visible and ConcatFlag("/Text/Enabled") or false

        ESP.Drawing.Healthbar.Main.Visible = ConcatFlag("/Box/Healthbar")
        and not BoxTooSmall and ESP.Drawing.Box.Main.Visible or false
        ESP.Drawing.Healthbar.Outline.Visible = ConcatFlag("/Box/Outline")
        and ESP.Drawing.Healthbar.Main.Visible or false

        ESP.Drawing.Arrow.Main.Visible = ArrowVisible and ConcatFlag("/Arrow/Enabled") or false
        ESP.Drawing.Arrow.Outline.Visible = ConcatFlag("/Arrow/Outline")
        and ESP.Drawing.Arrow.Main.Visible or false

        ESP.Drawing.Head.Main.Visible = Visible and ConcatFlag("/Head/Enabled") or false
        ESP.Drawing.Head.Outline.Visible = ConcatFlag("/Head/Outline")
        and ESP.Drawing.Head.Main.Visible or false

        ESP.Drawing.Tracer.Visible = Visible and ConcatFlag("/Tracer/Enabled") or false
    end)
end

function DrawingLibrary:ItemESP(Item,GlobalFlag,FlagConcat,Config)
    if DrawingLibrary.ESPContainer[Item[1]] then return end
    DrawingLibrary.ESPContainer[Item[1]] = {
        FlagConcat = FlagConcat,
        GlobalFlag = GlobalFlag,
        Config = Config,
        Drawing = {
            Text = AddDrawing("Text", {
                Center = true,
                --Color = Color3.new(1,1,1),
                --Font = 0,
                Outline = true,
                --OutlineColor = Color3.new(),
                --Position = Vector2.zero,
                --Size = 16,
                --Text = "",
                --Transparency = 1,
                --Visible = false
                ZIndex = 1
            })
        }
    }
    local ESP = DrawingLibrary.ESPContainer[Item[1]]
    ESP.Render = ItemESP(Item,ESP,typeof(Item[3]) ~= "Vector3") return ESP
end
function DrawingLibrary:AddESP(Target,Mode,FlagConcat,Config)
    if DrawingLibrary.ESPContainer[Target] then return end

    DrawingLibrary.ESPContainer[Target] = {
        FlagConcat = FlagConcat,
        Config = Config,Mode = Mode,
        Highlight = AddHighlight(),
        Drawing = {
            Box = {
                Main = AddDrawing("Square",{
                    ZIndex = 1
                }),
                Outline = AddDrawing("Square"),
                Text = AddDrawing("Text",{
                    Center = true,
                    Color = Color3.new(1,1,1),
                    ZIndex = 1
                })
            },
            Healthbar = {
                Main = AddDrawing("Square",{
                    Filled = true,
                    ZIndex = 1
                }),
                Outline = AddDrawing("Square",{
                    Filled = true
                })
            },
            Arrow = {
                Main = AddDrawing("Triangle",{
                    ZIndex = 1
                }),
                Outline = AddDrawing("Triangle")
            },
            Head = {
                Main = AddDrawing("Circle",{
                    ZIndex = 1
                }),
                Outline = AddDrawing("Circle")
            },
            Tracer = AddDrawing("Line",{
                ZIndex = 1
            })
        }
    }

    local ESP = DrawingLibrary.ESPContainer[Target]
    ESP.Render = PlayerESP(Target,ESP) return ESP
end

function DrawingLibrary:RemoveESP(Target)
    if not DrawingLibrary.ESPContainer[Target] then return end
    local ESP = DrawingLibrary.ESPContainer[Target]

    ESP.Render:Disconnect()
    RemoveDrawing(ESP.Drawing)
    if ESP.Highlight then
        ESP.Highlight:Destroy()
    end

    DrawingLibrary.ESPContainer[Target] = nil
end

function DrawingLibrary:SetupCursor(Config)
    local Cursor = AddDrawing("Triangle", {
        Color = Color3.new(1,1,1),
        Filled = true,
        Thickness = 1,
        Transparency = 1,
        Visible = true,
        ZIndex = 2
    })

    local CursorOutline = AddDrawing("Triangle", {
        Color = Color3.new(0,0,0),
        Filled = true,
        Thickness = 1,
        Transparency = 1,
        Visible = true,
        ZIndex = 1
    })

    local CrosshairL = AddDrawing("Line", {
        Thickness = 1.5,
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })

    local CrosshairR = AddDrawing("Line", {
        Thickness = 1.5,
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })

    local CrosshairT = AddDrawing("Line", {
        Thickness = 1.5,
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })

    local CrosshairB = AddDrawing("Line", {
        Thickness = 1.5,
        Transparency = 1,
        Visible = true,
        ZIndex = 3
    })

    RunService.RenderStepped:Connect(function()
        local CursorEnabled = Config["Mouse/Enabled"] and UserInputService.MouseBehavior == Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
        local CrosshairEnabled = Config["Mouse/Crosshair/Enabled"] and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
        local Mouse = UserInputService:GetMouseLocation()

        Cursor.Visible = CursorEnabled
        CursorOutline.Visible = CursorEnabled

        CrosshairL.Visible = CrosshairEnabled
        CrosshairR.Visible = CrosshairEnabled
        CrosshairT.Visible = CrosshairEnabled
        CrosshairB.Visible = CrosshairEnabled

        if CursorEnabled then
            Cursor.PointA = Mouse + Vector2.new(0,15)
            Cursor.PointB = Mouse
            Cursor.PointC = Mouse + Vector2.new(10,10)

            CursorOutline.PointA = Cursor.PointA + Vector2.new(0,1)
            CursorOutline.PointB = Cursor.PointB
            CursorOutline.PointC = Cursor.PointC + Vector2.new(1,0)
        end
        if CrosshairEnabled then
            local Color = Config["Mouse/Crosshair/Color"][6]
            CrosshairL.Color = Color
            CrosshairL.From = Mouse - Vector2.new(Config["Mouse/Crosshair/Gap"],0)
            CrosshairL.To = Mouse - Vector2.new(Config["Mouse/Crosshair/Size"] + Config["Mouse/Crosshair/Gap"],0)

            CrosshairR.Color = Color
            CrosshairR.From = Mouse + Vector2.new(Config["Mouse/Crosshair/Gap"] + 1,0)
            CrosshairR.To = Mouse + Vector2.new(Config["Mouse/Crosshair/Size"] + (Config["Mouse/Crosshair/Gap"] + 1),0)

            CrosshairT.Color = Color
            CrosshairT.From = Mouse - Vector2.new(0,Config["Mouse/Crosshair/Gap"])
            CrosshairT.To = Mouse - Vector2.new(0,Config["Mouse/Crosshair/Size"] + Config["Mouse/Crosshair/Gap"])

            CrosshairB.Color = Color
            CrosshairB.From = Mouse + Vector2.new(0,Config["Mouse/Crosshair/Gap"] + 1)
            CrosshairB.To = Mouse + Vector2.new(0,Config["Mouse/Crosshair/Size"] + (Config["Mouse/Crosshair/Gap"] + 1))
        end
    end)
end

--[[function DrawingLibrary:Watermark(Watermark)
    Watermark = GetType(Watermark,{},"table")
    Watermark.Title = GetType(Watermark.Title,"Title","string")
    Watermark.Enabled = GetType(Watermark.Enabled,false,"boolean")

    local WaterText = AddDrawing("Text", {
        Center = false,
        Color = Color3.new(1,1,1),
        Font = 2,
        Outline = false,
        OutlineColor = Color3.new(0,0,0),
        Position = Vector2.new(Workspace.CurrentCamera.ViewportSize.X - Workspace.CurrentCamera.ViewportSize.X / 5, 10),
        Size = 13,
        Text = Watermark.Title,
        Transparency = 1,
        Visible = Watermark.Enabled,
        ZIndex = 3
    })
    local MainWindow = AddDrawing("Square", {
        Color = Color3.fromRGB(30,30,30),
        Filled = true,
        Position = WaterText.Position - Vector2.new(4,4),
        Size = Vector2.new(WaterText.TextBounds.X + 8,WaterText.TextBounds.Y + 8),
        Thickness = 1,
        Transparency = 1,
        Visible = Watermark.Enabled,
        ZIndex = 2
    })
    local BorderWindow = AddDrawing("Square", {
        Color = Color3.fromRGB(60,60,60),
        Filled = true,
        Position = MainWindow.Position - Vector2.new(1,1),
        Size = MainWindow.Size + Vector2.new(2,2),
        Thickness = 1,
        Transparency = 1,
        Visible = Watermark.Enabled,
        ZIndex = 1
    })
    local Border2Window = AddDrawing("Square", {
        Color = Color3.new(0,0,0),
        Filled = true,
        Position = BorderWindow.Position - Vector2.new(1,1),
        Size = BorderWindow.Size + Vector2.new(2,2),
        Thickness = 1,
        Transparency = 1,
        Visible = Watermark.Enabled,
        ZIndex = 0
    })
    function Watermark:SetTitle(Text)
        WaterText.Text = Text
        MainWindow.Size = Vector2.new(WaterText.TextBounds.X + 8,WaterText.TextBounds.Y + 8)
        BorderWindow.Size = MainWindow.Size + Vector2.new(2,2)
        Border2Window.Size = BorderWindow.Size + Vector2.new(2,2)
    end
    function Bracket:WatermarkToggle(Bool)
        WaterText.Visible = Bool
        MainWindow.Visible = Bool
        BorderWindow.Visible = Bool
        Border2Window.Visible = Bool
    end

    return Watermark
end]]

function DrawingLibrary:FOVCircle(Name,Config)
    local FOVCircle = AddDrawing("Circle",{ZIndex = 4})
    local Outline = AddDrawing("Circle",{ZIndex = 3})

    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]
        Outline.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]

        if FOVCircle.Visible then
            local FOV = DynamicFOV(Config[Name.."/DynamicFOV"],Config[Name.."/FieldOfView"])
            local Position = UserInputService:GetMouseLocation()

            FOVCircle.Transparency = 1 - Config[Name.."/Circle/Color"][4]
            FOVCircle.Color = Config[Name.."/Circle/Color"][6]
            FOVCircle.Thickness = Config[Name.."/Circle/Thickness"]
            FOVCircle.NumSides = Config[Name.."/Circle/NumSides"]
            FOVCircle.Filled = Config[Name.."/Circle/Filled"]

            Outline.Transparency = 1 - Config[Name.."/Circle/Color"][4]
            Outline.Thickness = Config[Name.."/Circle/Thickness"] + 2
            Outline.NumSides = Config[Name.."/Circle/NumSides"]

            FOVCircle.Radius = FOV Outline.Radius = FOV
            FOVCircle.Position = Position Outline.Position = Position
        end
    end)
    --[[
    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            FOVCircle.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]
            Outline.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]

            if FOVCircle.Visible then
                local Position = AntiAliasingXY(Input.Position.X,Input.Position.Y + 37)
                local FOV = DynamicFOV(Config[Name.."/DynamicFOV"],Config[Name.."/FieldOfView"])

                FOVCircle.Transparency = 1 - Config[Name.."/Circle/Color"][4]
                FOVCircle.Color = Config[Name.."/Circle/Color"][6]
                FOVCircle.Thickness = Config[Name.."/Circle/Thickness"]
                FOVCircle.NumSides = Config[Name.."/Circle/NumSides"]
                FOVCircle.Filled = Config[Name.."/Circle/Filled"]

                Outline.Transparency = 1 - Config[Name.."/Circle/Color"][4]
                Outline.Thickness = Config[Name.."/Circle/Thickness"] + 2
                Outline.NumSides = Config[Name.."/Circle/NumSides"]

                FOVCircle.Radius = FOV Outline.Radius = FOV
                FOVCircle.Position = Position Outline.Position = Position
            end
        end
    end)
    ]]
end

return DrawingLibrary
