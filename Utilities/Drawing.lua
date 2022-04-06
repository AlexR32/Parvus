local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

function PlayerManager(Player)
	return Player.Character,
	(Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) or false,
	Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and
	Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or false,
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
		if Drawing.Remove then
			Drawing:Remove()
		else
			RemoveDrawing(Drawing)
		end
	end
end
--[[
local function CalculateBox(Model,Orientation,ScreenPosition)
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
]]
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
local function AntiAliasing(Position)
	return Vector2.new(math.round(Position.X), math.round(Position.Y))
end

local function CalculateBox(Model,Orientation,ScreenPosition)
	local Camera = Workspace.CurrentCamera
	local Size = Model:GetExtentsSize()

	local Height = (Camera.CFrame - Camera.CFrame.Position) * Vector3.new(0, Size.Y / 2, 0)
	Height = math.abs(Camera:WorldToViewportPoint(Orientation + Height).Y - Camera:WorldToViewportPoint(Orientation - Height).Y)
	Size = Vector2.new(Height / 2, Height)
	return Vector2.new(ScreenPosition.X - Size.X / 2, ScreenPosition.Y - Size.Y / 2), Size
end

if game.GameId == 580765040 then
	function PlayerManager(Player)
		local InEnemyTeam, PlayerColor = false, Color3.new(1,1,1)
		if Player.Character and Player.Character:FindFirstChild("Team") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Team") then
			if Player.Character.Team.Value ~= LocalPlayer.Character.Team.Value or Player.Character.Team.Value == "None" then
				InEnemyTeam, PlayerColor = true, Player.Character.Torso.Color
			end
		end

		return Player.Character, (Player.Character and Player.Character.PrimaryPart) or false,
		Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and
		Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 or false,
		InEnemyTeam, PlayerColor
	end
elseif game.GameId == 1168263273 then
	repeat task.wait() until ReplicatedStorage:FindFirstChild("TS")
	local Toroiseshell = require(ReplicatedStorage.TS)

	function PlayerManager(Player)
		return Player.Character and Player.Character:FindFirstChild("Hitbox"),
		(Player.Character and Player.Character.PrimaryPart) or false, true,
		LocalPlayer.Team ~= Player.Team or tostring(Player.Team) == "FFA",
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

function DrawingLibrary:AddESP(Mode, Model, Config)
	if not DrawingLibrary.ESPContainer[Model] then
		DrawingLibrary.ESPContainer[Model] = {
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
		Color = TableToColor(Config.Crosshair.Color),
		Thickness = 1.5,
		Transparency = 1,
		Visible = true,
		ZIndex = 3
	})
	
	local CrosshairR = AddDrawing("Line", {
		Color = TableToColor(Config.Crosshair.Color),
		Thickness = 1.5,
		Transparency = 1,
		Visible = true,
		ZIndex = 3
	})
	
	local CrosshairT = AddDrawing("Line", {
		Color = TableToColor(Config.Crosshair.Color),
		Thickness = 1.5,
		Transparency = 1,
		Visible = true,
		ZIndex = 3
	})
	
	local CrosshairB = AddDrawing("Line", {
		Color = TableToColor(Config.Crosshair.Color),
		Thickness = 1.5,
		Transparency = 1,
		Visible = true,
		ZIndex = 3
	})
	
	RunService.RenderStepped:Connect(function()
		local CursorEnabled = Config.Enabled and UserInputService.MouseBehavior == Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
		local CrosshairEnabled = Config.Crosshair.Enabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
		local Mouse = UserInputService:GetMouseLocation()
	
		Cursor.Visible = CursorEnabled
		CursorOutline.Visible = CursorEnabled
	
		CrosshairL.Visible = CrosshairEnabled
		CrosshairR.Visible = CrosshairEnabled
		CrosshairT.Visible = CrosshairEnabled
		CrosshairB.Visible = CrosshairEnabled
	
		if CursorEnabled then
			Cursor.PointA = Vector2.new(Mouse.X,Mouse.Y + Config.Length)
			Cursor.PointB = Vector2.new(Mouse.X,Mouse.Y)
			Cursor.PointC = Vector2.new(Mouse.X + Config.Width,Mouse.Y + Config.Width)
	
			CursorOutline.PointA = Cursor.PointA + Vector2.new(0,1)
			CursorOutline.PointB = Cursor.PointB
			CursorOutline.PointC = Cursor.PointC + Vector2.new(1,0)
		end
		if CrosshairEnabled then
			local Color = TableToColor(Config.Crosshair.Color)
			CrosshairL.Color = Color
			CrosshairL.From = Vector2.new(Mouse.X - Config.Crosshair.Gap,Mouse.Y)
			CrosshairL.To = Vector2.new(Mouse.X - (Config.Crosshair.Size + Config.Crosshair.Gap),Mouse.Y)
	
			CrosshairR.Color = Color
			CrosshairR.From = Vector2.new(Mouse.X + (Config.Crosshair.Gap + 1),Mouse.Y)
			CrosshairR.To = Vector2.new(Mouse.X + (Config.Crosshair.Size + (Config.Crosshair.Gap + 1)),Mouse.Y)
	
			CrosshairT.Color = Color
			CrosshairT.From = Vector2.new(Mouse.X,Mouse.Y - Config.Crosshair.Gap)
			CrosshairT.To = Vector2.new(Mouse.X,Mouse.Y - (Config.Crosshair.Size + Config.Crosshair.Gap))
	
			CrosshairB.Color = Color
			CrosshairB.From = Vector2.new(Mouse.X,Mouse.Y + (Config.Crosshair.Gap + 1))
			CrosshairB.To = Vector2.new(Mouse.X,Mouse.Y + (Config.Crosshair.Size + (Config.Crosshair.Gap + 1)))
		end
	end)
end

function DrawingLibrary:FoVCircle(Config)
	local FovCircle = AddDrawing("Circle",{ZIndex = 3})
	RunService.RenderStepped:Connect(function()
		FovCircle.Visible = Config.Enabled and Config.Circle.Visible
		if FovCircle.Visible then
			FovCircle.Transparency = 1 - Config.Circle.Color[4]
			FovCircle.Color = TableToColor(Config.Circle.Color)
			FovCircle.Thickness = Config.Circle.Thickness
			FovCircle.NumSides = Config.Circle.NumSides
			FovCircle.Radius = Config.FieldOfView
			FovCircle.Filled = Config.Circle.Filled
			FovCircle.Position = UserInputService:GetMouseLocation()
		end
	end)
end

RunService.Heartbeat:Connect(function()
	for Model, ESP in pairs(DrawingLibrary.ESPContainer) do
		local ScreenPosition, OnScreen = Vector2.zero, false
		local Character, PrimaryPart, IsAlive, InEnemyTeam, TeamColor = false, false, false, false, Color3.new(1,1,1)

		if ESP.Mode == "Player" then
			Character, PrimaryPart, IsAlive, InEnemyTeam, TeamColor = PlayerManager(Model)
			if Character and PrimaryPart and IsAlive then
				local Camera = Workspace.CurrentCamera
				ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
				if OnScreen then
					if ESP.Highlight.Enabled then
						ESP.Highlight.Adornee = Model.Character
						ESP.Highlight.FillColor = ESP.Config.TeamColor and TeamColor
						or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor)
						or TableToColor(ESP.Config.AllyColor))
						ESP.Highlight.FillTransparency = ESP.Config.Highlight.Transparency
						ESP.Highlight.OutlineColor = TableToColor(ESP.Config.Highlight.OutlineColor)
						ESP.Highlight.OutlineTransparency = ESP.Config.Highlight.OutlineColor[4]
					end
					if Character:FindFirstChild("Head") and ESP.Drawing.Other.Head.Visible then
						local HeadPosition = Camera:WorldToViewportPoint(Character.Head.Position)
						ESP.Drawing.Other.Head.Color = ESP.Config.TeamColor and TeamColor
						or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
						ESP.Drawing.Other.Head.Radius = ESP.Config.Other.Head.AutoScale 
						and math.clamp(1 / GetDistanceFromCamera(PrimaryPart.Position) * 1000, 0, ESP.Config.Other.Head.Radius)
						or ESP.Config.Other.Head.Radius
						ESP.Drawing.Other.Head.Filled = ESP.Config.Other.Head.Filled
						ESP.Drawing.Other.Head.NumSides = ESP.Config.Other.Head.NumSides
						ESP.Drawing.Other.Head.Thickness = ESP.Config.Other.Head.Thickness
						ESP.Drawing.Other.Head.Transparency = ESP.Config.Other.Head.Transparency
						ESP.Drawing.Other.Head.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
					end
					if Character:FindFirstChild("Head") and ESP.Drawing.Other.Tracer.Visible then
						local HeadPosition = Camera:WorldToViewportPoint(Character.Head.Position)
						ESP.Drawing.Other.Tracer.Color = ESP.Config.TeamColor and TeamColor
						or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor) or TableToColor(ESP.Config.AllyColor))
						ESP.Drawing.Other.Tracer.Thickness = ESP.Config.Other.Tracer.Thickness
						ESP.Drawing.Other.Tracer.Transparency = ESP.Config.Other.Tracer.Transparency
						ESP.Drawing.Other.Tracer.From = ESP.Config.Other.Tracer.From == "Mouse" and UserInputService:GetMouseLocation()
						or ESP.Config.Other.Tracer.From == "ScreenBottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
						ESP.Drawing.Other.Tracer.To = Vector2.new(HeadPosition.X,HeadPosition.Y)
					end
					if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
						local BoxPosition, BoxSize = CalculateBox(Character,PrimaryPart.Position,ScreenPosition)
						if ESP.Drawing.Box.Main.Visible then
							ESP.Drawing.Box.Main.Color = ESP.Config.TeamColor and TeamColor
							or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor)
							or TableToColor(ESP.Config.AllyColor))
							ESP.Drawing.Box.Main.Transparency = ESP.Config.Box.Transparency
							ESP.Drawing.Box.Main.Thickness = ESP.Config.Box.Thickness
							ESP.Drawing.Box.Main.Filled = ESP.Config.Box.Filled
							ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
							ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2
							ESP.Drawing.Box.Main.Size = BoxSize
							ESP.Drawing.Box.Main.Position = BoxPosition
							ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
							ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
						end
						if ESP.Drawing.Box.Info.Visible then
							local Distance = GetDistanceFromCamera(PrimaryPart.Position)
							ESP.Drawing.Box.Info.Size = ESP.Config.Box.Info.AutoScale
							and math.clamp(1 / Distance * 1000, 0, ESP.Config.Box.Info.Size)
							or ESP.Config.Box.Info.Size
							ESP.Drawing.Box.Info.Transparency = ESP.Config.Box.Info.Transparency
							ESP.Drawing.Box.Info.Text = string.format("%s\n%i studs",Model.Name,Distance)
							ESP.Drawing.Box.Info.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
						end
					end
				else
					if ESP.Drawing.Other.Arrow.Visible then
						local Relative = GetRelative(PrimaryPart.Position)
						local Direction = Relative.Unit
						local Base = Direction * ESP.Config.Other.Arrow.DistanceFromCenter
						local SideLength = ESP.Config.Other.Arrow.Width / 2
						local BaseL = Base + RotateDirection(Direction,90) * SideLength
						local BaseR = Base + RotateDirection(Direction,-90) * SideLength
						local Tip = Direction * (ESP.Config.Other.Arrow.DistanceFromCenter + ESP.Config.Other.Arrow.Height)

						ESP.Drawing.Other.Arrow.Color = ESP.Config.TeamColor and TeamColor
						or (InEnemyTeam and TableToColor(ESP.Config.EnemyColor)
						or TableToColor(ESP.Config.AllyColor))
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
				PrimaryPart, IsAlive = Model.PrimaryPart, true
				local Camera = Workspace.CurrentCamera
				ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
				if OnScreen then
					if ESP.Highlight.Enabled then
						ESP.Highlight.Adornee = Model
						ESP.Highlight.FillColor = TableToColor(ESP.Config.EnemyColor)
						ESP.Highlight.FillTransparency = ESP.Config.Highlight.Transparency
						ESP.Highlight.OutlineColor = TableToColor(ESP.Config.Highlight.OutlineColor)
						ESP.Highlight.OutlineTransparency = ESP.Config.Highlight.OutlineColor[4]
					end
					if Model:FindFirstChild("Head") and ESP.Drawing.Other.Head.Visible then
						local HeadPosition = Camera:WorldToViewportPoint(Model.Head.Position)
						ESP.Drawing.Other.Head.Color = TableToColor(ESP.Config.EnemyColor)
						ESP.Drawing.Other.Head.Radius = ESP.Config.Other.Head.AutoScale
						and math.clamp(1 / GetDistanceFromCamera(PrimaryPart.Position) * 1000, 0, ESP.Config.Other.Head.Radius)
						or ESP.Config.Other.Head.Radius
						ESP.Drawing.Other.Head.Filled = ESP.Config.Other.Head.Filled
						ESP.Drawing.Other.Head.NumSides = ESP.Config.Other.Head.NumSides
						ESP.Drawing.Other.Head.Thickness = ESP.Config.Other.Head.Thickness
						ESP.Drawing.Other.Head.Transparency = ESP.Config.Other.Head.Transparency
						ESP.Drawing.Other.Head.Position = Vector2.new(HeadPosition.X,HeadPosition.Y)
					end
					if Model:FindFirstChild("Head") and ESP.Drawing.Other.Tracer.Visible then
						local HeadPosition = Camera:WorldToViewportPoint(Model.Head.Position)
						ESP.Drawing.Other.Tracer.Color = TableToColor(ESP.Config.EnemyColor)
						ESP.Drawing.Other.Tracer.Thickness = ESP.Config.Other.Tracer.Thickness
						ESP.Drawing.Other.Tracer.Transparency = ESP.Config.Other.Tracer.Transparency
						ESP.Drawing.Other.Tracer.From = ESP.Config.Other.Tracer.From == "Mouse" and UserInputService:GetMouseLocation()
						or ESP.Config.Other.Tracer.From == "ScreenBottom" and Vector2.new(Camera.ViewportSize.X / 2,Camera.ViewportSize.Y)
						ESP.Drawing.Other.Tracer.To = Vector2.new(HeadPosition.X,HeadPosition.Y)
					end
					if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
						local BoxPosition, BoxSize = CalculateBox(Model,PrimaryPart.Position,ScreenPosition)
						if ESP.Drawing.Box.Main.Visible then
							ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config.EnemyColor)
							ESP.Drawing.Box.Main.Transparency = ESP.Config.Box.Transparency
							ESP.Drawing.Box.Main.Thickness = ESP.Config.Box.Thickness
							ESP.Drawing.Box.Main.Filled = ESP.Config.Box.Filled

							ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
							ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2

							ESP.Drawing.Box.Main.Size = BoxSize
							ESP.Drawing.Box.Main.Position = BoxPosition
							ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
							ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
						end
						if ESP.Drawing.Box.Info.Visible then
							local Distance = GetDistanceFromCamera(PrimaryPart.Position)
							ESP.Drawing.Box.Info.Size = ESP.Config.Box.Info.AutoScale
							and math.clamp(1 / Distance * 1000, 0, ESP.Config.Box.Info.Size)
							or ESP.Config.Box.Info.Size
							ESP.Drawing.Box.Info.Transparency = ESP.Config.Box.Info.Transparency
							ESP.Drawing.Box.Info.Text = string.format("%s\n%i studs",ESP.Config.Box.Info.Text,Distance)
							ESP.Drawing.Box.Info.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
						end
					end
				else
					if ESP.Drawing.Other.Arrow.Visible then
						local Relative = GetRelative(PrimaryPart.Position)
						local Direction = Relative.Unit
						local Base = Direction * ESP.Config.Other.Arrow.DistanceFromCenter
						local SideLength = ESP.Config.Other.Arrow.Width / 2
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
				PrimaryPart, IsAlive = Model.PrimaryPart, true
				local Camera = Workspace.CurrentCamera
				ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PrimaryPart.Position)
				if OnScreen then
					if ESP.Highlight.Enabled then
						ESP.Highlight.Adornee = Model
						ESP.Highlight.FillColor = TableToColor(ESP.Config.EnemyColor)
						ESP.Highlight.FillTransparency = ESP.Config.Highlight.Transparency
						ESP.Highlight.OutlineColor = TableToColor(ESP.Config.Highlight.OutlineColor)
						ESP.Highlight.OutlineTransparency = ESP.Config.Highlight.OutlineColor[4]
					end
					if ESP.Drawing.Box.Main.Visible or ESP.Drawing.Box.Info.Visible then
						local BoxPosition, BoxSize = CalculateBox(Model,PrimaryPart.Position,ScreenPosition)
						if ESP.Drawing.Box.Main.Visible then
							ESP.Drawing.Box.Main.Color = TableToColor(ESP.Config.EnemyColor)
							ESP.Drawing.Box.Main.Transparency = ESP.Config.Box.Transparency
							ESP.Drawing.Box.Main.Thickness = ESP.Config.Box.Thickness
							ESP.Drawing.Box.Main.Filled = ESP.Config.Box.Filled

							ESP.Drawing.Box.Outline.Transparency = ESP.Drawing.Box.Main.Transparency
							ESP.Drawing.Box.Outline.Thickness = ESP.Drawing.Box.Main.Thickness + 2

							ESP.Drawing.Box.Main.Size = BoxSize
							ESP.Drawing.Box.Main.Position = BoxPosition
							ESP.Drawing.Box.Outline.Size = ESP.Drawing.Box.Main.Size
							ESP.Drawing.Box.Outline.Position = ESP.Drawing.Box.Main.Position
						end
						if ESP.Drawing.Box.Info.Visible then
							local Distance = GetDistanceFromCamera(PrimaryPart.Position)
							local TextSize = ESP.Config.Box.Info.AutoScale
							and math.clamp(1 / Distance * 1000, 0, ESP.Config.Box.Info.Size)
							or ESP.Config.Box.Info.Size
							ESP.Drawing.Box.Info.Size = TextSize
							ESP.Drawing.Box.Info.Transparency = ESP.Config.Box.Info.Transparency
							ESP.Drawing.Box.Info.Text = string.format("%s\n%i studs",ESP.Config.Box.Info.Text,Distance)
							ESP.Drawing.Box.Info.Position = Vector2.new(BoxPosition.X + BoxSize.X / 2, BoxPosition.Y + BoxSize.Y)
						end
					end
				else
					if ESP.Drawing.Other.Arrow.Visible then
						local Relative = GetRelative(PrimaryPart.Position)
						local Direction = Relative.Unit
						local Base = Direction * ESP.Config.Other.Arrow.DistanceFromCenter
						local SideLength = ESP.Config.Other.Arrow.Width / 2
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
		end
		local Visible = OnScreen and IsAlive and PrimaryPart and (not ESP.Config.TeamCheck and not InEnemyTeam or InEnemyTeam)
		local ArrowVisible = not OnScreen and IsAlive and PrimaryPart and (not ESP.Config.TeamCheck and not InEnemyTeam or InEnemyTeam)
		
		ESP.Highlight.Enabled = Visible and ESP.Config.Highlight.Enabled

		ESP.Drawing.Box.Main.Visible = Visible and ESP.Config.Box.Enabled
		ESP.Drawing.Box.Outline.Visible = ESP.Config.Box.Outline and ESP.Drawing.Box.Main.Visible and not ESP.Drawing.Box.Main.Filled
		ESP.Drawing.Box.Info.Visible = Visible and ESP.Config.Box.Info.Enabled

		ESP.Drawing.Other.Head.Visible = Visible and ESP.Config.Other.Head.Enabled
		ESP.Drawing.Other.Tracer.Visible = Visible and ESP.Config.Other.Tracer.Enabled
		ESP.Drawing.Other.Arrow.Visible = ArrowVisible and ESP.Config.Other.Arrow.Enabled
	end
end)

return DrawingLibrary
