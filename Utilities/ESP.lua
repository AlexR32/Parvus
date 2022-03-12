local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer
local ESPLibrary = {ESPContainer = {}}

local HighlightContainer = nil
if CoreGui:FindFirstChild("HighlightContainer") then
    HighlightContainer = CoreGui.HighlightContainer
else
    HighlightContainer = Instance.new("Folder")
    HighlightContainer.Name = "HighlightContainer"
    HighlightContainer.Parent = CoreGui
end

function PlayerManager(Player)
    return Player.Character, Player.Character and Player.Character.PrimaryPart,
    (Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and
    Player.Character:FindFirstChildOfClass("Humanoid").Health > 0) or false,
    LocalPlayer.Team ~= Player.Team, Player.TeamColor.Color
end

local function GetDistanceFromCamera(Position)
    local Camera = Workspace.CurrentCamera
    return (Camera.CFrame.Position - Position).Magnitude
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
        if type(Drawing) == "table" and Drawing.Remove then
            Drawing:Remove()
        elseif type(Drawing) == "table" then
            RemoveDrawing(Drawing)
        end
    end
end

local function TableToColor(Table)
    if typeof(Table) ~= "table" then return Table end
    return Color3.new(Table[1],Table[2],Table[3])
end

local function CalculateBox(Model,Orientation,ScreenPosition)
    local Camera = Workspace.CurrentCamera
    local Size = Model:GetExtentsSize()

    local CornerTable = {
        TopLeft = Camera:WorldToViewportPoint(Vector3.new(Orientation.X - Size.X * 0.5, Orientation.Y + Size.Y * 0.5, Orientation.Z)),
        TopRight = Camera:WorldToViewportPoint(Vector3.new(Orientation.X + Size.X * 0.5, Orientation.Y + Size.Y * 0.5, Orientation.Z)),
        BottomLeft = Camera:WorldToViewportPoint(Vector3.new(Orientation.X - Size.X * 0.5, Orientation.Y - Size.Y * 0.5, Orientation.Z)),
        --BottomRight = Camera:WorldToViewportPoint(Vector3.new(Orientation.X + Size.X * 0.5, Orientation.Y - Size.Y * 0.5, Orientation.Z))
    }
    local ScreenSize = Vector2.new((CornerTable.TopLeft - CornerTable.TopRight).Magnitude, (CornerTable.TopLeft - CornerTable.BottomLeft).Magnitude)
    return Vector2.new(ScreenPosition.X - ScreenSize.X * 0.5, ScreenPosition.Y - ScreenSize.Y * 0.5), ScreenSize
end

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
    return Camera.ViewportSize * 0.5 - Size
end
local function AntiAliasing(Position)
    return Vector2.new(math.round(Position.X), math.round(Position.Y))
end

--[[
local function CalculateBox(Model,Orientation)
    local Camera = Workspace.CurrentCamera
    local Size = Model:GetExtentsSize()

    local Height = (Camera.CFrame - Camera.CFrame.Position) * Vector3.new(0, math.clamp(Size.Y, 1, 10) * 0.5, 0)
    Height = math.abs(Camera:WorldToScreenPoint(Orientation.Position + Height).Y - Camera:WorldToScreenPoint(Orientation.Position - Height).Y)
    Size = Vector2.new(Height * 0.5, Height)
    return Size
end
]]

if game.GameId == 580765040 then
    function PlayerManager(Player)
        local InEnemyTeam = false
        if Player.Character and Player.Character:FindFirstChild("Team") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Team") then
            if Player.Character.Team.Value ~= LocalPlayer.Character.Team.Value or Player.Character.Team.Value == "None" then
                InEnemyTeam = true
            end
        end

        return Player.Character, Player.Character and Player.Character.PrimaryPart,
        (Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and
        Player.Character:FindFirstChildOfClass("Humanoid").Health > 0) or false,
        InEnemyTeam, Player.TeamColor.Color
    end
elseif game.GameId == 1168263273 then
    repeat task.wait() until ReplicatedStorage:FindFirstChild("TS")
    local Toroiseshell = require(ReplicatedStorage.TS)

    function PlayerManager(Player,TeamCheck)
        return Player.Character and Player.Character:FindFirstChild("Hitbox"),
        Player.Character and Player.Character.PrimaryPart, true,
        (TeamCheck and LocalPlayer.Team ~= Player.Team) or
        (TeamCheck and tostring(Player.Team) == "FFA"),
        Toroiseshell.Teams.Colors[Player.Team]
    end

    local __index
    __index = hookmetamethod(game, "__index", function(table, index)
        if index == "Character" then
            return Toroiseshell.Characters:GetCharacter(table)
        elseif index == "Team" then
            return Toroiseshell.Teams:GetPlayerTeam(table)
        end
        return __index(table, index)
    end)
end

function ESPLibrary:Add(Mode, Model, Config)
    if not ESPLibrary.ESPContainer[Model] then
        ESPLibrary.ESPContainer[Model] = {
            Config = Config,
            Mode = Mode,
            --Model = Model,
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
                        Font = 3,
                        Outline = true,
                        OutlineColor = Color3.new(0,0,0),
                        Transparency = 1,
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
        return ESPLibrary.ESPContainer[Model]
    end
end

function ESPLibrary:Remove(Model)
    if ESPLibrary.ESPContainer[Model] then
        RemoveDrawing(ESPLibrary.ESPContainer[Model].Drawing)
        ESPLibrary.ESPContainer[Model].Highlight:Destroy()
        ESPLibrary.ESPContainer[Model] = nil
    end
end

RunService.Heartbeat:Connect(function()
    for Model, ESP in pairs(ESPLibrary.ESPContainer) do
        local ScreenPosition, OnScreen = Vector2.zero, false
        local Character, PrimaryPart, IsAlive, InEnemyTeam, TeamColor = nil, nil, true, false, true, Color3.new(0,0,0)

        if ESP.Mode == "Player" then
            Character, PrimaryPart, IsAlive, InEnemyTeam, TeamColor = PlayerManager(Model, ESP.Config.TeamCheck)
            if Character and PrimaryPart then
                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
                if OnScreen then
                    ESP.Highlight.Adornee = Model.Character
                    if Character:FindFirstChild("Head") and ESP.Drawing.Other.Head.Visible then
                        local HeadPosition = Camera:WorldToViewportPoint(Character.Head.Position)
                        local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                        local Radius = ESP.Config.Other.Head.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Other.Head.Radius) or ESP.Config.Other.Head.Radius
                        ESP.Drawing.Other.Head.Color = ESP.Config.TeamColor and TeamColor or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
                        ESP.Drawing.Other.Head.Radius = Radius
                        ESP.Drawing.Other.Head.Filled = ESP.Config.Other.Head.Filled
                        ESP.Drawing.Other.Head.NumSides = ESP.Config.Other.Head.NumSides
                        ESP.Drawing.Other.Head.Thickness = ESP.Config.Other.Head.Thickness
                        ESP.Drawing.Other.Head.Transparency = ESP.Config.Other.Head.Transparency
                        ESP.Drawing.Other.Head.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                    if ESP.Drawing.Other.Tracer.Visible then
                        local TracerFrom = ESP.Config.Other.Tracer.From == "Mouse" and UserInputService:GetMouseLocation()
                        or ESP.Config.Other.Tracer.From == "ScreenBottom" and Vector2.new(Camera.ViewportSize.X * 0.5,Camera.ViewportSize.Y)
                        local TracerTo = ScreenPosition
                        if Character:FindFirstChild(ESP.Config.Other.Tracer.To) then
                            TracerTo = Camera:WorldToViewportPoint(Character[ESP.Config.Other.Tracer.To].Position)
                        end
                        TracerTo = Vector2.new(TracerTo.X,TracerTo.Y)

                        ESP.Drawing.Other.Tracer.Color = ESP.Config.TeamColor and TeamColor or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
                        ESP.Drawing.Other.Tracer.Thickness = ESP.Config.Other.Tracer.Thickness
                        ESP.Drawing.Other.Tracer.Transparency = ESP.Config.Other.Tracer.Transparency
                        ESP.Drawing.Other.Tracer.From = TracerFrom
                        ESP.Drawing.Other.Tracer.To = TracerTo
                    end
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
                        local ScreenPosition, ScreenSize = CalculateBox(Character,PrimaryPart.CFrame,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = ESP.Config.TeamColor and TeamColor or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
                            ESP.Drawing.Box.Main.Transparency = ESP.Config.Box.Transparency
                            ESP.Drawing.Box.Main.Thickness = ESP.Config.Box.Thickness
                            ESP.Drawing.Box.Main.Filled = ESP.Config.Box.Filled
                            ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                            ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
                            ESP.Drawing.Box.Main.Size = ScreenSize
                            ESP.Drawing.Box.Main.Position = ScreenPosition
                            ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                            ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                        end
                        if ESP.Drawing.Box.Info.Visible then
                            local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                            local TextSize = ESP.Config.Box.Info.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Box.Info.Size) or ESP.Config.Box.Info.Size
                            ESP.Drawing.Box.Info.Size = TextSize
                            ESP.Drawing.Box.Info.Transparency = ESP.Config.Box.Info.Transparency
                            ESP.Drawing.Box.Info.Text = string.format("%s\n%d studs",Model.Name,Distance)
                            ESP.Drawing.Box.Info.Position = Vector2.new(ScreenPosition.X + ScreenSize.X * 0.5, ScreenPosition.Y + ScreenSize.Y)
                        end
                    end
                else
                    if ESP.Drawing.Other.Arrow.Visible then
                        local Relative = GetRelative(PrimaryPart.Position)
                        local Direction = Relative.Unit
                        local Base = Direction * ESP.Config.Other.Arrow.DistanceFromCenter
                        local SideLength = ESP.Config.Other.Arrow.Width * 0.5
                        local BaseL = Base + RotateDirection(Direction,90) * SideLength
                        local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                        local Tip = Direction * (ESP.Config.Other.Arrow.DistanceFromCenter + ESP.Config.Other.Arrow.Height)

                        ESP.Drawing.Other.Arrow.Color = ESP.Config.TeamColor and TeamColor or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
                        ESP.Drawing.Other.Arrow.Filled = ESP.Config.Other.Arrow.Filled
                        ESP.Drawing.Other.Arrow.Thickness = ESP.Config.Other.Arrow.Thickness
                        ESP.Drawing.Other.Arrow.Transparency = ESP.Config.Other.Arrow.Transparency

                        ESP.Drawing.Other.Arrow.PointA = RelativeToCenter(BaseL)
                        ESP.Drawing.Other.Arrow.PointB = RelativeToCenter(BaseR)
                        ESP.Drawing.Other.Arrow.PointC = RelativeToCenter(Tip)
                    end
                end
            end
        elseif ESP.Mode == "NPC" then
            if Model:IsA("Model") and Model.PrimaryPart then
                local Camera = Workspace.CurrentCamera
                Character, PrimaryPart = Model, Model.PrimaryPart
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Model.PrimaryPart.Position)
                if OnScreen then
                    ESP.Highlight.Adornee = Model
                    if Model:FindFirstChild("Head") and ESP.Drawing.Other.Head.Visible then
                        local HeadPosition = Camera:WorldToViewportPoint(Model.Head.Position)
                        local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                        local Radius = ESP.Config.Other.Head.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Other.Head.Radius) or ESP.Config.Other.Head.Radius
                        ESP.Drawing.Other.Head.Color = TableToColor(ESP.Config.EnemyColor)
                        ESP.Drawing.Other.Head.Radius = Radius
                        ESP.Drawing.Other.Head.Filled = ESP.Config.Other.Head.Filled
                        ESP.Drawing.Other.Head.NumSides = ESP.Config.Other.Head.NumSides
                        ESP.Drawing.Other.Head.Thickness = ESP.Config.Other.Head.Thickness
                        ESP.Drawing.Other.Head.Transparency = ESP.Config.Other.Head.Transparency
                        ESP.Drawing.Other.Head.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                    if ESP.Drawing.Other.Tracer.Visible then
                        local TracerFrom = ESP.Config.Other.Tracer.From == "Mouse" and UserInputService:GetMouseLocation()
                        or ESP.Config.Other.Tracer.From == "ScreenBottom" and Vector2.new(Camera.ViewportSize.X * 0.5,Camera.ViewportSize.Y)
                        local TracerTo = ScreenPosition
                        if Model:FindFirstChild(ESP.Config.Other.Tracer.To) then
                            TracerTo = Camera:WorldToViewportPoint(Model[ESP.Config.Other.Tracer.To].Position)
                        end
                        TracerTo = Vector2.new(TracerTo.X,TracerTo.Y)

                        ESP.Drawing.Other.Tracer.Color = TableToColor(ESP.Config.EnemyColor)
                        ESP.Drawing.Other.Tracer.Thickness = ESP.Config.Other.Tracer.Thickness
                        ESP.Drawing.Other.Tracer.Transparency = ESP.Config.Other.Tracer.Transparency
                        ESP.Drawing.Other.Tracer.From = TracerFrom
                        ESP.Drawing.Other.Tracer.To = TracerTo
                    end
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
                        local ScreenPosition, ScreenSize = CalculateBox(Model,Model.PrimaryPart.CFrame,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config.EnemyColor)
                            ESP.Drawing.Box.Main.Transparency = ESP.Config.Box.Transparency
                            ESP.Drawing.Box.Main.Thickness = ESP.Config.Box.Thickness
                            ESP.Drawing.Box.Main.Filled = ESP.Config.Box.Filled

                            ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                            ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2

                            ESP.Drawing.Box.Main.Size = ScreenSize
                            ESP.Drawing.Box.Main.Position = ScreenPosition
                            ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                            ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                        end
                        if ESP.Drawing.Box.Info.Visible then
                            local Distance = GetDistanceFromCamera(Model.PrimaryPart.Position)
                            local TextSize = ESP.Config.Box.Info.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Box.Info.Size) or ESP.Config.Box.Info.Size
                            ESP.Drawing.Box.Info.Size = TextSize
                            ESP.Drawing.Box.Info.Transparency = ESP.Config.Box.Info.Transparency
                            ESP.Drawing.Box.Info.Text = string.format("%s\n%s studs",ESP.Config.Box.Info.Text,Distance)
                            ESP.Drawing.Box.Info.Position = Vector2.new(ScreenPosition.X + ScreenSize.X * 0.5, ScreenPosition.Y + ScreenSize.Y)
                        end
                    end
                else
                    if ESP.Drawing.Other.Arrow.Visible then
                        local Relative = GetRelative(Model.PrimaryPart.Position)
                        local Direction = Relative.Unit
                        local Base = Direction * ESP.Config.Other.Arrow.DistanceFromCenter
                        local SideLength = ESP.Config.Other.Arrow.Width * 0.5
                        local BaseL = Base + RotateDirection(Direction,90) * SideLength
                        local BaseR = Base + RotateDirection(Direction,-90) * SideLength
                        local Tip = Direction * (ESP.Config.Other.Arrow.DistanceFromCenter + ESP.Config.Other.Arrow.Height)

                        ESP.Drawing.Other.Arrow.Color = TableToColor(ESP.Config.EnemyColor)
                        ESP.Drawing.Other.Arrow.Filled = ESP.Config.Other.Arrow.Filled
                        ESP.Drawing.Other.Arrow.Thickness = ESP.Config.Other.Arrow.Thickness
                        ESP.Drawing.Other.Arrow.Transparency = ESP.Config.Other.Arrow.Transparency

                        ESP.Drawing.Other.Arrow.PointA = RelativeToCenter(BaseL)
                        ESP.Drawing.Other.Arrow.PointB = RelativeToCenter(BaseR)
                        ESP.Drawing.Other.Arrow.PointC = RelativeToCenter(Tip)
                    end
                end
            end
        elseif ESP.Mode == "Model" then
            if Model:IsA("Model") and Model.PrimaryPart then
                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Model.PrimaryPart.Position)
                if OnScreen then
                    ESP.Highlight.Adornee = Model
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
                        local ScreenPosition, ScreenSize = CalculateBox(Model,Model.PrimaryPart.CFrame,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config.EnemyColor)
                            ESP.Drawing.Box.Main.Transparency = ESP.Config.Box.Transparency
                            ESP.Drawing.Box.Main.Thickness = ESP.Config.Box.Thickness
                            ESP.Drawing.Box.Main.Filled = ESP.Config.Box.Filled

                            ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
                            ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2

                            ESP.Drawing.Box.Main.Size = ScreenSize
                            ESP.Drawing.Box.Main.Position = ScreenPosition
                            ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
                            ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
                        end
                        if ESP.Drawing.Box.Info.Visible then
                            local Distance = GetDistanceFromCamera(Model.PrimaryPart.Position)
                            local TextSize = ESP.Config.Box.Info.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Box.Info.Size) or ESP.Config.Box.Info.Size
                            ESP.Drawing.Box.Info.Size = TextSize
                            ESP.Drawing.Box.Info.Transparency = ESP.Config.Box.Info.Transparency
                            ESP.Drawing.Box.Info.Text = string.format("%s\n%s studs",ESP.Config.Box.Info.Text,Distance)
                            ESP.Drawing.Box.Info.Position = Vector2.new(ScreenPosition.X + ScreenSize.X * 0.5, ScreenPosition.Y + ScreenSize.Y)
                        end
                    end
                end
            end
        end
        local Visible = OnScreen and IsAlive and (not ESP.Config.TeamCheck or InEnemyTeam)
        local ArrowVisible = (PrimaryPart or false) and not OnScreen and IsAlive and (not ESP.Config.TeamCheck or InEnemyTeam)
        
        ESP.Highlight.Enabled = Visible and ESP.Config.Highlight.Enabled
        if ESP.Highlight.Enabled then
            ESP.Highlight.FillColor = ESP.Config.TeamColor and TeamColor or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
            ESP.Highlight.FillTransparency = ESP.Config.Highlight.Transparency
            ESP.Highlight.OutlineColor = TableToColor(ESP.Config.Highlight.Outline.Color)
            ESP.Highlight.OutlineTransparency = ESP.Config.Highlight.Outline.Transparency
        end

        ESP.Drawing.Box.Main.Visible = Visible and ESP.Config.Box.Enabled
        ESP.Drawing.Box.Outline.Visible = ESP.Config.Box.Outline and ESP.Drawing.Box.Main.Visible and not ESP.Drawing.Box.Main.Filled
        ESP.Drawing.Box.Info.Visible = Visible and ESP.Config.Box.Info.Enabled

        ESP.Drawing.Other.Head.Visible = Visible and ESP.Config.Other.Head.Enabled
        ESP.Drawing.Other.Tracer.Visible = Visible and ESP.Config.Other.Tracer.Enabled
        ESP.Drawing.Other.Arrow.Visible = ArrowVisible and ESP.Config.Other.Arrow.Enabled
    end
end)

return ESPLibrary
