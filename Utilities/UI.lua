local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Debug = false
local MainAssetFolder = Debug and game.ReplicatedStorage["BracketV3.2"]
	or InsertService:LoadLocalAsset("rbxassetid://9153139105")

local function GetAsset(AssetFolder,Asset)
	return MainAssetFolder[AssetFolder][Asset]:Clone()
end
local function GetLongest(A,B)
	return A > B and A or B
end
local function GetType(Variant,Default,Type)
	if typeof(Variant) == Type then
		return Variant
	end
	return Default
end

local function MakeDraggable(Dragger,Object,Callback)
	local StartDrag, StartPosition = false, Vector2.zero
	
	Dragger.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartPosition = UserInputService:GetMouseLocation()
			StartDrag = true
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if StartDrag and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local Mouse = UserInputService:GetMouseLocation()
			local Delta = Mouse - StartPosition
			StartPosition = Mouse
			Object.Position = Object.Position + UDim2.new(0,Delta.X,0,Delta.Y)
		end
	end)
	Dragger.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartPosition = Vector2.new(0,0)
			Callback(Object.Position)
			StartDrag = false
		end
	end)
end

local function MakeResizeable(Dragger,Object,MinSize,Callback)
	local StartDrag, StartSize
	
	Dragger.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartSize = Object.AbsoluteSize
			StartDrag = UserInputService:GetMouseLocation()
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if StartDrag and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local Mouse = UserInputService:GetMouseLocation()
			local MouseMoved = Vector2.new(
				Mouse.X - StartDrag.X,
				Mouse.Y - StartDrag.Y
			)

			local Size = StartSize + MouseMoved
			local SizeX = math.max(MinSize.X, Size.X)
			local SizeY = math.max(MinSize.Y, Size.Y)
			Object.Size = UDim2.fromOffset(SizeX, SizeY)
		end
	end)
	Dragger.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartDrag = nil
			Callback(Object.Position)
		end
	end)
end

local function ChooseTab(ScreenAsset,TabButtonAsset,TabAsset)
	for Index,Instance in pairs(ScreenAsset:GetChildren()) do
		if Instance.Name == "Palette" or Instance.Name == "OptionContainer" then
			Instance.Visible = false
		end
	end
	for Index,Instance in pairs(ScreenAsset.Window.TabContainer:GetChildren()) do
		if Instance:IsA("ScrollingFrame") and Instance ~= TabAsset then
			Instance.Visible = false
		else
			Instance.Visible = true
		end
	end
	for Index,Instance in pairs(ScreenAsset.Window.TabButtonContainer:GetChildren()) do
		if Instance:IsA("TextButton") then
			Instance.Highlight.Visible = Instance == TabButtonAsset
		end
	end
end
local function ChooseTabSide(TabAsset,Mode)
	if Mode == "Longest" then
		if TabAsset.LeftSide.ListLayout.AbsoluteContentSize.Y > TabAsset.RightSide.ListLayout.AbsoluteContentSize.Y then
			return TabAsset.LeftSide
		else
			return TabAsset.RightSide
		end
	elseif Mode == "Left" then
		return TabAsset.LeftSide
	elseif Mode == "Right" then
		return TabAsset.RightSide
	else
		if TabAsset.LeftSide.ListLayout.AbsoluteContentSize.Y > TabAsset.RightSide.ListLayout.AbsoluteContentSize.Y then
			return TabAsset.RightSide
		else
			return TabAsset.LeftSide
		end
	end
end

local function InitToolTip(Parent,ScreenAsset,Text)
	Parent.MouseEnter:Connect(function()
		ScreenAsset.ToolTip.Text = Text
		ScreenAsset.ToolTip.Size = UDim2.new(0,ScreenAsset.ToolTip.TextBounds.X + 6,0,ScreenAsset.ToolTip.TextBounds.Y + 6)
		ScreenAsset.ToolTip.Visible = true
	end)
	Parent.MouseLeave:Connect(function()
		ScreenAsset.ToolTip.Visible = false
	end)
end
local function InitScreen()
	local ScreenAsset = GetAsset("Screen","Bracket")
	ScreenAsset.Name = "Bracket " .. game:GetService("HttpService"):GenerateGUID(false)
	ScreenAsset.Parent = Debug and game.Players.LocalPlayer.PlayerGui or CoreGui
	return {ScreenAsset = ScreenAsset}
end
local function InitWindow(ScreenAsset,Window)
	local WindowAsset = GetAsset("Window","Window")

	WindowAsset.Parent = ScreenAsset
	WindowAsset.Visible = Window.Enabled
	WindowAsset.Title.Text = Window.Name
	WindowAsset.Position = Window.Position
	WindowAsset.Size = Window.Size

	MakeDraggable(WindowAsset.Drag,WindowAsset,function(Position)
		Window.Position = Position
	end)
	MakeResizeable(WindowAsset.Resize,WindowAsset,Vector2.new(296,296),function(Size)
		Window.Size = Size
	end)

	WindowAsset.TabButtonContainer.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		WindowAsset.TabButtonContainer.CanvasSize = UDim2.new(0,WindowAsset.TabButtonContainer.ListLayout.AbsoluteContentSize.X,0,0)
	end)
	RunService.RenderStepped:Connect(function()
		if WindowAsset.Visible then
			ScreenAsset.ToolTip.Position = UDim2.new(0,UserInputService:GetMouseLocation().X + 5,0,UserInputService:GetMouseLocation().Y - 5)
		end
	end)
	RunService.Heartbeat:Connect(function()
		if Window.RainbowHue < 1 then
			Window.RainbowHue  = Window.RainbowHue + 0.001
		else
			Window.RainbowHue = 0
		end
	end)
	function Window:SetName(Name)
		Window.Name = Name
		WindowAsset.Title.Text = Name
	end
	function Window:SetSize(Size)
		Window.Size = Size
		WindowAsset.Size = Size
	end
	function Window:SetPosition(Position)
		Window.Position = Position
		WindowAsset.Pisition = Position
	end
	function Window:SetColor(Color3)
		for Index,Instance in pairs(Window.Colorable) do
			if Instance.BackgroundColor3 == Window.Color then
				Instance.BackgroundColor3 = Color3
			end
			if Instance.BorderColor3 == Window.Color then
				Instance.BorderColor3 = Color3
			end
		end
		Window.Color = Color3
	end
	function Window:Toggle(Boolean)
		Window.Enabled = Boolean
		WindowAsset.Visible = Window.Enabled
		for Index,Instance in pairs(ScreenAsset:GetChildren()) do
			if Instance.Name == "Palette" or Instance.Name == "OptionContainer" then
				Instance.Visible = false
			end
		end
	end

	Window.Background = WindowAsset.Background
	return WindowAsset
end
local function InitTab(ScreenAsset,WindowAsset,Window,Tab)
	local TabButtonAsset = GetAsset("Tab","TabButton")
	local TabAsset = GetAsset("Tab","Tab")
	
	TabButtonAsset.Parent = WindowAsset.TabButtonContainer
	TabButtonAsset.Text = Tab.Name
	TabButtonAsset.Highlight.BackgroundColor3 = Window.Color
	TabButtonAsset.Size = UDim2.new(0,TabButtonAsset.TextBounds.X + 10,1,-1)
	TabAsset.Parent = WindowAsset.TabContainer
	TabAsset.Visible = false

	table.insert(Window.Colorable,TabButtonAsset.Highlight)
	TabAsset.LeftSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if ChooseTabSide(TabAsset,"Longest") == TabAsset.LeftSide then
			TabAsset.CanvasSize = UDim2.new(0,0,0,TabAsset.LeftSide.ListLayout.AbsoluteContentSize.Y + 21)
		else
			TabAsset.CanvasSize = UDim2.new(0,0,0,TabAsset.RightSide.ListLayout.AbsoluteContentSize.Y + 21)
		end
	end)
	TabAsset.RightSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if ChooseTabSide(TabAsset,"Longest") == TabAsset.LeftSide then
			TabAsset.CanvasSize = UDim2.new(0,0,0,TabAsset.LeftSide.ListLayout.AbsoluteContentSize.Y + 21)
		else
			TabAsset.CanvasSize = UDim2.new(0,0,0,TabAsset.RightSide.ListLayout.AbsoluteContentSize.Y + 21)
		end
	end)
	TabButtonAsset.MouseButton1Click:Connect(function()
		ChooseTab(ScreenAsset,TabButtonAsset,TabAsset)
	end)

	if #WindowAsset.TabContainer:GetChildren() == 1 then
		ChooseTab(ScreenAsset,TabButtonAsset,TabAsset)
	end

	function Tab:SetName(Name)
		Tab.Name = Name
		TabButtonAsset.Text = Name
		TabButtonAsset.Size = UDim2.new(0,TabButtonAsset.TextBounds.X + 10,1,-1)
	end

	return function(Side)
		return ChooseTabSide(TabAsset,Side)
	end
end
local function InitSection(Parent,Section)
	local SectionAsset = GetAsset("Section","Section")
	
	SectionAsset.Parent = Parent
	SectionAsset.Title.Text = Section.Name
	SectionAsset.Title.Size = UDim2.new(0,SectionAsset.Title.TextBounds.X + 10,0,2)

	SectionAsset.Container.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		SectionAsset.Size = UDim2.new(1,0,0,SectionAsset.Container.ListLayout.AbsoluteContentSize.Y + 15)
	end)

	function Section:SetName(Name)
		Section.Name = Name
		SectionAsset.Title.Text = Name
		SectionAsset.Title.Size = UDim2.new(0,Section.Title.TextBounds.X + 10,0,2)
	end

	return SectionAsset.Container
end
local function InitDivider(Parent,Divider)
	local DividerAsset = GetAsset("Divider","Divider")
	
	DividerAsset.Parent = Parent
	DividerAsset.Title.Text = Divider.Text

	DividerAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		if DividerAsset.Title.TextBounds.X > 0 then
			DividerAsset.Size = UDim2.new(1,0,0,DividerAsset.Title.TextBounds.Y)
			DividerAsset.Left.Size = UDim2.new(0.5,-(DividerAsset.Title.TextBounds.X / 2) - 5,0,2)
			DividerAsset.Right.Position = UDim2.new(0.5,(DividerAsset.Title.TextBounds.X / 2) + 5,0.5,0)
			DividerAsset.Right.Size = UDim2.new(0.5,-(DividerAsset.Title.TextBounds.X / 2) - 5,0,2)
		else
			DividerAsset.Size = UDim2.new(1,0,0,2)
			DividerAsset.Left.Size = UDim2.new(1,0,0,2)
			DividerAsset.Right.Position = UDim2.new(0,0,0.5,0)
			DividerAsset.Right.Size = UDim2.new(1,0,0,2)
		end
	end)

	function Divider:SetText(Text)
		Divider.Text = Text
		Divider.Title.Text = Text
	end
end
local function InitLabel(Parent,Label)
	local LabelAsset = GetAsset("Label","Label")
	
	LabelAsset.Parent = Parent
	LabelAsset.Text = Label.Text

	LabelAsset:GetPropertyChangedSignal("TextBounds"):Connect(function()
		LabelAsset.Size = UDim2.new(1,0,0,LabelAsset.TextBounds.Y)
	end)

	function Label:SetText(Text)
		Label.Text = Text
		LabelAsset.Text = Text
	end
end
local function InitButton(Parent,ScreenAsset,Window,Button)
	local ButtonAsset = GetAsset("Button","Button")
	
	ButtonAsset.Parent = Parent
	ButtonAsset.Title.Text = Button.Name

	table.insert(Window.Colorable,ButtonAsset)
	Button.Connection = ButtonAsset.MouseButton1Click:Connect(Button.Callback)
	
	ButtonAsset.MouseButton1Down:Connect(function()
		ButtonAsset.BorderColor3 = Window.Color
	end)
	ButtonAsset.MouseButton1Up:Connect(function()
		ButtonAsset.BorderColor3 = Color3.new(0,0,0)
	end)
	ButtonAsset.MouseLeave:Connect(function()
		ButtonAsset.BorderColor3 = Color3.new(0,0,0)
	end)
	ButtonAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		ButtonAsset.Size = UDim2.new(1,0,0,ButtonAsset.Title.TextBounds.Y + 6)
	end)

	function Button:SetName(Name)
		Button.Name = Name
		ButtonAsset.Title.Text = Name
	end
	function Button:SetCallback(Callback)
		Button.Callback = Callback
		Button.Connection:Disconnect()
		Button.Connection = ButtonAsset.MouseButton1Click:Connect(Callback)
	end
	function Button:ToolTip(Text)
		InitToolTip(ButtonAsset,ScreenAsset,Text)
	end
end
local function InitToggle(Parent,ScreenAsset,Window,Toggle)
	local ToggleAsset = GetAsset("Toggle","Toggle")
	
	ToggleAsset.Parent = Parent
	ToggleAsset.Title.Text = Toggle.Name
	ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)
	Window.Flags[Toggle.Flag] = Toggle.Value
	
	table.insert(Window.Colorable,ToggleAsset.Tick)
	ToggleAsset.MouseButton1Click:Connect(function()
		Toggle.Value = not Toggle.Value
		Window.Flags[Toggle.Flag] = Toggle.Value
		Toggle.Callback(Toggle.Value)
		ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)
	end)
	ToggleAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		ToggleAsset.Size = UDim2.new(1,0,0,ToggleAsset.Title.TextBounds.Y)
	end)

	function Toggle:SetName(Name)
		Toggle.Name = Name
		ToggleAsset.Title.Text = Name
	end
	function Toggle:SetValue(Boolean)
		Toggle.Value = Boolean
		Window.Flags[Toggle.Flag] = Toggle.Value
		Toggle.Callback(Toggle.Value)
		ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)
	end
	function Toggle:SetCallback(Callback)
		Toggle.Callback = Callback
	end
	function Toggle:ToolTip(Text)
		InitToolTip(ToggleAsset,ScreenAsset,Text)
	end
	function Toggle:Keybind(Keybind)
		Keybind = GetType(Keybind,{},"table")
		Keybind.Flag = GetType(Keybind.Flag,"KFlag-" .. Toggle.Name,"string")
		Keybind.Key = GetType(Keybind.Key,"NONE","string")
		Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
		Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
		Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")
		Keybind.WaitingForBind = false

		ToggleAsset.Keybind.Visible = true
		ToggleAsset.Keybind.Text = "[ " .. Keybind.Key .. " ]"

		ToggleAsset.Keybind.MouseButton1Click:Connect(function()
			ToggleAsset.Keybind.Text = "[ ... ]"
			Keybind.WaitingForBind = true
		end)
		ToggleAsset.Keybind:GetPropertyChangedSignal("TextBounds"):Connect(function()
			ToggleAsset.Keybind.Size = UDim2.new(0,ToggleAsset.Keybind.TextBounds.X,1,0)
			ToggleAsset.Title.Size = UDim2.new(1,-ToggleAsset.Keybind.Size.X.Offset - 20,1,0)
		end)
		UserInputService.InputBegan:Connect(function(Input)
			local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
			if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.Keyboard then
				if not table.find(Keybind.Blacklist,Key) then
					ToggleAsset.Keybind.Text = "[ " .. Key .. " ]"
					Keybind.Key = Key
				else
					ToggleAsset.Keybind.Text = "[ NONE ]"
					Keybind.Key = nil
				end
				Keybind.WaitingForBind = false
				Window.Flags[Keybind.Flag] = {false,Keybind.Key}
				Keybind.Callback(false,Keybind.Key)
			elseif Input.UserInputType == Enum.UserInputType.Keyboard then
				if Key == Keybind.Key then
					Toggle.Value = not Toggle.Value 
					Window.Flags[Toggle.Flag] = Toggle.Value
					Window.Flags[Keybind.Flag] = {true,Keybind.Key}
					Toggle.Callback(Toggle.Value)
					Keybind.Callback(true,Keybind.Key)
					ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)
				end
			end
			if Keybind.Mouse then
				local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
				if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton1
					or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton2
					or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton3 then

					ToggleAsset.Keybind.Text = "[ " .. Key .. " ]"
					Keybind.Key = Key
					Keybind.WaitingForBind = false
					Keybind.Callback(false,Keybind.Key)
					Window.Flags[Keybind.Flag] = {false,Keybind.Key}
				elseif Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.MouseButton2
					or Input.UserInputType == Enum.UserInputType.MouseButton3 then

					if Key == Keybind.Key then
						Toggle.Value = not Toggle.Value
						Window.Flags[Toggle.Flag] = Toggle.Value
						Window.Flags[Keybind.Flag] = {true,Keybind.Key}
						Toggle.Callback(Toggle.Value)
						Keybind.Callback(true,Keybind.Key)
						ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)
					end
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(Input)
			local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				if Key == Keybind.Key then
					Window.Flags[Keybind.Flag] = {false,Keybind.Key}
					Keybind.Callback(false,Keybind.Key)
				end
			end
			if Keybind.Mouse then
				local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
				if Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.MouseButton2
					or Input.UserInputType == Enum.UserInputType.MouseButton3 then

					if Key == Keybind.Key then
						Window.Flags[Keybind.Flag] = {false,Keybind.Key}
						Keybind.Callback(false,Keybind.Key)
					end
				end
			end
		end)
		function Keybind:SetCallback(Callback)
			Keybind.Callback = Callback
		end

		return Keybind
	end
end
local function InitSlider(Parent,ScreenAsset,Window,Slider)
	local SliderAsset = GetAsset("Slider","Slider")
	
	SliderAsset.Parent = Parent
	SliderAsset.Title.Text = Slider.Name
	Slider.Value = tonumber(string.format("%." .. Slider.Precise .. "f",Slider.Value))
	SliderAsset.Background.Bar.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min),0,1,0)
	SliderAsset.Background.Bar.BackgroundColor3 = Window.Color
	
	table.insert(Window.Colorable,SliderAsset.Background.Bar)
	Window.Flags[Slider.Flag] = Slider.Value

	if #Slider.Unit == 0 then
		SliderAsset.Value.PlaceholderText = Slider.Value
	else
		SliderAsset.Value.PlaceholderText = Slider.Value .. " " .. Slider.Unit
	end

	local function UpdateVisual(Value)
		Slider.Value = tonumber(string.format("%." .. Slider.Precise .. "f",Value))
		SliderAsset.Background.Bar.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min),0,1,0)
		if #Slider.Unit == 0 then
			SliderAsset.Value.PlaceholderText = Slider.Value
		else
			SliderAsset.Value.PlaceholderText = Slider.Value .. " " .. Slider.Unit
		end
		Window.Flags[Slider.Flag] = Slider.Value
		Slider.Callback(Slider.Value)
	end
	local function AttachToMouse(Input)
		local XScale = math.clamp((Input.Position.X - SliderAsset.Background.AbsolutePosition.X) / SliderAsset.Background.AbsoluteSize.X,0,1)
		local SliderPrecise = math.clamp(XScale * (Slider.Max - Slider.Min) + Slider.Min,Slider.Min,Slider.Max)
		UpdateVisual(SliderPrecise)
	end

	function Slider:SetName(Name)
		Slider.Name = Name
		SliderAsset.Title.Text = Name
	end
	function Slider:SetValue(Value)
		UpdateVisual(Value)
	end
	function Slider:SetCallback(Callback)
		Slider.Callback = Callback
	end
	function Slider:ToolTip(Text)
		InitToolTip(SliderAsset,ScreenAsset,Text)
	end

	SliderAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		SliderAsset.Size = UDim2.new(1,0,0,SliderAsset.Title.TextBounds.Y + 16)
	end)
	SliderAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		SliderAsset.Value.Size = UDim2.new(0,SliderAsset.Value.TextBounds.X,1,-10)
		SliderAsset.Title.Size = UDim2.new(1,-SliderAsset.Value.Size.X.Offset,1,-10)
	end)
	SliderAsset.Value.FocusLost:Connect(function()
		if not tonumber(SliderAsset.Value.Text) then
			SliderAsset.Value.Text = Slider.Value
		elseif tonumber(SliderAsset.Value.Text) <= Slider.Min then
			SliderAsset.Value.Text = Slider.Min
		elseif tonumber(SliderAsset.Value.Text) >= Slider.Max then
			SliderAsset.Value.Text = Slider.Max
		end
		UpdateVisual(SliderAsset.Value.Text)
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
end
local function InitTextbox(Parent,ScreenAsset,Window,Textbox)
	local TextboxAsset = GetAsset("Textbox","Textbox")
	
	TextboxAsset.Parent = Parent
	TextboxAsset.Title.Text = Textbox.Name
	TextboxAsset.Background.Input.Text = Textbox.Text
	TextboxAsset.Background.Input.PlaceholderText = Textbox.Placeholder
	Window.Flags[Textbox.Flag] = Textbox.Text

	TextboxAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		TextboxAsset.Size = UDim2.new(1,0,0,(TextboxAsset.Title.TextBounds.Y + 6) + (TextboxAsset.Background.Input.TextBounds.Y + 6))
	end)
	TextboxAsset.Background.Input:GetPropertyChangedSignal("TextBounds"):Connect(function()
		TextboxAsset.Background.Size = UDim2.new(1,0,0,TextboxAsset.Background.Input.TextBounds.Y + 6)
	end)
	TextboxAsset.Background.Input.FocusLost:Connect(function()
		Textbox.Text = TextboxAsset.Background.Input.Text
		Window.Flags[Textbox.Flag] = Textbox.Text
		Textbox.Callback(Textbox.Text)
		--LocalTextbox.Background.Input.Text = ""
	end)

	function Textbox:SetName(Name)
		Textbox.Name = Name
		TextboxAsset.Title.Text = Name
	end
	function Textbox:SetText(Text)
		Textbox.Text = Text
		Window.Flags[Textbox.Flag] = Textbox.Text
		TextboxAsset.Background.Input.Text = Textbox.Text
		Textbox.Callback(Text)
	end
	function Textbox:SetPlaceholder(Text)
		Textbox.Placeholder = Text
		TextboxAsset.Background.Input.PlaceholderText = Textbox.Placeholder
	end
	function Textbox:ChangeCallback(Callback)
		Textbox.Callback = Callback
	end
	function Textbox:ToolTip(Text)
		InitToolTip(TextboxAsset,ScreenAsset,Text)
	end
end
local function InitKeybind(Parent,ScreenAsset,Window,Keybind)
	local KeybindAsset = GetAsset("Keybind","Keybind")
	
	KeybindAsset.Parent = Parent
	KeybindAsset.Title.Text = Keybind.Name
	KeybindAsset.Value.Text = "[ " .. Keybind.Key .. " ]"
	Keybind.WaitingForBind = false
	
	Window.Flags[Keybind.Flag] = {false,Keybind.Key}
	KeybindAsset.MouseButton1Click:Connect(function()
		KeybindAsset.Value.Text = "[ ... ]"
		Keybind.WaitingForBind = true
	end)
	KeybindAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		KeybindAsset.Size = UDim2.new(1,0,0,KeybindAsset.Title.TextBounds.Y)
	end)
	KeybindAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		KeybindAsset.Value.Size = UDim2.new(0,KeybindAsset.Value.TextBounds.X,1,0)
		KeybindAsset.Title.Size = UDim2.new(1,-KeybindAsset.Value.Size.X.Offset,1,0)
	end)
	UserInputService.InputBegan:Connect(function(Input)
		local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
		if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.Keyboard then
			if not table.find(Keybind.Blacklist,Key) then
				Keybind.Key = Key
				KeybindAsset.Value.Text = "[ " .. Key .. " ]"
			else
				Keybind.Key = nil
				KeybindAsset.Value.Text = "[ NONE ]"
			end
			Keybind.WaitingForBind = false
			Window.Flags[Keybind.Flag] = {false,Keybind.Key}
			Keybind.Callback(false,Keybind.Key)
		elseif Input.UserInputType == Enum.UserInputType.Keyboard then
			if Key == Keybind.Key then
				Window.Flags[Keybind.Flag] = {true,Keybind.Key}
				Keybind.Callback(true,Keybind.Key)
			end
		end
		if Keybind.Mouse then
			local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
			if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton1
				or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton2
				or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton3 then
				
				Keybind.Key = Key
				Keybind.WaitingForBind = false
				KeybindAsset.Value.Text = "[ " .. Key .. " ]"
				Window.Flags[Keybind.Flag] = {false,Keybind.Key}
				Keybind.Callback(false,Keybind.Key)
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.MouseButton2
				or Input.UserInputType == Enum.UserInputType.MouseButton3 then

				if Key == Keybind.Key then
					Window.Flags[Keybind.Flag] = {true,Keybind.Key}
					Keybind.Callback(true,Keybind.Key)
				end
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(Input)
		local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			if Key == Keybind.Key then
				Window.Flags[Keybind.Flag] = {false,Keybind.Key}
				Keybind.Callback(false,Keybind.Key)
			end
		end
		if Keybind.Mouse then
			local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
			if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.MouseButton2
				or Input.UserInputType == Enum.UserInputType.MouseButton3 then

				if Key == Keybind.Key then
					Window.Flags[Keybind.Flag] = {false,Keybind.Key}
					Keybind.Callback(false,Keybind.Key)
				end
			end
		end
	end)


	function Keybind:SetName(Name)
		Keybind.Name = Name
		KeybindAsset.Title.Text = Name
	end
	function Keybind:SetCallback(Callback)
		Keybind.Callback = Callback
	end
	function Keybind:ToolTip(Text)
		InitToolTip(KeybindAsset,ScreenAsset,Text)
	end
end
local function InitDropdown(Parent,ScreenAsset,Window,Dropdown)
	local DropdownAsset = GetAsset("Dropdown","Dropdown")
	local OptionContainerAsset = GetAsset("Dropdown","OptionContainer")
	DropdownAsset.Parent = Parent
	DropdownAsset.Title.Text = Dropdown.Name
	OptionContainerAsset.Parent = ScreenAsset

	local ContainerRender = nil
	DropdownAsset.MouseButton1Click:Connect(function()
		if not OptionContainerAsset.Visible and OptionContainerAsset.ListLayout.AbsoluteContentSize.Y ~= 0 then
			ContainerRender = RunService.RenderStepped:Connect(function()
				if not OptionContainerAsset.Visible then ContainerRender:Disconnect() end
				OptionContainerAsset.Position = UDim2.new(0,DropdownAsset.Background.AbsolutePosition.X,0,DropdownAsset.Background.AbsolutePosition.Y + 62)
				OptionContainerAsset.Size = UDim2.new(0,DropdownAsset.Background.AbsoluteSize.X,0,OptionContainerAsset.ListLayout.AbsoluteContentSize.Y + 2)
			end)
			OptionContainerAsset.Visible = true
		else
			ContainerRender:Disconnect()
			OptionContainerAsset.Visible = false
		end
	end)
	DropdownAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		DropdownAsset.Size = UDim2.new(1,0,0,(DropdownAsset.Title.TextBounds.Y + 6) + (DropdownAsset.Background.Value.TextBounds.Y + 6))
	end)
	DropdownAsset.Background.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		DropdownAsset.Background.Size = UDim2.new(1,0,0,DropdownAsset.Background.Value.TextBounds.Y + 6)
	end)

	if Dropdown.List then
		for Index, Option in pairs(Dropdown.List) do
			local OptionAsset = GetAsset("Dropdown","Option")
			OptionAsset.Parent = OptionContainerAsset
			OptionAsset.Title.Text = Option.Name
			table.insert(Window.Colorable, OptionAsset)
			Option.Instance = OptionAsset

			OptionAsset.MouseButton1Click:Connect(function()
				local Selected = {}
				if Option.Mode == "Button" then
					for Index, Option in pairs(Dropdown.List) do
						if Option.Mode == "Button" then
							Option.Instance.BorderColor3 = Color3.fromRGB(60,60,60)
							Option.Value = false
						end
					end
					Option.Value = true
					OptionContainerAsset.Visible = false
				elseif Option.Mode == "Toggle" then
					Option.Value = not Option.Value
				end
				Option.Instance.BorderColor3 = Option.Value and Window.Color or Color3.fromRGB(60,60,60)
				for Index, Option in pairs(Dropdown.List) do
					if Option.Value then
						table.insert(Selected,Option.Name)
					end
				end
				if not Selected[1] then
					DropdownAsset.Background.Value.Text = "..."
				else
					DropdownAsset.Background.Value.Text = table.concat(Selected,", ")
				end
				Option.Callback(Selected)
			end)
			OptionAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
				OptionAsset.Size = UDim2.new(1,0,0,OptionAsset.Title.TextBounds.Y + 6)
			end)
		end
	end
	if Dropdown.Default then
		for Index, Default in pairs(Dropdown.Default) do
			for Index, Option in pairs(Dropdown.List) do
				if Default == Option.Name then
					local Selected = {}
					if Option.Mode == "Button" then
						for Index, Option in pairs(Dropdown.List) do
							if Option.Mode == "Button" then
								Option.Instance.BorderColor3 = Color3.fromRGB(60,60,60)
								Option.Value = false
							end
						end
						Option.Value = true
						OptionContainerAsset.Visible = false
					elseif Option.Mode == "Toggle" then
						Option.Value = not Option.Value
					end
					Option.Instance.BorderColor3 = Option.Value and Window.Color or Color3.fromRGB(60,60,60)
					for Index, Option in pairs(Dropdown.List) do
						if Option.Value then
							table.insert(Selected,Option.Name)
						end
					end
					if not Selected[1] then
						DropdownAsset.Background.Value.Text = "..."
					else
						DropdownAsset.Background.Value.Text = table.concat(Selected,", ")
					end
					Option.Callback(Selected)
				end
			end
		end
	end

	function Dropdown:AddOption(Option)
		local OptionAsset = GetAsset("Dropdown","Option")
		OptionAsset.Parent = OptionContainerAsset
		OptionAsset.Title.Text = Option.Name
		table.insert(Window.Colorable, OptionAsset)
		table.insert(Dropdown.List,Option)
		Option.Instance = OptionAsset
		OptionAsset.MouseButton1Click:Connect(function()
			local Selected = {}
			if Option.Mode == "Button" then
				for Index, Option in pairs(Dropdown.List) do
					if Option.Mode == "Button" then
						Option.Instance.BorderColor3 = Color3.fromRGB(60,60,60)
						Option.Value = false
					end
				end
				Option.Value = true
				OptionContainerAsset.Visible = false
			elseif Option.Mode == "Toggle" then
				Option.Value = not Option.Value
			end
			Option.Instance.BorderColor3 = Option.Value and Window.Color or Color3.fromRGB(60,60,60)
			for Index, Option in pairs(Dropdown.List) do
				if Option.Value then
					table.insert(Selected,Option.Name)
				end
			end
			if not Selected[1] then
				DropdownAsset.Background.Value.Text = "..."
			else
				DropdownAsset.Background.Value.Text = table.concat(Selected,", ")
			end
			Option.Callback(Selected)
		end)
		OptionAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			OptionAsset.Size = UDim2.new(1,0,0,OptionAsset.Title.TextBounds.Y + 6)
		end)
	end
	function Dropdown:RemoveOption(Name)
		for Index, Option in pairs(Dropdown.List) do
			if Option.Name == Name then
				Option.Instance:Destroy()
			end
		end
	end
	function Dropdown:Clear()
		for Index, Option in pairs(Dropdown.List) do
			Option.Instance:Destroy()
		end
	end
	function Dropdown:SelectOption(Name)
		for Index, Option in pairs(Dropdown.List) do
			if Option.Name == Name then
				local Selected = {}
				if Option.Mode == "Button" then
					for Index, Option in pairs(Dropdown.List) do
						if Option.Mode == "Button" then
							Option.Instance.BorderColor3 = Color3.fromRGB(60,60,60)
							Option.Value = false
						end
					end
					Option.Value = true
					OptionContainerAsset.Visible = false
				elseif Option.Mode == "Toggle" then
					Option.Value = not Option.Value
				end
				Option.Instance.BorderColor3 = Option.Value and Window.Color or Color3.fromRGB(60,60,60)
				for Index, Option in pairs(Dropdown.List) do
					if Option.Value then
						table.insert(Selected,Option.Name)
					end
				end
				if not Selected[1] then
					DropdownAsset.Background.Value.Text = "..."
				else
					DropdownAsset.Background.Value.Text = table.concat(Selected,", ")
				end
				Option.Callback(Selected)
			end
		end
	end
	function Dropdown:SetName(Name)
		Dropdown.Name = Name
		DropdownAsset.Title.Text = Name
	end
	function Dropdown:ToolTip(Text)
		InitToolTip(DropdownAsset,ScreenAsset,Text)
	end
end
local function InitColorpicker(Parent,ScreenAsset,Window,Colorpicker)
	local ColorpickerAsset = GetAsset("Colorpicker","Colorpicker")
	local PaletteAsset = GetAsset("Colorpicker","Palette")
	ColorpickerAsset.Parent = Parent
	ColorpickerAsset.Title.Text = Colorpicker.Name
	PaletteAsset.Parent = ScreenAsset

	local PaletteRender = nil
	local SVRender = nil
	local HueRender = nil
	local AlphaRender = nil
	
	local function TableToColor(Table)
		if typeof(Table) ~= "table" then return end
		return Color3.fromHSV(Table[1],Table[2],Table[3])
	end
	
	local function Update()
		local Color = TableToColor(Colorpicker.HSVAR)
		ColorpickerAsset.Color.BackgroundColor3 = Color
		PaletteAsset.SVPicker.BackgroundColor3 = Color3.fromHSV(Colorpicker.HSVAR[1],1,1)
		PaletteAsset.SVPicker.Pin.Position = UDim2.new(Colorpicker.HSVAR[2],0,1 - Colorpicker.HSVAR[3],0)
		PaletteAsset.Hue.Pin.Position = UDim2.new(1 - Colorpicker.HSVAR[1],0,0.5,0)
		
		PaletteAsset.Alpha.Pin.Position = UDim2.new(Colorpicker.HSVAR[4],0,0.5,0)
		PaletteAsset.Alpha.Value.Text = Colorpicker.HSVAR[4]
		PaletteAsset.Alpha.BackgroundColor3 = Color
		
		PaletteAsset.RGB.RGBBox.PlaceholderText = math.round(Color.R * 255) .. "," .. math.round(Color.G * 255) .. "," .. math.round(Color.B * 255)
		PaletteAsset.HEX.HEXBox.PlaceholderText = Color:ToHex()
		Window.Flags[Colorpicker.Flag] = Colorpicker.HSVAR
		Colorpicker.Callback(Colorpicker.HSVAR,Color)
	end
	Update()

	ColorpickerAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		ColorpickerAsset.Size = UDim2.new(1,0,0,ColorpickerAsset.Title.TextBounds.Y)
	end)
	ColorpickerAsset.MouseButton1Click:Connect(function()
		if not PaletteAsset.Visible then
			PaletteAsset.Visible = true
			PaletteRender = RunService.RenderStepped:Connect(function()
				if not PaletteAsset.Visible then PaletteRender:Disconnect() end
				PaletteAsset.Position = UDim2.new(0,(ColorpickerAsset.Color.AbsolutePosition.X - PaletteAsset.AbsoluteSize.X) + 20,0,ColorpickerAsset.Color.AbsolutePosition.Y + 52)
			end)
		else
			PaletteRender:Disconnect()
			PaletteAsset.Visible = false
		end
	end)
	PaletteAsset.SVPicker.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if SVRender then
				SVRender:Disconnect()
			end
			SVRender = RunService.RenderStepped:Connect(function()
				if not PaletteAsset.Visible then SVRender:Disconnect() end
				local Mouse = UserInputService:GetMouseLocation()
				local ColorX = math.clamp(Mouse.X - PaletteAsset.SVPicker.AbsolutePosition.X,0,PaletteAsset.SVPicker.AbsoluteSize.X) / PaletteAsset.SVPicker.AbsoluteSize.X
				
				local ColorY = math.clamp(Mouse.Y - (PaletteAsset.SVPicker.AbsolutePosition.Y + 36),0,PaletteAsset.SVPicker.AbsoluteSize.Y) / PaletteAsset.SVPicker.AbsoluteSize.Y
				Colorpicker.HSVAR[2] = ColorX
				Colorpicker.HSVAR[3] = 1 - ColorY
				Update()
			end)
		end
	end)
	PaletteAsset.SVPicker.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if SVRender then
				SVRender:Disconnect()
			end
		end
	end)
	PaletteAsset.Hue.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if HueRender then
				HueRender:Disconnect()
			end
			HueRender = RunService.RenderStepped:Connect(function()
				if not PaletteAsset.Visible then HueRender:Disconnect() end
				local Mouse = UserInputService:GetMouseLocation()
				local ColorX = math.clamp(Mouse.X - PaletteAsset.Hue.AbsolutePosition.X,0,PaletteAsset.Hue.AbsoluteSize.X) / PaletteAsset.Hue.AbsoluteSize.X
				Colorpicker.HSVAR[1] = 1 - ColorX
				Update()
			end)
		end
	end)
	PaletteAsset.Hue.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if HueRender then
				HueRender:Disconnect()
			end
		end
	end)
	PaletteAsset.Alpha.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if AlphaRender then
				AlphaRender:Disconnect()
			end
			AlphaRender = RunService.RenderStepped:Connect(function()
				if not PaletteAsset.Visible then AlphaRender:Disconnect() end
				local Mouse = UserInputService:GetMouseLocation()
				local ColorX = math.clamp(Mouse.X - PaletteAsset.Alpha.AbsolutePosition.X,0,PaletteAsset.Alpha.AbsoluteSize.X) / PaletteAsset.Alpha.AbsoluteSize.X
				Colorpicker.HSVAR[4] = math.floor(ColorX * 10^2) / (10^2) -- idk %.2f little bit broken with this
				Update()
			end)
		end
	end)
	PaletteAsset.Alpha.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if AlphaRender then
				AlphaRender:Disconnect()
			end
		end
	end)

	function Colorpicker:SetName(Name)
		Colorpicker.Name = Name
		ColorpickerAsset.Title.Text = Name
	end
	function Colorpicker:SetCallback(Callback)
		Colorpicker.Callback = Callback
	end
	function Colorpicker:SetHSVAR(HSVAR)
		Colorpicker.HSVAR = HSVAR
		Update()
	end
	function Colorpicker:ToolTip(Text)
		InitToolTip(ColorpickerAsset,ScreenAsset,Text)
	end

	table.insert(Window.Colorable,PaletteAsset.Rainbow.Tick)
	PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.HSVAR[5] and Window.Color or Color3.fromRGB(60,60,60)
	PaletteAsset.Rainbow.MouseButton1Click:Connect(function()
		Colorpicker.HSVAR[5] = not Colorpicker.HSVAR[5]
		PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.HSVAR[5] and Window.Color or Color3.fromRGB(60,60,60)
	end)
	RunService.Heartbeat:Connect(function()
		if Colorpicker.HSVAR[5] then
			if PaletteAsset.Visible then
				Colorpicker.HSVAR[1] = Window.RainbowHue
				Update()
			else 
				local Color = TableToColor(Colorpicker.HSVAR)
				Colorpicker.HSVAR[1] = Window.RainbowHue
				ColorpickerAsset.Color.BackgroundColor3 = Color
				Window.Flags[Colorpicker.Flag] = Colorpicker.Color
				Colorpicker.Callback(Colorpicker.HSVAR,Color)
			end
		end
	end)

	PaletteAsset.RGB.RGBBox.FocusLost:Connect(function(Enter)
		if not Enter then return end
		local ColorString = string.split(string.gsub(PaletteAsset.RGB.RGBBox.Text," ",""),",")
		local Hue,Saturation,Value = Color3.fromRGB(ColorString[1],ColorString[2],ColorString[3]):ToHSV()
		PaletteAsset.RGB.RGBBox.Text = ""
		Colorpicker.HSVAR[1] = Hue
		Colorpicker.HSVAR[2] = Saturation
		Colorpicker.HSVAR[3] = Value
		Update()
	end)
	PaletteAsset.HEX.HEXBox.FocusLost:Connect(function(Enter)
		if not Enter then return end
		local Hue,Saturation,Value = Color3.fromHex("#" .. PaletteAsset.HEX.HEXBox.Text):ToHSV()
		PaletteAsset.RGB.RGBBox.Text = ""
		Colorpicker.HSVAR[1] = Hue
		Colorpicker.HSVAR[2] = Saturation
		Colorpicker.HSVAR[3] = Value
		Update()
	end)
end

local Bracket = InitScreen()
function Bracket:Window(Window)
	Window = GetType(Window,{},"table")
	Window.Name = GetType(Window.Name,"Window","string")
	Window.Color = GetType(Window.Color,Color3.new(1,0.5,0.25),"Color3")
	Window.Size = GetType(Window.Size,UDim2.new(0,496,0,496),"UDim2")
	Window.Position = GetType(Window.Position,UDim2.new(0.5,-248,0.5,-248),"UDim2")
	Window.Enabled = GetType(Window.Enabled,true,"boolean")
	
	Window.RainbowHue = 0
	Window.Colorable = {}
	Window.Flags = {}

	local WindowAsset = InitWindow(Bracket.ScreenAsset,Window)
	function Window:Tab(Tab)
		Tab = GetType(Tab,{},"table")
		Tab.Name = GetType(Tab.Name,"Tab","string")
		local ChooseTab = InitTab(Bracket.ScreenAsset,WindowAsset,Window,Tab)

		function Tab:Divider(Divider)
			Divider = GetType(Divider,{},"table")
			Divider.Text = GetType(Divider.Text,"","string")
			Divider.Side = GetType(Divider.Side,nil,"string")

			InitDivider(ChooseTab(Divider.Side),Divider)
			return Divider
		end
		function Tab:Label(Label)
			Label = GetType(Label,{},"table")
			Label.Text = GetType(Label.Text,"Label","string")
			Label.Side = GetType(Label.Side,nil,"string")

			InitLabel(ChooseTab(Label.Side),Label)
			return Label
		end
		function Tab:Button(Button)
			Button = GetType(Button,{},"table")
			Button.Name = GetType(Button.Name,"Button","string")
			Button.Side = GetType(Button.Side,nil,"string")

			Button.Callback = GetType(Button.Callback,function() end,"function")
			InitButton(ChooseTab(Button.Side),Bracket.ScreenAsset,Window,Button)
			return Button
		end
		function Tab:Toggle(Toggle)
			Toggle = GetType(Toggle,{},"table")
			Toggle.Name = GetType(Toggle.Name,"Toggle","string")
			Toggle.Side = GetType(Toggle.Side,nil,"string")
			Toggle.Value = GetType(Toggle.Value,false,"boolean")
			Toggle.Flag = GetType(Toggle.Flag,"Flag-" .. Toggle.Name,"string")
			Toggle.Callback = GetType(Toggle.Callback,function() end,"function")

			InitToggle(ChooseTab(Toggle.Side),Bracket.ScreenAsset,Window,Toggle)
			return Toggle
		end
		function Tab:Slider(Slider)
			Slider = GetType(Slider,{},"table")
			Slider.Name = GetType(Slider.Name,"Slider","string")
			Slider.Side = GetType(Slider.Side,nil,"string")

			Slider.Min = GetType(Slider.Min,0,"number")
			Slider.Max = GetType(Slider.Max,100,"number")
			Slider.Precise = GetType(Slider.Precise,0,"number")
			Slider.Unit = GetType(Slider.Unit,"","string")
			Slider.Value = GetType(Slider.Value,Slider.Max / 2,"number")
			Slider.Flag = GetType(Slider.Flag,"Flag-" .. Slider.Name,"string")
			Slider.Callback = GetType(Slider.Callback,function() end,"function")

			InitSlider(ChooseTab(Slider.Side),Bracket.ScreenAsset,Window,Slider)
			return Slider
		end
		function Tab:Textbox(Textbox)
			Textbox = GetType(Textbox,{},"table")
			Textbox.Name = GetType(Textbox.Name,"Textbox","string")
			Textbox.Side = GetType(Textbox.Side,nil,"string")

			Textbox.Text = GetType(Textbox.Text,"","string")
			Textbox.Placeholder = GetType(Textbox.Placeholder,"Input here","string")
			Textbox.Flag = GetType(Textbox.Flag,"Flag-" .. Textbox.Name,"string")
			--Textbox.NumbersOnly = GetType(Textbox.NumbersOnly,false,"boolean")
			Textbox.Callback = GetType(Textbox.Callback,function() end,"function")

			InitTextbox(ChooseTab(Textbox.Side),Bracket.ScreenAsset,Window,Textbox)
			return Textbox
		end
		function Tab:Keybind(Keybind)
			Keybind = GetType(Keybind,{},"table")
			Keybind.Name = GetType(Keybind.Name,"Keybind","string")
			Keybind.Side = GetType(Keybind.Side,nil,"string")

			Keybind.Key = GetType(Keybind.Key,"NONE","string")
			Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
			Keybind.Flag = GetType(Keybind.Flag,"Flag-" .. Keybind.Name,"string")
			Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
			Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")

			InitKeybind(ChooseTab(Keybind.Side),Bracket.ScreenAsset,Window,Keybind)
			return Keybind
		end
		function Tab:Dropdown(Dropdown)
			Dropdown = GetType(Dropdown,{},"table")
			Dropdown.Name = GetType(Dropdown.Name,"Dropdown","string")
			Dropdown.Side = GetType(Dropdown.Side,nil,"string")

			InitDropdown(ChooseTab(Dropdown.Side),Bracket.ScreenAsset,Window,Dropdown)
			return Dropdown
		end
		function Tab:Colorpicker(Colorpicker)
			Colorpicker = GetType(Colorpicker,{},"table")
			Colorpicker.Name = GetType(Colorpicker.Name,"Colorpicker","string")
			Colorpicker.Side = GetType(Colorpicker.Side,nil,"string")
			
			Colorpicker.HSVAR = GetType(Colorpicker.HSVAR,{1,1,1,0,false},"table")
			Colorpicker.Flag = GetType(Colorpicker.Flag,"Flag-" .. Colorpicker.Name,"string")
			Colorpicker.Callback = GetType(Colorpicker.Callback,function() end,"function")

			InitColorpicker(ChooseTab(Colorpicker.Side),Bracket.ScreenAsset,Window,Colorpicker)
			return Colorpicker
		end
		function Tab:Section(Section)
			Section = GetType(Section,{},"table")
			Section.Name = GetType(Section.Name,"Section","string")
			Section.Side = GetType(Section.Side,nil,"string")

			local SectionContainer = InitSection(ChooseTab(Section.Side),Section)
			function Section:Divider(Divider)
				Divider = GetType(Divider,{},"table")
				Divider.Text = GetType(Divider.Text,"","string")
				Divider.Side = GetType(Divider.Side,nil,"string")

				InitDivider(SectionContainer,Divider)
				return Divider
			end
			function Section:Label(Label)
				Label = GetType(Label,{},"table")
				Label.Text = GetType(Label.Text,"Label","string")
				Label.Side = GetType(Label.Side,nil,"string")

				InitLabel(SectionContainer,Label)
				return Label
			end
			function Section:Button(Button)
				Button = GetType(Button,{},"table")
				Button.Name = GetType(Button.Name,"Button","string")
				Button.Side = GetType(Button.Side,nil,"string")

				Button.Callback = GetType(Button.Callback,function() end,"function")
				InitButton(SectionContainer,Bracket.ScreenAsset,Window,Button)
				return Button
			end
			function Section:Toggle(Toggle)
				Toggle = GetType(Toggle,{},"table")
				Toggle.Name = GetType(Toggle.Name,"Toggle","string")
				Toggle.Side = GetType(Toggle.Side,nil,"string")
				Toggle.Value = GetType(Toggle.Value,false,"boolean")
				Toggle.Flag = GetType(Toggle.Flag,"Flag-" .. Toggle.Name,"string")
				Toggle.Callback = GetType(Toggle.Callback,function() end,"function")

				InitToggle(SectionContainer,Bracket.ScreenAsset,Window,Toggle)
				return Toggle
			end
			function Section:Slider(Slider)
				Slider = GetType(Slider,{},"table")
				Slider.Name = GetType(Slider.Name,"Slider","string")
				Slider.Side = GetType(Slider.Side,nil,"string")

				Slider.Min = GetType(Slider.Min,0,"number")
				Slider.Max = GetType(Slider.Max,100,"number")
				Slider.Precise = GetType(Slider.Precise,0,"number")
				Slider.Unit = GetType(Slider.Unit,"","string")
				Slider.Value = GetType(Slider.Value,Slider.Max / 2,"number")
				Slider.Flag = GetType(Slider.Flag,"Flag-" .. Slider.Name,"string")
				Slider.Callback = GetType(Slider.Callback,function() end,"function")

				InitSlider(SectionContainer,Bracket.ScreenAsset,Window,Slider)
				return Slider
			end
			function Section:Textbox(Textbox)
				Textbox = GetType(Textbox,{},"table")
				Textbox.Name = GetType(Textbox.Name,"Textbox","string")
				Textbox.Side = GetType(Textbox.Side,nil,"string")

				Textbox.Text = GetType(Textbox.Text,"","string")
				Textbox.Placeholder = GetType(Textbox.Placeholder,"Input here","string")
				Textbox.Flag = GetType(Textbox.Flag,"Flag-" .. Textbox.Name,"string")
				--Textbox.NumbersOnly = GetType(Textbox.NumbersOnly,false,"boolean")
				Textbox.Callback = GetType(Textbox.Callback,function() end,"function")

				InitTextbox(SectionContainer,Bracket.ScreenAsset,Window,Textbox)
				return Textbox
			end
			function Section:Keybind(Keybind)
				Keybind = GetType(Keybind,{},"table")
				Keybind.Name = GetType(Keybind.Name,"Keybind","string")
				Keybind.Side = GetType(Keybind.Side,nil,"string")

				Keybind.Key = GetType(Keybind.Key,"NONE","string")
				Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
				Keybind.Flag = GetType(Keybind.Flag,"Flag-" .. Keybind.Name,"string")
				Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
				Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")

				InitKeybind(SectionContainer,Bracket.ScreenAsset,Window,Keybind)
				return Keybind
			end
			function Section:Dropdown(Dropdown)
				Dropdown = GetType(Dropdown,{},"table")
				Dropdown.Name = GetType(Dropdown.Name,"Dropdown","string")
				Dropdown.Side = GetType(Dropdown.Side,nil,"string")

				InitDropdown(SectionContainer,Bracket.ScreenAsset,Window,Dropdown)
				return Dropdown
			end
			function Section:Colorpicker(Colorpicker)
				Colorpicker = GetType(Colorpicker,{},"table")
				Colorpicker.Name = GetType(Colorpicker.Name,"Colorpicker","string")
				Colorpicker.Side = GetType(Colorpicker.Side,nil,"string")

				Colorpicker.HSVAR = GetType(Colorpicker.HSVAR,{1,1,1,0,false},"table")
				Colorpicker.Flag = GetType(Colorpicker.Flag,"Flag-" .. Colorpicker.Name,"string")
				Colorpicker.Callback = GetType(Colorpicker.Callback,function() end,"function")

				InitColorpicker(SectionContainer,Bracket.ScreenAsset,Window,Colorpicker)
				return Colorpicker
			end
			return Section
		end
		return Tab
	end
	return Window
end

function Bracket:Notification(Notification)
	Notification = GetType(Notification,{},"table")
	Notification.Title = GetType(Notification.Title,"Title","string")
	Notification.Description = GetType(Notification.Description,"Description","string")

	local NotificationAsset = GetAsset("Notification","ND")
	NotificationAsset.Parent = Bracket.ScreenAsset.NDHandle
	NotificationAsset.Title.Text = Notification.Title
	NotificationAsset.Description.Text = Notification.Description
	NotificationAsset.Title.Size = UDim2.new(1,0,0,NotificationAsset.Title.TextBounds.Y)
	NotificationAsset.Description.Size = UDim2.new(1,0,0,NotificationAsset.Description.TextBounds.Y)
	NotificationAsset.Size = UDim2.new(
		0,GetLongest(
			NotificationAsset.Title.TextBounds.X,
			NotificationAsset.Description.TextBounds.X
		) + 24,
		0,NotificationAsset.ListLayout.AbsoluteContentSize.Y + 8
	)

	if Notification.Duration then
		coroutine.wrap(function()
			for Time = Notification.Duration,1,-1 do
				NotificationAsset.Title.Close.Text = Time
				task.wait(1)
			end
			NotificationAsset.Title.Close.Text = 0

			if Notification.Callback then
				Notification.Callback()
			end
			NotificationAsset:Destroy()
		end)()
	else
		NotificationAsset.Title.Close.MouseButton1Click:Connect(function()
			NotificationAsset:Destroy()
		end)
	end
end

function Bracket:Notification2(Notification)
	Notification = GetType(Notification,{},"table")
	Notification.Title = GetType(Notification.Title,"Title","string")
	Notification.Color = GetType(Notification.Color,Color3.new(1,0.5,0.25),"Color3")

	local NotificationAsset = GetAsset("Notification","NL")
	NotificationAsset.Parent = Bracket.ScreenAsset.NLHandle
	NotificationAsset.Main.Title.Text = Notification.Title
	NotificationAsset.Main.GLine.BackgroundColor3 = Notification.Color
	NotificationAsset.Main.Size = UDim2.new(
		0,NotificationAsset.Main.Title.TextBounds.X + 10,
		0,NotificationAsset.Main.Title.TextBounds.Y + 6
	)
	NotificationAsset.Size = UDim2.new(
		0,0,0,NotificationAsset.Main.Size.Y.Offset + 4
	)
	
	NotificationAsset:TweenSize(
		UDim2.new(
			0,NotificationAsset.Main.Size.X.Offset + 4,
			0,NotificationAsset.Main.Size.Y.Offset + 4
		),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		0.25,
		false,
		coroutine.wrap(function()
			task.wait(Notification.Duration or 5)
			NotificationAsset:TweenSize(
				UDim2.new(
					0,0,0,NotificationAsset.Main.Size.Y.Offset + 4
				),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				0.25,
				false,
				function()
					if Notification.Callback then
						Notification.Callback()
					end
					NotificationAsset:Destroy()
				end
			)
		end)
	)
end

function Bracket:Watermark(Watermark)
	Watermark = GetType(Watermark,{},"table")
	Watermark.Title = GetType(Watermark.Title,"Title","string")
	Watermark.Enabled = GetType(Watermark.Enabled,false,"boolean")

	Bracket.ScreenAsset.Watermark.Visible = Watermark.Enabled
	Bracket.ScreenAsset.Watermark.Title.Text = Watermark.Title
	Bracket.ScreenAsset.Watermark.Size = UDim2.new(0,Bracket.ScreenAsset.Watermark.Title.TextBounds.X + 10,0,Bracket.ScreenAsset.Watermark.Title.TextBounds.Y + 10)
end

return Bracket
