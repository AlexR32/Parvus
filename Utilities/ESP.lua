local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
            Model = Model,
            Highlight = AddHighlight(),
            Drawing = {
                Box = {
                    Main = AddDrawing("Square", {
                        Filled = false,
                        Thickness = 1,
                        Transparency = 1,
                        ZIndex = 1
                    }),
                    Outline = AddDrawing("Square", {
                        Color = Color3.new(0,0,0),
                        Filled = false,
                        Thickness = 3,
                        Transparency = 1,
                        ZIndex = 0
                    })
                },
                HeadCircle = AddDrawing("Circle", {
                    Transparency = 1,
                    Thickness = 1,
                    ZIndex = 2
                }),
                Text = AddDrawing("Text", {
                    Center = true,
                    Color = Color3.new(1,1,1),
                    Font = 3,
                    Outline = true,
                    OutlineColor = Color3.new(0,0,0),
                    Transparency = 1,
                    ZIndex = 1
                })
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
    for Index, ESP in pairs(ESPLibrary.ESPContainer) do
        local ScreenPosition, OnScreen = nil, false
        local Character, PrimaryPart, IsAlive, InEnemyTeam, TeamColor = nil, nil, true, false, true, Color3.new(0,0,0)

        if ESP.Mode == "Player" then
            Character, PrimaryPart, IsAlive, InEnemyTeam, TeamColor = PlayerManager(ESP.Model, ESP.Config.TeamCheck)
            if Character and PrimaryPart then
                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
                if OnScreen then
                    ESP.Highlight.Adornee = ESP.Model.Character
                    if ESP.Drawing.HeadCircle.Visible and Character:FindFirstChild("Head") then
                        local HeadPosition = Camera:WorldToViewportPoint(Character.Head.Position)
                        local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                        local Radius = ESP.Config.HeadCircle.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.HeadCircle.Radius) or ESP.Config.HeadCircle.Radius
                        ESP.Drawing.HeadCircle.Color = not ESP.Config.TeamColor and (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor)) or TeamColor
                        ESP.Drawing.HeadCircle.Radius = Radius
                        ESP.Drawing.HeadCircle.NumSides = ESP.Config.HeadCircle.NumSides
                        ESP.Drawing.HeadCircle.Filled = ESP.Config.HeadCircle.Filled
                        ESP.Drawing.HeadCircle.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Text.Visible then
                        local ScreenPosition, ScreenSize = CalculateBox(Character,PrimaryPart.CFrame,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = not ESP.Config.TeamColor and (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor)) or TeamColor
                            ESP.Drawing.Box.Main.Size = ScreenSize
                            ESP.Drawing.Box.Main.Position = ScreenPosition
                            ESP.Drawing.Box.Outline.Size = ScreenSize
                            ESP.Drawing.Box.Outline.Position = ScreenPosition
                        end
                        if ESP.Drawing.Text.Visible then
                            local Distance = GetDistanceFromCamera(PrimaryPart.Position)
                            local TextSize = ESP.Config.Text.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Text.Size) or ESP.Config.Text.Size
                            ESP.Drawing.Text.Size = TextSize
                            ESP.Drawing.Text.Text = string.format("%s\n%d studs",ESP.Model.Name,Distance)
                            ESP.Drawing.Text.Position = Vector2.new(ScreenPosition.X + ScreenSize.X * 0.5, ScreenPosition.Y + ScreenSize.Y)
                        end
                    end
                end
            end
        elseif ESP.Mode == "NPC" then
            if ESP.Model:IsA("Model") and ESP.Model.PrimaryPart then
                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(ESP.Model.PrimaryPart.Position)
                if OnScreen then
                    ESP.Highlight.Adornee = ESP.Model
                    if ESP.Drawing.HeadCircle.Visible and ESP.Model:FindFirstChild("Head") then
                        local HeadPosition = Camera:WorldToViewportPoint(ESP.Model.Head.Position)
                        local Distance = GetDistanceFromCamera(ESP.Model.PrimaryPart.Position)
                        local Radius = ESP.Config.HeadCircle.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.HeadCircle.Radius) or ESP.Config.HeadCircle.Radius
                        ESP.Drawing.HeadCircle.Color = TableToColor(ESP.Config.EnemyColor)
                        ESP.Drawing.HeadCircle.Radius = Radius
                        ESP.Drawing.HeadCircle.NumSides = ESP.Config.HeadCircle.NumSides
                        ESP.Drawing.HeadCircle.Filled = ESP.Config.HeadCircle.Filled
                        ESP.Drawing.HeadCircle.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
                    end
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Text.Visible then
                        local ScreenPosition, ScreenSize = CalculateBox(ESP.Model,ESP.Model.PrimaryPart.CFrame,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config.EnemyColor)
                            ESP.Drawing.Box.Main.Size = ScreenSize
                            ESP.Drawing.Box.Main.Position = ScreenPosition
                            ESP.Drawing.Box.Outline.Size = ScreenSize
                            ESP.Drawing.Box.Outline.Position = ScreenPosition
                        end
                        if ESP.Drawing.Text.Visible then
                            local Distance = GetDistanceFromCamera(ESP.Model.PrimaryPart.Position)
                            local TextSize = ESP.Config.Text.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Text.Size) or ESP.Config.Text.Size
                            ESP.Drawing.Text.Size = TextSize
                            ESP.Drawing.Text.Text = string.format("%s\n%d studs",ESP.Config.Text.Text,Distance)
                            ESP.Drawing.Text.Position = Vector2.new(ScreenPosition.X + ScreenSize.X * 0.5, ScreenPosition.Y + ScreenSize.Y)
                        end
                    end
                end
            end
        elseif ESP.Mode == "Model" then
            if ESP.Model:IsA("Model") and ESP.Model.PrimaryPart then
                local Camera = Workspace.CurrentCamera
                ScreenPosition, OnScreen = Camera:WorldToViewportPoint(ESP.Model.PrimaryPart.Position)
                if OnScreen then
                    ESP.Highlight.Adornee = ESP.Model
                    if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Text.Visible then
                        local ScreenPosition, ScreenSize = CalculateBox(ESP.Model,ESP.Model.PrimaryPart.CFrame,ScreenPosition)
                        if ESP.Drawing.Box.Main.Visible then
                            ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config.EnemyColor)
                            ESP.Drawing.Box.Main.Size = ScreenSize
                            ESP.Drawing.Box.Main.Position = ScreenPosition
                            ESP.Drawing.Box.Outline.Size = ScreenSize
                            ESP.Drawing.Box.Outline.Position = ScreenPosition
                        end
                        if ESP.Drawing.Text.Visible then
                            local Distance = GetDistanceFromCamera(ESP.Model.PrimaryPart.Position)
                            local TextSize = ESP.Config.Text.AutoScale and math.clamp(1 / Distance * 1000, 0, ESP.Config.Text.Size) or ESP.Config.Text.Size
                            ESP.Drawing.Text.Size = TextSize
                            ESP.Drawing.Text.Text = string.format("%s\n%d studs",ESP.Config.Text.Text,Distance)
                            ESP.Drawing.Text.Position = Vector2.new(ScreenPosition.X + ScreenSize.X * 0.5, ScreenPosition.Y + ScreenSize.Y)
                        end
                    end
                end
            end
        end

        ESP.Highlight.Enabled = (OnScreen and IsAlive and not ESP.Config.TeamCheck and ESP.Config.Highlight.Visible) or (OnScreen and IsAlive and InEnemyTeam and ESP.Config.Highlight.Visible)
        ESP.Highlight.FillColor = not ESP.Config.TeamColor and (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor)) or TeamColor
        ESP.Highlight.FillTransparency = ESP.Config.Highlight.Transparency
        ESP.Highlight.OutlineColor = TableToColor(ESP.Config.Highlight.OutlineColor)
        ESP.Highlight.OutlineTransparency = ESP.Config.Highlight.OutlineTransparency

        ESP.Drawing.Box.Main.Visible = (OnScreen and IsAlive and not ESP.Config.TeamCheck and ESP.Config.BoxVisible) or (OnScreen and IsAlive and InEnemyTeam and ESP.Config.BoxVisible)
        ESP.Drawing.Box.Outline.Visible = ESP.Drawing.Box.Main.Visible
        ESP.Drawing.HeadCircle.Visible = (OnScreen and IsAlive and not ESP.Config.TeamCheck and ESP.Config.HeadCircle.Visible) or (OnScreen and IsAlive and InEnemyTeam and ESP.Config.HeadCircle.Visible)
        ESP.Drawing.Text.Visible = (OnScreen and IsAlive and not ESP.Config.TeamCheck and ESP.Config.Text.Visible) or (OnScreen and IsAlive and InEnemyTeam and ESP.Config.Text.Visible)
    end
end)

return ESPLibrary
