local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local DrawingLibrary = {ESPContainer = {}}
local HighlightContainer = nil

if CoreGui:FindFirstChild("HighlightContainer") then
    HighlightContainer = CoreGui.HighlightContainer
else
    HighlightContainer = Instance.new("Folder")
    HighlightContainer.Name = "HighlightContainer"
    HighlightContainer.Parent = CoreGui
end

local function TableToColor(Table)
    if typeof(Table) ~= "table" then return Table end
    return Color3.fromHSV(Table[1],Table[2],Table[3])
end
local function GetFontFromName(FontName)
    if FontName == "UI" then
        return 0
    elseif FontName == "System" then
        return 1
    elseif FontName == "Plex" then
        return 2
    else--if FontName == "Monospace" then
        return 3
    end
end

local function GetDistanceFromCamera(Position)
    local Camera = Workspace.CurrentCamera
    return (Camera.CFrame.Position - Position).Magnitude
end
function ModelManager(Mode,Model)
    if Mode == "Player" then
        return Model.Character,
        (Model.Character and Model.Character:FindFirstChild("HumanoidRootPart")) or false,
        (Model.Character and Model.Character:FindFirstChildOfClass("Humanoid") and
        Model.Character:FindFirstChildOfClass("Humanoid").Health > 0) or false,
        LocalPlayer.Team ~= Model.Team, Model.TeamColor.Color
    else
        local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
        return Model, NPC:FindFirstChild("HumanoidRootPart") or false,
        (Humanoid and Humanoid.Health > 0) or false,
        true, Color3.new(1,1,1)
    end
end

local function AddHighlight()
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = HighlightContainer
    return Highlight
end
local function AddDrawing(Type, Properties)
    local Drawing = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        Drawing[Property] = Value
    end
    return Drawing
end
local function RemoveDrawing(Table)
    for Index, Drawing in pairs(Table) do
        if Drawing.Remove then
            Drawing:Remove()
        else
            RemoveDrawing(Drawing)
        end
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
local function CalculateBox(Model,Position) -- mickeyrbx
    local Camera = Workspace.CurrentCamera
    local Size = Model:GetExtentsSize()
    local ScaleFactor = 1 / (Position.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
    local Width,Height = math.round(ScaleFactor * Size.X),math.round(ScaleFactor * Size.Y)
    return Vector2.new(
        math.round(Position.X - Width / 2),
        math.round(Position.Y - Height / 2)
    ), Vector2.new(Width,Height)
end
-- Blissful
local function GetRelative(Position)
    local Camera = Workspace.CurrentCamera
    local Relative = Camera.CFrame:PointToObjectSpace(Position)
    return Vector2.new(-Relative.X, -Relative.Z)
end
local function RotateDirection(Direction, Radius)
    Radius = math.rad(Radius)
    local X = Direction.X * math.cos(Radius) - Direction.Y * math.sin(Radius)
    local Y = Direction.X * math.sin(Radius) + Direction.Y * math.cos(Radius)

    return Vector2.new(X,Y)
end
local function RelativeToCenter(Size)
    local Camera = Workspace.CurrentCamera
    return Camera.ViewportSize / 2 - Size
end
--[[local function AntiAliasing(Position)
    return Vector2.new(math.round(Position.X), math.round(Position.Y))
end]]

if game.GameId == 580765040 then
    function ModelManager(Mode,Model)
        local InEnemyTeam, PlayerColor = false, Color3.new(1,1,1)
        if Model.Character and Model.Character:FindFirstChild("Team") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Team") then
            if Model.Character.Team.Value ~= LocalPlayer.Character.Team.Value or Model.Character.Team.Value == "None" then
                InEnemyTeam, PlayerColor = true, Model.Character.Torso.Color
            end
        end

        return Model.Character,
        (Model.Character and Model.Character:FindFirstChild("Torso")) or false,
        (Model.Character and Model.Character:FindFirstChildOfClass("Humanoid") and
        Model.Character:FindFirstChildOfClass("Humanoid").Health > 0) or false,
        InEnemyTeam, PlayerColor
    end
elseif game.GameId == 1054526971 then
    function ModelManager(Mode,Model)
        if Mode == "Player" then
            return Model.Character,
            (Model.Character and Model.Character:FindFirstChild("HumanoidRootPart")) or false,
            (Model.Character and Model.Character:FindFirstChildOfClass("Humanoid") and
            Model.Character:FindFirstChildOfClass("Humanoid").Health > 0) or false,
            LocalPlayer.Team ~= Model.Team, Model.TeamColor.Color
        else
            local HumanoidRootPart = Model:FindFirstChild("HumanoidRootPart")
            local Humanoid = Model:FindFirstChildOfClass("Humanoid")
            local RootRigAttachment = HumanoidRootPart
            and HumanoidRootPart:FindFirstChild("RootRigAttachment")
            return Model, HumanoidRootPart or false,
            (Humanoid and Humanoid.Health > 0) or false,
            RootRigAttachment and not RootRigAttachment:FindFirstChildWhichIsA("ProximityPrompt") or false,
            Color3.new(1,1,1)
        end
    end
elseif game.GameId == 1168263273 then
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    repeat task.wait() until ReplicatedStorage:FindFirstChild("TS")
    local Tortoiseshell = require(ReplicatedStorage.TS)

    function ModelManager(Mode,Model)
        return Model.Character and Model.Character:FindFirstChild("Hitbox"),
        (Model.Character and Model.Character:FindFirstChild("Root")) or false,
        true,LocalPlayer.Team ~= Model.Team or tostring(Model.Team) == "FFA",
        Tortoiseshell.Teams.Colors[Model.Team]
    end

    local OldIndex
    OldIndex = hookmetamethod(game, "__index", function(Self, Index)
        if Index == "Character" then
            return Tortoiseshell.Characters:GetCharacter(Self)
        elseif Index == "Team" then
            return Tortoiseshell.Teams:GetPlayerTeam(Self)
        end
        return OldIndex(Self, Index)
    end)
elseif game.GameId == 1586272220 then
    local function GetPlayerTank(Player)
        local Char = Player:WaitForChild("Char")
        if not Char then return end
        local CharValue = Char.Value
        if not CharValue then return end
        if not CharValue.Parent
        and not CharValue.Parent.Parent
        and not CharValue.Parent.Parent.Parent then return end
        return CharValue.Parent.Parent.Parent
    end
    function ModelManager(Mode,Model)
        local PlayerTank = GetPlayerTank(Model)
        if PlayerTank then
            return PlayerTank,PlayerTank.PrimaryPart or false,
            PlayerTank.Stats.Health.Value > 0,
            LocalPlayer.Team ~= Model.Team, Model.TeamColor.Color
        end
    end
end

function DrawingLibrary:AddESP(Model,Mode,ConfigName,Config)
    if not DrawingLibrary.ESPContainer[Model] then
        DrawingLibrary.ESPContainer[Model] = {
            ConfigName = ConfigName,
            Config = Config,
            Mode = Mode,
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
                    Info = AddDrawing("Text", {
                        Center = true,
                        Color = Color3.new(1,1,1),
                        --Font = 3,
                        --Outline = true,
                        OutlineColor = Color3.new(0,0,0),
                        --Transparency = 1,
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
        return DrawingLibrary.ESPContainer[Model]
    end
end

function DrawingLibrary:RemoveESP(Model)
    if DrawingLibrary.ESPContainer[Model] then
        RemoveDrawing(DrawingLibrary.ESPContainer[Model].Drawing)
        DrawingLibrary.ESPContainer[Model].Highlight:Destroy()
        DrawingLibrary.ESPContainer[Model] = nil
    end
end

function DrawingLibrary:Cursor(Config)
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
            local Color = TableToColor(Config["Mouse/Crosshair/Color"])
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

function DrawingLibrary:FoVCircle(Name,Config)
    local FovCircle = AddDrawing("Circle",{ZIndex = 3})
    RunService.RenderStepped:Connect(function()
        FovCircle.Visible = Config[Name.."/Enabled"] and Config[Name.."/Circle/Enabled"]
        if FovCircle.Visible then
            FovCircle.Transparency = 1 - Config[Name.."/Circle/Color"][4]
            FovCircle.Color = TableToColor(Config[Name.."/Circle/Color"])
            FovCircle.Thickness = Config[Name.."/Circle/Thickness"]
            FovCircle.NumSides = Config[Name.."/Circle/NumSides"]
            FovCircle.Radius = Config[Name.."/DynamicFoV"] and
            ((120 - Workspace.CurrentCamera.FieldOfView) * 4) + Config[Name.."/FieldOfView"]
            or Config[Name.."/FieldOfView"]
            FovCircle.Filled = Config[Name.."/Circle/Filled"]
            FovCircle.Position = UserInputService:GetMouseLocation()
        end
    end)
end

RunService.Heartbeat:Connect(function()
    for Model, ESP in pairs(DrawingLibrary.ESPContainer) do
        local ScreenPosition,OnScreen = false,false
        local Character,PrimaryPart,IsAlive,InEnemyTeam,TeamColor
        = false,false,false,false,Color3.new(1,1,1)

        if ESP.Mode == "Player" or ESP.Mode == "NPC" then
            Character,PrimaryPart,IsAlive,InEnemyTeam,TeamColor = ModelManager(ESP.Mode,Model)

            if Character and PrimaryPart and IsAlive then
                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
                local Color = ESP.Config[ESP.ConfigName.."/TeamColor"] and TeamColor
                or (InEnemyTeam and TableToColor(ESP.Config[ESP.ConfigName.."/Enemy"])
                or TableToColor(ESP.Config[ESP.ConfigName.."/Ally"]))

                if OnScreen then
                    if ESP.Highlight.Enabled then
                        ESP.Highlight.Adornee = ESP.Mode == "Player" and Model.Character or Character
                        ESP.Highlight.FillColor = Color
                        ESP.Highlight.FillTransparency = ESP.Config[ESP.ConfigName.."/Highlight/Transparency"]
                        ESP.Highlight.OutlineColor = TableToColor(ESP.Config[ESP.ConfigName.."/Highlight/OutlineColor"])
                        ESP.Highlight.OutlineTransparency = ESP.Config[ESP.ConfigName.."/Highlight/OutlineColor"][4]
                    end
                    if Character:FindFirstChild("Head") and (ESP.Drawing.Other.Head.Visible or ESP.Drawing.Other.Tracer.Visible) then
                        local HeadPosition = Camera:WorldToViewportPoint(Character.Head.Position)
                        if ESP.Drawing.Other.Head.Visible then
                            ESP.Drawing.Other.Head.Color = Color
                            ESP.Drawing.Other.Head.Radius = ESP.Config[ESP.ConfigName.."/Head/Autoscale"]
                            and math.clamp(1 / GetDistanceFromCamera(PrimaryPart.Position) * 1000, 0, ESP.Config[ESP.ConfigName.."/Head/Radius"])
                            or ESP.Config[ESP.ConfigName.."/Head/Radius"]
                            ESP.Drawing.Other.Head.Filled = ESP.Config[ESP.ConfigName.."/Head/Filled"]
                            ESP.Drawing.Other.Head.NumSides = ESP.Config[ESP.ConfigName.."/Head/NumSides"]
                            ESP.Drawing.Other.Head.Thickness = ESP.Config[ESP.ConfigName.."/Head/Thickness"]
                            ESP.Drawing.Other.Head.Transparency = 1-ESP.Config[ESP.ConfigName.."/Head/Transparency"]
                            ESP.Drawing.Other.Head.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                        end
                        if ESP.Drawing.Other.Tracer.Visible then
                            ESP.Drawing.Other.Tracer.Color = Color
                            ESP.Drawing.Other.Tracer.Thickness = ESP.Config[ESP.ConfigName.."/Tracer/Thickness"]
                            ESP.Drawing.Other.Tracer.Transparency = 1-ESP.Config[ESP.ConfigName.."/Tracer/Transparency"]
                            ESP.Drawing.Other.Tracer.From = ESP.Config[ESP.ConfigName.."/Tracer/Mode"][1] == "From Mouse" and UserInputService:GetMouseLocation()
                            or ESP.Config[ESP.ConfigName.."/Tracer/Mode"][1] == "From Bottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
                            ESP.Drawing.Other.Tracer.To = Vector2.new(HeadPosition.X,HeadPosition.Y)
                        end
                    end
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
                        local BoxPosition, BoxSize = CalculateBox(Character,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = Color
                            ESP.Drawing.Box.Main.Filled = ESP.Config[ESP.ConfigName.."/Box/Filled"]
                            ESP.Drawing.Box.Main.Thickness = ESP.Config[ESP.ConfigName.."/Box/Thickness"]
                            ESP.Drawing.Box.Main.Transparency = 1-ESP.Config[ESP.ConfigName.."/Box/Transparency"]
                            ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                            ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
                            ESP.Drawing.Box.Main.Size = BoxSize
                            ESP.Drawing.Box.Main.Position = BoxPosition
                            ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                            ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                        end
                        if ESP.Drawing.Box.Info.Visible then
                            local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                            ESP.Drawing.Box.Info.Size = ESP.Config[ESP.ConfigName.."/Text/Autoscale"]
                            and math.clamp(1 / Distance * 1000, 0, ESP.Config[ESP.ConfigName.."/Text/Size"])
                            or ESP.Config[ESP.ConfigName.."/Text/Size"]
                            ESP.Drawing.Box.Info.Outline = ESP.Config[ESP.ConfigName.."/Text/Outline"]
                            ESP.Drawing.Box.Info.Font = GetFontFromName(ESP.Config[ESP.ConfigName.."/Text/Font"][1])
                            ESP.Drawing.Box.Info.Transparency = 1-ESP.Config[ESP.ConfigName.."/Text/Transparency"]
                            ESP.Drawing.Box.Info.Text = string.format("%s\n%i studs",ESP.Mode == "Player" and Model.Name
                            or (InEnemyTeam and "Enemy NPC" or "Ally NPC"),Distance)
                            ESP.Drawing.Box.Info.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                        end
                    end
                else
                    if ESP.Drawing.Other.Arrow.Visible then
                        local Relative = GetRelative(PrimaryPart.Position)
                        local Direction = Relative.Unit
                        local Base = Direction * ESP.Config[ESP.ConfigName.."/Arrow/Distance"]
                        local SideLength = ESP.Config[ESP.ConfigName.."/Arrow/Width"] / 2
                        local BaseL = Base + RotateDirection(Direction,90) * SideLength
                        local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                        local Tip = Direction * (ESP.Config[ESP.ConfigName.."/Arrow/Distance"] + ESP.Config[ESP.ConfigName.."/Arrow/Height"])

                        ESP.Drawing.Other.Arrow.Color = Color
                        ESP.Drawing.Other.Arrow.Filled = ESP.Config[ESP.ConfigName.."/Arrow/Filled"]
                        ESP.Drawing.Other.Arrow.Thickness = ESP.Config[ESP.ConfigName.."/Arrow/Thickness"]
                        ESP.Drawing.Other.Arrow.Transparency = 1-ESP.Config[ESP.ConfigName.."/Arrow/Transparency"]

                        ESP.Drawing.Other.Arrow.PointA = RelativeToCenter(BaseL)
                        ESP.Drawing.Other.Arrow.PointB = RelativeToCenter(BaseR)
                        ESP.Drawing.Other.Arrow.PointC = RelativeToCenter(Tip)
                    end
                end
            end
        else
            if Model:IsA("Model") and Model.PrimaryPart then
                Character, PrimaryPart, IsAlive, InEnemyTeam =
                Model, Model.PrimaryPart, true, true

                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
                if OnScreen then
                    if ESP.Highlight.Enabled then
                        ESP.Highlight.Adornee = Model
                        ESP.Highlight.FillColor = TableToColor(ESP.Config[ESP.ConfigName.."/Enemy"])
                        ESP.Highlight.FillTransparency = ESP.Config[ESP.ConfigName.."/Highlight/Transparency"]
                        ESP.Highlight.OutlineColor = TableToColor(ESP.Config[ESP.ConfigName.."/Highlight/OutlineColor"])
                        ESP.Highlight.OutlineTransparency = ESP.Config[ESP.ConfigName.."/Highlight/OutlineColor"][4]
                    end
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
                        local BoxPosition, BoxSize = CalculateBox(Model,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config[ESP.ConfigName.."/Enemy"])
                            ESP.Drawing.Box.Main.Filled = ESP.Config[ESP.ConfigName.."/Box/Filled"]
                            ESP.Drawing.Box.Main.Thickness = ESP.Config[ESP.ConfigName.."/Box/Thickness"]
                            ESP.Drawing.Box.Main.Transparency = 1-ESP.Config[ESP.ConfigName.."/Box/Transparency"]
                            ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                            ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
                            ESP.Drawing.Box.Main.Size = BoxSize
                            ESP.Drawing.Box.Main.Position = BoxPosition
                            ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                            ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                        end
                        if ESP.Drawing.Box.Info.Visible then
                            local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                            ESP.Drawing.Box.Info.Size = ESP.Config[ESP.ConfigName.."/Text/Autoscale"]
                            and math.clamp(1 / Distance * 1000, 0, ESP.Config[ESP.ConfigName.."/Text/Size"])
                            or ESP.Config[ESP.ConfigName.."/Text/Size"]
                            ESP.Drawing.Box.Info.Outline = ESP.Config[ESP.ConfigName.."/Text/Outline"]
                            ESP.Drawing.Box.Info.Font = GetFontFromName(ESP.Config[ESP.ConfigName.."/Text/Font"][1])
                            ESP.Drawing.Box.Info.Transparency = 1-ESP.Config[ESP.ConfigName.."/Text/Transparency"]
                            ESP.Drawing.Box.Info.Text = string.format("%s\n%i studs",Model.Name,Distance)
                            ESP.Drawing.Box.Info.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
                        end
                    end
                else
                    if ESP.Drawing.Other.Arrow.Visible then
                        local Relative = GetRelative(PrimaryPart.Position)
                        local Direction = Relative.Unit
                        local Base = Direction * ESP.Config[ESP.ConfigName.."/Arrow/Distance"]
                        local SideLength = ESP.Config[ESP.ConfigName.."/Arrow/Width"] / 2
                        local BaseL = Base + RotateDirection(Direction,90) * SideLength
                        local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                        local Tip = Direction * (ESP.Config[ESP.ConfigName.."/Arrow/Distance"] + ESP.Config[ESP.ConfigName.."/Arrow/Height"])

                        ESP.Drawing.Other.Arrow.Color = TableToColor(ESP.Config[ESP.ConfigName.."/Global/Enemy"])
                        ESP.Drawing.Other.Arrow.Filled = ESP.Config[ESP.ConfigName.."/Arrow/Filled"]
                        ESP.Drawing.Other.Arrow.Thickness = ESP.Config[ESP.ConfigName.."/Arrow/Thickness"]
                        ESP.Drawing.Other.Arrow.Transparency = 1-ESP.Config[ESP.ConfigName.."/Arrow/Transparency"]

                        ESP.Drawing.Other.Arrow.PointA = RelativeToCenter(BaseL)
                        ESP.Drawing.Other.Arrow.PointB = RelativeToCenter(BaseR)
                        ESP.Drawing.Other.Arrow.PointC = RelativeToCenter(Tip)
                    end
                end
            end
        end

        local Visible = OnScreen and IsAlive and PrimaryPart and (not ESP.Config[ESP.ConfigName.."/TeamCheck"] and not InEnemyTeam or InEnemyTeam)
        local ArrowVisible = not OnScreen and IsAlive and PrimaryPart and (not ESP.Config[ESP.ConfigName.."/TeamCheck"] and not InEnemyTeam or InEnemyTeam)

        ESP.Highlight.Enabled = Visible and ESP.Config[ESP.ConfigName.."/Highlight/Enabled"] or false

        ESP.Drawing.Box.Main.Visible = Visible and ESP.Config[ESP.ConfigName.."/Box/Enabled"] or false
        ESP.Drawing.Box.Outline.Visible = ESP.Config[ESP.ConfigName.."/Box/Outline"] and ESP.Drawing.Box.Main.Visible and not ESP.Drawing.Box.Main.Filled
        ESP.Drawing.Box.Info.Visible = Visible and ESP.Config[ESP.ConfigName.."/Text/Enabled"] or false

        ESP.Drawing.Other.Head.Visible = Visible and ESP.Config[ESP.ConfigName.."/Head/Enabled"] or false
        ESP.Drawing.Other.Tracer.Visible = Visible and ESP.Config[ESP.ConfigName.."/Tracer/Enabled"] or false
        ESP.Drawing.Other.Arrow.Visible = ArrowVisible and ESP.Config[ESP.ConfigName.."/Arrow/Enabled"] or false
    end
end)

return DrawingLibrary
