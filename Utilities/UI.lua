local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local GuiInset = GuiService:GetGuiInset()
local LocalPlayer = PlayerService.LocalPlayer
local Bracket = {IsLocal = not identifyexecutor}

Bracket.Utilities = {
	TableToColor = function(Table)
		if type(Table) ~= "table" then return Table end
		return Color3.fromHSV(Table[1], Table[2], Table[3])
	end,
	ColorToString = function(Color)
		return ("%i, %i, %i"):format(Color.R * 255, Color.G * 255, Color.B * 255)
	end,
	Scale = function(Value, InputMin, InputMax, OutputMin, OutputMax)
		return OutputMin + (Value - InputMin) * (OutputMax - OutputMin) / (InputMax - InputMin)
	end,
	DeepCopy = function(Self, Original)
		local Copy = {}

		for Index, Value in pairs(Original) do
			if type(Value) == "table" then
				Value = Self:DeepCopy(Value)
			end

			Copy[Index] = Value
		end

		return Copy
	end,
	Proxify = function(Table)
		local Proxy, Events = {}, {}
		local ChangedEvent = Instance.new("BindableEvent")
		Table.Changed = ChangedEvent.Event
		Proxy.Internal = Table

		function Table:GetPropertyChangedSignal(Property)
			local PropertyEvent = Instance.new("BindableEvent")

			Events[Property] = Events[Property] or {}
			table.insert(Events[Property], PropertyEvent)

			return PropertyEvent.Event
		end

		setmetatable(Proxy, {
			__index = function(Self, Key)
				return Table[Key]
			end,
			__newindex = function(Self, Key, Value)
				local OldValue = Table[Key]
				Table[Key] = Value

				ChangedEvent:Fire(Key, Value, OldValue)
				if Events[Key] then
					for Index, Event in ipairs(Events[Key]) do
						Event:Fire(Value, OldValue)
					end
				end
			end
		})

		return Proxy
	end,
	GetType = function(Self, Object, Default, Type, UseProxify)
		if typeof(Object) == Type then
			return UseProxify and Self.Proxify(Object) or Object
		end

		return UseProxify and Self.Proxify(Default) or Default
	end,
	GetTextBounds = function(Text, Font, Size)
		return TextService:GetTextSize(Text, Size.Y, Font, Vector2.new(Size.X, 1e6))
	end,
	MakeDraggable = function(Dragger, Object, OnChange, OnEnd)
		local Position, StartPosition = nil, nil

		Dragger.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Position = UserInputService:GetMouseLocation()
				StartPosition = Object.AbsolutePosition
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if StartPosition and Input.UserInputType == Enum.UserInputType.MouseMovement then
				local Mouse = UserInputService:GetMouseLocation()
				local Delta = Mouse - Position
				Position = Mouse

				Delta = Object.Position + UDim2.fromOffset(Delta.X, Delta.Y)
				if OnChange then OnChange(Delta) end
			end
		end)
		Dragger.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if OnEnd then OnEnd(Object.Position, StartPosition) end
				Position, StartPosition = nil, nil
			end
		end)
	end,
	MakeResizeable = function(Dragger, Object, MinSize, MaxSize, OnChange, OnEnd)
		local Position, StartSize = nil, nil

		Dragger.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Position = UserInputService:GetMouseLocation()
				StartSize = Object.AbsoluteSize
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if StartSize and Input.UserInputType == Enum.UserInputType.MouseMovement then
				local Mouse = UserInputService:GetMouseLocation()
				local Delta = Mouse - Position
				local Size = StartSize + Delta

				local SizeX = math.max(MinSize.X, Size.X)
				--SizeX = math.min(MaxSize.X, Size.X)

				local SizeY = math.max(MinSize.Y, Size.Y)
				--SizeY = math.min(MaxSize.Y, Size.Y)

				OnChange(UDim2.fromOffset(SizeX, SizeY))
			end
		end)
		Dragger.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if OnEnd then OnEnd(Object.Size, StartSize) end
				Position, StartSize = nil, nil
			end
		end)
	end,
	ClosePopUps = function()
		for Index, Object in pairs(Bracket.Screen:GetChildren()) do
			if Object.Name == "OptionContainer" or Object.Name == "Palette" then
				Object.Visible = false
			end
		end
	end,
	ChooseTab = function(TabButtonAsset, TabAsset)
		for Index, Object in pairs(Bracket.Screen:GetChildren()) do
			if Object.Name == "OptionContainer" or Object.Name == "Palette" then
				Object.Visible = false
			end
		end
		for Index, Object in pairs(Bracket.Screen.Window.TabContainer:GetChildren()) do
			if Object:IsA("ScrollingFrame") then
				Object.Visible = Object == TabAsset
			end
		end
		for Index, Object in pairs(Bracket.Screen.Window.TabButtonContainer:GetChildren()) do
			if Object:IsA("TextButton") then
				Object.Highlight.Visible = Object == TabButtonAsset
			end
		end
	end,
	GetLongestSide = function(TabAsset)
		local LeftSideSize = TabAsset.LeftSide.ListLayout.AbsoluteContentSize
		local RightSideSize = TabAsset.RightSide.ListLayout.AbsoluteContentSize
		return LeftSideSize.Y >= RightSideSize.Y and TabAsset.LeftSide or TabAsset.RightSide
	end,
	GetShortestSide = function(TabAsset)
		local LeftSideSize = TabAsset.LeftSide.ListLayout.AbsoluteContentSize
		local RightSideSize = TabAsset.RightSide.ListLayout.AbsoluteContentSize
		return LeftSideSize.Y <= RightSideSize.Y and TabAsset.LeftSide or TabAsset.RightSide
	end,
	ChooseTabSide = function(Self, TabAsset, Mode)
		if Mode == "Left" then
			return TabAsset.LeftSide
		elseif Mode == "Right" then
			return TabAsset.RightSide
		else
			return Self.GetShortestSide(TabAsset)
		end
	end,
	FindElementByFlag = function(Elements, Flag)
		for Index, Element in pairs(Elements) do
			if Element.Flag == Flag then
				return Element
			end
		end
	end,
	GetConfigs = function(FolderName)
		if not isfolder(FolderName) then makefolder(FolderName) end
		if not isfolder(FolderName .. "\\Configs") then makefolder(FolderName .. "\\Configs") end

		local Configs = {}
		for Index, Config in pairs(listfiles(FolderName .. "\\Configs") or {}) do
			Config = Config:gsub(FolderName .. "\\Configs\\", "")
			Config = Config:gsub(".json", "")

			Configs[#Configs + 1] = Config
		end

		return Configs
	end,
	ConfigsToList = function(FolderName)
		if not isfolder(FolderName) then makefolder(FolderName) end
		if not isfolder(FolderName .. "\\Configs") then makefolder(FolderName .. "\\Configs") end
		if not isfile(FolderName .. "\\AutoLoads.json") then writefile(FolderName .. "\\AutoLoads.json", "[]") end

		local AutoLoads = HttpService:JSONDecode(readfile(FolderName .. "\\AutoLoads.json"))
		local AutoLoad = AutoLoads[tostring(game.GameId)]

		local Configs = {}
		for Index, Config in pairs(listfiles(FolderName .. "\\Configs") or {}) do
			Config = Config:gsub(FolderName .. "\\Configs\\", "")
			Config = Config:gsub(".json", "")

			Configs[#Configs + 1] = {
				Name = Config,
				Mode = "Button",
				Value = Config == AutoLoad
			}
		end

		return Configs
	end
}
Bracket.Assets = {
	Screen = function(Self)
		local Screen = Instance.new("ScreenGui")
		Screen.Name = "Bracket"
		Screen.ResetOnSpawn = false
		Screen.IgnoreGuiInset = true
		Screen.DisplayOrder = Bracket.IsLocal and 0 or 10

		local ToolTip = Instance.new("TextLabel")
		ToolTip.Name = "ToolTip"
		ToolTip.ZIndex = 6
		ToolTip.Visible = false
		ToolTip.AnchorPoint = Vector2.new(0, 1)
		ToolTip.Size = UDim2.new(0, 45, 0, 20)
		ToolTip.BorderColor3 = Color3.fromRGB(63, 63, 63)
		ToolTip.Position = UDim2.new(0, 50, 0, 50)
		ToolTip.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		ToolTip.TextStrokeTransparency = 0.75
		ToolTip.TextSize = 14
		ToolTip.RichText = true
		ToolTip.TextColor3 = Color3.fromRGB(255, 255, 255)
		ToolTip.Text = "ToolTip"
		ToolTip.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
		ToolTip.Parent = Screen

		local Watermark = Instance.new("TextLabel")
		Watermark.Name = "Watermark"
		Watermark.Visible = false
		Watermark.AnchorPoint = Vector2.new(1, 0)
		Watermark.Size = UDim2.new(0, 61, 0, 20)
		Watermark.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Watermark.Position = UDim2.new(1, -20, 0, 20)
		Watermark.BorderSizePixel = 2
		Watermark.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Watermark.TextStrokeTransparency = 0.75
		Watermark.TextSize = 14
		Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
		Watermark.Text = "Watermark"
		Watermark.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
		Watermark.Parent = Screen

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Color = Color3.fromRGB(63, 63, 63)
		Stroke.Parent = Watermark

		-- Push Notification
		local PNContainer = Instance.new("Frame")
		PNContainer.Name = "PNContainer"
		PNContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		PNContainer.Size = UDim2.new(1, 0, 1, 0)
		PNContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		PNContainer.BackgroundTransparency = 1
		PNContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
		PNContainer.BorderSizePixel = 0
		PNContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		PNContainer.Parent = Screen

		local PNPadding = Instance.new("UIPadding")
		PNPadding.Name = "Padding"
		PNPadding.PaddingTop = UDim.new(0, 10)
		PNPadding.PaddingBottom = UDim.new(0, 10)
		PNPadding.PaddingLeft = UDim.new(0, 10)
		PNPadding.PaddingRight = UDim.new(0, 10)
		PNPadding.Parent = PNContainer

		local PNListLayout = Instance.new("UIListLayout")
		PNListLayout.Name = "ListLayout"
		PNListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		PNListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		PNListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PNListLayout.Padding = UDim.new(0, 12)
		PNListLayout.Parent = PNContainer

		-- Toast Notification
		local TNContainer = Instance.new("Frame")
		TNContainer.Name = "TNContainer"
		TNContainer.AnchorPoint = Vector2.new(0.5, 0.5)
		TNContainer.Size = UDim2.new(1, 0, 1, 0)
		TNContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TNContainer.BackgroundTransparency = 1
		TNContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
		TNContainer.BorderSizePixel = 0
		TNContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		TNContainer.Parent = Screen

		local TNPadding = Instance.new("UIPadding")
		TNPadding.Name = "Padding"
		TNPadding.PaddingTop = UDim.new(0, 39)
		TNPadding.PaddingBottom = UDim.new(0, 10)
		TNPadding.Parent = TNContainer

		local TNListLayout = Instance.new("UIListLayout")
		TNListLayout.Name = "ListLayout"
		TNListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TNListLayout.Padding = UDim.new(0, 5)
		TNListLayout.Parent = TNContainer

		local KeybindList = Self.KeybindList()
		KeybindList.Parent = Screen

		return Screen
	end,
	Window = function()
		local Window = Instance.new("Frame")
		Window.Name = "Window"
		Window.Size = UDim2.new(0, 496, 0, 496)
		Window.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Window.Position = UDim2.new(0.5, -248, 0.5, -248)
		Window.BorderSizePixel = 2
		Window.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Color = Color3.fromRGB(63, 63, 63)
		Stroke.Parent = Window

		local Drag = Instance.new("Frame")
		Drag.Name = "Drag"
		Drag.AnchorPoint = Vector2.new(0.5, 0)
		Drag.Size = UDim2.new(1, 0, 0, 16)
		Drag.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Drag.Position = UDim2.new(0.5, 0, 0, 0)
		Drag.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Drag.Parent = Window

		local Resize = Instance.new("ImageButton")
		Resize.Name = "Resize"
		Resize.ZIndex = 3
		Resize.AnchorPoint = Vector2.new(1, 1)
		Resize.Size = UDim2.new(0, 10, 0, 10)
		Resize.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Resize.BackgroundTransparency = 1
		Resize.Position = UDim2.new(1, 0, 1, 0)
		Resize.BorderSizePixel = 0
		Resize.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Resize.ImageColor3 = Color3.fromRGB(63, 63, 63)
		Resize.ScaleType = Enum.ScaleType.Fit
		Resize.ResampleMode = Enum.ResamplerMode.Pixelated
		Resize.Image = "rbxassetid://7368471234"
		Resize.Parent = Window

		local Snowflake = Instance.new("ImageLabel")
		Snowflake.Name = "Snowflake"
		Snowflake.Visible = false
		Snowflake.AnchorPoint = Vector2.new(0.5, 0)
		Snowflake.Size = UDim2.new(0, 10, 0, 10)
		Snowflake.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Snowflake.BackgroundTransparency = 1
		Snowflake.BorderSizePixel = 0
		Snowflake.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Snowflake.Image = "rbxassetid://242109931"
		Snowflake.Parent = Window

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.AnchorPoint = Vector2.new(0.5, 0)
		Title.Size = UDim2.new(1, -10, 0, 16)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Window"
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Window

		local Label = Instance.new("TextLabel")
		Label.Name = "Version"
		Label.AnchorPoint = Vector2.new(0.5, 0)
		Label.Size = UDim2.new(1, -10, 0, 16)
		Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Position = UDim2.new(0.5, 0, 0, 0)
		Label.BorderSizePixel = 0
		Label.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Label.TextStrokeTransparency = 0.75
		Label.TextSize = 14
		Label.RichText = true
		Label.TextColor3 = Color3.fromRGB(191, 191, 191)
		Label.Text = "Bracket V3.4"
		Label.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
		Label.TextXAlignment = Enum.TextXAlignment.Right
		Label.Parent = Window

		local Background = Instance.new("ImageLabel")
		Background.Name = "Background"
		Background.AnchorPoint = Vector2.new(0.5, 0)
		Background.Size = UDim2.new(1, 0, 1, -34)
		Background.ClipsDescendants = true
		Background.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Background.Position = UDim2.new(0.5, 0, 0, 34)
		Background.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Background.ScaleType = Enum.ScaleType.Tile
		Background.ImageColor3 = Color3.fromRGB(0, 0, 0)
		Background.TileSize = UDim2.new(0, 74, 0, 74)
		Background.Image = "rbxassetid://5553946656"
		Background.Parent = Window

		local TabContainer = Instance.new("Frame")
		TabContainer.Name = "TabContainer"
		TabContainer.AnchorPoint = Vector2.new(0.5, 0)
		TabContainer.Size = UDim2.new(1, 0, 1, -34)
		TabContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabContainer.BackgroundTransparency = 1
		TabContainer.Position = UDim2.new(0.5, 0, 0, 34)
		TabContainer.BorderSizePixel = 0
		TabContainer.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		TabContainer.Parent = Window

		local TabButtonContainer = Instance.new("ScrollingFrame")
		TabButtonContainer.Name = "TabButtonContainer"
		TabButtonContainer.AnchorPoint = Vector2.new(0.5, 0)
		TabButtonContainer.Size = UDim2.new(1, 0, 0, 17)
		TabButtonContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButtonContainer.BackgroundTransparency = 1
		TabButtonContainer.Position = UDim2.new(0.5, 0, 0, 17)
		TabButtonContainer.Active = true
		TabButtonContainer.BorderSizePixel = 0
		TabButtonContainer.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		TabButtonContainer.ScrollingDirection = Enum.ScrollingDirection.X
		TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabButtonContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		TabButtonContainer.MidImage = "rbxassetid://6432766838"
		TabButtonContainer.ScrollBarThickness = 0
		TabButtonContainer.TopImage = "rbxassetid://6432766838"
		TabButtonContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		TabButtonContainer.BottomImage = "rbxassetid://6432766838"
		TabButtonContainer.Parent = Window

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.FillDirection = Enum.FillDirection.Horizontal
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Parent = TabButtonContainer

		return Window
	end,
	PushNotification = function()
		local Notification = Instance.new("Frame")
		Notification.Name = "Notification"
		Notification.Size = UDim2.new(0, 200, 0, 48)
		Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Notification.BorderSizePixel = 2
		Notification.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Color = Color3.fromRGB(63, 63, 63)
		Stroke.Parent = Notification

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingTop = UDim.new(0, 4)
		Padding.PaddingBottom = UDim.new(0, 4)
		Padding.PaddingLeft = UDim.new(0, 4)
		Padding.PaddingRight = UDim.new(0, 4)
		Padding.Parent = Notification

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 5)
		ListLayout.Parent = Notification

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.Size = UDim2.new(1, 0, 0, 14)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Title"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Notification

		local Description = Instance.new("TextLabel")
		Description.Name = "Description"
		Description.LayoutOrder = 2
		Description.Size = UDim2.new(1, 0, 0, 14)
		Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Description.BorderSizePixel = 0
		Description.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Description.TextStrokeTransparency = 0.75
		Description.TextSize = 14
		Description.RichText = true
		Description.TextColor3 = Color3.fromRGB(255, 255, 255)
		Description.Text = "Description"
		Description.TextWrapped = true
		Description.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Description.TextXAlignment = Enum.TextXAlignment.Left
		Description.Parent = Notification

		local Divider = Instance.new("Frame")
		Divider.Name = "Divider"
		Divider.LayoutOrder = 1
		Divider.Size = UDim2.new(1, -2, 0, 2)
		Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Divider.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Divider.Parent = Notification

		local Close = Instance.new("TextButton")
		Close.Name = "Close"
		Close.AnchorPoint = Vector2.new(1, 0.5)
		Close.Size = UDim2.new(0, 14, 1, 0)
		Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Close.Position = UDim2.new(1, 0, 0.5, 0)
		Close.BorderSizePixel = 0
		Close.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Close.AutoButtonColor = false
		Close.TextStrokeTransparency = 0.75
		Close.TextSize = 14
		Close.TextColor3 = Color3.fromRGB(255, 255, 255)
		Close.Text = "X"
		Close.FontFace = Font.fromEnum(Enum.Font.Nunito)
		Close.Parent = Title

		return Notification
	end,
	ToastNotification = function()
		local Notification = Instance.new("Frame")
		Notification.Name = "Notification"
		Notification.Size = UDim2.new(0, 259, 0, 24)
		Notification.ClipsDescendants = true
		Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Notification.BackgroundTransparency = 1
		Notification.BorderSizePixel = 2
		Notification.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Main = Instance.new("Frame")
		Main.Name = "Main"
		Main.Size = UDim2.new(0, 255, 0, 20)
		Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Main.Position = UDim2.new(0, 2, 0, 2)
		Main.BorderSizePixel = 2
		Main.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Main.Parent = Notification

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Color = Color3.fromRGB(63, 63, 63)
		Stroke.Parent = Main

		local GradientLine = Instance.new("Frame")
		GradientLine.Name = "GradientLine"
		GradientLine.AnchorPoint = Vector2.new(1, 0.5)
		GradientLine.Size = UDim2.new(0, 2, 1, 4)
		GradientLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
		GradientLine.Position = UDim2.new(0, 0, 0.5, 0)
		GradientLine.BorderSizePixel = 0
		GradientLine.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
		GradientLine.Parent = Main

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0),
			NumberSequenceKeypoint.new(0.75, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		Gradient.Rotation = 90
		Gradient.Parent = GradientLine

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.AnchorPoint = Vector2.new(0.5, 0.5)
		Title.Size = UDim2.new(1, -10, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Hit OnlyTwentyCharacters in the Head with AK47"
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Main

		return Notification
	end,
	KeybindList = function()
		local KeybindList = Instance.new("Frame")
		KeybindList.Name = "KeybindList"
		KeybindList.ZIndex = 4
		KeybindList.Visible = false
		KeybindList.Size = UDim2.new(0, 121, 0, 246)
		KeybindList.BorderColor3 = Color3.fromRGB(0, 0, 0)
		KeybindList.Position = UDim2.new(0, 10, 0.5, -123)
		KeybindList.BorderSizePixel = 2
		KeybindList.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Color = Color3.fromRGB(63, 63, 63)
		Stroke.Parent = KeybindList

		local Drag = Instance.new("Frame")
		Drag.Name = "Drag"
		Drag.ZIndex = 4
		Drag.AnchorPoint = Vector2.new(0.5, 0)
		Drag.Size = UDim2.new(1, 0, 0, 16)
		Drag.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Drag.Position = UDim2.new(0.5, 0, 0, 0)
		Drag.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Drag.Parent = KeybindList

		local Resize = Instance.new("ImageButton")
		Resize.Name = "Resize"
		Resize.ZIndex = 5
		Resize.AnchorPoint = Vector2.new(1, 1)
		Resize.Size = UDim2.new(0, 10, 0, 10)
		Resize.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Resize.BackgroundTransparency = 1
		Resize.Position = UDim2.new(1, 0, 1, 0)
		Resize.BorderSizePixel = 0
		Resize.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Resize.ImageColor3 = Color3.fromRGB(63, 63, 63)
		Resize.ScaleType = Enum.ScaleType.Fit
		Resize.ResampleMode = Enum.ResamplerMode.Pixelated
		Resize.Image = "rbxassetid://7368471234"
		Resize.Parent = KeybindList

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 4
		Title.AnchorPoint = Vector2.new(0.5, 0)
		Title.Size = UDim2.new(1, -10, 0, 16)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Keybinds"
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSansSemibold)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = KeybindList

		local Background = Instance.new("ImageLabel")
		Background.Name = "Background"
		Background.ZIndex = 4
		Background.AnchorPoint = Vector2.new(0.5, 0)
		Background.Size = UDim2.new(1, 0, 1, -17)
		Background.ClipsDescendants = true
		Background.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Background.Position = UDim2.new(0.5, 0, 0, 17)
		Background.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Background.ScaleType = Enum.ScaleType.Tile
		Background.ImageColor3 = Color3.fromRGB(0, 0, 0)
		Background.TileSize = UDim2.new(0, 74, 0, 74)
		Background.Image = "rbxassetid://5553946656"
		Background.Parent = KeybindList

		local List = Instance.new("ScrollingFrame")
		List.Name = "List"
		List.ZIndex = 4
		List.AnchorPoint = Vector2.new(0.5, 0)
		List.Size = UDim2.new(1, 0, 1, -17)
		List.BorderColor3 = Color3.fromRGB(0, 0, 0)
		List.BackgroundTransparency = 1
		List.Position = UDim2.new(0.5, 0, 0, 17)
		List.Active = true
		List.BorderSizePixel = 0
		List.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		List.ScrollingDirection = Enum.ScrollingDirection.Y
		List.CanvasSize = UDim2.new(0, 0, 0, 0)
		List.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		List.MidImage = "rbxassetid://6432766838"
		List.ScrollBarThickness = 0
		List.TopImage = "rbxassetid://6432766838"
		List.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		List.BottomImage = "rbxassetid://6432766838"
		List.Parent = KeybindList

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingTop = UDim.new(0, 5)
		Padding.PaddingLeft = UDim.new(0, 5)
		Padding.PaddingRight = UDim.new(0, 5)
		Padding.Parent = List

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 5)
		ListLayout.Parent = List

		return KeybindList
	end,
	KeybindMimic = function()
		local KeybindMimic = Instance.new("Frame")
		KeybindMimic.Name = "KeybindMimic"
		KeybindMimic.ZIndex = 4
		KeybindMimic.Size = UDim2.new(1, 0, 0, 14)
		KeybindMimic.BorderColor3 = Color3.fromRGB(0, 0, 0)
		KeybindMimic.BackgroundTransparency = 1
		KeybindMimic.BorderSizePixel = 0
		KeybindMimic.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 5
		Title.AnchorPoint = Vector2.new(0, 0.5)
		Title.Size = UDim2.new(1, -14, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 14, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Toggle"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = KeybindMimic

		local Tick = Instance.new("Frame")
		Tick.Name = "Tick"
		Tick.ZIndex = 5
		Tick.AnchorPoint = Vector2.new(0, 0.5)
		Tick.Size = UDim2.new(0, 10, 0, 10)
		Tick.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tick.Position = UDim2.new(0, 0, 0.5, 0)
		Tick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Tick.Parent = KeybindMimic

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Tick

		local Layout = Instance.new("Frame")
		Layout.Name = "Layout"
		Layout.ZIndex = 5
		Layout.AnchorPoint = Vector2.new(1, 0.5)
		Layout.Size = UDim2.new(1, -56, 1, 0)
		Layout.ClipsDescendants = true
		Layout.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Layout.BackgroundTransparency = 1
		Layout.Position = UDim2.new(1, 1, 0.5, 0)
		Layout.BorderSizePixel = 0
		Layout.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Layout.Parent = KeybindMimic

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingRight = UDim.new(0, 1)
		Padding.Parent = Layout

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.FillDirection = Enum.FillDirection.Horizontal
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 4)
		ListLayout.Parent = Layout

		local Keybind = Instance.new("TextLabel")
		Keybind.Name = "Keybind"
		Keybind.ZIndex = 5
		Keybind.Size = UDim2.new(0, 42, 1, 0)
		Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Keybind.BackgroundTransparency = 1
		Keybind.BorderSizePixel = 0
		Keybind.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		--Keybind.AutoButtonColor = false
		Keybind.TextStrokeTransparency = 0.75
		Keybind.TextSize = 14
		Keybind.RichText = true
		Keybind.TextColor3 = Color3.fromRGB(189, 189, 189)
		Keybind.Text = "[ NONE ]"
		Keybind.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Keybind.TextXAlignment = Enum.TextXAlignment.Right
		Keybind.Parent = Layout

		return KeybindMimic
	end,
	Tab = function()
		local Tab = Instance.new("ScrollingFrame")
		Tab.Name = "Tab"
		Tab.AnchorPoint = Vector2.new(0.5, 0.5)
		Tab.Size = UDim2.new(1, 0, 1, 0)
		Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tab.BackgroundTransparency = 1
		Tab.Position = UDim2.new(0.5, 0, 0.5, 0)
		Tab.Active = true
		Tab.BorderSizePixel = 0
		Tab.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Tab.ScrollingDirection = Enum.ScrollingDirection.Y
		Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
		Tab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
		Tab.MidImage = "rbxassetid://6432766838"
		Tab.ScrollBarThickness = 0
		Tab.TopImage = "rbxassetid://6432766838"
		Tab.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		Tab.BottomImage = "rbxassetid://6432766838"

		local LeftSide = Instance.new("Frame")
		LeftSide.Name = "LeftSide"
		LeftSide.Size = UDim2.new(0.5, 0, 1, 0)
		LeftSide.BorderColor3 = Color3.fromRGB(0, 0, 0)
		LeftSide.BackgroundTransparency = 1
		LeftSide.BorderSizePixel = 0
		LeftSide.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		LeftSide.Parent = Tab

		local LeftPadding = Instance.new("UIPadding")
		LeftPadding.Name = "Padding"
		LeftPadding.PaddingTop = UDim.new(0, 11)
		LeftPadding.PaddingLeft = UDim.new(0, 5)
		LeftPadding.PaddingRight = UDim.new(0, 5)
		LeftPadding.Parent = LeftSide

		local LeftListLayout = Instance.new("UIListLayout")
		LeftListLayout.Name = "ListLayout"
		LeftListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		LeftListLayout.Padding = UDim.new(0, 10)
		LeftListLayout.Parent = LeftSide

		local RightSide = Instance.new("Frame")
		RightSide.Name = "RightSide"
		RightSide.AnchorPoint = Vector2.new(1, 0)
		RightSide.Size = UDim2.new(0.5, 0, 1, 0)
		RightSide.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RightSide.BackgroundTransparency = 1
		RightSide.Position = UDim2.new(1, 0, 0, 0)
		RightSide.BorderSizePixel = 0
		RightSide.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		RightSide.Parent = Tab

		local RightPadding = Instance.new("UIPadding")
		RightPadding.Name = "Padding"
		RightPadding.PaddingTop = UDim.new(0, 11)
		RightPadding.PaddingLeft = UDim.new(0, 5)
		RightPadding.PaddingRight = UDim.new(0, 5)
		RightPadding.Parent = RightSide

		local RightListLayout = Instance.new("UIListLayout")
		RightListLayout.Name = "ListLayout"
		RightListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		RightListLayout.Padding = UDim.new(0, 10)
		RightListLayout.Parent = RightSide

		return Tab
	end,
	TabButton = function()
		local TabButton = Instance.new("TextButton")
		TabButton.Name = "TabButton"
		TabButton.Size = UDim2.new(0, 67, 1, -1)
		TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.BackgroundTransparency = 1
		TabButton.BorderSizePixel = 0
		TabButton.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		TabButton.AutoButtonColor = false
		TabButton.TextStrokeTransparency = 0.75
		TabButton.TextSize = 14
		TabButton.RichText = true
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.Text = "TabButton"
		TabButton.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Highlight = Instance.new("Frame")
		Highlight.Name = "Highlight"
		Highlight.Visible = false
		Highlight.AnchorPoint = Vector2.new(0.5, 1)
		Highlight.Size = UDim2.new(1, 0, 0, 1)
		Highlight.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Highlight.Position = UDim2.new(0.5, 0, 1, 1)
		Highlight.BorderSizePixel = 0
		Highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Highlight.Parent = TabButton

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0),
			NumberSequenceKeypoint.new(0.75, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		Gradient.Parent = Highlight

		return TabButton
	end,
	Section = function()
		local Section = Instance.new("Frame")
		Section.Name = "Section"
		Section.ZIndex = 2
		Section.Size = UDim2.new(1, 0, 0, 10)
		Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Section.BorderSizePixel = 2
		Section.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Color = Color3.fromRGB(63, 63, 63)
		Stroke.Parent = Section

		local Border = Instance.new("Frame")
		Border.Name = "Border"
		Border.Visible = false
		Border.AnchorPoint = Vector2.new(0.5, 0.5)
		Border.Size = UDim2.new(1, 2, 1, 2)
		Border.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Border.Position = UDim2.new(0.5, 0, 0.5, 0)
		Border.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Border.Parent = Section

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.Size = UDim2.new(0, 44, 0, 2)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.Position = UDim2.new(0, 5, 0, -2)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Section"
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.Parent = Section

		local Container = Instance.new("Frame")
		Container.Name = "Container"
		Container.ZIndex = 2
		Container.AnchorPoint = Vector2.new(0.5, 0)
		Container.Size = UDim2.new(1, 0, 1, -10)
		Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Container.BackgroundTransparency = 1
		Container.BorderSizePixel = 0
		Container.Position = UDim2.new(0.5, 0, 0, 10)
		Container.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Container.Parent = Section

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingLeft = UDim.new(0, 5)
		Padding.PaddingRight = UDim.new(0, 5)
		Padding.Parent = Container

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 5)
		ListLayout.Parent = Container

		return Section
	end,
	Divider = function()
		local Divider = Instance.new("Frame")
		Divider.Name = "Divider"
		Divider.ZIndex = 2
		Divider.AnchorPoint = Vector2.new(0.5, 0)
		Divider.Size = UDim2.new(1, 0, 0, 14)
		Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Divider.BackgroundTransparency = 1
		Divider.BorderSizePixel = 0
		Divider.BackgroundColor3 = Color3.fromRGB(31, 31, 31)

		local Left = Instance.new("Frame")
		Left.Name = "Left"
		Left.ZIndex = 2
		Left.AnchorPoint = Vector2.new(0, 0.5)
		Left.Size = UDim2.new(0.5, -24, 0, 2)
		Left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Left.Position = UDim2.new(0, 0, 0.5, 0)
		Left.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Left.Parent = Divider

		local Right = Instance.new("Frame")
		Right.Name = "Right"
		Right.ZIndex = 2
		Right.AnchorPoint = Vector2.new(1, 0.5)
		Right.Size = UDim2.new(0.5, -24, 0, 2)
		Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Right.Position = UDim2.new(1, 0, 0.5, 0)
		Right.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Right.Parent = Divider

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0.5, 0.5)
		Title.Size = UDim2.new(1, 0, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Divider"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.Parent = Divider

		return Divider
	end,
	Label = function()
		local Label = Instance.new("TextLabel")
		Label.Name = "Label"
		Label.ZIndex = 2
		Label.Size = UDim2.new(1, 0, 0, 14)
		Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Label.BackgroundTransparency = 1
		Label.BorderSizePixel = 0
		Label.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Label.TextStrokeTransparency = 0.75
		Label.TextSize = 14
		Label.RichText = true
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label.Text = "Text Label"
		Label.TextWrapped = true
		Label.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		return Label
	end,
	Button = function()
		local Button = Instance.new("TextButton")
		Button.Name = "Button"
		Button.ZIndex = 2
		Button.Size = UDim2.new(1, 0, 0, 16)
		Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Button.AutoButtonColor = false
		Button.TextStrokeTransparency = 0.75
		Button.TextSize = 14
		Button.RichText = true
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.Text = ""
		Button.TextWrapped = true
		Button.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0.5, 0.5)
		Title.Size = UDim2.new(1, -12, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Button"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.Parent = Button

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Button

		return Button
	end,
	Toggle = function()
		local Toggle = Instance.new("TextButton")
		Toggle.Name = "Toggle"
		Toggle.ZIndex = 2
		Toggle.Size = UDim2.new(1, 0, 0, 14)
		Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Toggle.BackgroundTransparency = 1
		Toggle.BorderSizePixel = 0
		Toggle.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Toggle.AutoButtonColor = false
		Toggle.TextStrokeTransparency = 0.75
		Toggle.TextSize = 14
		Toggle.RichText = true
		Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
		Toggle.Text = ""
		Toggle.TextWrapped = true
		Toggle.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0, 0.5)
		Title.Size = UDim2.new(1, -14, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 14, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Toggle"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Toggle

		local Tick = Instance.new("Frame")
		Tick.Name = "Tick"
		Tick.ZIndex = 2
		Tick.AnchorPoint = Vector2.new(0, 0.5)
		Tick.Size = UDim2.new(0, 10, 0, 10)
		Tick.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tick.Position = UDim2.new(0, 0, 0.5, 0)
		Tick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Tick.Parent = Toggle

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Tick

		local Layout = Instance.new("Frame")
		Layout.Name = "Layout"
		Layout.ZIndex = 2
		Layout.AnchorPoint = Vector2.new(1, 0.5)
		Layout.Size = UDim2.new(1, -56, 1, 0)
		Layout.ClipsDescendants = true
		Layout.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Layout.BackgroundTransparency = 1
		Layout.Position = UDim2.new(1, 1, 0.5, 0)
		Layout.BorderSizePixel = 0
		Layout.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Layout.Parent = Toggle

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingRight = UDim.new(0, 1)
		Padding.Parent = Layout

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.FillDirection = Enum.FillDirection.Horizontal
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 4)
		ListLayout.Parent = Layout

		return Toggle
	end,
	Slider = function()
		local Slider = Instance.new("TextButton")
		Slider.Name = "Slider"
		Slider.ZIndex = 2
		Slider.Size = UDim2.new(1, 0, 0, 16)
		Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Slider.BackgroundTransparency = 1
		Slider.BorderSizePixel = 0
		Slider.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Slider.AutoButtonColor = false
		Slider.TextStrokeTransparency = 0.75
		Slider.TextSize = 14
		Slider.RichText = true
		Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
		Slider.Text = ""
		Slider.TextWrapped = true
		Slider.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.ZIndex = 2
		Background.AnchorPoint = Vector2.new(0.5, 0.5)
		Background.Size = UDim2.new(1, 0, 1, 0)
		Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Background.Position = UDim2.new(0.5, 0, 0.5, 0)
		Background.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Background.Parent = Slider

		local BackGradient = Instance.new("UIGradient")
		BackGradient.Name = "Gradient"
		BackGradient.Rotation = 90
		BackGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		BackGradient.Parent = Background

		local Bar = Instance.new("Frame")
		Bar.Name = "Bar"
		Bar.ZIndex = 2
		Bar.AnchorPoint = Vector2.new(0, 0.5)
		Bar.Size = UDim2.new(0.5, 0, 1, 0)
		Bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Bar.Position = UDim2.new(0, 0, 0.5, 0)
		Bar.BorderSizePixel = 0
		Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Bar.Parent = Background

		local BarGradient = Instance.new("UIGradient")
		BarGradient.Name = "Gradient"
		BarGradient.Rotation = 90
		BarGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		BarGradient.Parent = Bar

		local Value = Instance.new("TextBox")
		Value.Name = "Value"
		Value.ZIndex = 2
		Value.AnchorPoint = Vector2.new(1, 0)
		Value.Size = UDim2.new(0, 12, 1, 0)
		Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Value.BackgroundTransparency = 1
		Value.Position = UDim2.new(1, -6, 0, 0)
		Value.BorderSizePixel = 0
		Value.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Value.TextStrokeTransparency = 0.75
		Value.PlaceholderColor3 = Color3.fromRGB(189, 189, 189)
		Value.TextSize = 14
		Value.TextColor3 = Color3.fromRGB(255, 255, 255)
		Value.PlaceholderText = "50"
		Value.Text = ""
		Value.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.Parent = Slider

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.Size = UDim2.new(1, -24, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 6, 0, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Slider"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Slider

		return Slider
	end,
	SlimSlider = function()
		local Slider = Instance.new("TextButton")
		Slider.Name = "Slider"
		Slider.ZIndex = 2
		Slider.Size = UDim2.new(1, 0, 0, 22)
		Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Slider.BackgroundTransparency = 1
		Slider.BorderSizePixel = 0
		Slider.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Slider.AutoButtonColor = false
		Slider.TextStrokeTransparency = 0.75
		Slider.TextSize = 14
		Slider.RichText = true
		Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
		Slider.Text = ""
		Slider.TextWrapped = true
		Slider.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.Size = UDim2.new(1, -12, 0, 16)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Slider"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Slider

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.ZIndex = 2
		Background.AnchorPoint = Vector2.new(0.5, 1)
		Background.Size = UDim2.new(1, 0, 0, 6)
		Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Background.Position = UDim2.new(0.5, 0, 1, 0)
		Background.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Background.Parent = Slider

		local BackGradient = Instance.new("UIGradient")
		BackGradient.Name = "Gradient"
		BackGradient.Rotation = 90
		BackGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		BackGradient.Parent = Background

		local Bar = Instance.new("Frame")
		Bar.Name = "Bar"
		Bar.ZIndex = 2
		Bar.AnchorPoint = Vector2.new(0, 0.5)
		Bar.Size = UDim2.new(0.5, 0, 1, 0)
		Bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Bar.Position = UDim2.new(0, 0, 0.5, 0)
		Bar.BorderSizePixel = 0
		Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Bar.Parent = Background

		local BarGradient = Instance.new("UIGradient")
		BarGradient.Name = "Gradient"
		BarGradient.Rotation = 90
		BarGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		BarGradient.Parent = Bar

		local Value = Instance.new("TextBox")
		Value.Name = "Value"
		Value.ZIndex = 2
		Value.AnchorPoint = Vector2.new(1, 0)
		Value.Size = UDim2.new(0, 12, 0, 16)
		Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Value.BackgroundTransparency = 1
		Value.Position = UDim2.new(1, 0, 0, 0)
		Value.BorderSizePixel = 0
		Value.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Value.TextStrokeTransparency = 0.75
		Value.PlaceholderColor3 = Color3.fromRGB(189, 189, 189)
		Value.TextSize = 14
		Value.TextColor3 = Color3.fromRGB(255, 255, 255)
		Value.PlaceholderText = "50"
		Value.Text = ""
		Value.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.Parent = Slider

		return Slider
	end,
	Textbox = function()
		local Textbox = Instance.new("TextButton")
		Textbox.Name = "Textbox"
		Textbox.ZIndex = 2
		Textbox.Size = UDim2.new(1, 0, 0, 32)
		Textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Textbox.BackgroundTransparency = 1
		Textbox.BorderSizePixel = 0
		Textbox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Textbox.AutoButtonColor = false
		Textbox.TextStrokeTransparency = 0.75
		Textbox.TextSize = 14
		Textbox.RichText = true
		Textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
		Textbox.Text = ""
		Textbox.TextWrapped = true
		Textbox.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0.5, 0)
		Title.Size = UDim2.new(1, 0, 0, 16)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Textbox"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Textbox

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.ZIndex = 2
		Background.AnchorPoint = Vector2.new(0.5, 0)
		Background.Size = UDim2.new(1, 0, 0, 16)
		Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Background.Position = UDim2.new(0.5, 0, 0, 16)
		Background.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Background.Parent = Textbox

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Background

		local Input = Instance.new("TextBox")
		Input.Name = "Input"
		Input.ZIndex = 2
		Input.AnchorPoint = Vector2.new(0.5, 0.5)
		Input.Size = UDim2.new(1, -10, 1, 0)
		Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Input.BackgroundTransparency = 1
		Input.Position = UDim2.new(0.5, 0, 0.5, 0)
		Input.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Input.TextStrokeTransparency = 0.75
		Input.TextWrapped = true
		Input.PlaceholderColor3 = Color3.fromRGB(189, 189, 189)
		Input.TextSize = 14
		Input.TextColor3 = Color3.fromRGB(255, 255, 255)
		Input.PlaceholderText = "Input here"
		Input.Text = ""
		Input.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Input.ClearTextOnFocus = false
		Input.Parent = Background

		return Textbox
	end,
	Keybind = function()
		local Keybind = Instance.new("TextButton")
		Keybind.Name = "Keybind"
		Keybind.ZIndex = 2
		Keybind.Size = UDim2.new(1, 0, 0, 14)
		Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Keybind.BackgroundTransparency = 1
		Keybind.BorderSizePixel = 0
		Keybind.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Keybind.AutoButtonColor = false
		Keybind.TextStrokeTransparency = 0.75
		Keybind.TextSize = 14
		Keybind.RichText = true
		Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
		Keybind.Text = ""
		Keybind.TextWrapped = true
		Keybind.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0, 0.5)
		Title.Size = UDim2.new(1, -42, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 0, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Keybind"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Keybind

		local Value = Instance.new("TextLabel")
		Value.Name = "Value"
		Value.ZIndex = 2
		Value.AnchorPoint = Vector2.new(1, 0.5)
		Value.Size = UDim2.new(0, 42, 1, 0)
		Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Value.BackgroundTransparency = 1
		Value.Position = UDim2.new(1, 0, 0.5, 0)
		Value.BorderSizePixel = 0
		Value.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Value.TextStrokeTransparency = 0.75
		Value.TextSize = 14
		Value.RichText = true
		Value.TextColor3 = Color3.fromRGB(189, 189, 189)
		Value.Text = "[ NONE ]"
		Value.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.Parent = Keybind

		return Keybind
	end,
	ToggleKeybind = function()
		local Keybind = Instance.new("TextButton")
		Keybind.Name = "Keybind"
		Keybind.ZIndex = 2
		Keybind.Size = UDim2.new(0, 42, 1, 0)
		Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Keybind.BackgroundTransparency = 1
		Keybind.BorderSizePixel = 0
		Keybind.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Keybind.AutoButtonColor = false
		Keybind.TextStrokeTransparency = 0.75
		Keybind.TextSize = 14
		Keybind.RichText = true
		Keybind.TextColor3 = Color3.fromRGB(189, 189, 189)
		Keybind.Text = "[ NONE ]"
		Keybind.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Keybind.TextXAlignment = Enum.TextXAlignment.Right

		return Keybind
	end,
	Dropdown = function()
		local Dropdown = Instance.new("TextButton")
		Dropdown.Name = "Dropdown"
		Dropdown.ZIndex = 2
		Dropdown.Size = UDim2.new(1, 0, 0, 32)
		Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Dropdown.BackgroundTransparency = 1
		Dropdown.BorderSizePixel = 0
		Dropdown.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Dropdown.AutoButtonColor = false
		Dropdown.TextStrokeTransparency = 0.75
		Dropdown.TextSize = 14
		Dropdown.RichText = true
		Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
		Dropdown.Text = ""
		Dropdown.TextWrapped = true
		Dropdown.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0.5, 0)
		Title.Size = UDim2.new(1, 0, 0, 16)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Dropdown"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Dropdown

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.ZIndex = 2
		Background.AnchorPoint = Vector2.new(0.5, 0)
		Background.Size = UDim2.new(1, 0, 0, 16)
		Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Background.Position = UDim2.new(0.5, 0, 0, 16)
		Background.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Background.Parent = Dropdown

		local Value = Instance.new("TextLabel")
		Value.Name = "Value"
		Value.ZIndex = 2
		Value.AnchorPoint = Vector2.new(0.5, 0.5)
		Value.Size = UDim2.new(1, -10, 1, 0)
		Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Value.BackgroundTransparency = 1
		Value.Position = UDim2.new(0.5, 0, 0.5, 0)
		Value.BorderSizePixel = 0
		Value.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Value.TextStrokeTransparency = 0.75
		Value.TextTruncate = Enum.TextTruncate.AtEnd
		Value.TextSize = 14
		Value.TextColor3 = Color3.fromRGB(255, 255, 255)
		Value.Text = "..."
		Value.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Value.TextXAlignment = Enum.TextXAlignment.Left
		Value.Parent = Background

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Background

		return Dropdown
	end,
	DropdownContainer = function()
		local OptionContainer = Instance.new("ScrollingFrame")
		OptionContainer.Name = "OptionContainer"
		OptionContainer.ZIndex = 3
		OptionContainer.Visible = false
		OptionContainer.Size = UDim2.new(0, 100, 0, 100)
		OptionContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		OptionContainer.Active = true
		OptionContainer.BorderSizePixel = 0
		OptionContainer.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		OptionContainer.ScrollingDirection = Enum.ScrollingDirection.Y
		OptionContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		OptionContainer.ScrollBarImageColor3 = Color3.fromRGB(31, 31, 31)
		OptionContainer.MidImage = "rbxassetid://6432766838"
		OptionContainer.ScrollBarThickness = 2
		OptionContainer.TopImage = "rbxassetid://6432766838"
		OptionContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		OptionContainer.BottomImage = "rbxassetid://6432766838"

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Parent = OptionContainer

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingTop = UDim.new(0, 2)
		Padding.PaddingBottom = UDim.new(0, 2)
		Padding.PaddingLeft = UDim.new(0, 2)
		Padding.PaddingRight = UDim.new(0, 2)
		Padding.Parent = OptionContainer

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 2)
		ListLayout.Parent = OptionContainer

		return OptionContainer
	end,
	DropdownOption = function()
		local Option = Instance.new("TextButton")
		Option.Name = "Option"
		Option.ZIndex = 3
		Option.Size = UDim2.new(1, 0, 0, 16)
		Option.BorderColor3 = Color3.fromRGB(63, 63, 63)
		Option.BorderSizePixel = 0
		Option.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Option.AutoButtonColor = false
		Option.TextStrokeTransparency = 0.75
		Option.TextSize = 14
		Option.RichText = true
		Option.TextColor3 = Color3.fromRGB(255, 255, 255)
		Option.Text = ""
		Option.TextWrapped = true
		Option.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Option

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 3
		Title.AnchorPoint = Vector2.new(0, 0.5)
		Title.Size = UDim2.new(1, -18, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 18, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextTruncate = Enum.TextTruncate.AtEnd
		Title.TextSize = 14
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Toggle"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Option

		local Tick = Instance.new("Frame")
		Tick.Name = "Tick"
		Tick.ZIndex = 3
		Tick.AnchorPoint = Vector2.new(0, 0.5)
		Tick.Size = UDim2.new(0, 12, 0, 12)
		Tick.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tick.Position = UDim2.new(0, 2, 0.5, 0)
		Tick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		Tick.Parent = Option

		local TickGradient = Instance.new("UIGradient")
		TickGradient.Name = "Gradient"
		TickGradient.Rotation = 90
		TickGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		TickGradient.Parent = Tick

		local Layout = Instance.new("Frame")
		Layout.Name = "Layout"
		Layout.ZIndex = 3
		Layout.AnchorPoint = Vector2.new(1, 0.5)
		Layout.Size = UDim2.new(1, -54, 1, 0)
		Layout.ClipsDescendants = true
		Layout.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Layout.BackgroundTransparency = 1
		Layout.Position = UDim2.new(1, -1, 0.5, 0)
		Layout.BorderSizePixel = 0
		Layout.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Layout.Parent = Option

		local Padding = Instance.new("UIPadding")
		Padding.Name = "Padding"
		Padding.PaddingRight = UDim.new(0, 1)
		Padding.Parent = Layout

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Name = "ListLayout"
		ListLayout.FillDirection = Enum.FillDirection.Horizontal
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Padding = UDim.new(0, 4)
		ListLayout.Parent = Layout

		return Option
	end,
	Colorpicker = function()
		local Colorpicker = Instance.new("TextButton")
		Colorpicker.Name = "Colorpicker"
		Colorpicker.ZIndex = 2
		Colorpicker.Size = UDim2.new(1, 0, 0, 14)
		Colorpicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Colorpicker.BackgroundTransparency = 1
		Colorpicker.BorderSizePixel = 0
		Colorpicker.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Colorpicker.AutoButtonColor = false
		Colorpicker.TextStrokeTransparency = 0.75
		Colorpicker.TextSize = 14
		Colorpicker.RichText = true
		Colorpicker.TextColor3 = Color3.fromRGB(255, 255, 255)
		Colorpicker.Text = ""
		Colorpicker.TextWrapped = true
		Colorpicker.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 2
		Title.AnchorPoint = Vector2.new(0.5, 0.5)
		Title.Size = UDim2.new(1, 0, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0.5, 0, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Colorpicker"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Colorpicker

		local Color = Instance.new("Frame")
		Color.Name = "Color"
		Color.ZIndex = 2
		Color.AnchorPoint = Vector2.new(1, 0.5)
		Color.Size = UDim2.new(0, 20, 0, 10)
		Color.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Color.Position = UDim2.new(1, 0, 0.5, 0)
		Color.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		Color.Parent = Colorpicker

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Color

		return Colorpicker
	end,
	ToggleColorpicker = function()
		local TColorpicker = Instance.new("TextButton")
		TColorpicker.Name = "TColorpicker"
		TColorpicker.ZIndex = 2
		TColorpicker.AnchorPoint = Vector2.new(1, 0.5)
		TColorpicker.Size = UDim2.new(0, 24, 0, 12)
		TColorpicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TColorpicker.Position = UDim2.new(1, 0, 0.5, 0)
		TColorpicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		TColorpicker.AutoButtonColor = false
		TColorpicker.TextStrokeTransparency = 0.75
		TColorpicker.TextSize = 14
		TColorpicker.RichText = true
		TColorpicker.TextColor3 = Color3.fromRGB(255, 255, 255)
		TColorpicker.Text = ""
		TColorpicker.TextWrapped = true
		TColorpicker.FontFace = Font.fromEnum(Enum.Font.SourceSans)

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = TColorpicker

		return TColorpicker
	end,
	ColorpickerPalette = function()
		local Palette = Instance.new("Frame")
		Palette.Name = "Palette"
		Palette.ZIndex = 3
		Palette.Visible = false
		Palette.Size = UDim2.new(0, 150, 0, 290)
		Palette.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Palette.Position = UDim2.new(0, 20, 0, 20)
		Palette.BackgroundColor3 = Color3.fromRGB(63, 63, 63)

		local Gradient = Instance.new("UIGradient")
		Gradient.Name = "Gradient"
		Gradient.Rotation = 90
		Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		Gradient.Parent = Palette

		local SVPicker = Instance.new("TextButton")
		SVPicker.Name = "SVPicker"
		SVPicker.ZIndex = 3
		SVPicker.AnchorPoint = Vector2.new(0.5, 0)
		SVPicker.Size = UDim2.new(1, -10, 0, 180)
		SVPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SVPicker.Position = UDim2.new(0.5, 0, 0, 5)
		SVPicker.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		SVPicker.AutoButtonColor = false
		SVPicker.TextStrokeTransparency = 0.75
		SVPicker.TextSize = 14
		SVPicker.RichText = true
		SVPicker.TextColor3 = Color3.fromRGB(255, 255, 255)
		SVPicker.Text = ""
		SVPicker.TextWrapped = true
		SVPicker.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		SVPicker.Parent = Palette

		local Saturation = Instance.new("Frame")
		Saturation.Name = "Saturation"
		Saturation.ZIndex = 3
		Saturation.AnchorPoint = Vector2.new(0.5, 0.5)
		Saturation.Size = UDim2.new(1, 0, 1, 0)
		Saturation.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Saturation.Position = UDim2.new(0.5, 0, 0.5, 0)
		Saturation.BorderSizePixel = 0
		Saturation.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		Saturation.Parent = SVPicker

		local SaturationGradient = Instance.new("UIGradient")
		SaturationGradient.Name = "Gradient"
		SaturationGradient.Transparency = NumberSequence.new(1, 0)
		SaturationGradient.Rotation = 90
		SaturationGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
		SaturationGradient.Parent = Saturation

		local Brightness = Instance.new("Frame")
		Brightness.Name = "Brightness"
		Brightness.ZIndex = 3
		Brightness.AnchorPoint = Vector2.new(0.5, 0.5)
		Brightness.Size = UDim2.new(1, 0, 1, 0)
		Brightness.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Brightness.Position = UDim2.new(0.5, 0, 0.5, 0)
		Brightness.BorderSizePixel = 0
		Brightness.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Brightness.Parent = SVPicker

		local BrightnessGradient = Instance.new("UIGradient")
		BrightnessGradient.Name = "Gradient"
		BrightnessGradient.Transparency = NumberSequence.new(0, 1)
		BrightnessGradient.Parent = Brightness

		local SVPin = Instance.new("Frame")
		SVPin.Name = "Pin"
		SVPin.ZIndex = 3
		SVPin.AnchorPoint = Vector2.new(0.5, 0.5)
		SVPin.Size = UDim2.new(0, 3, 0, 3)
		SVPin.BorderColor3 = Color3.fromRGB(0, 0, 0)
		SVPin.Rotation = 45
		SVPin.BackgroundTransparency = 1
		SVPin.Position = UDim2.new(0.5, 0, 0.5, 0)
		SVPin.BorderSizePixel = 0
		SVPin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SVPin.Parent = SVPicker

		local SVPinStroke = Instance.new("UIStroke")
		SVPinStroke.Name = "Stroke"
		SVPinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		SVPinStroke.LineJoinMode = Enum.LineJoinMode.Miter
		SVPinStroke.Thickness = 1.5
		SVPinStroke.Parent = SVPin

		local Hue = Instance.new("TextButton")
		Hue.Name = "Hue"
		Hue.ZIndex = 3
		Hue.AnchorPoint = Vector2.new(0.5, 0)
		Hue.Size = UDim2.new(1, -10, 0, 10)
		Hue.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Hue.Position = UDim2.new(0.5, 0, 0, 191)
		Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Hue.AutoButtonColor = false
		Hue.TextStrokeTransparency = 0.75
		Hue.TextSize = 14
		Hue.RichText = true
		Hue.TextColor3 = Color3.fromRGB(255, 255, 255)
		Hue.Text = ""
		Hue.TextWrapped = true
		Hue.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Hue.Parent = Palette

		local HuePin = Instance.new("Frame")
		HuePin.Name = "Pin"
		HuePin.ZIndex = 3
		HuePin.AnchorPoint = Vector2.new(0.5, 0.5)
		HuePin.Size = UDim2.new(0, 1, 1, 0)
		HuePin.BorderColor3 = Color3.fromRGB(0, 0, 0)
		HuePin.Position = UDim2.new(0, 0, 0.5, 0)
		HuePin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		HuePin.Parent = Hue

		local HueGradient = Instance.new("UIGradient")
		HueGradient.Name = "Gradient"
		HueGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1 / 3, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(1 / 1.5, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(1 / 1.2, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
		HueGradient.Parent = Hue

		local Alpha = Instance.new("TextButton")
		Alpha.Name = "Alpha"
		Alpha.ZIndex = 3
		Alpha.AnchorPoint = Vector2.new(0.5, 0)
		Alpha.Size = UDim2.new(1, -10, 0, 10)
		Alpha.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Alpha.Position = UDim2.new(0.5, 0, 0, 207)
		Alpha.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		Alpha.AutoButtonColor = false
		Alpha.TextStrokeTransparency = 0.75
		Alpha.TextSize = 14
		Alpha.RichText = true
		Alpha.TextColor3 = Color3.fromRGB(255, 255, 255)
		Alpha.Text = ""
		Alpha.TextWrapped = true
		Alpha.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Alpha.Parent = Palette

		local Stroke = Instance.new("UIStroke")
		Stroke.Name = "Stroke"
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.LineJoinMode = Enum.LineJoinMode.Miter
		Stroke.Parent = Alpha

		local AlphaGradient = Instance.new("UIGradient")
		AlphaGradient.Name = "Gradient"
		AlphaGradient.Transparency = NumberSequence.new(0, 1)
		AlphaGradient.Parent = Alpha

		local AlphaPin = Instance.new("Frame")
		AlphaPin.Name = "Pin"
		AlphaPin.ZIndex = 3
		AlphaPin.AnchorPoint = Vector2.new(0.5, 0.5)
		AlphaPin.Size = UDim2.new(0, 1, 1, 0)
		AlphaPin.BorderColor3 = Color3.fromRGB(0, 0, 0)
		AlphaPin.Position = UDim2.new(0, 0, 0.5, 0)
		AlphaPin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		AlphaPin.Parent = Alpha

		local Value = Instance.new("TextLabel")
		Value.Name = "Value"
		Value.ZIndex = 3
		Value.AnchorPoint = Vector2.new(0.5, 0.5)
		Value.Size = UDim2.new(1, -8, 1, 0)
		Value.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Value.BackgroundTransparency = 1
		Value.Position = UDim2.new(0.5, 0, 0.5, 0)
		Value.BorderSizePixel = 0
		Value.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		Value.TextStrokeTransparency = 0.75
		Value.TextSize = 12
		Value.TextColor3 = Color3.fromRGB(255, 255, 255)
		Value.TextYAlignment = Enum.TextYAlignment.Bottom
		Value.Text = "1"
		Value.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Value.TextXAlignment = Enum.TextXAlignment.Right
		Value.Parent = Alpha

		local RGB = Instance.new("Frame")
		RGB.Name = "RGB"
		RGB.ZIndex = 3
		RGB.AnchorPoint = Vector2.new(0.5, 0)
		RGB.Size = UDim2.new(1, -10, 0, 20)
		RGB.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RGB.Position = UDim2.new(0.5, 0, 0, 223)
		RGB.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		RGB.Parent = Palette

		local RGBBox = Instance.new("TextBox")
		RGBBox.Name = "RGBBox"
		RGBBox.ZIndex = 3
		RGBBox.AnchorPoint = Vector2.new(0, 0.5)
		RGBBox.Size = UDim2.new(1, -36, 1, 0)
		RGBBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RGBBox.BackgroundTransparency = 1
		RGBBox.Position = UDim2.new(0, 31, 0.5, 0)
		RGBBox.BorderSizePixel = 0
		RGBBox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		RGBBox.TextStrokeTransparency = 0.75
		RGBBox.PlaceholderColor3 = Color3.fromRGB(189, 189, 189)
		RGBBox.TextSize = 14
		RGBBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		RGBBox.PlaceholderText = "255, 0, 0"
		RGBBox.Text = ""
		RGBBox.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		RGBBox.TextXAlignment = Enum.TextXAlignment.Left
		RGBBox.Parent = RGB

		local RGBText = Instance.new("TextLabel")
		RGBText.Name = "RGBText"
		RGBText.ZIndex = 3
		RGBText.Size = UDim2.new(0, 26, 0, 20)
		RGBText.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RGBText.BackgroundTransparency = 1
		RGBText.Position = UDim2.new(0, 5, 0, 0)
		RGBText.BorderSizePixel = 0
		RGBText.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		RGBText.TextStrokeTransparency = 0.75
		RGBText.TextSize = 14
		RGBText.RichText = true
		RGBText.TextColor3 = Color3.fromRGB(255, 255, 255)
		RGBText.Text = "RGB: "
		RGBText.TextWrapped = true
		RGBText.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		RGBText.TextXAlignment = Enum.TextXAlignment.Left
		RGBText.Parent = RGB

		local RGBGradient = Instance.new("UIGradient")
		RGBGradient.Name = "Gradient"
		RGBGradient.Rotation = 90
		RGBGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		RGBGradient.Parent = RGB

		local HEX = Instance.new("Frame")
		HEX.Name = "HEX"
		HEX.ZIndex = 3
		HEX.AnchorPoint = Vector2.new(0.5, 0)
		HEX.Size = UDim2.new(1, -10, 0, 20)
		HEX.BorderColor3 = Color3.fromRGB(0, 0, 0)
		HEX.Position = UDim2.new(0.5, 0, 0, 249)
		HEX.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		HEX.Parent = Palette

		local HEXBox = Instance.new("TextBox")
		HEXBox.Name = "HEXBox"
		HEXBox.ZIndex = 3
		HEXBox.AnchorPoint = Vector2.new(0, 0.5)
		HEXBox.Size = UDim2.new(1, -36, 1, 0)
		HEXBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		HEXBox.BackgroundTransparency = 1
		HEXBox.Position = UDim2.new(0, 36, 0.5, 0)
		HEXBox.BorderSizePixel = 0
		HEXBox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		HEXBox.TextStrokeTransparency = 0.75
		HEXBox.PlaceholderColor3 = Color3.fromRGB(189, 189, 189)
		HEXBox.TextSize = 14
		HEXBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		HEXBox.PlaceholderText = "ff0000"
		HEXBox.Text = ""
		HEXBox.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		HEXBox.TextXAlignment = Enum.TextXAlignment.Left
		HEXBox.Parent = HEX

		local HEXText = Instance.new("TextLabel")
		HEXText.Name = "HEXText"
		HEXText.ZIndex = 3
		HEXText.Size = UDim2.new(0, 31, 0, 20)
		HEXText.BorderColor3 = Color3.fromRGB(0, 0, 0)
		HEXText.BackgroundTransparency = 1
		HEXText.Position = UDim2.new(0, 5, 0, 0)
		HEXText.BorderSizePixel = 0
		HEXText.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		HEXText.TextStrokeTransparency = 0.75
		HEXText.TextSize = 14
		HEXText.RichText = true
		HEXText.TextColor3 = Color3.fromRGB(255, 255, 255)
		HEXText.Text = "HEX: #"
		HEXText.TextWrapped = true
		HEXText.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		HEXText.TextXAlignment = Enum.TextXAlignment.Left
		HEXText.Parent = HEX

		local HEXGradient = Instance.new("UIGradient")
		HEXGradient.Name = "Gradient"
		HEXGradient.Rotation = 90
		HEXGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		HEXGradient.Parent = HEX

		local Rainbow = Instance.new("TextButton")
		Rainbow.Name = "Rainbow"
		Rainbow.ZIndex = 3
		Rainbow.AnchorPoint = Vector2.new(0.5, 0)
		Rainbow.Size = UDim2.new(1, -10, 0, 20)
		Rainbow.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Rainbow.BackgroundTransparency = 1
		Rainbow.Position = UDim2.new(0.5, 0, 0, 270)
		Rainbow.BorderSizePixel = 0
		Rainbow.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Rainbow.AutoButtonColor = false
		Rainbow.TextStrokeTransparency = 0.75
		Rainbow.TextSize = 14
		Rainbow.RichText = true
		Rainbow.TextColor3 = Color3.fromRGB(255, 255, 255)
		Rainbow.Text = ""
		Rainbow.TextWrapped = true
		Rainbow.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Rainbow.Parent = Palette

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.ZIndex = 3
		Title.AnchorPoint = Vector2.new(0, 0.5)
		Title.Size = UDim2.new(1, -15, 1, 0)
		Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 15, 0.5, 0)
		Title.BorderSizePixel = 0
		Title.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
		Title.TextStrokeTransparency = 0.75
		Title.TextSize = 14
		Title.RichText = true
		Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		Title.Text = "Rainbow"
		Title.TextWrapped = true
		Title.FontFace = Font.fromEnum(Enum.Font.SourceSans)
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Rainbow

		local RainbowTick = Instance.new("Frame")
		RainbowTick.Name = "Tick"
		RainbowTick.ZIndex = 3
		RainbowTick.AnchorPoint = Vector2.new(0, 0.5)
		RainbowTick.Size = UDim2.new(0, 10, 0, 10)
		RainbowTick.BorderColor3 = Color3.fromRGB(0, 0, 0)
		RainbowTick.Position = UDim2.new(0, 0, 0.5, 0)
		RainbowTick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
		RainbowTick.Parent = Rainbow

		local RainbowTickGradient = Instance.new("UIGradient")
		RainbowTickGradient.Name = "Gradient"
		RainbowTickGradient.Rotation = 90
		RainbowTickGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(191, 191, 191))
		RainbowTickGradient.Parent = RainbowTick

		return Palette
	end
}
Bracket.Elements = {
	Screen = function()
		local ScreenAsset = Bracket.Assets:Screen()
		if not Bracket.IsLocal then sethiddenproperty(ScreenAsset, "OnTopOfCoreBlur", true) end
		ScreenAsset.Name = "Bracket " .. game:GetService("HttpService"):GenerateGUID(false)
		ScreenAsset.Parent = Bracket.IsLocal and LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
		Bracket.Screen = ScreenAsset
	end,
	Window = function(Window)
		local WindowAsset = Bracket.Assets.Window()

		Window.Elements, Window.Flags, Window.Colorable = {}, {}, {}
		Window.RainbowHue, Window.RainbowSpeed = 0, 10

		Window.Asset = WindowAsset
		Window.Background = Window.Asset.Background

		WindowAsset.Parent = Bracket.Screen
		WindowAsset.Visible = Window.Enabled
		WindowAsset.Title.Text = Window.Name
		WindowAsset.Position = Window.Position
		WindowAsset.Size = Window.Size

		Bracket.Utilities.MakeDraggable(WindowAsset.Drag, WindowAsset, function(Position)
			Window.Position = Position
		end)
		Bracket.Utilities.MakeResizeable(WindowAsset.Resize, WindowAsset, Vector2.new(296, 296), Vector2.new(896, 896), function(Size)
			Window.Size = Size
		end)

		--local Month = tonumber(os.date("%m"))
		--if Month == 12 or Month == 1 then task.spawn(Bracket.Elements.Snowflakes, WindowAsset) end
		WindowAsset.TabButtonContainer.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			WindowAsset.TabButtonContainer.CanvasSize = UDim2.fromOffset(WindowAsset.TabButtonContainer.ListLayout.AbsoluteContentSize.X, 0)
		end)

		UserInputService.InputChanged:Connect(function(Input)
			if WindowAsset.Visible and Input.UserInputType == Enum.UserInputType.MouseMovement then
				local Mouse = UserInputService:GetMouseLocation()
				Bracket.Screen.ToolTip.Position = UDim2.fromOffset(Mouse.X + 5, Mouse.Y - 5)
			end
		end)
		RunService.RenderStepped:Connect(function()
			Window.RainbowHue = os.clock() % Window.RainbowSpeed / Window.RainbowSpeed
		end)

		Window:GetPropertyChangedSignal("Enabled"):Connect(function(Enabled)
			WindowAsset.Visible = Enabled

			if not Bracket.IsLocal then
				RunService:SetRobloxGuiFocused(Enabled and Window.Blur)
			end
			if not Enabled then
				for Index, Object in pairs(Bracket.Screen:GetChildren()) do
					if Object.Name == "Palette" or Object.Name == "OptionContainer" then
						Object.Visible = false
					end
				end
			end
		end)
		Window:GetPropertyChangedSignal("Blur"):Connect(function(Blur)
			if not Bracket.IsLocal then
				RunService:SetRobloxGuiFocused(Window.Enabled and Blur)
			end
		end)
		Window:GetPropertyChangedSignal("Name"):Connect(function(Name)
			WindowAsset.Title.Text = Name
		end)
		Window:GetPropertyChangedSignal("Position"):Connect(function(Position)
			WindowAsset.Position = Position
		end)
		Window:GetPropertyChangedSignal("Size"):Connect(function(Size)
			WindowAsset.Size = Size
		end)
		Window:GetPropertyChangedSignal("Color"):Connect(function(Color)
			for Object, ColorConfig in pairs(Window.Colorable) do
				if ColorConfig[1] then
					Object[ColorConfig[2]] = Color
				end
			end
		end)

		function Window.SetValue(Self, Flag, Value)
			for Index, Element in pairs(Self.Elements) do
				if Element.Flag == Flag then
					Element.Value = Value
				end
			end
		end
		function Window.GetValue(Self, Flag)
			for Index, Element in pairs(Self.Elements) do
				if Element.Flag == Flag then
					return Element.Value
				end
			end
		end

		function Window.Watermark(Self, Watermark)
			Watermark = Bracket.Utilities:GetType(Watermark, {}, "table", true)
			Watermark.Enabled = Bracket.Utilities:GetType(Watermark.Enabled, false, "boolean")
			Watermark.Title = Bracket.Utilities:GetType(Watermark.Title, "Hello World!", "string")
			Watermark.Flag = Bracket.Utilities:GetType(Watermark.Flag, "UI/Watermark/Position", "string")

			Bracket.Screen.Watermark.Visible = Watermark.Enabled
			Bracket.Screen.Watermark.Text = Watermark.Title

			Bracket.Screen.Watermark.Size = UDim2.fromOffset(
				Bracket.Screen.Watermark.TextBounds.X + 6,
                Bracket.Utilities.GetTextBounds(
                    Bracket.Screen.Watermark.Text,
                    Bracket.Screen.Watermark.Font.Name,
                    Vector2.new(Bracket.Screen.Watermark.AbsoluteSize.X, Bracket.Screen.Watermark.TextSize)
                ).Y + 6
			)

			Bracket.Utilities.MakeDraggable(Bracket.Screen.Watermark, Bracket.Screen.Watermark, function(Position)
				if not Window.Enabled then return end
				Bracket.Screen.Watermark.Position = Position
			end, function(Position)
				if not Window.Enabled then return end
				Watermark.Value = {
					Position.X.Scale, Position.X.Offset,
					Position.Y.Scale, Position.Y.Offset
				}
			end)

			Watermark:GetPropertyChangedSignal("Enabled"):Connect(function(Enabled)
				Bracket.Screen.Watermark.Visible = Enabled
			end)
			Watermark:GetPropertyChangedSignal("Title"):Connect(function(Title)
				Bracket.Screen.Watermark.Text = Title
				Bracket.Screen.Watermark.Size = UDim2.fromOffset(
					Bracket.Screen.Watermark.TextBounds.X + 6,
                    Bracket.Utilities.GetTextBounds(
                        Bracket.Screen.Watermark.Text,
                        Bracket.Screen.Watermark.Font.Name,
                        Vector2.new(Bracket.Screen.Watermark.AbsoluteSize.X, Bracket.Screen.Watermark.TextSize)
                    ).Y + 6
				)
			end)
			Watermark:GetPropertyChangedSignal("Value"):Connect(function(Value)
				if type(Value) ~= "table" then return end
				Bracket.Screen.Watermark.Position = UDim2.new(
					Value[1], Value[2],
					Value[3], Value[4]
				)
				Self.Flags[Watermark.Flag] = {
					Value[1], Value[2],
					Value[3], Value[4]
				}
			end)

			Self.Elements[#Self.Elements + 1] = Watermark
			Self.Watermark = Watermark
			return Watermark
		end
		function Window.KeybindList(Self, KeybindList)
			KeybindList = Bracket.Utilities:GetType(KeybindList, {}, "table", true)
			KeybindList.Enabled = Bracket.Utilities:GetType(KeybindList.Enabled, false, "boolean")
			KeybindList.Title = Bracket.Utilities:GetType(KeybindList.Title, "Keybinds", "string")

			KeybindList.Position = Bracket.Utilities:GetType(KeybindList.Position, UDim2.new(0, 10, 0.5, -123), "UDim2")
			KeybindList.Size = Bracket.Utilities:GetType(KeybindList.Size, UDim2.new(0, 121, 0, 246), "UDim2")
			KeybindList.List = Bracket.Screen.KeybindList.List

			Bracket.Screen.KeybindList.Visible = KeybindList.Enabled
			Bracket.Screen.KeybindList.Title.Text = KeybindList.Title

			Bracket.Utilities.MakeDraggable(Bracket.Screen.KeybindList.Drag, Bracket.Screen.KeybindList, function(Position)
				KeybindList.Position = Position
			end)
			Bracket.Utilities.MakeResizeable(Bracket.Screen.KeybindList.Resize, Bracket.Screen.KeybindList, Vector2.new(121, 246), Vector2.new(896, 896), function(Size)
				KeybindList.Size = Size
			end)

			KeybindList:GetPropertyChangedSignal("Title"):Connect(function(Title)
				Bracket.Screen.KeybindList.Title.Text = Title
			end)
			KeybindList:GetPropertyChangedSignal("Enabled"):Connect(function(Enabled)
				Bracket.Screen.KeybindList.Visible = Enabled
			end)
			KeybindList:GetPropertyChangedSignal("Position"):Connect(function(Position)
				Bracket.Screen.KeybindList.Position = Position
			end)
			KeybindList:GetPropertyChangedSignal("Size"):Connect(function(Size)
				Bracket.Screen.KeybindList.Size = Size
			end)

			WindowAsset.Background.Changed:Connect(function(Property)
				if Property == "Image" then
					Bracket.Screen.KeybindList.Background.Image = WindowAsset.Background.Image
				elseif Property == "ImageColor3" then
					Bracket.Screen.KeybindList.Background.ImageColor3 = WindowAsset.Background.ImageColor3
				elseif Property == "ImageTransparency" then
					Bracket.Screen.KeybindList.Background.ImageTransparency = WindowAsset.Background.ImageTransparency
				elseif Property == "TileSize" then
					Bracket.Screen.KeybindList.Background.TileSize = WindowAsset.Background.TileSize
				end
			end)

			for Index, Element in pairs(Self.Elements) do
				if type(Element.WaitingForBind) == "boolean" and not Element.IgnoreList then
					Element.ListMimic = {}
					Element.ListMimic.Asset = Bracket.Assets.KeybindMimic()
					Element.ListMimic.Asset.Title.Text = Element.Name or Element.Toggle.Name
					Element.ListMimic.Asset.Visible = Element.Value ~= "NONE"
					Element.ListMimic.Asset.Parent = KeybindList.List

					Element.ListMimic.ColorConfig = {false, "BackgroundColor3"}
					Self.Colorable[Element.ListMimic.Asset.Tick] = Element.ListMimic.ColorConfig
				end
			end

			--Self.Elements[#Self.Elements + 1] = KeybindList
			Self.KeybindList = KeybindList
			return KeybindList
		end

		function Window.SaveConfig(Self, FolderName, Name)
			local Config = {}
			for Index, Element in pairs(Self.Elements) do
				if Element.Flag and not Element.IgnoreFlag then
					Config[Element.Flag] = Self.Flags[Element.Flag]
				end
			end
			writefile(
				FolderName .. "\\Configs\\" .. Name .. ".json",
				HttpService:JSONEncode(Config)
			)
		end
		function Window.LoadConfig(Self, FolderName, Name)
			if table.find(Bracket.Utilities.GetConfigs(FolderName), Name) then
				local DecodedJSON = HttpService:JSONDecode(
					readfile(FolderName .. "\\Configs\\" .. Name .. ".json")
				)
				for Flag, Value in pairs(DecodedJSON) do
					local Element = Bracket.Utilities.FindElementByFlag(Self.Elements, Flag)
					if Element ~= nil then Element.Value = Value end
				end
			end
		end
		function Window:DeleteConfig(FolderName, Name)
			if table.find(Bracket.Utilities.GetConfigs(FolderName), Name) then
				delfile(FolderName .. "\\Configs\\" .. Name .. ".json")
			end
		end
		function Window:GetAutoLoadConfig(FolderName)
			if not isfolder(FolderName) then makefolder(FolderName) end
			if not isfile(FolderName .. "\\AutoLoads.json") then
				writefile(FolderName .. "\\AutoLoads.json", "[]")
			end

			local AutoLoads = HttpService:JSONDecode(
				readfile(FolderName .. "\\AutoLoads.json")
			) local AutoLoad = AutoLoads[tostring(game.GameId)]

			if table.find(Bracket.Utilities.GetConfigs(FolderName), AutoLoad) then
				return AutoLoad
			end
		end
		function Window:AddToAutoLoad(FolderName, Name)
			if not isfolder(FolderName) then makefolder(FolderName) end
			if not isfile(FolderName .. "\\AutoLoads.json") then
				writefile(FolderName .. "\\AutoLoads.json", "[]")
			end

			local AutoLoads = HttpService:JSONDecode(
				readfile(FolderName .. "\\AutoLoads.json")
			) AutoLoads[tostring(game.GameId)] = Name

			writefile(FolderName .. "\\AutoLoads.json",
				HttpService:JSONEncode(AutoLoads)
			)
		end
		function Window:RemoveFromAutoLoad(FolderName)
			if not isfolder(FolderName) then makefolder(FolderName) end
			if not isfile(FolderName .. "\\AutoLoads.json") then
				writefile(FolderName .. "\\AutoLoads.json", "[]")
				return
			end

			local AutoLoads = HttpService:JSONDecode(
				readfile(FolderName .. "\\AutoLoads.json")
			) AutoLoads[tostring(game.GameId)] = nil

			writefile(FolderName .. "\\AutoLoads.json",
				HttpService:JSONEncode(AutoLoads)
			)
		end
		function Window.AutoLoadConfig(Self, FolderName)
			if not isfolder(FolderName) then makefolder(FolderName) end
			if not isfile(FolderName .. "\\AutoLoads.json") then
				writefile(FolderName .. "\\AutoLoads.json", "[]")
			end

			local AutoLoads = HttpService:JSONDecode(
				readfile(FolderName .. "\\AutoLoads.json")
			) local AutoLoad = AutoLoads[tostring(game.GameId)]

			if table.find(Bracket.Utilities.GetConfigs(FolderName), AutoLoad) then
				Self:LoadConfig(FolderName, AutoLoad)
			end
		end

		return WindowAsset
	end,
	Tab = function(WindowAsset, Window, Tab)
		local TabAsset = Bracket.Assets.Tab()
		local TabButtonAsset = Bracket.Assets.TabButton()

		Tab.ColorConfig = {true, "BackgroundColor3"}
		Window.Colorable[TabButtonAsset.Highlight] = Tab.ColorConfig

		TabAsset.Parent = WindowAsset.TabContainer
		TabButtonAsset.Parent = WindowAsset.TabButtonContainer

		TabAsset.Visible = false
		TabButtonAsset.Text = Tab.Name
		TabButtonAsset.Highlight.BackgroundColor3 = Window.Color
		TabButtonAsset.Size = UDim2.new(0, TabButtonAsset.TextBounds.X + 12, 1, -1)
		TabButtonAsset.Parent = WindowAsset.TabButtonContainer

		TabAsset.LeftSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local Side = Bracket.Utilities.GetLongestSide(TabAsset)
			TabAsset.CanvasSize = UDim2.fromOffset(0, Side.ListLayout.AbsoluteContentSize.Y + 21)
		end)
		TabAsset.RightSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local Side = Bracket.Utilities.GetLongestSide(TabAsset)
			TabAsset.CanvasSize = UDim2.fromOffset(0, Side.ListLayout.AbsoluteContentSize.Y + 21)
		end)
		TabButtonAsset.MouseButton1Click:Connect(function()
			Bracket.Utilities.ChooseTab(TabButtonAsset, TabAsset)
		end)

		if #WindowAsset.TabContainer:GetChildren() == 1 then
			Bracket.Utilities.ChooseTab(TabButtonAsset, TabAsset)
		end

		Tab:GetPropertyChangedSignal("Name"):Connect(function(Name)
			TabButtonAsset.Text = Name
			TabButtonAsset.Size = UDim2.new(
				0, TabButtonAsset.TextBounds.X + 12,
				1, -1
			)
		end)

		return TabAsset
	end,
	Section = function(Parent, Section)
		local SectionAsset = Bracket.Assets.Section()

		SectionAsset.Parent = Parent
		SectionAsset.Title.Text = Section.Name
		SectionAsset.Title.Size = UDim2.fromOffset(
			SectionAsset.Title.TextBounds.X + 6, 2
		)

		SectionAsset.Container.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			SectionAsset.Size = UDim2.new(1, 0, 0, SectionAsset.Container.ListLayout.AbsoluteContentSize.Y + 15)
		end)

		Section:GetPropertyChangedSignal("Name"):Connect(function(Name)
			SectionAsset.Title.Text = Name
			SectionAsset.Title.Size = UDim2.fromOffset(
				Section.Title.TextBounds.X + 6, 2
			)
		end)

		return SectionAsset.Container
	end,
	Tooltip = function(Parent, Text)
		Parent.MouseEnter:Connect(function()
			Bracket.Screen.ToolTip.Text = Text
			Bracket.Screen.ToolTip.Size = UDim2.fromOffset(
				Bracket.Screen.ToolTip.TextBounds.X + 6,
                Bracket.Utilities.GetTextBounds(
                    Bracket.Screen.ToolTip.Text,
                    Bracket.Screen.ToolTip.Font.Name,
                    Vector2.new(Bracket.Screen.ToolTip.AbsoluteSize.X, Bracket.Screen.ToolTip.TextSize)
                ).Y + 6
			)

			Bracket.Screen.ToolTip.Visible = true
		end)
		Parent.MouseLeave:Connect(function()
			Bracket.Screen.ToolTip.Visible = false
		end)
	end,
	Snowflakes = function(WindowAsset)
		local ParticleEmitter = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/rParticle/master/Main.lua"))()
		local Emitter = ParticleEmitter.new(WindowAsset.Background, WindowAsset.Snowflake)
		local NewRandom = Random.new() Emitter.SpawnRate = 20

		Emitter.OnSpawn = function(Particle)
			local RandomPosition = NewRandom:NextNumber()
			local RandomSize = NewRandom:NextInteger(10, 50)
			local RandomYVelocity = NewRandom:NextInteger(10, 50)
			local RandomXVelocity = NewRandom:NextInteger(-50, 50)

			Particle.Object.ImageTransparency = RandomSize / 50
			Particle.Object.Size = UDim2.fromOffset(RandomSize, RandomSize)
			Particle.Velocity = Vector2.new(RandomXVelocity, RandomYVelocity)
			Particle.Position = Vector2.new(RandomPosition * WindowAsset.Background.AbsoluteSize.X, 0)
			Particle.MaxAge = 20 task.wait(0.5) Particle.Object.Visible = true
		end

		Emitter.OnUpdate = function(Particle, Delta)
			Particle.Position += Particle.Velocity * Delta
		end
	end,
	Divider = function(Parent, Divider)
		local DividerAsset = Bracket.Assets.Divider()

		DividerAsset.Parent = Parent
		DividerAsset.Title.Text = Divider.Text

		DividerAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			if DividerAsset.Title.TextBounds.X > 0 then
				DividerAsset.Size = UDim2.new(1, 0, 0, 
                    Bracket.Utilities.GetTextBounds(
                        DividerAsset.Title.Text,
                        DividerAsset.Title.Font.Name,
                        Vector2.new(DividerAsset.Title.AbsoluteSize.X, DividerAsset.Title.TextSize)
                    ).Y
                )
				DividerAsset.Left.Size = UDim2.new(0.5, -(DividerAsset.Title.TextBounds.X / 2) - 6, 0 , 2)
				DividerAsset.Right.Size = UDim2.new(0.5, -(DividerAsset.Title.TextBounds.X / 2) - 6, 0, 2)
			else
				DividerAsset.Size = UDim2.new(1, 0, 0, 14)
				DividerAsset.Left.Size = UDim2.new(1, 0, 0, 2)
				DividerAsset.Right.Size = UDim2.new(1, 0, 0, 2)
			end
		end)

		Divider:GetPropertyChangedSignal("Text"):Connect(function(Text)
			DividerAsset.Title.Text = Text
		end)
	end,
	Label = function(Parent, Label)
		local LabelAsset = Bracket.Assets.Label()

		LabelAsset.Parent = Parent
		LabelAsset.Text = Label.Text

		LabelAsset:GetPropertyChangedSignal("TextBounds"):Connect(function()
			LabelAsset.Size = UDim2.new(1, 0, 0, 
                Bracket.Utilities.GetTextBounds(
                    LabelAsset.Text,
                    LabelAsset.Font.Name,
                    Vector2.new(LabelAsset.AbsoluteSize.X, LabelAsset.TextSize)
                ).Y
            )
		end)

		Label:GetPropertyChangedSignal("Text"):Connect(function(Text)
			LabelAsset.Text = Text
		end)
	end,
	Button = function(Parent, Window, Button)
		local ButtonAsset = Bracket.Assets.Button()

		Button.ColorConfig = {false, "BorderColor3"}
		Window.Colorable[ButtonAsset] = Button.ColorConfig

		Button.Connection = ButtonAsset.MouseButton1Click:Connect(Button.Callback)

		ButtonAsset.Parent = Parent
		ButtonAsset.Title.Text = Button.Name

		ButtonAsset.MouseButton1Down:Connect(function()
			Button.ColorConfig[1] = true
			ButtonAsset.BorderColor3 = Window.Color
		end)
		ButtonAsset.MouseButton1Up:Connect(function()
			Button.ColorConfig[1] = false
			ButtonAsset.BorderColor3 = Color3.new(0, 0, 0)
		end)
		ButtonAsset.MouseLeave:Connect(function()
			Button.ColorConfig[1] = false
			ButtonAsset.BorderColor3 = Color3.new(0, 0, 0)
		end)
		ButtonAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			ButtonAsset.Size = UDim2.new(1, 0, 0, 
                Bracket.Utilities.GetTextBounds(
                    ButtonAsset.Title.Text,
                    ButtonAsset.Title.Font.Name,
                    Vector2.new(ButtonAsset.Title.AbsoluteSize.X, ButtonAsset.Title.TextSize)
                ).Y + 2
            )
		end)

		Button:GetPropertyChangedSignal("Name"):Connect(function(Name)
			ButtonAsset.Title.Text = Name
		end)
		Button:GetPropertyChangedSignal("Callback"):Connect(function(Callback)
			Button.Connection:Disconnect()
			Button.Connection = ButtonAsset.MouseButton1Click:Connect(Callback)
		end)

		function Button:Tooltip(Text)
			Bracket.Elements.Tooltip(ButtonAsset, Text)
		end
	end,
	Toggle = function(Parent, Window, Toggle)
		local ToggleAsset = Bracket.Assets.Toggle()

		Toggle.ColorConfig = {Toggle.Value, "BackgroundColor3"}
		Window.Colorable[ToggleAsset.Tick] = Toggle.ColorConfig

		ToggleAsset.Parent = Parent
		ToggleAsset.Title.Text = Toggle.Name
		ToggleAsset.Tick.BackgroundColor3 = Toggle.Value
			and Window.Color or Color3.fromRGB(63, 63, 63)

		ToggleAsset.MouseButton1Click:Connect(function()
			Toggle.Value = not Toggle.Value
		end)
		ToggleAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			ToggleAsset.Size = UDim2.new(1, 0, 0, 
                Bracket.Utilities.GetTextBounds(
                    ToggleAsset.Title.Text,
                    ToggleAsset.Title.Font.Name,
                    Vector2.new(ToggleAsset.Title.AbsoluteSize.X, ToggleAsset.Title.TextSize)
                ).Y
            )
			ToggleAsset.Layout.Size = UDim2.new(1, -ToggleAsset.Title.TextBounds.X - 18, 1, 0)
		end)

		Toggle:GetPropertyChangedSignal("Name"):Connect(function(Name)
			ToggleAsset.Title.Text = Name
		end)
		Toggle:GetPropertyChangedSignal("Value"):Connect(function(Value)
			Toggle.ColorConfig[1] = Value
			ToggleAsset.Tick.BackgroundColor3 = Value
				and Window.Color or Color3.fromRGB(63, 63, 63)
			Window.Flags[Toggle.Flag] = Value
			Toggle.Callback(Value)
		end)

		function Toggle:Tooltip(Text)
			Bracket.Elements.Tooltip(ToggleAsset, Text)
		end

		return ToggleAsset
	end,
	Slider = function(Parent, Window, Slider)
		local SliderAsset = Slider.Slim and Bracket.Assets.SlimSlider() or Bracket.Assets.Slider()

		Slider.ColorConfig = {true, "BackgroundColor3"}
		Window.Colorable[SliderAsset.Background.Bar] = Slider.ColorConfig

		Slider.Active = false
		Slider.Value = tonumber(string.format("%." .. Slider.Precise .. "f", Slider.Value))

		SliderAsset.Parent = Parent
		SliderAsset.Title.Text = Slider.Name
		SliderAsset.Background.Bar.BackgroundColor3 = Window.Color
		SliderAsset.Background.Bar.Size = UDim2.fromScale(Bracket.Utilities.Scale(Slider.Value, Slider.Min, Slider.Max, 0, 1), 1)
		SliderAsset.Value.PlaceholderText = #Slider.Unit == 0 and Slider.Value or Slider.Value .. " " .. Slider.Unit

		local function AttachToMouse(Input)
			local ScaleX = math.clamp((Input.Position.X - SliderAsset.Background.AbsolutePosition.X) / SliderAsset.Background.AbsoluteSize.X, 0, 1)
			Slider.Value = Bracket.Utilities.Scale(ScaleX, 0, 1, Slider.Min, Slider.Max)
		end

		if Slider.Slim then
			SliderAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
				SliderAsset.Value.Size = UDim2.fromOffset(SliderAsset.Value.TextBounds.X, 16)
				SliderAsset.Title.Size = UDim2.new(1, -SliderAsset.Value.Size.X.Offset, 0, 16)
				SliderAsset.Size = UDim2.new(1, 0, 0,
                    Bracket.Utilities.GetTextBounds(
                        SliderAsset.Title.Title.Text,
                        SliderAsset.Title.Title.Font.Name,
                        Vector2.new(SliderAsset.Title.Title.AbsoluteSize.X, SliderAsset.Title.Title.TextSize)
                    ).Y + 8
                )
			end)
			SliderAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
				SliderAsset.Value.Size = UDim2.fromOffset(SliderAsset.Value.TextBounds.X, 16)
				SliderAsset.Title.Size = UDim2.new(1, -SliderAsset.Value.Size.X.Offset, 0, 16)
			end)
		else
			SliderAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
				SliderAsset.Value.Size = UDim2.new(0, SliderAsset.Value.TextBounds.X, 1, 0)
				SliderAsset.Title.Size = UDim2.new(1, -SliderAsset.Value.Size.X.Offset - 12, 1, 0)
				SliderAsset.Size = UDim2.new(1, 0, 0,
                    Bracket.Utilities.GetTextBounds(
                        SliderAsset.Title.Text,
                        SliderAsset.Title.Font.Name,
                        Vector2.new(SliderAsset.Title.AbsoluteSize.X, SliderAsset.Title.TextSize)
                    ).Y + 2
                )
			end)
			SliderAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
				SliderAsset.Value.Size = UDim2.new(0, SliderAsset.Value.TextBounds.X, 1, 0)
				SliderAsset.Title.Size = UDim2.new(1, -SliderAsset.Value.Size.X.Offset - 12, 1, 0)
			end)
		end

		SliderAsset.Value.FocusLost:Connect(function()
			if not tonumber(SliderAsset.Value.Text) then
				SliderAsset.Value.Text = ""
				return
			end

			Slider.Value = SliderAsset.Value.Text
			SliderAsset.Value.Text = ""
		end)
		SliderAsset.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				AttachToMouse(Input)
				Slider.Active = true
			end
		end)
		SliderAsset.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Slider.Active = false
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Slider.Active and Input.UserInputType == Enum.UserInputType.MouseMovement then
				AttachToMouse(Input)
			end
		end)

		Slider:GetPropertyChangedSignal("Name"):Connect(function(Name)
			SliderAsset.Title.Text = Name
		end)
		Slider:GetPropertyChangedSignal("Value"):Connect(function(Value)
			Value = tonumber(string.format("%." .. Slider.Precise .. "f", Value))

			if Value < Slider.Min then
				Value = Slider.Min
			elseif Value > Slider.Max then
				Value = Slider.Max
			end

			if Slider.OnlyOdd and Slider.Precise == 0 then
				if Value % 2 == 0 then return end
			elseif Slider.OnlyEven and Slider.Precise == 0 then
				if Value % 2 == 1 then return end
			end

			SliderAsset.Background.Bar.Size = UDim2.fromScale(Bracket.Utilities.Scale(Value, Slider.Min, Slider.Max, 0, 1), 1)
			SliderAsset.Value.PlaceholderText = #Slider.Unit == 0
				and Value or Value .. " " .. Slider.Unit

			Slider.Internal.Value = Value
			Window.Flags[Slider.Flag] = Value
			Slider.Callback(Value)
		end)

		function Slider:Tooltip(Text)
			Bracket.Elements.Tooltip(SliderAsset, Text)
		end
	end,
	Textbox = function(Parent, Window, Textbox)
		local TextboxAsset = Bracket.Assets.Textbox()
		Textbox.EnterPressed = false

		TextboxAsset.Parent = Parent
		TextboxAsset.Title.Text = Textbox.Name
		TextboxAsset.Background.Input.Text = Textbox.Value
		TextboxAsset.Background.Input.PlaceholderText = Textbox.Placeholder
		TextboxAsset.Title.Visible = not Textbox.HideName

		TextboxAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			TextboxAsset.Title.Size = Textbox.HideName and UDim2.fromScale(1, 0) or UDim2.new(1, 0, 0,
                Bracket.Utilities.GetTextBounds(
                    TextboxAsset.Title.Title.Text,
                    TextboxAsset.Title.Title.Font.Name,
                    Vector2.new(TextboxAsset.Title.Title.AbsoluteSize.X, TextboxAsset.Title.Title.TextSize)
                ).Y + 2
            )
			TextboxAsset.Background.Position = UDim2.new(0.5, 0, 0, TextboxAsset.Title.Size.Y.Offset)
			TextboxAsset.Size = UDim2.new(1, 0, 0, TextboxAsset.Title.Size.Y.Offset + TextboxAsset.Background.Size.Y.Offset)
		end)
		TextboxAsset.Background.Input:GetPropertyChangedSignal("Text"):Connect(function()
			local TextBounds = Bracket.Utilities.GetTextBounds(
				TextboxAsset.Background.Input.Text,
				TextboxAsset.Background.Input.Font.Name,
				Vector2.new(TextboxAsset.Background.Input.AbsoluteSize.X, TextboxAsset.Background.Input.TextSize)
			)

			TextboxAsset.Background.Size = UDim2.new(1, 0, 0, TextBounds.Y + 2)
			TextboxAsset.Size = UDim2.new(1, 0, 0, TextboxAsset.Title.Size.Y.Offset + TextboxAsset.Background.Size.Y.Offset)
		end)

		TextboxAsset.Background.Input.Focused:Connect(function()
			local TextBounds = Bracket.Utilities.GetTextBounds(
				TextboxAsset.Background.Input.Text,
				TextboxAsset.Background.Input.Font.Name,
				Vector2.new(TextboxAsset.Background.Input.AbsoluteSize.X, TextboxAsset.Background.Input.TextSize)
			)

			TextboxAsset.Background.Size = UDim2.new(1, 0, 0, TextBounds.Y + 2)
			TextboxAsset.Size = UDim2.new(1, 0, 0, TextboxAsset.Title.Size.Y.Offset + TextboxAsset.Background.Size.Y.Offset)

			TextboxAsset.Background.Input.Text = Textbox.Value
		end)
		TextboxAsset.Background.Input.FocusLost:Connect(function(EnterPressed)
			local Input = TextboxAsset.Background.Input

			Textbox.EnterPressed = EnterPressed
			Textbox.Value = Input.Text Textbox.EnterPressed = false
		end)

		Textbox:GetPropertyChangedSignal("Name"):Connect(function(Name)
			TextboxAsset.Title.Text = Name
		end)
		Textbox:GetPropertyChangedSignal("Placeholder"):Connect(function(PlaceHolder)
			TextboxAsset.Background.Input.PlaceholderText = PlaceHolder
		end)
		Textbox:GetPropertyChangedSignal("Value"):Connect(function(Value)
			local Input = TextboxAsset.Background.Input
			Input.Text = Textbox.AutoClear and "" or Value
			if Textbox.PasswordMode then Input.Text = string.rep(utf8.char(8226), #Input.Text) end

			TextboxAsset.Background.Size = UDim2.new(1, 0, 0, Input.TextSize + 2)
			TextboxAsset.Size = UDim2.new(1, 0, 0, TextboxAsset.Title.Size.Y.Offset + TextboxAsset.Background.Size.Y.Offset)

			Window.Flags[Textbox.Flag] = Value
			Textbox.Callback(Value, Textbox.EnterPressed)
		end)

		function Textbox:Tooltip(Text)
			Bracket.Elements.Tooltip(TextboxAsset, Text)
		end
	end,
	Keybind = function(Parent, Window, Keybind)
		local KeybindAsset = Bracket.Assets.Keybind()
		Keybind.WaitingForBind = false

		KeybindAsset.Parent = Parent
		KeybindAsset.Title.Text = Keybind.Name
		KeybindAsset.Value.Text = "[ " .. Keybind.Value .. " ]"

		KeybindAsset.MouseButton1Click:Connect(function()
			KeybindAsset.Value.Text = "[ ... ]"
			Keybind.WaitingForBind = true
		end)
		KeybindAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			KeybindAsset.Size = UDim2.new(1, 0, 0,
                Bracket.Utilities.GetTextBounds(
                    KeybindAsset.Title.Text,
                    KeybindAsset.Title.Font.Name,
                    Vector2.new(KeybindAsset.Title.AbsoluteSize.X, KeybindAsset.Title.TextSize)
                ).Y
            )
		end)
		KeybindAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
			KeybindAsset.Value.Size = UDim2.new(0, KeybindAsset.Value.TextBounds.X, 1, 0)
			KeybindAsset.Title.Size = UDim2.new(1, -KeybindAsset.Value.Size.X.Offset, 1, 0)
		end)

		if type(Window.KeybindList) == "table" and not Keybind.IgnoreList then
			Keybind.ListMimic = {}
			Keybind.ListMimic.Asset = Bracket.Assets.KeybindMimic()
			Keybind.ListMimic.Asset.Title.Text = Keybind.Name
			Keybind.ListMimic.Asset.Visible = Keybind.Value ~= "NONE"
			Keybind.ListMimic.Asset.Parent = Window.KeybindList.List


			Keybind.ListMimic.ColorConfig = {false, "BackgroundColor3"}
			Window.Colorable[Keybind.ListMimic.Asset.Tick] = Keybind.ListMimic.ColorConfig
		end

		UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
			if GameProcessedEvent then return end
			local Key = Input.KeyCode.Name
			if Keybind.WaitingForBind and Input.UserInputType.Name == "Keyboard" then
				Keybind.Value = Key
			elseif Input.UserInputType.Name == "Keyboard" then
				if Key == Keybind.Value then
					Keybind.Toggle = not Keybind.Toggle
					if Keybind.ListMimic then
						Keybind.ListMimic.ColorConfig[1] = true
						Keybind.ListMimic.Asset.Tick.BackgroundColor3 = Window.Color
					end
					Keybind.Callback(Keybind.Value, true, Keybind.Toggle)
				end
			end
			if Keybind.Mouse then Key = Input.UserInputType.Name
				if Keybind.WaitingForBind and (Key == "MouseButton1"
					or Key == "MouseButton2" or Key == "MouseButton3") then
					Keybind.Value = Key
				elseif Key == "MouseButton1"
					or Key == "MouseButton2"
					or Key == "MouseButton3" then
					if Key == Keybind.Value then
						Keybind.Toggle = not Keybind.Toggle
						if Keybind.ListMimic then
							Keybind.ListMimic.ColorConfig[1] = true
							Keybind.ListMimic.Asset.Tick.BackgroundColor3 = Window.Color
						end
						Keybind.Callback(Keybind.Value, true, Keybind.Toggle)
					end
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
			if GameProcessedEvent then return end
			local Key = Input.KeyCode.Name
			if Input.UserInputType.Name == "Keyboard" then
				if Key == Keybind.Value then
					if Keybind.ListMimic then
						Keybind.ListMimic.ColorConfig[1] = false
						Keybind.ListMimic.Asset.Tick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
					end
					Keybind.Callback(Keybind.Value, false, Keybind.Toggle)
				end
			end
			if Keybind.Mouse then Key = Input.UserInputType.Name
				if Key == "MouseButton1"
					or Key == "MouseButton2"
					or Key == "MouseButton3" then
					if Key == Keybind.Value then
						if Keybind.ListMimic then
							Keybind.ListMimic.ColorConfig[1] = false
							Keybind.ListMimic.Asset.Tick.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
						end
						Keybind.Callback(Keybind.Value, false, Keybind.Toggle)
					end
				end
			end
		end)

		Keybind:GetPropertyChangedSignal("Name"):Connect(function(Name)
			KeybindAsset.Title.Text = Name
		end)
		Keybind:GetPropertyChangedSignal("Value"):Connect(function(Value, OldValue)
			if table.find(Keybind.Blacklist, Value) then
				Value = Keybind.DoNotClear and OldValue or "NONE"
			end

			KeybindAsset.Value.Text = "[ " .. tostring(Value) .. " ]"
			if Keybind.ListMimic then
				Keybind.ListMimic.Asset.Visible = Value ~= "NONE"
				Keybind.ListMimic.Asset.Layout.Keybind.Text = "[ " .. tostring(Value) .. " ]"
			end

			Keybind.WaitingForBind = false
			Keybind.Internal.Value = Value
			Window.Flags[Keybind.Flag] = Value
			Keybind.Callback(Value, false, Keybind.Toggle)
		end)

		function Keybind:Tooltip(Text)
			Bracket.Elements.Tooltip(KeybindAsset, Text)
		end
	end,
	ToggleKeybind = function(Parent, Window, Keybind, Toggle)
		local KeybindAsset = Bracket.Assets.ToggleKeybind()
		Keybind.WaitingForBind = false
		Keybind.Toggle = Toggle

		KeybindAsset.Parent = Parent
		KeybindAsset.Text = "[ " .. Keybind.Value .. " ]"

		KeybindAsset.MouseButton1Click:Connect(function()
			KeybindAsset.Text = "[ ... ]"
			Keybind.WaitingForBind = true
		end)
		KeybindAsset:GetPropertyChangedSignal("TextBounds"):Connect(function()
			KeybindAsset.Size = UDim2.new(0, KeybindAsset.TextBounds.X, 1, 0)
		end)

		if type(Window.KeybindList) == "table" and not Keybind.IgnoreList then
			Keybind.ListMimic = {}
			Keybind.ListMimic.Asset = Bracket.Assets.KeybindMimic()
			Keybind.ListMimic.Asset.Title.Text = Toggle.Name
			Keybind.ListMimic.Asset.Visible = Keybind.Value ~= "NONE"
			Keybind.ListMimic.Asset.Parent = Window.KeybindList.List

			Keybind.ListMimic.ColorConfig = {false, "BackgroundColor3"}
			Window.Colorable[Keybind.ListMimic.Asset.Tick] = Keybind.ListMimic.ColorConfig
		end

		UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
			if GameProcessedEvent then return end
			local Key = Input.KeyCode.Name
			if Keybind.WaitingForBind and Input.UserInputType.Name == "Keyboard" then
				Keybind.Value = Key
			elseif Input.UserInputType.Name == "Keyboard" then
				if Key == Keybind.Value then
					if not Keybind.DisableToggle then Toggle.Value = not Toggle.Value end
					Keybind.Callback(Keybind.Value, true, Toggle.Value)
				end
			end
			if Keybind.Mouse then Key = Input.UserInputType.Name
				if Keybind.WaitingForBind and (Key == "MouseButton1"
					or Key == "MouseButton2" or Key == "MouseButton3") then
					Keybind.Value = Key
				elseif Key == "MouseButton1"
					or Key == "MouseButton2"
					or Key == "MouseButton3" then
					if Key == Keybind.Value then
						if not Keybind.DisableToggle then Toggle.Value = not Toggle.Value end
						Keybind.Callback(Keybind.Value, true, Toggle.Value)
					end
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
			if GameProcessedEvent then return end
			local Key = Input.KeyCode.Name
			if Input.UserInputType.Name == "Keyboard" then
				if Key == Keybind.Value then
					Keybind.Callback(Keybind.Value, false, Toggle.Value)
				end
			end
			if Keybind.Mouse then Key = Input.UserInputType.Name
				if Key == "MouseButton1"
					or Key == "MouseButton2"
					or Key == "MouseButton3" then
					if Key == Keybind.Value then
						Keybind.Callback(Keybind.Value, false, Toggle.Value)
					end
				end
			end
		end)

		Toggle:GetPropertyChangedSignal("Value"):Connect(function(Value)
			if Keybind.ListMimic then
				Keybind.ListMimic.ColorConfig[1] = Value
				Keybind.ListMimic.Asset.Tick.BackgroundColor3 = Value
					and Window.Color or Color3.fromRGB(63, 63, 63)
			end
		end)

		Keybind:GetPropertyChangedSignal("Value"):Connect(function(Value, OldValue)
			if table.find(Keybind.Blacklist, Value) then
				Value = Keybind.DoNotClear and OldValue or "NONE"
			end

			KeybindAsset.Text = "[ " .. tostring(Value) .. " ]"
			if Keybind.ListMimic then
				Keybind.ListMimic.Asset.Visible = Value ~= "NONE"
				Keybind.ListMimic.Asset.Layout.Keybind.Text = "[ " .. tostring(Value) .. " ]"
			end

			Keybind.WaitingForBind = false
			Keybind.Internal.Value = Value
			Window.Flags[Keybind.Flag] = Value
			Keybind.Callback(Value, false, Toggle.Value)
		end)
	end,
	Dropdown = function(Parent, Window, Dropdown)
		local OptionContainerAsset = Bracket.Assets.DropdownContainer()
		local DropdownAsset = Bracket.Assets.Dropdown()

		Dropdown.Internal.Value = {}
		local ContainerRender = nil

		DropdownAsset.Parent = Parent
		OptionContainerAsset.Parent = Bracket.Screen

		DropdownAsset.Title.Text = Dropdown.Name
		DropdownAsset.Title.Visible = not Dropdown.HideName

		DropdownAsset.MouseButton1Click:Connect(function()
			if not OptionContainerAsset.Visible and OptionContainerAsset.ListLayout.AbsoluteContentSize.Y ~= 0 then
				Bracket.Utilities.ClosePopUps()
				OptionContainerAsset.Visible = true

				ContainerRender = RunService.RenderStepped:Connect(function()
					if not OptionContainerAsset.Visible then ContainerRender:Disconnect() end

					local TabPosition = Window.Asset.TabContainer.AbsolutePosition.Y + Window.Asset.TabContainer.AbsoluteSize.Y
					local DropdownPosition = DropdownAsset.Background.AbsolutePosition.Y + DropdownAsset.Background.AbsoluteSize.Y
					if TabPosition < DropdownPosition then
						OptionContainerAsset.Visible = false
					end

					TabPosition = Window.Asset.TabContainer.AbsolutePosition.Y
					DropdownPosition = DropdownAsset.Background.AbsolutePosition.Y
					if TabPosition > DropdownPosition then
						OptionContainerAsset.Visible = false
					end

					OptionContainerAsset.Position = UDim2.fromOffset(
						DropdownAsset.Background.AbsolutePosition.X,
						(DropdownAsset.Background.AbsolutePosition.Y + GuiInset.Y) + DropdownAsset.Background.AbsoluteSize.Y + 4
					)
					OptionContainerAsset.Size = UDim2.fromOffset(
						DropdownAsset.Background.AbsoluteSize.X,
						math.clamp(OptionContainerAsset.ListLayout.AbsoluteContentSize.Y, 16, 112) + 4
						--OptionContainerAsset.ListLayout.AbsoluteContentSize.Y + 2
					)
				end)
			else
				OptionContainerAsset.Visible = false
			end
		end)
		DropdownAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			DropdownAsset.Title.Size = Dropdown.HideName and UDim2.fromScale(1, 0) or UDim2.new(1, 0, 0, 
                Bracket.Utilities.GetTextBounds(
                    DropdownAsset.Title.Text,
                    DropdownAsset.Title.Font.Name,
                    Vector2.new(DropdownAsset.Title.AbsoluteSize.X, DropdownAsset.Title.TextSize)
                ).Y + 2
            )

			DropdownAsset.Background.Position = UDim2.new(0.5, 0, 0, DropdownAsset.Title.Size.Y.Offset)
			DropdownAsset.Size = UDim2.new(1, 0, 0, DropdownAsset.Title.Size.Y.Offset + DropdownAsset.Background.Size.Y.Offset)
		end)
		OptionContainerAsset.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			OptionContainerAsset.CanvasSize = UDim2.fromOffset(0, OptionContainerAsset.ListLayout.AbsoluteContentSize.Y + 4)
		end)
		--[[DropdownAsset.Background.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
			DropdownAsset.Background.Size = UDim2.new(1, 0, 0, DropdownAsset.Background.Value.TextBounds.Y + 2)
			DropdownAsset.Size = UDim2.new(1, 0, 0, DropdownAsset.Title.Size.Y.Offset + DropdownAsset.Background.Size.Y.Offset)
		end)]]

		local function RefreshSelected()
			table.clear(Dropdown.Internal.Value)

			for Index, Option in pairs(Dropdown.List) do
				if Option.Value then
					table.insert(Dropdown.Internal.Value, Option.Name)
				end
			end

			Window.Flags[Dropdown.Flag] = Dropdown.Internal.Value
			DropdownAsset.Background.Value.Text = #Dropdown.Internal.Value == 0
				and "..." or table.concat(Dropdown.Internal.Value, ", ")
		end

		local function SetValue(Option, Value)
			Option.Value = Value
			Option.ColorConfig[1] = Value
			Option.Object.Tick.BackgroundColor3 = Value
				and Window.Color or Color3.fromRGB(63, 63, 63)
			--Option.Callback(Dropdown.Selected, Option)
		end

		local function AddOption(Option, AddToList, Order)
			Option = Bracket.Utilities:GetType(Option, {}, "table", true)
			Option.Name = Bracket.Utilities:GetType(Option.Name, "Option", "string")
			Option.Mode = Bracket.Utilities:GetType(Option.Mode, "Button", "string")
			Option.Value = Bracket.Utilities:GetType(Option.Value, false, "boolean")
			Option.Callback = Bracket.Utilities:GetType(Option.Callback, function() end, "function")

			local OptionAsset = Bracket.Assets.DropdownOption()
			Option.Object = OptionAsset

			OptionAsset.LayoutOrder = Order
			OptionAsset.Parent = OptionContainerAsset
			OptionAsset.Title.Text = Option.Name
			OptionAsset.Tick.BackgroundColor3 = Option.Value
				and Window.Color or Color3.fromRGB(63, 63, 63)

			Option.ColorConfig = {Option.Value, "BackgroundColor3"}
			Window.Colorable[OptionAsset.Tick] = Option.ColorConfig
			if AddToList then table.insert(Dropdown.List, Option) end

			OptionAsset.MouseButton1Click:Connect(function()
				Option.Value = not Option.Value
			end)
			OptionAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
				OptionAsset.Layout.Size = UDim2.new(1, -OptionAsset.Title.TextBounds.X - 22, 1, 0)
			end)

			Option:GetPropertyChangedSignal("Name"):Connect(function(Name)
				OptionAsset.Title.Text = Name
			end)
			Option:GetPropertyChangedSignal("Value"):Connect(function(Value)
				if Option.Mode == "Button" then
					for Index, OldOption in pairs(Dropdown.List) do
						SetValue(OldOption.Internal, false)
					end

					Value = true
					Option.Internal.Value = Value
					OptionContainerAsset.Visible = false
				end

				RefreshSelected()
				Option.ColorConfig[1] = Value
				Option.Object.Tick.BackgroundColor3 = Value
					and Window.Color or Color3.fromRGB(63, 63, 63)
				Option.Callback(Dropdown.Value, Option)
			end)

			for Index, Value in pairs(Option.Internal) do
				if string.find(Index, "Colorpicker") then
					Option[Index] = Bracket.Utilities:GetType(Option[Index], {}, "table", true)
					Option[Index].Flag = Bracket.Utilities:GetType(Option[Index].Flag,
						Dropdown.Flag .. "/" .. Option.Name .. "/Colorpicker", "string")

					Option[Index].Value = Bracket.Utilities:GetType(Option[Index].Value, {1, 1, 1, 0, false}, "table")
					Option[Index].Callback = Bracket.Utilities:GetType(Option[Index].Callback, function() end, "function")
					Window.Elements[#Window.Elements + 1] = Option[Index]
					Window.Flags[Option[Index].Flag] = Option[Index].Value

					Bracket.Elements.ToggleColorpicker(OptionAsset.Layout, Window, Option[Index])
				end
			end

			return Option
		end

		-- Dropdown Update
		for Index, Option in pairs(Dropdown.List) do
			Dropdown.List[Index] = AddOption(Option, false, Index)
		end for Index, Option in pairs(Dropdown.List) do
			if Option.Value then Option.Value = true end
		end RefreshSelected()

		function Dropdown:BulkAdd(Table)
			for Index, Option in pairs(Table) do
				AddOption(Option, true, Index)
			end
		end
		function Dropdown.AddOption(Self, Option)
			AddOption(Option, true, #Self.List)
		end

		function Dropdown.Clear(Self)
			for Index, Option in pairs(Self.List) do
				Option.Object:Destroy()
			end table.clear(Self.List)
		end
		function Dropdown.RemoveOption(Self, Name)
			for Index, Option in pairs(Self.List) do
				if Option.Name == Name then
					Option.Object:Destroy()
					table.remove(Self.List, Index)
				end
			end
			for Index, Option in pairs(Self.List) do
				Option.Object.LayoutOrder = Index
			end
		end
		function Dropdown.RefreshToPlayers(Self, ToggleMode)
			local Players = {}
			for Index, Player in pairs(PlayerService:GetPlayers()) do
				if Player == LocalPlayer then continue end
				table.insert(Players, {Name = Player.Name,
					Mode = ToggleMode == "Toggle" or "Button"
				})
			end
			Self:Clear()
			Self:BulkAdd(Players)
		end

		Dropdown:GetPropertyChangedSignal("Name"):Connect(function(Name)
			DropdownAsset.Title.Text = Name
		end)
		Dropdown:GetPropertyChangedSignal("Value"):Connect(function(Value)
			if type(Value) ~= "table" then return end
			if #Value == 0 then RefreshSelected() return end

			for Index, Option in pairs(Dropdown.List) do
				if table.find(Value, Option.Name) then
					Option.Value = true
				else
					if Option.Mode ~= "Button" then
						Option.Value = false
					end
				end
			end
		end)

		function Dropdown:Tooltip(Text)
			Bracket.Elements.Tooltip(DropdownAsset, Text)
		end
	end,
	Colorpicker = function(Parent, Window, Colorpicker)
		local ColorpickerAsset = Bracket.Assets.Colorpicker()
		local PaletteAsset = Bracket.Assets.ColorpickerPalette()

		Colorpicker.ColorConfig = {Colorpicker.Value[5], "BackgroundColor3"}
		Window.Colorable[PaletteAsset.Rainbow.Tick] = Colorpicker.ColorConfig
		local PaletteRender, SVRender, HueRender, AlphaRender = nil, nil, nil, nil


		ColorpickerAsset.Parent = Parent
		PaletteAsset.Parent = Bracket.Screen

		ColorpickerAsset.Title.Text = Colorpicker.Name
		PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5]
			and Window.Color or Color3.fromRGB(63, 63, 63)


		ColorpickerAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			ColorpickerAsset.Size = UDim2.new(1, 0, 0,
                Bracket.Utilities.GetTextBounds(
                    ColorpickerAsset.Title.Text,
                    ColorpickerAsset.Title.Font.Name,
                    Vector2.new(ColorpickerAsset.Title.AbsoluteSize.X, ColorpickerAsset.Title.TextSize)
                ).Y
            )
		end)

		ColorpickerAsset.MouseButton1Click:Connect(function()
			if not PaletteAsset.Visible then
				Bracket.Utilities.ClosePopUps()
				PaletteAsset.Visible = true

				PaletteRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then PaletteRender:Disconnect() end

					local TabPosition = Window.Asset.TabContainer.AbsolutePosition.Y + Window.Asset.TabContainer.AbsoluteSize.Y
					local ColorpickerPosition = ColorpickerAsset.Color.AbsolutePosition.Y + ColorpickerAsset.Color.AbsoluteSize.Y
					if TabPosition < ColorpickerPosition then
						PaletteAsset.Visible = false
					end

					TabPosition = Window.Asset.TabContainer.AbsolutePosition.Y
					ColorpickerPosition = ColorpickerAsset.Color.AbsolutePosition.Y
					if TabPosition > ColorpickerPosition then
						PaletteAsset.Visible = false
					end

					PaletteAsset.Position = UDim2.fromOffset(
						(ColorpickerAsset.Color.AbsolutePosition.X - PaletteAsset.AbsoluteSize.X) + 20,
						(ColorpickerAsset.Color.AbsolutePosition.Y + GuiInset.Y) + 14
					)
				end)
			else
				PaletteAsset.Visible = false
			end
		end)

		PaletteAsset.Rainbow.MouseButton1Click:Connect(function()
			Colorpicker.Value[5] = not Colorpicker.Value[5]
			Colorpicker.ColorConfig[1] = Colorpicker.Value[5]
			PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5]
				and Window.Color or Color3.fromRGB(63, 63, 63)
		end)
		PaletteAsset.SVPicker.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SVRender then SVRender:Disconnect() end
				SVRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then SVRender:Disconnect() end
					local Mouse = UserInputService:GetMouseLocation()
					local ColorX = math.clamp(Mouse.X - PaletteAsset.SVPicker.AbsolutePosition.X, 0, PaletteAsset.SVPicker.AbsoluteSize.X) / PaletteAsset.SVPicker.AbsoluteSize.X
					local ColorY = math.clamp(Mouse.Y - (PaletteAsset.SVPicker.AbsolutePosition.Y + GuiInset.Y), 0, PaletteAsset.SVPicker.AbsoluteSize.Y) / PaletteAsset.SVPicker.AbsoluteSize.Y

					Colorpicker.Value[2] = ColorX
					Colorpicker.Value[3] = 1 - ColorY
					Colorpicker.Value = Colorpicker.Value
				end)
			end
		end)
		PaletteAsset.SVPicker.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SVRender then SVRender:Disconnect() end
			end
		end)
		PaletteAsset.Hue.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if HueRender then HueRender:Disconnect() end
				HueRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then HueRender:Disconnect() end
					local Mouse = UserInputService:GetMouseLocation()
					local ColorX = math.clamp(Mouse.X - PaletteAsset.Hue.AbsolutePosition.X, 0, PaletteAsset.Hue.AbsoluteSize.X) / PaletteAsset.Hue.AbsoluteSize.X
					Colorpicker.Value[1] = 1 - ColorX
					Colorpicker.Value = Colorpicker.Value
				end)
			end
		end)
		PaletteAsset.Hue.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if HueRender then HueRender:Disconnect() end
			end
		end)
		PaletteAsset.Alpha.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if AlphaRender then AlphaRender:Disconnect() end
				AlphaRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then AlphaRender:Disconnect() end
					local Mouse = UserInputService:GetMouseLocation()
					local ColorX = math.clamp(Mouse.X - PaletteAsset.Alpha.AbsolutePosition.X, 0, PaletteAsset.Alpha.AbsoluteSize.X) / PaletteAsset.Alpha.AbsoluteSize.X
					Colorpicker.Value[4] = math.floor(ColorX * 10^2) / (10^2) -- idk %.2f little bit broken with this
					Colorpicker.Value = Colorpicker.Value
				end)
			end
		end)
		PaletteAsset.Alpha.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if AlphaRender then AlphaRender:Disconnect() end
			end
		end)

		PaletteAsset.RGB.RGBBox.FocusLost:Connect(function(Enter)
			if not Enter then return end
			local ColorString = string.split(string.gsub(PaletteAsset.RGB.RGBBox.Text, " ", ""), ", ")
			local Hue, Saturation, Value = Color3.fromRGB(ColorString[1], ColorString[2], ColorString[3]):ToHSV()
			PaletteAsset.RGB.RGBBox.Text = ""
			Colorpicker.Value[1] = Hue
			Colorpicker.Value[2] = Saturation
			Colorpicker.Value[3] = Value
			Colorpicker.Value = Colorpicker.Value
		end)
		PaletteAsset.HEX.HEXBox.FocusLost:Connect(function(Enter)
			if not Enter then return end
			local Hue, Saturation, Value = Color3.fromHex("#" .. PaletteAsset.HEX.HEXBox.Text):ToHSV()
			PaletteAsset.RGB.RGBBox.Text = ""
			Colorpicker.Value[1] = Hue
			Colorpicker.Value[2] = Saturation
			Colorpicker.Value[3] = Value
			Colorpicker.Value = Colorpicker.Value
		end)

		RunService.Heartbeat:Connect(function()
			if Colorpicker.Value[5] then
				if PaletteAsset.Visible then
					Colorpicker.Value[1] = Window.RainbowHue
					Colorpicker.Value = Colorpicker.Value
				else 
					Colorpicker.Value[1] = Window.RainbowHue
					Colorpicker.Value[6] = Bracket.Utilities.TableToColor(Colorpicker.Value)
					ColorpickerAsset.Color.BackgroundColor3 = Colorpicker.Value[6]
					Window.Flags[Colorpicker.Flag] = Colorpicker.Value
					Colorpicker.Callback(Colorpicker.Value, Colorpicker.Value[6])
				end
			end
		end)

		Colorpicker:GetPropertyChangedSignal("Name"):Connect(function(Name)
			ColorpickerAsset.Title.Text = Name
		end)
		Colorpicker:GetPropertyChangedSignal("Value"):Connect(function(Value)
			Value[6] = Bracket.Utilities.TableToColor(Value)
			Colorpicker.ColorConfig[1] = Colorpicker.Value[5]
			ColorpickerAsset.Color.BackgroundColor3 = Value[6]

			PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5]
				and Window.Color or Color3.fromRGB(63, 63, 63)

			PaletteAsset.SVPicker.BackgroundColor3 = Color3.fromHSV(Value[1], 1, 1)
			PaletteAsset.SVPicker.Pin.Position = UDim2.fromScale(Value[2], 1 - Value[3])
			PaletteAsset.Hue.Pin.Position = UDim2.fromScale(1 - Value[1], 0.5)

			PaletteAsset.Alpha.Pin.Position = UDim2.fromScale(Value[4], 0.5)
			PaletteAsset.Alpha.Value.Text = Value[4]
			PaletteAsset.Alpha.BackgroundColor3 = Value[6]

			PaletteAsset.RGB.RGBBox.PlaceholderText = Bracket.Utilities.ColorToString(Value[6])
			PaletteAsset.HEX.HEXBox.PlaceholderText = string.upper(Value[6]:ToHex())
			Window.Flags[Colorpicker.Flag] = Value
			Colorpicker.Callback(Value, Value[6])
		end) Colorpicker.Value = Colorpicker.Value

		function Colorpicker:Tooltip(Text)
			Bracket.Elements.Tooltip(ColorpickerAsset, Text)
		end
	end,
	ToggleColorpicker = function(Parent, Window, Colorpicker)
		local ColorpickerAsset = Bracket.Assets.ToggleColorpicker()
		local PaletteAsset = Bracket.Assets.ColorpickerPalette()

		Colorpicker.ColorConfig = {Colorpicker.Value[5], "BackgroundColor3"}
		Window.Colorable[PaletteAsset.Rainbow.Tick] = Colorpicker.ColorConfig
		local PaletteRender, SVRender, HueRender, AlphaRender = nil, nil, nil, nil

		ColorpickerAsset.Parent = Parent
		PaletteAsset.Parent = Bracket.Screen

		PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5]
			and Window.Color or Color3.fromRGB(63, 63, 63)

		ColorpickerAsset.MouseButton1Click:Connect(function()
			if not PaletteAsset.Visible then
				Bracket.Utilities.ClosePopUps()
				PaletteAsset.Visible = true

				PaletteRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then PaletteRender:Disconnect() end

					local TabPosition = Window.Asset.TabContainer.AbsolutePosition.Y + Window.Asset.TabContainer.AbsoluteSize.Y
					local ColorpickerPosition = ColorpickerAsset.AbsolutePosition.Y + ColorpickerAsset.AbsoluteSize.Y
					if TabPosition < ColorpickerPosition then
						PaletteAsset.Visible = false
					end

					TabPosition = Window.Asset.TabContainer.AbsolutePosition.Y
					ColorpickerPosition = ColorpickerAsset.AbsolutePosition.Y
					if TabPosition > ColorpickerPosition then
						PaletteAsset.Visible = false
					end

					PaletteAsset.Position = UDim2.fromOffset(
						(ColorpickerAsset.AbsolutePosition.X - PaletteAsset.AbsoluteSize.X) + 24,
						(ColorpickerAsset.AbsolutePosition.Y + GuiInset.Y) + 16
					)
				end)
			else
				PaletteAsset.Visible = false
			end
		end)

		PaletteAsset.Rainbow.MouseButton1Click:Connect(function()
			Colorpicker.Value[5] = not Colorpicker.Value[5]
			Colorpicker.ColorConfig[1] = Colorpicker.Value[5]
			PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5]
				and Window.Color or Color3.fromRGB(63, 63, 63)
		end)
		PaletteAsset.SVPicker.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SVRender then SVRender:Disconnect() end
				SVRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then SVRender:Disconnect() end
					local Mouse = UserInputService:GetMouseLocation()
					local ColorX = math.clamp(Mouse.X - PaletteAsset.SVPicker.AbsolutePosition.X, 0, PaletteAsset.SVPicker.AbsoluteSize.X) / PaletteAsset.SVPicker.AbsoluteSize.X
					local ColorY = math.clamp(Mouse.Y - (PaletteAsset.SVPicker.AbsolutePosition.Y + GuiInset.Y), 0, PaletteAsset.SVPicker.AbsoluteSize.Y) / PaletteAsset.SVPicker.AbsoluteSize.Y

					Colorpicker.Value[2] = ColorX
					Colorpicker.Value[3] = 1 - ColorY
					Colorpicker.Value = Colorpicker.Value
				end)
			end
		end)
		PaletteAsset.SVPicker.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if SVRender then SVRender:Disconnect() end
			end
		end)
		PaletteAsset.Hue.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if HueRender then HueRender:Disconnect() end
				HueRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then HueRender:Disconnect() end
					local Mouse = UserInputService:GetMouseLocation()
					local ColorX = math.clamp(Mouse.X - PaletteAsset.Hue.AbsolutePosition.X, 0, PaletteAsset.Hue.AbsoluteSize.X) / PaletteAsset.Hue.AbsoluteSize.X
					Colorpicker.Value[1] = 1 - ColorX
					Colorpicker.Value = Colorpicker.Value
				end)
			end
		end)
		PaletteAsset.Hue.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if HueRender then HueRender:Disconnect() end
			end
		end)
		PaletteAsset.Alpha.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if AlphaRender then AlphaRender:Disconnect() end
				AlphaRender = RunService.RenderStepped:Connect(function()
					if not PaletteAsset.Visible then AlphaRender:Disconnect() end
					local Mouse = UserInputService:GetMouseLocation()
					local ColorX = math.clamp(Mouse.X - PaletteAsset.Alpha.AbsolutePosition.X, 0, PaletteAsset.Alpha.AbsoluteSize.X) / PaletteAsset.Alpha.AbsoluteSize.X
					Colorpicker.Value[4] = math.floor(ColorX * 10^2) / (10^2) -- idk %.2f little bit broken with this
					Colorpicker.Value = Colorpicker.Value
				end)
			end
		end)
		PaletteAsset.Alpha.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if AlphaRender then AlphaRender:Disconnect() end
			end
		end)

		PaletteAsset.RGB.RGBBox.FocusLost:Connect(function(Enter)
			if not Enter then return end
			local ColorString = string.split(string.gsub(PaletteAsset.RGB.RGBBox.Text, " ", ""), ", ")
			local Hue, Saturation, Value = Color3.fromRGB(ColorString[1], ColorString[2], ColorString[3]):ToHSV()
			PaletteAsset.RGB.RGBBox.Text = ""
			Colorpicker.Value[1] = Hue
			Colorpicker.Value[2] = Saturation
			Colorpicker.Value[3] = Value
			Colorpicker.Value = Colorpicker.Value
		end)
		PaletteAsset.HEX.HEXBox.FocusLost:Connect(function(Enter)
			if not Enter then return end
			local Hue, Saturation, Value = Color3.fromHex("#" .. PaletteAsset.HEX.HEXBox.Text):ToHSV()
			PaletteAsset.RGB.RGBBox.Text = ""
			Colorpicker.Value[1] = Hue
			Colorpicker.Value[2] = Saturation
			Colorpicker.Value[3] = Value
			Colorpicker.Value = Colorpicker.Value
		end)

		RunService.Heartbeat:Connect(function()
			if Colorpicker.Value[5] then
				if PaletteAsset.Visible then
					Colorpicker.Value[1] = Window.RainbowHue
					Colorpicker.Value = Colorpicker.Value
				else 
					Colorpicker.Value[1] = Window.RainbowHue
					Colorpicker.Value[6] = Bracket.Utilities.TableToColor(Colorpicker.Value)
					ColorpickerAsset.BackgroundColor3 = Colorpicker.Value[6]
					Window.Flags[Colorpicker.Flag] = Colorpicker.Value
					Colorpicker.Callback(Colorpicker.Value, Colorpicker.Value[6])
				end
			end
		end)
		Colorpicker:GetPropertyChangedSignal("Value"):Connect(function(Value)
			Value[6] = Bracket.Utilities.TableToColor(Value)
			Colorpicker.ColorConfig[1] = Colorpicker.Value[5]
			ColorpickerAsset.BackgroundColor3 = Value[6]

			PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5]
				and Window.Color or Color3.fromRGB(63, 63, 63)

			PaletteAsset.SVPicker.BackgroundColor3 = Color3.fromHSV(Value[1], 1, 1)
			PaletteAsset.SVPicker.Pin.Position = UDim2.fromScale(Value[2], 1 - Value[3])
			PaletteAsset.Hue.Pin.Position = UDim2.fromScale(1 - Value[1], 0.5)

			PaletteAsset.Alpha.Pin.Position = UDim2.fromScale(Value[4], 0.5)
			PaletteAsset.Alpha.Value.Text = Value[4]
			PaletteAsset.Alpha.BackgroundColor3 = Value[6]

			PaletteAsset.RGB.RGBBox.PlaceholderText = Bracket.Utilities.ColorToString(Value[6])
			PaletteAsset.HEX.HEXBox.PlaceholderText = string.upper(Value[6]:ToHex())
			Window.Flags[Colorpicker.Flag] = Value
			Colorpicker.Callback(Value, Value[6])
		end) Colorpicker.Value = Colorpicker.Value
	end
}

Bracket.Elements.Screen()
function Bracket:Window(Window)
	Window = Bracket.Utilities:GetType(Window, {}, "table", true)
	Window.Blur = Bracket.Utilities:GetType(Window.Blur, false, "boolean")
	Window.Name = Bracket.Utilities:GetType(Window.Name, "Window", "string")
	Window.Enabled = Bracket.Utilities:GetType(Window.Enabled, true, "boolean")
	Window.Color = Bracket.Utilities:GetType(Window.Color, Color3.new(1, 0.5, 0.25), "Color3")
	Window.Position = Bracket.Utilities:GetType(Window.Position, UDim2.new(0.5, -248, 0.5, -248), "UDim2")
	Window.Size = Bracket.Utilities:GetType(Window.Size, UDim2.new(0, 496, 0, 496), "UDim2")
	local WindowAsset = Bracket.Elements.Window(Window)

	function Window:Tab(Tab)
		Tab = Bracket.Utilities:GetType(Tab, {}, "table", true)
		Tab.Name = Bracket.Utilities:GetType(Tab.Name, "Tab", "string")
		local TabAsset = Bracket.Elements.Tab(WindowAsset, Window, Tab)

		function Tab:AddConfigSection(FolderName, Side)
			local ConfigSection = Tab:Section({Name = "Config System", Side = Side}) do
				local ConfigList, ConfigDropdown = Bracket.Utilities.ConfigsToList(FolderName), nil
				local ALConfig = Window:GetAutoLoadConfig(FolderName)

				local function UpdateList(Name) ConfigDropdown:Clear()
					ConfigList = Bracket.Utilities.ConfigsToList(FolderName) ConfigDropdown:BulkAdd(ConfigList)
					ConfigDropdown.Value = {}
					--ConfigDropdown.Value = {Name or (ConfigList[#ConfigList] and ConfigList[#ConfigList].Name)}
				end

				local ConfigTextbox = ConfigSection:Textbox({HideName = true, Placeholder = "Config Name", IgnoreFlag = true})
				ConfigSection:Button({Name = "Create", Callback = function()
					Window:SaveConfig(FolderName, ConfigTextbox.Value) UpdateList(ConfigTextbox.Value)
				end})

				ConfigSection:Divider({Text = "Configs"})

				ConfigDropdown = ConfigSection:Dropdown({HideName = true, IgnoreFlag = true, List = ConfigList})
				--ConfigDropdown.Value = {ConfigList[#ConfigList] and ConfigList[#ConfigList].Name}

				ConfigSection:Button({Name = "Save", Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:SaveConfig(FolderName, ConfigDropdown.Value[1])
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "Select Config First",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Load", Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:LoadConfig(FolderName, ConfigDropdown.Value[1])
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "Select Config First",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Delete", Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:DeleteConfig(FolderName, ConfigDropdown.Value[1])
						UpdateList()
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "Select Config First",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Refresh", Callback = UpdateList})

				local ConfigDivider = ConfigSection:Divider({Text = not ALConfig and "AutoLoad Config"
					or "AutoLoad Config\n<font color=\"rgb(189, 189, 189)\">[ " .. ALConfig .. " ]</font>"})

				ConfigSection:Button({Name = "Set AutoLoad Config", Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:AddToAutoLoad(FolderName, ConfigDropdown.Value[1])
						ConfigDivider.Text = "AutoLoad Config\n<font color=\"rgb(189, 189, 189)\">[ " .. ConfigDropdown.Value[1] .. " ]</font>"
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "Select Config First",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Clear AutoLoad Config", Callback = function()
					Window:RemoveFromAutoLoad(FolderName)
					ConfigDivider.Text = "AutoLoad Config"
				end})
			end
		end

		function Tab:Divider(Divider)
			Divider = Bracket.Utilities:GetType(Divider, {}, "table", true)
			Divider.Text = Bracket.Utilities:GetType(Divider.Text, "", "string")
			Bracket.Elements.Divider(Bracket.Utilities:ChooseTabSide(TabAsset, Divider.Side), Divider)
			return Divider
		end
		function Tab:Label(Label)
			Label = Bracket.Utilities:GetType(Label, {}, "table", true)
			Label.Text = Bracket.Utilities:GetType(Label.Text, "Label", "string")
			Bracket.Elements.Label(Bracket.Utilities:ChooseTabSide(TabAsset, Label.Side), Label)
			return Label
		end
		function Tab:Button(Button)
			Button = Bracket.Utilities:GetType(Button, {}, "table", true)
			Button.Name = Bracket.Utilities:GetType(Button.Name, "Button", "string")
			Button.Callback = Bracket.Utilities:GetType(Button.Callback, function() end, "function")
			Bracket.Elements.Button(Bracket.Utilities:ChooseTabSide(TabAsset, Button.Side), Window, Button)
			return Button
		end
		function Tab:Toggle(Toggle)
			Toggle = Bracket.Utilities:GetType(Toggle, {}, "table", true)
			Toggle.Name = Bracket.Utilities:GetType(Toggle.Name, "Toggle", "string")
			Toggle.Flag = Bracket.Utilities:GetType(Toggle.Flag, Toggle.Name, "string")

			Toggle.Value = Bracket.Utilities:GetType(Toggle.Value, false, "boolean")
			Toggle.Callback = Bracket.Utilities:GetType(Toggle.Callback, function() end, "function")
			Window.Elements[#Window.Elements + 1] = Toggle
			Window.Flags[Toggle.Flag] = Toggle.Value

			local ToggleAsset = Bracket.Elements.Toggle(Bracket.Utilities:ChooseTabSide(TabAsset, Toggle.Side), Window, Toggle)
			function Toggle:Keybind(Keybind)
				Keybind = Bracket.Utilities:GetType(Keybind, {}, "table", true)
				Keybind.Flag = Bracket.Utilities:GetType(Keybind.Flag, Toggle.Flag .. "/Keybind", "string")

				Keybind.Value = Bracket.Utilities:GetType(Keybind.Value, "NONE", "string")
				Keybind.Mouse = Bracket.Utilities:GetType(Keybind.Mouse, false, "boolean")
				Keybind.Callback = Bracket.Utilities:GetType(Keybind.Callback, function() end, "function")
				Keybind.Blacklist = Bracket.Utilities:GetType(Keybind.Blacklist, {"W", "A", "S", "D", "Slash", "Tab", "Backspace", "Escape", "Space", "Delete", "Unknown", "Backquote"}, "table")
				Window.Elements[#Window.Elements + 1] = Keybind
				Window.Flags[Keybind.Flag] = Keybind.Value

				Bracket.Elements.ToggleKeybind(ToggleAsset.Layout, Window, Keybind, Toggle)
				return Keybind
			end
			function Toggle:Colorpicker(Colorpicker)
				Colorpicker = Bracket.Utilities:GetType(Colorpicker, {}, "table", true)
				Colorpicker.Flag = Bracket.Utilities:GetType(Colorpicker.Flag, Toggle.Flag .. "/Colorpicker", "string")

				Colorpicker.Value = Bracket.Utilities:GetType(Colorpicker.Value, {1, 1, 1, 0, false}, "table")
				Colorpicker.Callback = Bracket.Utilities:GetType(Colorpicker.Callback, function() end, "function")
				Window.Elements[#Window.Elements + 1] = Colorpicker
				Window.Flags[Colorpicker.Flag] = Colorpicker.Value

				Bracket.Elements.ToggleColorpicker(ToggleAsset.Layout, Window, Colorpicker)
				return Colorpicker
			end
			return Toggle
		end
		function Tab:Slider(Slider)
			Slider = Bracket.Utilities:GetType(Slider, {}, "table", true)
			Slider.Name = Bracket.Utilities:GetType(Slider.Name, "Slider", "string")
			Slider.Flag = Bracket.Utilities:GetType(Slider.Flag, Slider.Name, "string")

			Slider.Min = Bracket.Utilities:GetType(Slider.Min, 0, "number")
			Slider.Max = Bracket.Utilities:GetType(Slider.Max, 100, "number")
			Slider.Precise = Bracket.Utilities:GetType(Slider.Precise, 0, "number")
			Slider.Unit = Bracket.Utilities:GetType(Slider.Unit, "", "string")
			Slider.Value = Bracket.Utilities:GetType(Slider.Value, Slider.Max / 2, "number")
			Slider.Callback = Bracket.Utilities:GetType(Slider.Callback, function() end, "function")
			Window.Elements[#Window.Elements + 1] = Slider
			Window.Flags[Slider.Flag] = Slider.Value

			Bracket.Elements.Slider(Bracket.Utilities:ChooseTabSide(TabAsset, Slider.Side), Window, Slider)
			return Slider
		end
		function Tab:Textbox(Textbox)
			Textbox = Bracket.Utilities:GetType(Textbox, {}, "table", true)
			Textbox.Name = Bracket.Utilities:GetType(Textbox.Name, "Textbox", "string")
			Textbox.Flag = Bracket.Utilities:GetType(Textbox.Flag, Textbox.Name, "string")

			Textbox.Value = Bracket.Utilities:GetType(Textbox.Value, "", "string")
			Textbox.NumbersOnly = Bracket.Utilities:GetType(Textbox.NumbersOnly, false, "boolean")
			Textbox.Placeholder = Bracket.Utilities:GetType(Textbox.Placeholder, "Input here", "string")
			Textbox.Callback = Bracket.Utilities:GetType(Textbox.Callback, function() end, "function")
			Window.Elements[#Window.Elements + 1] = Textbox
			Window.Flags[Textbox.Flag] = Textbox.Value

			Bracket.Elements.Textbox(Bracket.Utilities:ChooseTabSide(TabAsset, Textbox.Side), Window, Textbox)
			return Textbox
		end
		function Tab:Keybind(Keybind)
			Keybind = Bracket.Utilities:GetType(Keybind, {}, "table", true)
			Keybind.Name = Bracket.Utilities:GetType(Keybind.Name, "Keybind", "string")
			Keybind.Flag = Bracket.Utilities:GetType(Keybind.Flag, Keybind.Name, "string")

			Keybind.Value = Bracket.Utilities:GetType(Keybind.Value, "NONE", "string")
			Keybind.Mouse = Bracket.Utilities:GetType(Keybind.Mouse, false, "boolean")
			Keybind.Callback = Bracket.Utilities:GetType(Keybind.Callback, function() end, "function")
			Keybind.Blacklist = Bracket.Utilities:GetType(Keybind.Blacklist, {"W", "A", "S", "D", "Slash", "Tab", "Backspace", "Escape", "Space", "Delete", "Unknown", "Backquote"}, "table")
			Window.Elements[#Window.Elements + 1] = Keybind
			Window.Flags[Keybind.Flag] = Keybind.Value

			Bracket.Elements.Keybind(Bracket.Utilities:ChooseTabSide(TabAsset, Keybind.Side), Window, Keybind)
			return Keybind
		end
		function Tab:Dropdown(Dropdown)
			Dropdown = Bracket.Utilities:GetType(Dropdown, {}, "table", true)
			Dropdown.Name = Bracket.Utilities:GetType(Dropdown.Name, "Dropdown", "string")
			Dropdown.Flag = Bracket.Utilities:GetType(Dropdown.Flag, Dropdown.Name, "string")
			Dropdown.List = Bracket.Utilities:GetType(Dropdown.List, {}, "table")
			Window.Elements[#Window.Elements + 1] = Dropdown
			Window.Flags[Dropdown.Flag] = Dropdown.Value

			Bracket.Elements.Dropdown(Bracket.Utilities:ChooseTabSide(TabAsset, Dropdown.Side), Window, Dropdown)
			return Dropdown
		end
		function Tab:Colorpicker(Colorpicker)
			Colorpicker = Bracket.Utilities:GetType(Colorpicker, {}, "table", true)
			Colorpicker.Name = Bracket.Utilities:GetType(Colorpicker.Name, "Colorpicker", "string")
			Colorpicker.Flag = Bracket.Utilities:GetType(Colorpicker.Flag, Colorpicker.Name, "string")

			Colorpicker.Value = Bracket.Utilities:GetType(Colorpicker.Value, {1, 1, 1, 0, false}, "table")
			Colorpicker.Callback = Bracket.Utilities:GetType(Colorpicker.Callback, function() end, "function")
			Window.Elements[#Window.Elements + 1] = Colorpicker
			Window.Flags[Colorpicker.Flag] = Colorpicker.Value

			Bracket.Elements.Colorpicker(Bracket.Utilities:ChooseTabSide(TabAsset, Colorpicker.Side), Window, Colorpicker)
			return Colorpicker
		end
		function Tab:Section(Section)
			Section = Bracket.Utilities:GetType(Section, {}, "table", true)
			Section.Name = Bracket.Utilities:GetType(Section.Name, "Section", "string")
			local SectionContainer = Bracket.Elements.Section(Bracket.Utilities:ChooseTabSide(TabAsset, Section.Side), Section)

			function Section:Divider(Divider)
				Divider = Bracket.Utilities:GetType(Divider, {}, "table", true)
				Divider.Text = Bracket.Utilities:GetType(Divider.Text, "", "string")
				Bracket.Elements.Divider(SectionContainer, Divider)
				return Divider
			end
			function Section:Label(Label)
				Label = Bracket.Utilities:GetType(Label, {}, "table", true)
				Label.Text = Bracket.Utilities:GetType(Label.Text, "Label", "string")
				Bracket.Elements.Label(SectionContainer, Label)
				return Label
			end
			function Section:Button(Button)
				Button = Bracket.Utilities:GetType(Button, {}, "table", true)
				Button.Name = Bracket.Utilities:GetType(Button.Name, "Button", "string")
				Button.Callback = Bracket.Utilities:GetType(Button.Callback, function() end, "function")
				Bracket.Elements.Button(SectionContainer, Window, Button)
				return Button
			end
			function Section:Toggle(Toggle)
				Toggle = Bracket.Utilities:GetType(Toggle, {}, "table", true)
				Toggle.Name = Bracket.Utilities:GetType(Toggle.Name, "Toggle", "string")
				Toggle.Flag = Bracket.Utilities:GetType(Toggle.Flag, Toggle.Name, "string")

				Toggle.Value = Bracket.Utilities:GetType(Toggle.Value, false, "boolean")
				Toggle.Callback = Bracket.Utilities:GetType(Toggle.Callback, function() end, "function")
				Window.Elements[#Window.Elements + 1] = Toggle
				Window.Flags[Toggle.Flag] = Toggle.Value

				local ToggleAsset = Bracket.Elements.Toggle(SectionContainer, Window, Toggle)
				function Toggle:Keybind(Keybind)
					Keybind = Bracket.Utilities:GetType(Keybind, {}, "table", true)
					Keybind.Flag = Bracket.Utilities:GetType(Keybind.Flag, Toggle.Flag .. "/Keybind", "string")

					Keybind.Value = Bracket.Utilities:GetType(Keybind.Value, "NONE", "string")
					Keybind.Mouse = Bracket.Utilities:GetType(Keybind.Mouse, false, "boolean")
					Keybind.Callback = Bracket.Utilities:GetType(Keybind.Callback, function() end, "function")
					Keybind.Blacklist = Bracket.Utilities:GetType(Keybind.Blacklist, {"W", "A", "S", "D", "Slash", "Tab", "Backspace", "Escape", "Space", "Delete", "Unknown", "Backquote"}, "table")
					Window.Elements[#Window.Elements + 1] = Keybind
					Window.Flags[Keybind.Flag] = Keybind.Value

					Bracket.Elements.ToggleKeybind(ToggleAsset.Layout, Window, Keybind, Toggle)
					return Keybind
				end
				function Toggle:Colorpicker(Colorpicker)
					Colorpicker = Bracket.Utilities:GetType(Colorpicker, {}, "table", true)
					Colorpicker.Flag = Bracket.Utilities:GetType(Colorpicker.Flag, Toggle.Flag .. "/Colorpicker", "string")

					Colorpicker.Value = Bracket.Utilities:GetType(Colorpicker.Value, {1, 1, 1, 0, false}, "table")
					Colorpicker.Callback = Bracket.Utilities:GetType(Colorpicker.Callback, function() end, "function")
					Window.Elements[#Window.Elements + 1] = Colorpicker
					Window.Flags[Colorpicker.Flag] = Colorpicker.Value

					Bracket.Elements.ToggleColorpicker(ToggleAsset.Layout, Window, Colorpicker)
					return Colorpicker
				end
				return Toggle
			end
			function Section:Slider(Slider)
				Slider = Bracket.Utilities:GetType(Slider, {}, "table", true)
				Slider.Name = Bracket.Utilities:GetType(Slider.Name, "Slider", "string")
				Slider.Flag = Bracket.Utilities:GetType(Slider.Flag, Slider.Name, "string")

				Slider.Min = Bracket.Utilities:GetType(Slider.Min, 0, "number")
				Slider.Max = Bracket.Utilities:GetType(Slider.Max, 100, "number")
				Slider.Precise = Bracket.Utilities:GetType(Slider.Precise, 0, "number")
				Slider.Unit = Bracket.Utilities:GetType(Slider.Unit, "", "string")
				Slider.Value = Bracket.Utilities:GetType(Slider.Value, Slider.Max / 2, "number")
				Slider.Callback = Bracket.Utilities:GetType(Slider.Callback, function() end, "function")
				Window.Elements[#Window.Elements + 1] = Slider
				Window.Flags[Slider.Flag] = Slider.Value

				Bracket.Elements.Slider(SectionContainer, Window, Slider)
				return Slider
			end
			function Section:Textbox(Textbox)
				Textbox = Bracket.Utilities:GetType(Textbox, {}, "table", true)
				Textbox.Name = Bracket.Utilities:GetType(Textbox.Name, "Textbox", "string")
				Textbox.Flag = Bracket.Utilities:GetType(Textbox.Flag, Textbox.Name, "string")

				Textbox.Value = Bracket.Utilities:GetType(Textbox.Value, "", "string")
				Textbox.NumbersOnly = Bracket.Utilities:GetType(Textbox.NumbersOnly, false, "boolean")
				Textbox.Placeholder = Bracket.Utilities:GetType(Textbox.Placeholder, "Input here", "string")
				Textbox.Callback = Bracket.Utilities:GetType(Textbox.Callback, function() end, "function")
				Window.Elements[#Window.Elements + 1] = Textbox
				Window.Flags[Textbox.Flag] = Textbox.Value

				Bracket.Elements.Textbox(SectionContainer, Window, Textbox)
				return Textbox
			end
			function Section:Keybind(Keybind)
				Keybind = Bracket.Utilities:GetType(Keybind, {}, "table", true)
				Keybind.Name = Bracket.Utilities:GetType(Keybind.Name, "Keybind", "string")
				Keybind.Flag = Bracket.Utilities:GetType(Keybind.Flag, Keybind.Name, "string")

				Keybind.Value = Bracket.Utilities:GetType(Keybind.Value, "NONE", "string")
				Keybind.Mouse = Bracket.Utilities:GetType(Keybind.Mouse, false, "boolean")
				Keybind.Callback = Bracket.Utilities:GetType(Keybind.Callback, function() end, "function")
				Keybind.Blacklist = Bracket.Utilities:GetType(Keybind.Blacklist, {"W", "A", "S", "D", "Slash", "Tab", "Backspace", "Escape", "Space", "Delete", "Unknown", "Backquote"}, "table")
				Window.Elements[#Window.Elements + 1] = Keybind
				Window.Flags[Keybind.Flag] = Keybind.Value

				Bracket.Elements.Keybind(SectionContainer, Window, Keybind)
				return Keybind
			end
			function Section:Dropdown(Dropdown)
				Dropdown = Bracket.Utilities:GetType(Dropdown, {}, "table", true)
				Dropdown.Name = Bracket.Utilities:GetType(Dropdown.Name, "Dropdown", "string")
				Dropdown.Flag = Bracket.Utilities:GetType(Dropdown.Flag, Dropdown.Name, "string")
				Dropdown.List = Bracket.Utilities:GetType(Dropdown.List, {}, "table")
				Window.Elements[#Window.Elements + 1] = Dropdown
				Window.Flags[Dropdown.Flag] = Dropdown.Value

				Bracket.Elements.Dropdown(SectionContainer, Window, Dropdown)
				return Dropdown
			end
			function Section:Colorpicker(Colorpicker)
				Colorpicker = Bracket.Utilities:GetType(Colorpicker, {}, "table", true)
				Colorpicker.Name = Bracket.Utilities:GetType(Colorpicker.Name, "Colorpicker", "string")
				Colorpicker.Flag = Bracket.Utilities:GetType(Colorpicker.Flag, Colorpicker.Name, "string")

				Colorpicker.Value = Bracket.Utilities:GetType(Colorpicker.Value, {1, 1, 1, 0, false}, "table")
				Colorpicker.Callback = Bracket.Utilities:GetType(Colorpicker.Callback, function() end, "function")
				Window.Elements[#Window.Elements + 1] = Colorpicker
				Window.Flags[Colorpicker.Flag] = Colorpicker.Value

				Bracket.Elements.Colorpicker(SectionContainer, Window, Colorpicker)
				return Colorpicker
			end
			return Section
		end
		return Tab
	end
	return Window
end

function Bracket:Push(Notification)
	Notification = Bracket.Utilities:GetType(Notification, {}, "table")
	Notification.Title = Bracket.Utilities:GetType(Notification.Title, "Title", "string")
	Notification.Description = Bracket.Utilities:GetType(Notification.Description, "Description", "string")

	local NotificationAsset = Bracket.Assets.PushNotification()
	NotificationAsset.Parent = Bracket.Screen.PNContainer
	NotificationAsset.Title.Text = Notification.Title
	NotificationAsset.Description.Text = Notification.Description
	NotificationAsset.Title.Size = UDim2.new(1, 0, 0,
        Bracket.Utilities.GetTextBounds(
            NotificationAsset.Title.Text,
            NotificationAsset.Title.Font.Name,
            Vector2.new(NotificationAsset.Title.AbsoluteSize.X, NotificationAsset.Title.TextSize)
        ).Y
    )
	NotificationAsset.Description.Size = UDim2.new(1, 0, 0,
        Bracket.Utilities.GetTextBounds(
            NotificationAsset.Title.Text,
            NotificationAsset.Title.Font.Name,
            Vector2.new(NotificationAsset.Title.AbsoluteSize.X, NotificationAsset.Title.TextSize)
        ).Y
    )

	NotificationAsset.Size = UDim2.fromOffset(
		(NotificationAsset.Title.TextBounds.X > NotificationAsset.Description.TextBounds.X
			and NotificationAsset.Title.TextBounds.X or NotificationAsset.Description.TextBounds.X) + 24,
		NotificationAsset.ListLayout.AbsoluteContentSize.Y + 8
	)

	if Notification.Duration then
		task.spawn(function()
			for Time = Notification.Duration, 1, -1 do
				NotificationAsset.Title.Close.Text = Time
				task.wait(1)
			end
			NotificationAsset.Title.Close.Text = 0

			NotificationAsset:Destroy()
			if Notification.Callback then
				Notification.Callback()
			end
		end)
	else
		NotificationAsset.Title.Close.MouseButton1Click:Connect(function()
			NotificationAsset:Destroy()
		end)
	end
end

function Bracket:Toast(Notification)
	Notification = Bracket.Utilities:GetType(Notification, {}, "table")
	Notification.Title = Bracket.Utilities:GetType(Notification.Title, "Title", "string")
	Notification.Duration = Bracket.Utilities:GetType(Notification.Duration, 5, "number")
	Notification.Color = Bracket.Utilities:GetType(Notification.Color, Color3.new(1, 0.5, 0.25), "Color3")

	local NotificationAsset = Bracket.Assets.ToastNotification()
	NotificationAsset.Parent = Bracket.Screen.TNContainer
	NotificationAsset.Main.Title.Text = Notification.Title
	NotificationAsset.Main.GradientLine.BackgroundColor3 = Notification.Color

	NotificationAsset.Main.Size = UDim2.fromOffset(
		NotificationAsset.Main.Title.TextBounds.X + 10,
        Bracket.Utilities.GetTextBounds(
            NotificationAsset.Main.Title.Text,
            NotificationAsset.Main.Title.Font.Name,
            Vector2.new(NotificationAsset.Main.Title.AbsoluteSize.X, NotificationAsset.Main.Title.TextSize)
        ).Y + 6
	)
	NotificationAsset.Size = UDim2.fromOffset(0,
		NotificationAsset.Main.Size.Y.Offset + 4
	)

	local function TweenSize(X, Y, Callback)
		NotificationAsset:TweenSize(
			UDim2.fromOffset(X, Y),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Linear,
			0.25, false, Callback
		)
	end

	TweenSize(NotificationAsset.Main.Size.X.Offset + 4, NotificationAsset.Main.Size.Y.Offset + 4, function()
		task.wait(Notification.Duration) TweenSize(0, NotificationAsset.Main.Size.Y.Offset + 4, function()
			NotificationAsset:Destroy() if Notification.Callback then Notification.Callback() end
		end)
	end)
end

return Bracket
