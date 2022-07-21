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
        return 1
    end
end

local function GetDistanceFromCamera(Position)
    local Camera = Workspace.CurrentCamera
    return (Position - Camera.CFrame.Position).Magnitude
end
local function ClampDistance(Enabled,Clamp,Distance)
    --Distance = type(Distance) == "number" and
    --Distance or GetDistanceFromCamera(Distance.Position)
    return Enabled and math.clamp(1 / Distance * 1000,0,Clamp) or Clamp
end

function ModelManager(Mode,Model)
    if Mode == "Player" then
        if not Model.Character then return end local Character = Model.Character
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not HumanoidRootPart or not Humanoid then return end
        return Character,HumanoidRootPart,Humanoid.Health > 0,
        LocalPlayer.Team ~= Model.Team,Model.TeamColor.Color
    else
        local HumanoidRootPart = Model:FindFirstChild("HumanoidRootPart")
        local Humanoid = Model:FindFirstChildOfClass("Humanoid")
        if not Humanoid or not HumanoidRootPart then return end
        return Model,HumanoidRootPart,Humanoid.Health > 0,true
    end
end

local function AddHighlight()
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = HighlightContainer
    return Highlight
end
local function AddDrawing(Type,Properties)
    local Drawing = Drawing.new(Type)
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
    function ModelManager(Mode,Model)
        local Character,LPCharacter = Model.Character,LocalPlayer.Character
        if not Character or not LPCharacter then return end
        local Torso = Character:FindFirstChild("Torso")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid or not Torso then return end
        
        local InEnemyTeam, PlayerColor = false, Color3.new(1,1,1)
        if Character:FindFirstChild("Team") and LPCharacter:FindFirstChild("Team") then
            if Character.Team.Value ~= LPCharacter.Team.Value or Character.Team.Value == "None" then
                InEnemyTeam, PlayerColor = true, Torso.Color
            end
        end return Character,Torso,Humanoid.Health > 0,InEnemyTeam,PlayerColor
    end
elseif game.GameId == 1054526971 then
    function ModelManager(Mode,Model)
        if Mode == "Player" then
            if not Model.Character then return end local Character = Model.Character
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not HumanoidRootPart or not Humanoid then return end
            return Character,HumanoidRootPart,Humanoid.Health > 0,
            LocalPlayer.Team ~= Model.Team,Model.TeamColor.Color
        else
            local HumanoidRootPart = Model:FindFirstChild("HumanoidRootPart")
            local Humanoid = Model:FindFirstChildOfClass("Humanoid")
            if not HumanoidRootPart or not Humanoid then return end

            local RootRigAttachment = HumanoidRootPart:FindFirstChild("RootRigAttachment")
            return Model,HumanoidRootPart,Humanoid.Health > 0,RootRigAttachment and
            not RootRigAttachment:FindFirstChildWhichIsA("ProximityPrompt") or false
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

    function ModelManager(Mode,Model) local Character = Characters[Model]
        if not Character or Character.Parent == nil then return end
        local Team,LPTeam = GetPlayerTeam(Model),GetPlayerTeam(LocalPlayer)
        return Character:FindFirstChild("Hitbox"),Character:FindFirstChild("Root"),
        true,LPTeam ~= Team or tostring(Team) == "FFA",Tortoiseshell.Teams.Colors[Team]
    end
elseif game.GameId == 1586272220 then
    local function GetPlayerTank(Player)
        local Character = Player:FindFirstChild("Char")
        if not Character then return end
        if not Character.Value then return end
        return Character.Value.Parent.Parent.Parent
    end
    function ModelManager(Mode,Model)
        local PlayerTank = GetPlayerTank(Model)
        if not PlayerTank then return end
        return PlayerTank,PlayerTank.PrimaryPart or false,
        PlayerTank.Stats.Health.Value > 0,
        LocalPlayer.Team ~= Model.Team, Model.TeamColor.Color
    end
end

local function ItemESP(Item,ESP,IsBasePart)
    local ScreenPosition,OnScreen,MaxDistance
    local function ConcatFlag(Flag)
        return ESP.Config[ESP.FlagConcat .. Flag]
    end
    local function GlobalFlag(Flag)
        return ESP.Config[ESP.GlobalFlag .. Flag]
    end

    return RunService.Heartbeat:Connect(function() local Camera = Workspace.CurrentCamera
        ScreenPosition, OnScreen = Camera:WorldToViewportPoint(IsBasePart and Item[3].Position or Item[3])
        local Distance = GetDistanceFromCamera(Item[3]) * 0.28
        MaxDistance = Distance <= GlobalFlag("/Distance")
        if OnScreen and MaxDistance then
            if ESP.Drawing.Text.Visible then
                local Color = ConcatFlag("/Color")
                ESP.Drawing.Text.Color = Color[6]
                ESP.Drawing.Text.Transparency = 1-Color[4]

                ESP.Drawing.Text.Text = string.format("%s\n%i meters",Item[2],Distance)
                ESP.Drawing.Text.Position = Vector2.new(ScreenPosition.X,ScreenPosition.Y)
            end
        end ESP.Drawing.Text.Visible = OnScreen and MaxDistance and ConcatFlag("/Enabled") or false
    end)
end

local function ModelESP(Item,ESP)
    local ScreenPosition,OnScreen = Vector3.zero,false
    local function ConcatFlag(Flag)
        return ESP.Config[ESP.FlagConcat .. Flag]
    end

    return RunService.Heartbeat:Connect(function() local Camera = Workspace.CurrentCamera
        ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Item.PrimaryPart.Position)
        if OnScreen then
            if ESP.Drawing.Tracer.Visible then
                local TracerMode = ConcatFlag("/Tracer/Mode")
                ESP.Drawing.Tracer.Color = ConcatFlag("/Color")[6]
                ESP.Drawing.Tracer.Thickness = ConcatFlag("/Tracer/Thickness")
                ESP.Drawing.Tracer.Transparency = 1-ConcatFlag("/Color")[4]
                ESP.Drawing.Tracer.From = TracerMode[1] == "From Mouse" and UserInputService:GetMouseLocation()
                or TracerMode[1] == "From Bottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
                ESP.Drawing.Tracer.To = Vector2.new(ScreenPosition.X,ScreenPosition.Y)
            end
            if ESP.Drawing.Text.Visible then
                local Distance = GetDistanceFromCamera(Item.PrimaryPart.Position)
                ESP.Drawing.Text.Size = ClampDistance(ConcatFlag("/Text/Autoscale"),
                ConcatFlag("/Text/Size"),Distance)
                ESP.Drawing.Text.Outline = ConcatFlag("/Text/Outline")
                ESP.Drawing.Text.Font = GetFontFromName(ConcatFlag("/Text/Font")[1])
                ESP.Drawing.Text.Transparency = 1-ConcatFlag("/Text/Transparency")
                ESP.Drawing.Text.Text = string.format("%s\n%i studs",Item.Name,Distance)
                ESP.Drawing.Text.Position = Vector2.new(ScreenPosition.X,ScreenPosition.Y)
            end
        end

        ESP.Drawing.Text.Visible = OnScreen and ConcatFlag("/Text/Enabled") or false
        ESP.Drawing.Tracer.Visible = OnScreen and ConcatFlag("/Tracer/Enabled") or false
    end)
end

local function PlayerESP(Model,ESP)
    local ScreenPosition,OnScreen,MaxDistance
    local Character,PrimaryPart,IsAlive,InEnemyTeam,
    TeamColor = nil,nil,false,false,Color3.new(1,1,1)

    local function ConcatFlag(Flag)
        return ESP.Config[ESP.FlagConcat .. Flag]
    end

    return RunService.Heartbeat:Connect(function()
        Character,PrimaryPart,IsAlive,InEnemyTeam,
        TeamColor = ModelManager(ESP.Mode,Model)

        if Character and PrimaryPart and IsAlive then local Camera = Workspace.CurrentCamera
            ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
            local Distance = GetDistanceFromCamera(PrimaryPart.Position) * 0.28
            MaxDistance = Distance <= ConcatFlag("/Distance")

            local Color = ConcatFlag("/TeamColor") and TeamColor
            or (InEnemyTeam and ConcatFlag("/Enemy")[6]
            or ConcatFlag("/Ally")[6])

            if OnScreen and MaxDistance then
                if ESP.Highlight.Enabled then
                    ESP.Highlight.Adornee = ESP.Mode == "Player" and Model.Character or Character
                    ESP.Highlight.FillColor = Color
                    ESP.Highlight.FillTransparency = ConcatFlag("/Highlight/Transparency")
                    ESP.Highlight.OutlineColor = ConcatFlag("/Highlight/OutlineColor")[6]
                    ESP.Highlight.OutlineTransparency = ConcatFlag("/Highlight/OutlineColor")[4]
                end
                if ESP.Drawing.Other.Head.Visible or ESP.Drawing.Other.Tracer.Visible then
                    local HeadPosition = Character:FindFirstChild("Head") and Camera:WorldToViewportPoint(Character.Head.Position) or Vector3.zero
                    if ESP.Drawing.Other.Head.Visible then
                        ESP.Drawing.Other.Head.Color = Color
                        ESP.Drawing.Other.Head.Radius = ClampDistance(ConcatFlag("/Head/Autoscale"),ConcatFlag("/Head/Radius"),Distance)
                        ESP.Drawing.Other.Head.Filled = ConcatFlag("/Head/Filled")
                        ESP.Drawing.Other.Head.NumSides = ConcatFlag("/Head/NumSides")
                        ESP.Drawing.Other.Head.Thickness = ConcatFlag("/Head/Thickness")
                        ESP.Drawing.Other.Head.Transparency = 1-ConcatFlag("/Head/Transparency")
                        ESP.Drawing.Other.Head.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                    if ESP.Drawing.Other.Tracer.Visible then
                        local TracerMode = ConcatFlag("/Tracer/Mode")
                        ESP.Drawing.Other.Tracer.Color = Color
                        ESP.Drawing.Other.Tracer.Thickness = ConcatFlag("/Tracer/Thickness")
                        ESP.Drawing.Other.Tracer.Transparency = 1-ConcatFlag("/Tracer/Transparency")
                        ESP.Drawing.Other.Tracer.From = TracerMode[1] == "From Mouse" and UserInputService:GetMouseLocation()
                        or TracerMode[1] == "From Bottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
                        ESP.Drawing.Other.Tracer.To = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                end
                if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Text.Visible then
                    local BoxPosition, BoxSize = CalculateBox(Character,ScreenPosition)
                    if ESP.Drawing.Box.Main.Visible then
                        ESP.Drawing.Box.Main.Color = Color
                        ESP.Drawing.Box.Main.Filled = ConcatFlag("/Box/Filled")
                        ESP.Drawing.Box.Main.Thickness = ConcatFlag("/Box/Thickness")
                        ESP.Drawing.Box.Main.Transparency = 1-ConcatFlag("/Box/Transparency")
                        ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                        ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
                        ESP.Drawing.Box.Main.Size = BoxSize
                        ESP.Drawing.Box.Main.Position = BoxPosition
                        ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                        ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                    end
                    if ESP.Drawing.Box.Text.Visible then
                        ESP.Drawing.Box.Text.Size = ClampDistance(ConcatFlag("/Text/Autoscale"),ConcatFlag("/Text/Size"),Distance)
                        ESP.Drawing.Box.Text.Outline = ConcatFlag("/Text/Outline")
                        ESP.Drawing.Box.Text.Font = GetFontFromName(ConcatFlag("/Text/Font")[1])
                        ESP.Drawing.Box.Text.Transparency = 1-ConcatFlag("/Text/Transparency")
                        ESP.Drawing.Box.Text.Text = string.format("%s\n%i meters",ESP.Mode == "Player" and Model.Name
                        or (InEnemyTeam and "Enemy NPC" or "Ally NPC"),Distance)
                        ESP.Drawing.Box.Text.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                    end
                end
            else
                if ESP.Drawing.Other.Arrow.Visible then
                    local Relative = GetRelative(PrimaryPart.Position)
                    local Direction = Relative.Unit
                    local Base = Direction * ConcatFlag("/Arrow/Distance")
                    local SideLength = ConcatFlag("/Arrow/Width") / 2
                    local BaseL = Base + RotateDirection(Direction,90) * SideLength
                    local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                    local Tip = Direction * (ConcatFlag("/Arrow/Distance") + ConcatFlag("/Arrow/Height"))

                    ESP.Drawing.Other.Arrow.Color = Color
                    ESP.Drawing.Other.Arrow.Filled = ConcatFlag("/Arrow/Filled")
                    ESP.Drawing.Other.Arrow.Thickness = ConcatFlag("/Arrow/Thickness")
                    ESP.Drawing.Other.Arrow.Transparency = 1-ConcatFlag("/Arrow/Transparency")

                    ESP.Drawing.Other.Arrow.PointA = RelativeToCenter(BaseL)
                    ESP.Drawing.Other.Arrow.PointB = RelativeToCenter(BaseR)
                    ESP.Drawing.Other.Arrow.PointC = RelativeToCenter(Tip)
                end
            end
        end

        local Visible = OnScreen and MaxDistance and IsAlive and PrimaryPart and (not ConcatFlag("/TeamCheck") and not InEnemyTeam or InEnemyTeam)
        local ArrowVisible = not OnScreen and MaxDistance and IsAlive and PrimaryPart and (not ConcatFlag("/TeamCheck") and not InEnemyTeam or InEnemyTeam)

        ESP.Highlight.Enabled = Visible and ConcatFlag("/Highlight/Enabled") or false

        ESP.Drawing.Box.Main.Visible = Visible and ConcatFlag("/Box/Enabled") or false
        ESP.Drawing.Box.Outline.Visible = ConcatFlag("/Box/Outline")
        and ESP.Drawing.Box.Main.Visible and not ESP.Drawing.Box.Main.Filled
        ESP.Drawing.Box.Text.Visible = Visible and ConcatFlag("/Text/Enabled") or false

        ESP.Drawing.Other.Head.Visible = Visible and ConcatFlag("/Head/Enabled") or false
        ESP.Drawing.Other.Tracer.Visible = Visible and ConcatFlag("/Tracer/Enabled") or false
        ESP.Drawing.Other.Arrow.Visible = ArrowVisible and ConcatFlag("/Arrow/Enabled") or false
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
                --Font = 1,
                Outline = true,
                --OutlineColor = Color3.new(),
                --Position = Vector2.zero,
                --Size = 14,
                --Text = "Text",
                --Transparency = 1,
                --Visible = true
                ZIndex = 1
            })
        }
    }
    local IsBasePart = false
    if typeof(Item[3]) ~= "Vector3" then IsBasePart = true end
    local ESP = DrawingLibrary.ESPContainer[Item[1]]
    ESP.Render = ItemESP(Item,ESP,IsBasePart) return ESP
end
function DrawingLibrary:ModelESP(Item,FlagConcat,Config)
    if DrawingLibrary.ESPContainer[Item] then return end
    DrawingLibrary.ESPContainer[Item] = {
        FlagConcat = FlagConcat,
        Config = Config,
        Drawing = {
            Tracer = AddDrawing("Line", {
                ZIndex = 2
            }),
            Text = AddDrawing("Text", {
                Center = true,
                Color = Color3.new(1,1,1),
                OutlineColor = Color3.new(0,0,0),
                ZIndex = 1
            })
        }
    }

    local ESP = DrawingLibrary.ESPContainer[Item]
    ESP.Render = Model(Item,ESP) return ESP
end
function DrawingLibrary:AddESP(Model,Mode,FlagConcat,Config)
    if DrawingLibrary.ESPContainer[Model] then return end

    DrawingLibrary.ESPContainer[Model] = {
        FlagConcat = FlagConcat,
        Config = Config,Mode = Mode,
        Highlight = AddHighlight(),
        Drawing = {
            Box = {
                Main = AddDrawing("Square", {
                    ZIndex = 1
                }),
                Outline = AddDrawing("Square", {
                    Color = Color3.new(0,0,0),
                    Filled = false,
                    ZIndex = 0
                }),
                Text = AddDrawing("Text", {
                    Center = true,
                    Color = Color3.new(1,1,1),
                    OutlineColor = Color3.new(0,0,0),
                    ZIndex = 1
                })
            },
            Other = {
                Head = AddDrawing("Circle", {
                    ZIndex = 2
                }),
                Tracer = AddDrawing("Line", {
                    ZIndex = 2
                }),
                Arrow = AddDrawing("Triangle", {
                    ZIndex = 2
                })
            }
        }
    }

    local ESP = DrawingLibrary.ESPContainer[Model]
    ESP.Render = PlayerESP(Model,ESP) return ESP
end

function DrawingLibrary:RemoveESP(Model)
    if not DrawingLibrary.ESPContainer[Model] then return end
    local ESP = DrawingLibrary.ESPContainer[Model]

    ESP.Render:Disconnect()
    RemoveDrawing(ESP.Drawing)
    if ESP.Highlight then
        ESP.Highlight:Destroy()
    end

    DrawingLibrary.ESPContainer[Model] = nil
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
    local FovCircle = AddDrawing("Circle",{ZIndex = 3})
    RunService.RenderStepped:Connect(function()
        FovCircle.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]
        if FovCircle.Visible then
            FovCircle.Transparency = 1 - Config[Name.."/Circle/Color"][4]
            FovCircle.Color = Config[Name.."/Circle/Color"][6]
            FovCircle.Thickness = Config[Name.."/Circle/Thickness"]
            FovCircle.NumSides = Config[Name.."/Circle/NumSides"]
            FovCircle.Radius = Config[Name.."/DynamicFOV"] and
            ((120 - Workspace.CurrentCamera.FieldOfView) * 4) + Config[Name.."/FieldOfView"]
            or Config[Name.."/FieldOfView"]
            FovCircle.Filled = Config[Name.."/Circle/Filled"]
            FovCircle.Position = UserInputService:GetMouseLocation()
        end
    end)
end

return DrawingLibrary
