local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local DrawingLibrary = {ESPContainer = {}}
local WhiteColor = Color3.new(1,1,1)
local GreenColor = Color3.new(0,1,0)
local RedColor = Color3.new(1,0,0)

if not HighlightContainer then
    local CoreGui = game:GetService("CoreGui")
    getgenv().HighlightContainer = Instance.new("Folder")
    HighlightContainer.Name = "HighlightContainer"
    HighlightContainer.Parent = CoreGui
end

local function GetFontFromName(FontName)
    return (FontName == "UI" and 0)
    or (FontName == "System" and 1)
    or (FontName == "Plex" and 2)
    or (FontName == "Monospace" and 3)
    or 0
end

local function GetDistanceFromCamera(Camera,Position)
    return (Position - Camera.CFrame.Position).Magnitude
end
local function CheckDistance(Enabled,Distance,MaxDistance)
    if not Enabled then return true end
    return Distance <= MaxDistance
end
local function ClampDistance(Enabled,Clamp,Distance)
    if not Enabled then return Clamp end
    return math.clamp(1 / Distance * 1000,0,Clamp)
end
local function DynamicFOV(Camera,Enabled,FOV)
    if not Enabled then return FOV end
    return ((120 - Camera.FieldOfView) * 4) + FOV
end
local function ConcatFlag(Flags,FlagConcat,Flag)
    return Flags[FlagConcat .. Flag]
end

function GetCharacter(Target,Mode)
    if Mode == "Player" then
        if not Target.Character then return end local Character = Target.Character
        return Character,Character:FindFirstChild("HumanoidRootPart")
    else return Target,Target:FindFirstChild("HumanoidRootPart") end
end
function GetHealth(Target,Character,Mode)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
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

local function AntiAliasingXY(X,Y)
    return Vector2.new(math.round(X),math.round(Y))
end
local function AntiAliasingP(Position)
    return Vector2.new(math.round(Position.X),math.round(Position.Y))
end

-- CalculateBox by mickeyrbx (highly edited)
local function CalculateBox(Camera,Model,Position) local Size = Model:GetExtentsSize()
    local ScaleFactor = 1 / (Position.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
    Size = AntiAliasingXY(ScaleFactor * Size.X,ScaleFactor * Size.Y)
    Position = Vector2.new(Position.X,Position.Y)
    return AntiAliasingP(Position - Size / 2),Size
end

local function GetRelative(Camera,Position) -- Offscreen Arrows by Blissful
    local Relative = Camera.CFrame:PointToObjectSpace(Position)
    return Vector2.new(-Relative.X, -Relative.Z)
end
local function RotateDirection(Direction, Radius) Radius = math.rad(Radius)
    local X = Direction.X * math.cos(Radius) - Direction.Y * math.sin(Radius)
    local Y = Direction.X * math.sin(Radius) + Direction.Y * math.cos(Radius)
    return Vector2.new(X,Y)
end
local function RelativeToCenter(Camera,Size)
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
        if Character:FindFirstChild("Team")
        and LPCharacter:FindFirstChild("Team") then
            if Character.Team.Value ~= LPCharacter.Team.Value
            or Character.Team.Value == "None" then
                return true,Character.PrimaryPart.Color
            end
        end return false,Character.PrimaryPart.Color
    end
elseif game.GameId == 1054526971 then
    function GetTeam(Target,Character,Mode)
        if Mode == "Player" then
            if Target.Neutral then return true,Target.TeamColor.Color else
                return LocalPlayer.Team ~= Target.Team,Target.TeamColor.Color
            end else return not Character:FindFirstChildWhichIsA("ProximityPrompt",true),WhiteColor
        end
    end
elseif game.GameId == 1168263273 then
    local TeamService = game:GetService("Teams")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Tortoiseshell = require(ReplicatedStorage:WaitForChild("TS"))
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
    function GetHealth(Target,Character,Mode) local Health = Character.Health
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

    return RunService.Heartbeat:Connect(function()
        local Camera,Position = Workspace.CurrentCamera,IsBasePart and Item[3].Position or Item[3]
        ScreenPosition,OnScreen = Camera:WorldToViewportPoint(Position)
        local Distance = GetDistanceFromCamera(Camera,Position) * 0.28
        InTheRange = CheckDistance(GlobalFlag("/DistanceCheck"),
        Distance,GlobalFlag("/Distance"))
        
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
    ESP.Render = ItemESP(Item,ESP,typeof(Item[3]) ~= "Vector3")
    return ESP
end
function DrawingLibrary:AddESP(Target,Mode,FlagConcat,Flags)
    if DrawingLibrary.ESPContainer[Target] then return end

    DrawingLibrary.ESPContainer[Target] = {
        FlagConcat = FlagConcat,Target = {},
        Flags = Flags,Mode = Mode,
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
    } return DrawingLibrary.ESPContainer[Target]
end

function DrawingLibrary:RemoveESP(Target)
    local ESP = DrawingLibrary.ESPContainer[Target]
    if not ESP then return end

    if ESP.Render then
        ESP.Render:Disconnect()
    end if ESP.Highlight then
        ESP.Highlight:Destroy()
    end RemoveDrawing(ESP.Drawing)
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

function DrawingLibrary:FOVCircle(Name,Config)
    local FOVCircle = AddDrawing("Circle",{ZIndex = 4})
    local Outline = AddDrawing("Circle",{ZIndex = 3})

    RunService.RenderStepped:Connect(function()
        FOVCircle.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]
        Outline.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]

        if FOVCircle.Visible then local Camera = Workspace.CurrentCamera
            local FOV = DynamicFOV(Camera,Config[Name.."/DynamicFOV"],Config[Name.."/FieldOfView"])
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
end

RunService.Heartbeat:Connect(function()
    for Target,ESP in pairs(DrawingLibrary.ESPContainer) do
        if not ESP.Target then continue end
        ESP.Target.Character,ESP.Target.RootPart = GetCharacter(Target,ESP.Mode)
        if ESP.Target.Character and ESP.Target.RootPart then local Camera = Workspace.CurrentCamera
            ESP.Target.ScreenPosition,ESP.Target.OnScreen = Camera:WorldToViewportPoint(ESP.Target.RootPart.Position)

            local Distance = GetDistanceFromCamera(Camera,ESP.Target.RootPart.Position)
            ESP.Target.InTheRange = CheckDistance(ConcatFlag(ESP.Flags,ESP.FlagConcat,"/DistanceCheck"),
            Distance,ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Distance"))

            ESP.Target.InEnemyTeam,ESP.Target.TeamColor = GetTeam(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.Health,ESP.Target.MaxHealth,ESP.Target.IsAlive = GetHealth(Target,ESP.Target.Character,ESP.Mode)
            ESP.Target.Color = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/TeamColor") and ESP.Target.TeamColor
            or (ESP.Target.InEnemyTeam and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Enemy")[6]
            or ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Ally")[6])

            if ESP.Target.OnScreen and ESP.Target.InTheRange then
                if ESP.Highlight.Enabled then
                    ESP.Highlight.Adornee = ESP.Target.Character
                    ESP.Highlight.FillColor = ESP.Target.Color
                    ESP.Highlight.FillTransparency = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Highlight/Transparency")
                    ESP.Highlight.OutlineColor = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Highlight/OutlineColor")[6]
                    ESP.Highlight.OutlineTransparency = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Highlight/OutlineColor")[4]
                end
                if ESP.Drawing.Head.Main.Visible or ESP.Drawing.Tracer.Visible then
                    local Head = ESP.Target.Character:FindFirstChild("Head",true)
                    if Head then local HeadPosition = Camera:WorldToViewportPoint(Head.Position)
                        if ESP.Drawing.Head.Main.Visible then
                            ESP.Drawing.Head.Main.Color = ESP.Target.Color
                            ESP.Drawing.Head.Main.Radius = ClampDistance(ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Autoscale"),
                            ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Radius"),Distance)
                            ESP.Drawing.Head.Main.Filled = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Filled")
                            ESP.Drawing.Head.Main.NumSides = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/NumSides")
                            ESP.Drawing.Head.Main.Thickness = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Thickness")
                            ESP.Drawing.Head.Main.Transparency = 1-ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Transparency")
                            ESP.Drawing.Head.Outline.Radius = ESP.Drawing.Head.Main.Radius
                            ESP.Drawing.Head.Outline.NumSides = ESP.Drawing.Head.Main.NumSides
                            ESP.Drawing.Head.Outline.Thickness = ESP.Drawing.Head.Main.Thickness + 2
                            ESP.Drawing.Head.Outline.Transparency = ESP.Drawing.Head.Main.Transparency

                            ESP.Drawing.Head.Main.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                            ESP.Drawing.Head.Outline.Position = ESP.Drawing.Head.Main.Position
                        end
                        if ESP.Drawing.Tracer.Visible then
                            local TracerMode = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Tracer/Mode")
                            ESP.Drawing.Tracer.Color = ESP.Target.Color
                            ESP.Drawing.Tracer.Thickness = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Tracer/Thickness")
                            ESP.Drawing.Tracer.Transparency = 1-ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Tracer/Transparency")
                            ESP.Drawing.Tracer.From = TracerMode[1] == "From Mouse" and UserInputService:GetMouseLocation()
                            or TracerMode[1] == "From Bottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
                            ESP.Drawing.Tracer.To = Vector2.new(HeadPosition.X,HeadPosition.Y)
                        end
                    end
                end
                if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Text.Visible then
                    local BoxPosition,BoxSize = CalculateBox(Camera,ESP.Target.Character,ESP.Target.ScreenPosition)
                    ESP.Target.HealthPercent = ESP.Target.Health / ESP.Target.MaxHealth
                    ESP.Target.BoxTooSmall = BoxSize.Y <= 12
                    if ESP.Drawing.Box.Main.Visible then
                        ESP.Drawing.Box.Main.Color = ESP.Target.Color
                        ESP.Drawing.Box.Main.Filled = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Filled")
                        ESP.Drawing.Box.Main.Thickness = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Thickness")
                        ESP.Drawing.Box.Main.Transparency = 1-ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Transparency")
                        ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
                        ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                        ESP.Drawing.Box.Main.Size = BoxSize
                        ESP.Drawing.Box.Main.Position = BoxPosition
                        ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                        ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                    end
                    if ESP.Drawing.Healthbar.Main.Visible and not ESP.Target.BoxTooSmall then
                        ESP.Drawing.Healthbar.Main.Color = RedColor:Lerp(GreenColor,ESP.Target.HealthPercent)

                        ESP.Drawing.Healthbar.Outline.Size = Vector2.new(3,BoxSize.Y + 2)

                        ESP.Drawing.Healthbar.Outline.Position = Vector2.new(
                        BoxPosition.X - ESP.Drawing.Healthbar.Outline.Size.X - 2,BoxPosition.Y - 1)

                        ESP.Drawing.Healthbar.Main.Size = Vector2.new(ESP.Drawing.Healthbar.Outline.Size.X - 2,
                        -ESP.Target.HealthPercent * (ESP.Drawing.Healthbar.Outline.Size.Y - 2))

                        ESP.Drawing.Healthbar.Main.Position = ESP.Drawing.Healthbar.Outline.Position
                        + Vector2.new(1,ESP.Drawing.Healthbar.Outline.Size.Y - 1)
                    end
                    if ESP.Drawing.Box.Text.Visible then
                        ESP.Drawing.Box.Text.Size = ClampDistance(ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Text/Autoscale"),
                        ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Text/Size"),Distance)
                        ESP.Drawing.Box.Text.Outline = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Text/Outline")
                        ESP.Drawing.Box.Text.Font = GetFontFromName(ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Text/Font")[1])
                        ESP.Drawing.Box.Text.Transparency = 1-ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Text/Transparency")
                        ESP.Drawing.Box.Text.Text = string.format("%s\n%i meters",ESP.Mode == "Player" and Target.Name
                        or (ESP.Target.InEnemyTeam and "Enemy NPC" or "Ally NPC"),Distance)
                        ESP.Drawing.Box.Text.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                    end
                end
            else
                if ESP.Drawing.Arrow.Main.Visible then
                    local Relative = GetRelative(Camera,ESP.Target.RootPart.Position)
                    local SideLength = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Width") / 2

                    local Direction = Relative.Unit
                    local Base = Direction * ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Distance")
                    local BaseL = Base + RotateDirection(Direction,90) * SideLength
                    local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                    local Tip = Direction * (ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Distance") + ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Height"))

                    local RTCBL = RelativeToCenter(Camera,BaseL)
                    local RTCBR = RelativeToCenter(Camera,BaseR)
                    local RTCT = RelativeToCenter(Camera,Tip)

                    ESP.Drawing.Arrow.Main.Color = ESP.Target.Color
                    ESP.Drawing.Arrow.Main.Filled = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Filled")
                    ESP.Drawing.Arrow.Main.Thickness = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Thickness")
                    ESP.Drawing.Arrow.Main.Transparency = 1 - ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Transparency")
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

        local TeamCheck = not ConcatFlag(ESP.Flags,ESP.FlagConcat,"/TeamCheck") and not ESP.Target.InEnemyTeam or ESP.Target.InEnemyTeam
        local Visible = ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.RootPart and ESP.Target.IsAlive and TeamCheck
        local ArrowVisible = not ESP.Target.OnScreen and ESP.Target.InTheRange and ESP.Target.RootPart and ESP.Target.IsAlive and TeamCheck

        ESP.Highlight.Enabled = Visible and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Highlight/Enabled") or false

        ESP.Drawing.Box.Main.Visible = Visible and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Enabled") or false
        ESP.Drawing.Box.Outline.Visible = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Outline")
        and ESP.Drawing.Box.Main.Visible or false
        ESP.Drawing.Box.Text.Visible = Visible and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Text/Enabled") or false

        ESP.Drawing.Healthbar.Main.Visible = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Healthbar")
        and not ESP.Target.BoxTooSmall and ESP.Drawing.Box.Main.Visible or false
        ESP.Drawing.Healthbar.Outline.Visible = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Box/Outline")
        and ESP.Drawing.Healthbar.Main.Visible or false

        ESP.Drawing.Arrow.Main.Visible = ArrowVisible and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Enabled") or false
        ESP.Drawing.Arrow.Outline.Visible = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Arrow/Outline")
        and ESP.Drawing.Arrow.Main.Visible or false

        ESP.Drawing.Head.Main.Visible = Visible and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Enabled") or false
        ESP.Drawing.Head.Outline.Visible = ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Head/Outline")
        and ESP.Drawing.Head.Main.Visible or false

        ESP.Drawing.Tracer.Visible = Visible and ConcatFlag(ESP.Flags,ESP.FlagConcat,"/Tracer/Enabled") or false
    end
end)
return DrawingLibrary
