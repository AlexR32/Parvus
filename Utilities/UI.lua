local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Debug,Assets,LocalPlayer = false,{},PlayerService.LocalPlayer
local MainAssetFolder = Debug and ReplicatedStorage.BracketV33
	or InsertService:LoadLocalAsset("rbxassetid://10827276896")

local function GetAsset(AssetPath)
	AssetPath = AssetPath:split("/")
	local Asset = MainAssetFolder
	for Index,Name in pairs(AssetPath) do
		Asset = Asset[Name]
	end return Asset:Clone()
end
local function GetLongest(A,B)
	return A > B and A or B
end
local function GetType(Object,Default,Type)
	if typeof(Object) == Type then
		return Object
	end
	return Default
end

local function MakeDraggable(Dragger,Object,Callback)
	local StartPosition,StartDrag = nil,nil
	Dragger.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartPosition = UserInputService:GetMouseLocation()
			StartDrag = Object.AbsolutePosition
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
			StartPosition,StartDrag = nil,nil
			Callback(Object.Position)
		end
	end)
end

local function MakeResizeable(Dragger,Object,MinSize,Callback)
	local StartPosition,StartSize = nil,nil
	Dragger.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartPosition = UserInputService:GetMouseLocation()
			StartSize = Object.AbsoluteSize
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if StartPosition and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local Mouse = UserInputService:GetMouseLocation()
			local Delta = Mouse - StartPosition

			local Size = StartSize + Delta
			local SizeX = math.max(MinSize.X,Size.X)
			local SizeY = math.max(MinSize.Y,Size.Y)
			Object.Size = UDim2.fromOffset(SizeX,SizeY)
		end
	end)
	Dragger.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			StartPosition,StartSize = nil,nil
			Callback(Object.Size)
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

local function GetConfigs(FolderName)
	if not isfolder(FolderName) then makefolder(FolderName) end
	if not isfolder(FolderName.."\\Configs") then makefolder(FolderName.."\\Configs") end
	if not isfile(FolderName.."\\DefaultConfig.txt") then writefile(FolderName.."\\DefaultConfig.txt","") end

	local Configs = {}
	for Index,Config in pairs(listfiles(FolderName.."\\Configs") or {}) do
		Config = Config:gsub(FolderName.."\\Configs\\","")
		Config = Config:gsub(".json","")
		Configs[#Configs + 1] = Config
	end
	return Configs
end
local function ConfigsToList(FolderName)
	if not isfolder(FolderName) then makefolder(FolderName) end
	if not isfolder(FolderName.."\\Configs") then makefolder(FolderName.."\\Configs") end
	if not isfile(FolderName.."\\DefaultConfig.txt") then writefile(FolderName.."\\DefaultConfig.txt","") end

	local Configs = {}
	local DefaultConfig = readfile(FolderName.."\\DefaultConfig.txt")
	for Index,Config in pairs(listfiles(FolderName.."\\Configs") or {}) do
		Config = Config:gsub(FolderName.."\\Configs\\","")
		Config = Config:gsub(".json","")
		Configs[#Configs + 1] = {
			Name = Config,Mode = "Button",
			Value = Config == DefaultConfig
		}
	end
	return Configs
end

function Assets:Screen()
	local ScreenAsset = GetAsset("Screen/Bracket")
	if not Debug then sethiddenproperty(ScreenAsset,"OnTopOfCoreBlur",true) end
	ScreenAsset.Name = "Bracket " .. game:GetService("HttpService"):GenerateGUID(false)
	ScreenAsset.Parent = Debug and LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
	--[[if Debug then
		ScreenAsset.Parent = LocalPlayer.PlayerGui
	else
		Parvus.Utilities.Misc:HideObject(ScreenAsset)
	end]]
	return {ScreenAsset = ScreenAsset}
end
function Assets:Window(ScreenAsset,Window)
	local WindowAsset = GetAsset("Window/Window")

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

	local ParticleEmitter = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/AlexR32/rParticle/master/src/ParticleEmitter/init.lua"))()
	local snowflake = ParticleEmitter.new(WindowAsset.Background,WindowAsset.Snowflake)
	local random = Random.new() snowflake.rate = 20

	snowflake.onSpawn = function(particle)
		local randomPosition = random:NextNumber()
		local randomSize = random:NextInteger(10,50)
		local randomYVelocity = random:NextInteger(10,50)
		local randomXVelocity = random:NextInteger(-50,50)

		particle.element.ImageTransparency = randomSize / 50
		particle.element.Size = UDim2.fromOffset(randomSize,randomSize)
		particle.velocity = Vector2.new(randomXVelocity,randomYVelocity)
		particle.position = Vector2.new(randomPosition * WindowAsset.Background.AbsoluteSize.X,0)
		particle.maxAge = 50 particle.element.Visible = true
	end

	snowflake.onUpdate = function(particle,deltaTime)
		particle.position += particle.velocity * deltaTime
	end

	WindowAsset.TabButtonContainer.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		WindowAsset.TabButtonContainer.CanvasSize = UDim2.new(0,WindowAsset.TabButtonContainer.ListLayout.AbsoluteContentSize.X,0,0)
	end)
	RunService.RenderStepped:Connect(function()
		if WindowAsset.Visible then
			ScreenAsset.ToolTip.Position = UDim2.new(0,UserInputService:GetMouseLocation().X + 5,0,UserInputService:GetMouseLocation().Y - 5)
		end
	end)
	RunService.RenderStepped:Connect(function()
		Window.RainbowHue = os.clock()%10/10
		--[[if Window.RainbowHue < 1 then
			Window.RainbowHue = Window.RainbowHue + 0.001
		else
			Window.RainbowHue = 0
		end]]
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
	function Window:SetColor(Color)
		if Color.R < 5/255
			and Color.G < 5/255
			and Color.B < 5/255 then
			Color = Color3.fromRGB(5,5,5)
		end

		for Index,Instance in pairs(Window.Colorable) do
			if Instance.BackgroundColor3 == Window.Color then
				Instance.BackgroundColor3 = Color
			end
			if Instance.BorderColor3 == Window.Color then
				Instance.BorderColor3 = Color
			end
		end
		Window.Color = Color
	end
	function Window:Toggle(Boolean)
		Window.Enabled = Boolean
		WindowAsset.Visible = Window.Enabled

		if not Debug  then
			RunService:SetRobloxGuiFocused(Window.Enabled and Window.Flags["UI/Blur"]) end
		if not Window.Enabled then for Index,Instance in pairs(ScreenAsset:GetChildren()) do
				if Instance.Name == "Palette" or Instance.Name == "OptionContainer" then
					Instance.Visible = false
				end
			end end
	end

	function Window:SetValue(Flag,Value)
		for Index,Element in pairs(Window.Elements) do
			if Element.Flag == Flag then
				Element:SetValue(Value)
			end
		end
	end

	function Window:GetValue(Flag)
		for Index,Element in pairs(Window.Elements) do
			if Element.Flag == Flag then
				return Window.Flags[Element.Flag]
			end
		end
	end

	function Window:Watermark(Watermark)
		Watermark = GetType(Watermark,{},"table")
		Watermark.Title = GetType(Watermark.Title,"","string")
		Watermark.Enabled = GetType(Watermark.Enabled,false,"boolean")
		Watermark.Flag = GetType(Watermark.Flag,"UI/Watermark/Position","string")

		ScreenAsset.Watermark.Visible = Watermark.Enabled
		ScreenAsset.Watermark.Text = Watermark.Title
		ScreenAsset.Watermark.Position = UDim2.new(0.95,0,0,10)
		ScreenAsset.Watermark.Size = UDim2.new(
			0,ScreenAsset.Watermark.TextBounds.X + 6,
			0,ScreenAsset.Watermark.TextBounds.Y + 6)
		MakeDraggable(ScreenAsset.Watermark,ScreenAsset.Watermark,function(Position)
			Window.Flags[Watermark.Flag] = 
				{Position.X.Scale,Position.X.Offset,
					Position.Y.Scale,Position.Y.Offset}
		end)

		function Watermark:Toggle(Boolean)
			Watermark.Enabled = Boolean
			ScreenAsset.Watermark.Visible = Watermark.Enabled
		end
		function Watermark:Transparency(Number)
			ScreenAsset.Watermark.BackgroundTransparency = Number
			ScreenAsset.Watermark.Stroke.Transparency = Number
			ScreenAsset.Watermark.TextTransparency = Number
		end
		function Watermark:SetTitle(Text)
			Watermark.Title = Text
			ScreenAsset.Watermark.Text = Watermark.Title
			ScreenAsset.Watermark.Size = UDim2.new(0,ScreenAsset.Watermark.TextBounds.X + 6,0,ScreenAsset.Watermark.TextBounds.Y + 6)
		end
		function Watermark:SetValue(Table)
			if not Table then return end
			ScreenAsset.Watermark.Position = UDim2.new(
				Table[1],Table[2],
				Table[3],Table[4]
			)
		end

		Window.Elements[#Window.Elements + 1] = Watermark
		Window.Watermark = Watermark
	end

	function Window:SaveConfig(FolderName,Name)
		local Config = {}
		--[[if table.find(GetConfigs(FolderName),Name) then
			Config = HttpService:JSONDecode(readfile(FolderName.."\\Configs\\"..Name..".json"))
		end]]
		for Index,Element in pairs(Window.Elements) do
			if not Element.IgnoreFlag then
				Config[Element.Flag] = Window.Flags[Element.Flag]
			end
		end
		writefile(
			FolderName.."\\Configs\\"..Name..".json",
			HttpService:JSONEncode(Config)
		)
	end
	function Window:LoadConfig(FolderName,Name)
		if table.find(GetConfigs(FolderName),Name) then
			local DecodedJSON = HttpService:JSONDecode(readfile(FolderName.."\\Configs\\"..Name..".json"))
			for Index,Element in pairs(Window.Elements) do
				local Value = DecodedJSON[Element.Flag]
				if Value ~= nil then Element:SetValue(Value) end
			end
		end
	end
	function Window:DeleteConfig(FolderName,Name)
		if table.find(GetConfigs(FolderName),Name) then
			delfile(FolderName.."\\Configs\\"..Name..".json")
		end
	end
	function Window:GetDefaultConfig(FolderName)
		if not isfolder(FolderName) then makefolder(FolderName) end
		if not isfolder(FolderName.."\\Configs") then makefolder(FolderName.."\\Configs") end
		if not isfile(FolderName.."\\DefaultConfig.txt") then writefile(FolderName.."\\DefaultConfig.txt","") end

		local DefaultConfig = readfile(FolderName.."\\DefaultConfig.txt")
		if table.find(GetConfigs(FolderName),DefaultConfig) then return DefaultConfig end
	end
	function Window:LoadDefaultConfig(FolderName)
		if not isfolder(FolderName) then makefolder(FolderName) end
		if not isfolder(FolderName.."\\Configs") then makefolder(FolderName.."\\Configs") end
		if not isfile(FolderName.."\\DefaultConfig.txt") then writefile(FolderName.."\\DefaultConfig.txt","") end

		local DefaultConfig = readfile(FolderName.."\\DefaultConfig.txt")
		if table.find(GetConfigs(FolderName),DefaultConfig) then
			Window:LoadConfig(FolderName,DefaultConfig)
		end
	end

	Window.Background = WindowAsset.Background
	return WindowAsset
end
function Assets:Tab(ScreenAsset,WindowAsset,Window,Tab)
	local TabButtonAsset = GetAsset("Tab/TabButton")
	local TabAsset = GetAsset("Tab/Tab")

	TabButtonAsset.Parent = WindowAsset.TabButtonContainer
	TabButtonAsset.Text = Tab.Name
	TabButtonAsset.Highlight.BackgroundColor3 = Window.Color
	TabButtonAsset.Size = UDim2.new(0,TabButtonAsset.TextBounds.X + 12,1,-1)
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
		TabButtonAsset.Size = UDim2.new(0,TabButtonAsset.TextBounds.X + 6,1,-1)
	end

	return function(Side)
		return ChooseTabSide(TabAsset,Side)
	end
end
function Assets:Section(Parent,Section)
	local SectionAsset = GetAsset("Section/Section")

	SectionAsset.Parent = Parent
	SectionAsset.Title.Text = Section.Name
	SectionAsset.Title.Size = UDim2.new(0,SectionAsset.Title.TextBounds.X + 6,0,2)

	SectionAsset.Container.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		SectionAsset.Size = UDim2.new(1,0,0,SectionAsset.Container.ListLayout.AbsoluteContentSize.Y + 15)
	end)

	function Section:SetName(Name)
		Section.Name = Name
		SectionAsset.Title.Text = Name
		SectionAsset.Title.Size = UDim2.new(0,Section.Title.TextBounds.X + 6,0,2)
	end

	return SectionAsset.Container
end
function Assets:ToolTip(Parent,ScreenAsset,Text)
	Parent.MouseEnter:Connect(function()
		ScreenAsset.ToolTip.Text = Text
		ScreenAsset.ToolTip.Size = UDim2.new(0,ScreenAsset.ToolTip.TextBounds.X + 6,0,ScreenAsset.ToolTip.TextBounds.Y + 6)
		ScreenAsset.ToolTip.Visible = true
	end)
	Parent.MouseLeave:Connect(function()
		ScreenAsset.ToolTip.Visible = false
	end)
end
function Assets:Divider(Parent,Divider)
	local DividerAsset = GetAsset("Divider/Divider")

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
		DividerAsset.Title.Text = Text
	end
end
function Assets:Label(Parent,Label)
	local LabelAsset = GetAsset("Label/Label")

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
function Assets:Button(Parent,ScreenAsset,Window,Button)
	local ButtonAsset = GetAsset("Button/Button")

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
		ButtonAsset.Size = UDim2.new(1,0,0,ButtonAsset.Title.TextBounds.Y + 2)
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
		Assets:ToolTip(ButtonAsset,ScreenAsset,Text)
	end
end
function Assets:Toggle(Parent,ScreenAsset,Window,Toggle)
	local ToggleAsset = GetAsset("Toggle/Toggle")

	ToggleAsset.Parent = Parent
	ToggleAsset.Title.Text = Toggle.Name
	ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)

	table.insert(Window.Colorable,ToggleAsset.Tick)
	ToggleAsset.MouseButton1Click:Connect(function()
		Toggle.Value = not Toggle.Value
		Window.Flags[Toggle.Flag] = Toggle.Value
		Toggle.Callback(Toggle.Value)
		ToggleAsset.Tick.BackgroundColor3 = Toggle.Value and Window.Color or Color3.fromRGB(60,60,60)
	end)
	ToggleAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		ToggleAsset.Size = UDim2.new(1,0,0,ToggleAsset.Title.TextBounds.Y)
		ToggleAsset.Layout.Size = UDim2.new(1,-ToggleAsset.Title.TextBounds.X - 21,1,0)
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
		Assets:ToolTip(ToggleAsset,ScreenAsset,Text)
	end

	return ToggleAsset
end
function Assets:Slider(Parent,ScreenAsset,Window,Slider)
	local SliderAsset = GetAsset("Slider/Slider")

	SliderAsset.Parent = Parent
	SliderAsset.Title.Text = Slider.Name
	Slider.Value = tonumber(string.format("%." .. Slider.Precise .. "f",Slider.Value))
	SliderAsset.Background.Bar.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min),0,1,0)
	SliderAsset.Background.Bar.BackgroundColor3 = Window.Color
	table.insert(Window.Colorable,SliderAsset.Background.Bar)

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
		Assets:ToolTip(SliderAsset,ScreenAsset,Text)
	end

	SliderAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		SliderAsset.Value.Size = UDim2.new(0,SliderAsset.Value.TextBounds.X,0,16)
		SliderAsset.Title.Size = UDim2.new(1,-SliderAsset.Value.Size.X.Offset,0,16)
		SliderAsset.Size = UDim2.new(1,0,0,SliderAsset.Title.TextBounds.Y + 8)
	end)
	SliderAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		SliderAsset.Value.Size = UDim2.new(0,SliderAsset.Value.TextBounds.X,0,16)
		SliderAsset.Title.Size = UDim2.new(1,-SliderAsset.Value.Size.X.Offset,0,16)
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
function Assets:HighSlider(Parent,ScreenAsset,Window,Slider)
	local SliderAsset = GetAsset("Slider/HighSlider")

	SliderAsset.Parent = Parent
	SliderAsset.Title.Text = Slider.Name
	Slider.Value = tonumber(string.format("%." .. Slider.Precise .. "f",Slider.Value))
	SliderAsset.Background.Bar.Size = UDim2.new((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min),0,1,0)
	SliderAsset.Background.Bar.BackgroundColor3 = Window.Color
	table.insert(Window.Colorable,SliderAsset.Background.Bar)

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
		Assets:ToolTip(SliderAsset,ScreenAsset,Text)
	end

	SliderAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		SliderAsset.Value.Size = UDim2.new(0,SliderAsset.Value.TextBounds.X,1,0)
		SliderAsset.Title.Size = UDim2.new(1,-SliderAsset.Value.Size.X.Offset+10,1,0)
		SliderAsset.Size = UDim2.new(1,0,0,SliderAsset.Title.TextBounds.Y + 2)
	end)
	SliderAsset.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		SliderAsset.Value.Size = UDim2.new(0,SliderAsset.Value.TextBounds.X,1,0)
		SliderAsset.Title.Size = UDim2.new(1,-SliderAsset.Value.Size.X.Offset+10,1,0)
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
function Assets:Textbox(Parent,ScreenAsset,Window,Textbox)
	local TextboxAsset = GetAsset("Textbox/Textbox")

	TextboxAsset.Parent = Parent
	TextboxAsset.Title.Text = Textbox.Name
	TextboxAsset.Background.Input.Text = Textbox.Value
	TextboxAsset.Background.Input.PlaceholderText = Textbox.Placeholder

	TextboxAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		TextboxAsset.Size = UDim2.new(1,0,0,(TextboxAsset.Title.TextBounds.Y + 2) + (TextboxAsset.Background.Input.TextBounds.Y + 2))
	end)
	TextboxAsset.Background.Input:GetPropertyChangedSignal("TextBounds"):Connect(function()
		TextboxAsset.Background.Size = UDim2.new(1,0,0,TextboxAsset.Background.Input.TextBounds.Y + 2)
	end)
	TextboxAsset.Background.Input.FocusLost:Connect(function(EnterPressed)
		Textbox.Value = TextboxAsset.Background.Input.Text
		Window.Flags[Textbox.Flag] = Textbox.Value
		if Textbox.AutoClear then TextboxAsset.Background.Input.Text = "" end
		if EnterPressed then Textbox.Callback(Textbox.Value) end
	end)

	function Textbox:SetName(Name)
		Textbox.Name = Name
		TextboxAsset.Title.Text = Name
	end
	function Textbox:SetValue(Text)
		Textbox.Value = Text
		Window.Flags[Textbox.Flag] = Textbox.Value
		TextboxAsset.Background.Input.Text = Textbox.Value
		Textbox.Callback(Textbox.Value)
	end
	function Textbox:SetPlaceholder(Text)
		Textbox.Placeholder = Text
		TextboxAsset.Background.Input.PlaceholderText = Textbox.Placeholder
	end
	function Textbox:ChangeCallback(Callback)
		Textbox.Callback = Callback
	end
	function Textbox:ToolTip(Text)
		Assets:ToolTip(TextboxAsset,ScreenAsset,Text)
	end
end
function Assets:Keybind(Parent,ScreenAsset,Window,Keybind)
	local KeybindAsset = GetAsset("Keybind/Keybind")

	KeybindAsset.Parent = Parent
	KeybindAsset.Title.Text = Keybind.Name
	KeybindAsset.Value.Text = "[ " .. Keybind.Value .. " ]"
	Keybind.WaitingForBind = false

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
				KeybindAsset.Value.Text = "[ " .. Key .. " ]"
				Keybind.Value = Key
			else
				if Keybind.DoNotClear then
					KeybindAsset.Value.Text = "[ " .. Keybind.Value .. " ]"
				else
					KeybindAsset.Value.Text = "[ NONE ]"
					Keybind.Value = "NONE"
				end
			end

			Keybind.WaitingForBind = false
			Window.Flags[Keybind.Flag] = Keybind.Value
			Keybind.Callback(Keybind.Value,false,Keybind.Toggle)
		elseif Input.UserInputType == Enum.UserInputType.Keyboard then
			if Key == Keybind.Value then
				Keybind.Toggle = not Keybind.Toggle
				Keybind.Callback(Keybind.Value,true,Keybind.Toggle)
			end
		end
		if Keybind.Mouse then
			local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
			if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton1
				or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton2
				or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton3 then
				KeybindAsset.Value.Text = "[ " .. Key .. " ]"

				Keybind.Value = Key
				Keybind.WaitingForBind = false
				Window.Flags[Keybind.Flag] = Keybind.Value
				Keybind.Callback(Keybind.Value,false,Keybind.Toggle)
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.MouseButton2
				or Input.UserInputType == Enum.UserInputType.MouseButton3 then

				if Key == Keybind.Value then
					Keybind.Toggle = not Keybind.Toggle
					Keybind.Callback(Keybind.Value,true,Keybind.Toggle)
				end
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(Input)
		local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			if Key == Keybind.Value then
				Keybind.Callback(Keybind.Value,false,Keybind.Toggle)
			end
		end
		if Keybind.Mouse then
			local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
			if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.MouseButton2
				or Input.UserInputType == Enum.UserInputType.MouseButton3 then

				if Key == Keybind.Value then
					Keybind.Callback(Keybind.Value,false,Keybind.Toggle)
				end
			end
		end
	end)


	function Keybind:SetName(Name)
		Keybind.Name = Name
		KeybindAsset.Title.Text = Name
	end
	function Keybind:SetValue(Key)
		KeybindAsset.Value.Text = "[ " .. tostring(Key) .. " ]"
		Keybind.Value = Key
		Keybind.WaitingForBind = false
		Window.Flags[Keybind.Flag] = Keybind.Value
		Keybind.Callback(Keybind.Value,false,Keybind.Toggle)
	end
	function Keybind:SetCallback(Callback)
		Keybind.Callback = Callback
	end
	function Keybind:ToolTip(Text)
		Assets:ToolTip(KeybindAsset,ScreenAsset,Text)
	end
end
function Assets:ToggleKeybind(Parent,ScreenAsset,Window,Keybind,Toggle)
	local KeybindAsset = GetAsset("Keybind/TKeybind")

	KeybindAsset.Parent = Parent.Layout
	KeybindAsset.Text = "[ " .. Keybind.Value .. " ]"
	Keybind.WaitingForBind = false

	KeybindAsset.MouseButton1Click:Connect(function()
		KeybindAsset.Text = "[ ... ]"
		Keybind.WaitingForBind = true
	end)
	KeybindAsset:GetPropertyChangedSignal("TextBounds"):Connect(function()
		KeybindAsset.Size = UDim2.new(0,KeybindAsset.TextBounds.X,1,0)
	end)
	UserInputService.InputBegan:Connect(function(Input)
		local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
		if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.Keyboard then
			if not table.find(Keybind.Blacklist,Key) then
				KeybindAsset.Text = "[ " .. Key .. " ]"
				Keybind.Value = Key
			else
				if Keybind.DoNotClear then
					KeybindAsset.Text = "[ " .. Keybind.Value .. " ]"
				else
					KeybindAsset.Text = "[ NONE ]"
					Keybind.Value = "NONE"
				end
			end

			Keybind.WaitingForBind = false
			Window.Flags[Keybind.Flag] = Keybind.Value
			Keybind.Callback(Keybind.Value,false,Toggle.Value)
		elseif Input.UserInputType == Enum.UserInputType.Keyboard then
			if Key == Keybind.Value then
				Toggle:SetValue(not Toggle.Value)
				Keybind.Callback(Keybind.Value,true,Toggle.Value)
			end
		end
		if Keybind.Mouse then
			local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
			if Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton1
				or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton2
				or Keybind.WaitingForBind and Input.UserInputType == Enum.UserInputType.MouseButton3 then
				KeybindAsset.Text = "[ " .. Key .. " ]"

				Keybind.Value = Key
				Keybind.WaitingForBind = false
				Window.Flags[Keybind.Flag] = Keybind.Value
				Keybind.Callback(Keybind.Value,false,Toggle.Value)
			elseif Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.MouseButton2
				or Input.UserInputType == Enum.UserInputType.MouseButton3 then

				if Key == Keybind.Value then
					Toggle:SetValue(not Toggle.Value)
					Keybind.Callback(Keybind.Value,true,Toggle.Value)
				end
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(Input)
		local Key = tostring(Input.KeyCode):gsub("Enum.KeyCode.","")
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			if Key == Keybind.Value then
				Keybind.Callback(Keybind.Value,false,Toggle.Value)
			end
		end
		if Keybind.Mouse then
			local Key = tostring(Input.UserInputType):gsub("Enum.UserInputType.","")
			if Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.MouseButton2
				or Input.UserInputType == Enum.UserInputType.MouseButton3 then

				if Key == Keybind.Value then
					Keybind.Callback(Keybind.Value,false,Toggle.Value)
				end
			end
		end
	end)

	function Keybind:SetValue(Key)
		KeybindAsset.Text = "[ " .. tostring(Key) .. " ]"
		Keybind.Value = Key
		Keybind.WaitingForBind = false
		Window.Flags[Keybind.Flag] = Keybind.Value
		Keybind.Callback(Keybind.Value,false,Toggle.Value)
	end
	function Keybind:SetCallback(Callback)
		Keybind.Callback = Callback
	end
end
function Assets:Dropdown(Parent,ScreenAsset,Window,Dropdown)
	local DropdownAsset = GetAsset("Dropdown/Dropdown")
	local OptionContainerAsset = GetAsset("Dropdown/OptionContainer")
	DropdownAsset.Parent = Parent
	DropdownAsset.Title.Text = Dropdown.Name
	OptionContainerAsset.Parent = ScreenAsset
	local ContainerRender = nil

	DropdownAsset.MouseButton1Click:Connect(function()
		if not OptionContainerAsset.Visible and OptionContainerAsset.ListLayout.AbsoluteContentSize.Y ~= 0 then
			ContainerRender = RunService.RenderStepped:Connect(function()
				if not OptionContainerAsset.Visible then ContainerRender:Disconnect() end
				OptionContainerAsset.Position = UDim2.new(0,DropdownAsset.Background.AbsolutePosition.X,0,
					DropdownAsset.Background.AbsolutePosition.Y + DropdownAsset.Background.AbsoluteSize.Y + 42)
				OptionContainerAsset.Size = UDim2.new(0,DropdownAsset.Background.AbsoluteSize.X,0,OptionContainerAsset.ListLayout.AbsoluteContentSize.Y + 2)
			end)
			OptionContainerAsset.Visible = true
		else
			if ContainerRender then
				ContainerRender:Disconnect()
			end
			OptionContainerAsset.Visible = false
		end
	end)
	DropdownAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		DropdownAsset.Title.Size = UDim2.new(1,0,0,DropdownAsset.Title.TextBounds.Y + 2)
		DropdownAsset.Background.Position = UDim2.new(0.5,0,0,DropdownAsset.Title.Size.Y.Offset)
		DropdownAsset.Size = UDim2.new(1,0,0,DropdownAsset.Title.Size.Y.Offset + DropdownAsset.Background.Size.Y.Offset)
	end)
	--[[DropdownAsset.Background.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		DropdownAsset.Background.Size = UDim2.new(1,0,0,DropdownAsset.Background.Value.TextBounds.Y + 2)
		DropdownAsset.Size = UDim2.new(1,0,0,DropdownAsset.Title.Size.Y.Offset + DropdownAsset.Background.Size.Y.Offset)
	end)]]

	local function SetOptionState(Option,Toggle)
		local Selected = {}

		-- Value Setting
		if Option.Mode == "Button" then
			for Index, Option in pairs(Dropdown.List) do
				if Option.Mode == "Button" then
					if Option.Instance then
						Option.Instance.Tick.BackgroundColor3 = Color3.fromRGB(60,60,60)
					end
					Option.Value = false
				end
			end
			Option.Value = true
			OptionContainerAsset.Visible = false
		elseif Option.Mode == "Toggle" then
			Option.Value = Toggle
		end

		Option.Instance.Tick.BackgroundColor3 = Option.Value
			and Window.Color or Color3.fromRGB(60,60,60)

		-- Selected Setting
		for Index, Option in pairs(Dropdown.List) do
			if Option.Value then
				Selected[#Selected + 1] = Option.Name
			end
		end

		-- Dropdown Title Setting
		if #Selected == 0 then
			DropdownAsset.Background.Value.Text = "..."
		else
			DropdownAsset.Background.Value.Text = table.concat(Selected,", ")
		end

		Dropdown.Value = Selected
		if Option.Callback then
			Option.Callback(Dropdown.Value,Option)
		end
		Window.Flags[Dropdown.Flag] = Dropdown.Value
	end

	for Index, Option in pairs(Dropdown.List) do
		local OptionAsset = GetAsset("Dropdown/Option")
		OptionAsset.Parent = OptionContainerAsset
		OptionAsset.Title.Text = Option.Name
		Option.Instance = OptionAsset

		table.insert(Window.Colorable, OptionAsset.Tick)
		OptionAsset.MouseButton1Click:Connect(function()
			SetOptionState(Option,not Option.Value)
		end)
		OptionAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
			OptionAsset.Size = UDim2.new(1,0,0,OptionAsset.Title.TextBounds.Y + 2)
			OptionAsset.Layout.Size = UDim2.new(1,-OptionAsset.Title.TextBounds.X - 22,1,0)
		end)

		for Index,Value in pairs(Option) do
			if string.find(Index,"Colorpicker") then
				Option[Index] = GetType(Option[Index],{},"table")
				Option[Index].Flag = GetType(Option[Index].Flag,
					Dropdown.Flag.."/"..Option.Name.."/Colorpicker","string")

				Option[Index].Value = GetType(Option[Index].Value,{1,1,1,0,false},"table")
				Option[Index].Callback = GetType(Option[Index].Callback,function() end,"function")
				Window.Elements[#Window.Elements + 1] = Option[Index]
				Window.Flags[Option[Index].Flag] = Option[Index].Value

				Assets:ToggleColorpicker(OptionAsset,ScreenAsset,Window,Option[Index])
			end
		end
	end
	for Index, Option in pairs(Dropdown.List) do
		if Option.Value then
			SetOptionState(Option,Option.Value)
		end
	end

	function Dropdown:BulkAdd(Table)
		for Index,Option in pairs(Table) do
			local OptionAsset = GetAsset("Dropdown/Option")
			OptionAsset.Parent = OptionContainerAsset
			OptionAsset.Title.Text = Option.Name
			Option.Instance = OptionAsset

			table.insert(Window.Colorable, OptionAsset)
			table.insert(Dropdown.List,Option)
			OptionAsset.MouseButton1Click:Connect(function()
				SetOptionState(Option,not Option.Value)
			end)
			OptionAsset.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
				OptionAsset.Size = UDim2.new(1,0,0,OptionAsset.Title.TextBounds.Y + 2)
			end)

			for Index,Value in pairs(Option) do
				if string.find(Index,"Colorpicker") then
					Option[Index] = GetType(Option[Index],{},"table")
					Option[Index].Flag = GetType(Option[Index].Flag,
						Dropdown.Flag.."/"..Option.Name.."/Colorpicker","string")

					Option[Index].Value = GetType(Option[Index].Value,{1,1,1,0,false},"table")
					Option[Index].Callback = GetType(Option[Index].Callback,function() end,"function")
					Window.Elements[#Window.Elements + 1] = Option[Index]
					Window.Flags[Option[Index].Flag] = Option[Index].Value

					Assets:ToggleColorpicker(OptionAsset,ScreenAsset,Window,Option[Index])
				end
			end
		end
		for Index, Option in pairs(Dropdown.List) do
			if Option.Value then
				SetOptionState(Option,Option.Value)
			end
		end
	end
	function Dropdown:RemoveOption(Name)
		for Index, Option in pairs(Dropdown.List) do
			if Option.Name == Name then
				Option.Instance:Destroy()
				Dropdown.List[Index] = nil
			end
		end
	end
	function Dropdown:Clear()
		for Index, Option in pairs(Dropdown.List) do
			Option.Instance:Destroy()
			Dropdown.List[Index] = nil
		end
	end
	function Dropdown:SetValue(Options)
		if #Options == 0 then
			DropdownAsset.Background.Value.Text = "..."
			return
		end
		for Index, Option in pairs(Dropdown.List) do
			if table.find(Options,Option.Name) then
				SetOptionState(Option,true)
			else
				if Option.Mode ~= "Button" then
					SetOptionState(Option,false)
				end
			end
		end
	end

	function Dropdown:SetName(Name)
		Dropdown.Name = Name
		DropdownAsset.Title.Text = Name
	end
	function Dropdown:ToolTip(Text)
		Assets:ToolTip(DropdownAsset,ScreenAsset,Text)
	end
end
function Assets:Colorpicker(Parent,ScreenAsset,Window,Colorpicker)
	local ColorpickerAsset = GetAsset("Colorpicker/Colorpicker")
	local PaletteAsset = GetAsset("Colorpicker/Palette")
	ColorpickerAsset.Parent = Parent
	ColorpickerAsset.Title.Text = Colorpicker.Name
	PaletteAsset.Parent = ScreenAsset

	local PaletteRender = nil
	local SVRender = nil
	local HueRender = nil
	local AlphaRender = nil

	local function TableToColor(Table)
		if type(Table) ~= "table" then return Table end
		return Color3.fromHSV(Table[1],Table[2],Table[3])
	end
	local function FormatToString(Color)
		return math.round(Color.R * 255) .. "," .. math.round(Color.G * 255) .. "," .. math.round(Color.B * 255)
	end

	local function Update()
		Colorpicker.Value[6] = TableToColor(Colorpicker.Value)
		ColorpickerAsset.Color.BackgroundColor3 = Colorpicker.Value[6]
		PaletteAsset.SVPicker.BackgroundColor3 = Color3.fromHSV(Colorpicker.Value[1],1,1)
		PaletteAsset.SVPicker.Pin.Position = UDim2.new(Colorpicker.Value[2],0,1 - Colorpicker.Value[3],0)
		PaletteAsset.Hue.Pin.Position = UDim2.new(1 - Colorpicker.Value[1],0,0.5,0)

		PaletteAsset.Alpha.Pin.Position = UDim2.new(Colorpicker.Value[4],0,0.5,0)
		PaletteAsset.Alpha.Value.Text = Colorpicker.Value[4]
		PaletteAsset.Alpha.BackgroundColor3 = Colorpicker.Value[6]

		PaletteAsset.RGB.RGBBox.PlaceholderText = FormatToString(Colorpicker.Value[6])
		PaletteAsset.HEX.HEXBox.PlaceholderText = Colorpicker.Value[6]:ToHex()
		Window.Flags[Colorpicker.Flag] = Colorpicker.Value
		Colorpicker.Callback(Colorpicker.Value,Colorpicker.Value[6])
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
				Colorpicker.Value[2] = ColorX
				Colorpicker.Value[3] = 1 - ColorY
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
				Colorpicker.Value[1] = 1 - ColorX
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
				Colorpicker.Value[4] = math.floor(ColorX * 10^2) / (10^2) -- idk %.2f little bit broken with this
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
	function Colorpicker:SetValue(HSVAR)
		Colorpicker.Value = HSVAR
		Update()
	end
	function Colorpicker:ToolTip(Text)
		Assets:ToolTip(ColorpickerAsset,ScreenAsset,Text)
	end

	table.insert(Window.Colorable,PaletteAsset.Rainbow.Tick)
	PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5] and Window.Color or Color3.fromRGB(60,60,60)
	PaletteAsset.Rainbow.MouseButton1Click:Connect(function()
		Colorpicker.Value[5] = not Colorpicker.Value[5]
		PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5] and Window.Color or Color3.fromRGB(60,60,60)
	end)
	RunService.Heartbeat:Connect(function()
		if Colorpicker.Value[5] then
			if PaletteAsset.Visible then
				Colorpicker.Value[1] = Window.RainbowHue
				Update()
			else 
				Colorpicker.Value[1] = Window.RainbowHue
				Colorpicker.Value[6] = TableToColor(Colorpicker.Value)
				ColorpickerAsset.Color.BackgroundColor3 = Colorpicker.Value[6]
				Window.Flags[Colorpicker.Flag] = Colorpicker.Value
				Colorpicker.Callback(Colorpicker.Value,Colorpicker.Value[6])
			end
		end
	end)

	PaletteAsset.RGB.RGBBox.FocusLost:Connect(function(Enter)
		if not Enter then return end
		local ColorString = string.split(string.gsub(PaletteAsset.RGB.RGBBox.Text," ",""),",")
		local Hue,Saturation,Value = Color3.fromRGB(ColorString[1],ColorString[2],ColorString[3]):ToHSV()
		PaletteAsset.RGB.RGBBox.Text = ""
		Colorpicker.Value[1] = Hue
		Colorpicker.Value[2] = Saturation
		Colorpicker.Value[3] = Value
		Update()
	end)
	PaletteAsset.HEX.HEXBox.FocusLost:Connect(function(Enter)
		if not Enter then return end
		local Hue,Saturation,Value = Color3.fromHex("#" .. PaletteAsset.HEX.HEXBox.Text):ToHSV()
		PaletteAsset.RGB.RGBBox.Text = ""
		Colorpicker.Value[1] = Hue
		Colorpicker.Value[2] = Saturation
		Colorpicker.Value[3] = Value
		Update()
	end)
end
function Assets:ToggleColorpicker(Parent,ScreenAsset,Window,Colorpicker)
	local ColorpickerAsset = GetAsset("Colorpicker/TColorpicker")
	local PaletteAsset = GetAsset("Colorpicker/Palette")
	ColorpickerAsset.Parent = Parent.Layout
	PaletteAsset.Parent = ScreenAsset

	local PaletteRender = nil
	local SVRender = nil
	local HueRender = nil
	local AlphaRender = nil

	local function TableToColor(Table)
		if type(Table) ~= "table" then return Table end
		return Color3.fromHSV(Table[1],Table[2],Table[3])
	end
	local function FormatToString(Color)
		return math.round(Color.R * 255) .. "," .. math.round(Color.G * 255) .. "," .. math.round(Color.B * 255)
	end

	local function Update()
		Colorpicker.Value[6] = TableToColor(Colorpicker.Value)
		ColorpickerAsset.BackgroundColor3 = Colorpicker.Value[6]
		PaletteAsset.SVPicker.BackgroundColor3 = Color3.fromHSV(Colorpicker.Value[1],1,1)
		PaletteAsset.SVPicker.Pin.Position = UDim2.new(Colorpicker.Value[2],0,1 - Colorpicker.Value[3],0)
		PaletteAsset.Hue.Pin.Position = UDim2.new(1 - Colorpicker.Value[1],0,0.5,0)

		PaletteAsset.Alpha.Pin.Position = UDim2.new(Colorpicker.Value[4],0,0.5,0)
		PaletteAsset.Alpha.Value.Text = Colorpicker.Value[4]
		PaletteAsset.Alpha.BackgroundColor3 = Colorpicker.Value[6]

		PaletteAsset.RGB.RGBBox.PlaceholderText = FormatToString(Colorpicker.Value[6])
		PaletteAsset.HEX.HEXBox.PlaceholderText = Colorpicker.Value[6]:ToHex()
		Window.Flags[Colorpicker.Flag] = Colorpicker.Value
		Colorpicker.Callback(Colorpicker.Value,Colorpicker.Value[6])
	end
	Update()

	ColorpickerAsset.MouseButton1Click:Connect(function()
		if not PaletteAsset.Visible then
			PaletteAsset.Visible = true
			PaletteRender = RunService.RenderStepped:Connect(function()
				if not PaletteAsset.Visible then PaletteRender:Disconnect() end
				PaletteAsset.Position = UDim2.new(0,(ColorpickerAsset.AbsolutePosition.X - PaletteAsset.AbsoluteSize.X) + 20,0,ColorpickerAsset.AbsolutePosition.Y + 52)
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
				Colorpicker.Value[2] = ColorX
				Colorpicker.Value[3] = 1 - ColorY
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
				Colorpicker.Value[1] = 1 - ColorX
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
				Colorpicker.Value[4] = math.floor(ColorX * 10^2) / (10^2) -- idk %.2f little bit broken with this
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

	function Colorpicker:SetCallback(Callback)
		Colorpicker.Callback = Callback
	end
	function Colorpicker:SetValue(HSVAR)
		Colorpicker.Value = HSVAR
		Update()
	end

	table.insert(Window.Colorable,PaletteAsset.Rainbow.Tick)
	PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5] and Window.Color or Color3.fromRGB(60,60,60)
	PaletteAsset.Rainbow.MouseButton1Click:Connect(function()
		Colorpicker.Value[5] = not Colorpicker.Value[5]
		PaletteAsset.Rainbow.Tick.BackgroundColor3 = Colorpicker.Value[5] and Window.Color or Color3.fromRGB(60,60,60)
	end)
	RunService.Heartbeat:Connect(function()
		if Colorpicker.Value[5] then
			if PaletteAsset.Visible then
				Colorpicker.Value[1] = Window.RainbowHue
				Update()
			else 
				Colorpicker.Value[1] = Window.RainbowHue
				Colorpicker.Value[6] = TableToColor(Colorpicker.Value)
				ColorpickerAsset.BackgroundColor3 = Colorpicker.Value[6]
				Window.Flags[Colorpicker.Flag] = Colorpicker.Value
				Colorpicker.Callback(Colorpicker.Value,Colorpicker.Value[6])
			end
		end
	end)

	PaletteAsset.RGB.RGBBox.FocusLost:Connect(function(Enter)
		if not Enter then return end
		local ColorString = string.split(string.gsub(PaletteAsset.RGB.RGBBox.Text," ",""),",")
		local Hue,Saturation,Value = Color3.fromRGB(ColorString[1],ColorString[2],ColorString[3]):ToHSV()
		PaletteAsset.RGB.RGBBox.Text = ""
		Colorpicker.Value[1] = Hue
		Colorpicker.Value[2] = Saturation
		Colorpicker.Value[3] = Value
		Update()
	end)
	PaletteAsset.HEX.HEXBox.FocusLost:Connect(function(Enter)
		if not Enter then return end
		local Hue,Saturation,Value = Color3.fromHex("#" .. PaletteAsset.HEX.HEXBox.Text):ToHSV()
		PaletteAsset.RGB.RGBBox.Text = ""
		Colorpicker.Value[1] = Hue
		Colorpicker.Value[2] = Saturation
		Colorpicker.Value[3] = Value
		Update()
	end)
end

local Bracket = Assets:Screen()
function Bracket:Window(Window)
	Window = GetType(Window,{},"table")
	Window.Name = GetType(Window.Name,"Window","string")
	Window.Color = GetType(Window.Color,Color3.new(1,0.5,0.25),"Color3")
	Window.Size = GetType(Window.Size,UDim2.new(0,496,0,496),"UDim2")
	Window.Position = GetType(Window.Position,UDim2.new(0.5,-248,0.5,-248),"UDim2")
	Window.Enabled = GetType(Window.Enabled,true,"boolean")

	Window.RainbowHue = 0
	Window.Colorable = {}
	Window.Elements = {}
	Window.Flags = {}

	local WindowAsset = Assets:Window(Bracket.ScreenAsset,Window)
	function Window:Tab(Tab)
		Tab = GetType(Tab,{},"table")
		Tab.Name = GetType(Tab.Name,"Tab","string")
		local ChooseTab = Assets:Tab(Bracket.ScreenAsset,WindowAsset,Window,Tab)

		function Tab:AddConfigSection(FolderName,Side)
			local ConfigSection = Tab:Section({Name = "Config System",Side = Side}) do
				local ConfigList,ConfigDropdown = ConfigsToList(FolderName),nil
				local function UpdateList(Name)
					ConfigDropdown:Clear()
					ConfigList = ConfigsToList(FolderName)
					ConfigDropdown:BulkAdd(ConfigList)
					ConfigDropdown:SetValue({Name or (ConfigList[1] and ConfigList[1].Name) or nil})
				end

				local ConfigTextbox = ConfigSection:Textbox({Name = "Config Name",
					Placeholder = "Name",IgnoreFlag = true})

				ConfigSection:Button({Name = "Create",Callback = function()
					Window:SaveConfig(FolderName,ConfigTextbox.Value) UpdateList(ConfigTextbox.Value)
				end})

				ConfigDropdown = ConfigSection:Dropdown({Name = "List",
					IgnoreFlag = true,List = ConfigList})

				ConfigSection:Button({Name = "Save",Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:SaveConfig(FolderName,ConfigDropdown.Value[1])
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "First Select Config",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Load",Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:LoadConfig(FolderName,ConfigDropdown.Value[1])
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "First Select Config",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Delete",Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						Window:DeleteConfig(FolderName,ConfigDropdown.Value[1])
						UpdateList()
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "First Select Config",
							Duration = 10
						})
					end
				end})

				local DefaultConfig = Window:GetDefaultConfig(FolderName)
				local ConfigDivider = ConfigSection:Divider({Text = not DefaultConfig and "Default Config" or
					"Default Config\n<font color=\"rgb(189,189,189)\">[ "..DefaultConfig.." ]</font>"})

				ConfigSection:Button({Name = "Set Default",Callback = function()
					if ConfigDropdown.Value and ConfigDropdown.Value[1] then
						DefaultConfig = ConfigDropdown.Value[1] writefile(FolderName.."\\DefaultConfig.txt",DefaultConfig)
						ConfigDivider:SetText("Default Config\n<font color=\"rgb(189,189,189)\">[ "..DefaultConfig.." ]</font>")
					else
						Bracket:Notification({
							Title = "Config System",
							Description = "First Select Config",
							Duration = 10
						})
					end
				end})
				ConfigSection:Button({Name = "Clear Default",Callback = function()
					writefile(FolderName.."\\DefaultConfig.txt","") ConfigDivider:SetText("Default Config")
				end})
			end
		end

		function Tab:Divider(Divider)
			Divider = GetType(Divider,{},"table")
			Divider.Text = GetType(Divider.Text,"","string")
			Assets:Divider(ChooseTab(Divider.Side),Divider)
			return Divider
		end
		function Tab:Label(Label)
			Label = GetType(Label,{},"table")
			Label.Text = GetType(Label.Text,"Label","string")
			Assets:Label(ChooseTab(Label.Side),Label)
			return Label
		end
		function Tab:Button(Button)
			Button = GetType(Button,{},"table")
			Button.Name = GetType(Button.Name,"Button","string")
			Button.Callback = GetType(Button.Callback,function() end,"function")
			Assets:Button(ChooseTab(Button.Side),Bracket.ScreenAsset,Window,Button)
			return Button
		end
		function Tab:Toggle(Toggle)
			Toggle = GetType(Toggle,{},"table")
			Toggle.Name = GetType(Toggle.Name,"Toggle","string")
			Toggle.Flag = GetType(Toggle.Flag,Toggle.Name,"string")

			Toggle.Value = GetType(Toggle.Value,false,"boolean")
			Toggle.Callback = GetType(Toggle.Callback,function() end,"function")
			Window.Elements[#Window.Elements + 1] = Toggle
			Window.Flags[Toggle.Flag] = Toggle.Value

			local ToggleAsset = Assets:Toggle(ChooseTab(Toggle.Side),Bracket.ScreenAsset,Window,Toggle)
			function Toggle:Keybind(Keybind)
				Keybind = GetType(Keybind,{},"table")
				Keybind.Flag = GetType(Keybind.Flag,Toggle.Flag.."/Keybind","string")

				Keybind.Value = GetType(Keybind.Value,"NONE","string")
				Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
				Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
				Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")
				Window.Elements[#Window.Elements + 1] = Keybind
				Window.Flags[Keybind.Flag] = Keybind.Value

				Assets:ToggleKeybind(ToggleAsset,Bracket.ScreenAsset,Window,Keybind,Toggle)
				return Toggle
			end
			function Toggle:Colorpicker(Colorpicker)
				Colorpicker = GetType(Colorpicker,{},"table")
				Colorpicker.Flag = GetType(Colorpicker.Flag,Toggle.Flag.."/Colorpicker","string")

				Colorpicker.Value = GetType(Colorpicker.Value,{1,1,1,0,false},"table")
				Colorpicker.Callback = GetType(Colorpicker.Callback,function() end,"function")
				Window.Elements[#Window.Elements + 1] = Colorpicker
				Window.Flags[Colorpicker.Flag] = Colorpicker.Value

				Assets:ToggleColorpicker(ToggleAsset,Bracket.ScreenAsset,Window,Colorpicker)
				return Toggle
			end
			return Toggle
		end
		function Tab:Slider(Slider)
			Slider = GetType(Slider,{},"table")
			Slider.Name = GetType(Slider.Name,"Slider","string")
			Slider.Flag = GetType(Slider.Flag,Slider.Name,"string")

			Slider.Min = GetType(Slider.Min,0,"number")
			Slider.Max = GetType(Slider.Max,100,"number")
			Slider.Precise = GetType(Slider.Precise,0,"number")
			Slider.Unit = GetType(Slider.Unit,"","string")
			Slider.Value = GetType(Slider.Value,Slider.Max / 2,"number")
			Slider.Callback = GetType(Slider.Callback,function() end,"function")
			Window.Elements[#Window.Elements + 1] = Slider
			Window.Flags[Slider.Flag] = Slider.Value

			if Slider.HighType then
				Assets:HighSlider(ChooseTab(Slider.Side),Bracket.ScreenAsset,Window,Slider)
			else
				Assets:Slider(ChooseTab(Slider.Side),Bracket.ScreenAsset,Window,Slider)
			end return Slider
		end
		function Tab:Textbox(Textbox)
			Textbox = GetType(Textbox,{},"table")
			Textbox.Name = GetType(Textbox.Name,"Textbox","string")
			Textbox.Flag = GetType(Textbox.Flag,Textbox.Name,"string")

			Textbox.Value = GetType(Textbox.Value,"","string")
			Textbox.NumbersOnly = GetType(Textbox.NumbersOnly,false,"boolean")
			Textbox.Placeholder = GetType(Textbox.Placeholder,"Input here","string")
			Textbox.Callback = GetType(Textbox.Callback,function() end,"function")
			Window.Elements[#Window.Elements + 1] = Textbox
			Window.Flags[Textbox.Flag] = Textbox.Value

			Assets:Textbox(ChooseTab(Textbox.Side),Bracket.ScreenAsset,Window,Textbox)
			return Textbox
		end
		function Tab:Keybind(Keybind)
			Keybind = GetType(Keybind,{},"table")
			Keybind.Name = GetType(Keybind.Name,"Keybind","string")
			Keybind.Flag = GetType(Keybind.Flag,Keybind.Name,"string")

			Keybind.Value = GetType(Keybind.Value,"NONE","string")
			Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
			Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
			Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")
			Window.Elements[#Window.Elements + 1] = Keybind
			Window.Flags[Keybind.Flag] = Keybind.Value

			Assets:Keybind(ChooseTab(Keybind.Side),Bracket.ScreenAsset,Window,Keybind)
			return Keybind
		end
		function Tab:Dropdown(Dropdown)
			Dropdown = GetType(Dropdown,{},"table")
			Dropdown.Name = GetType(Dropdown.Name,"Dropdown","string")
			Dropdown.Flag = GetType(Dropdown.Flag,Dropdown.Name,"string")
			Dropdown.List = GetType(Dropdown.List,{},"table")
			Window.Elements[#Window.Elements + 1] = Dropdown
			Window.Flags[Dropdown.Flag] = Dropdown.Value

			Assets:Dropdown(ChooseTab(Dropdown.Side),Bracket.ScreenAsset,Window,Dropdown)
			return Dropdown
		end
		function Tab:Colorpicker(Colorpicker)
			Colorpicker = GetType(Colorpicker,{},"table")
			Colorpicker.Name = GetType(Colorpicker.Name,"Colorpicker","string")
			Colorpicker.Flag = GetType(Colorpicker.Flag,Colorpicker.Name,"string")

			Colorpicker.Value = GetType(Colorpicker.Value,{1,1,1,0,false},"table")
			Colorpicker.Callback = GetType(Colorpicker.Callback,function() end,"function")
			Window.Elements[#Window.Elements + 1] = Colorpicker
			Window.Flags[Colorpicker.Flag] = Colorpicker.Value

			Assets:Colorpicker(ChooseTab(Colorpicker.Side),Bracket.ScreenAsset,Window,Colorpicker)
			return Colorpicker
		end
		function Tab:Section(Section)
			Section = GetType(Section,{},"table")
			Section.Name = GetType(Section.Name,"Section","string")
			local SectionContainer = Assets:Section(ChooseTab(Section.Side),Section)

			function Section:Divider(Divider)
				Divider = GetType(Divider,{},"table")
				Divider.Text = GetType(Divider.Text,"","string")
				Assets:Divider(SectionContainer,Divider)
				return Divider
			end
			function Section:Label(Label)
				Label = GetType(Label,{},"table")
				Label.Text = GetType(Label.Text,"Label","string")
				Assets:Label(SectionContainer,Label)
				return Label
			end
			function Section:Button(Button)
				Button = GetType(Button,{},"table")
				Button.Name = GetType(Button.Name,"Button","string")
				Button.Callback = GetType(Button.Callback,function() end,"function")
				Assets:Button(SectionContainer,Bracket.ScreenAsset,Window,Button)
				return Button
			end
			function Section:Toggle(Toggle)
				Toggle = GetType(Toggle,{},"table")
				Toggle.Name = GetType(Toggle.Name,"Toggle","string")
				Toggle.Flag = GetType(Toggle.Flag,Toggle.Name,"string")

				Toggle.Value = GetType(Toggle.Value,false,"boolean")
				Toggle.Callback = GetType(Toggle.Callback,function() end,"function")
				Window.Elements[#Window.Elements + 1] = Toggle
				Window.Flags[Toggle.Flag] = Toggle.Value

				local ToggleAsset = Assets:Toggle(SectionContainer,Bracket.ScreenAsset,Window,Toggle)
				function Toggle:Keybind(Keybind)
					Keybind = GetType(Keybind,{},"table")
					Keybind.Flag = GetType(Keybind.Flag,Toggle.Flag.."/Keybind","string")

					Keybind.Value = GetType(Keybind.Value,"NONE","string")
					Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
					Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
					Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")
					Window.Elements[#Window.Elements + 1] = Keybind
					Window.Flags[Keybind.Flag] = Keybind.Value

					Assets:ToggleKeybind(ToggleAsset,Bracket.ScreenAsset,Window,Keybind,Toggle)
					return Toggle
				end
				function Toggle:Colorpicker(Colorpicker)
					Colorpicker = GetType(Colorpicker,{},"table")
					Colorpicker.Flag = GetType(Colorpicker.Flag,Toggle.Flag.."/Colorpicker","string")

					Colorpicker.Value = GetType(Colorpicker.Value,{1,1,1,0,false},"table")
					Colorpicker.Callback = GetType(Colorpicker.Callback,function() end,"function")
					Window.Elements[#Window.Elements + 1] = Colorpicker
					Window.Flags[Colorpicker.Flag] = Colorpicker.Value

					Assets:ToggleColorpicker(ToggleAsset,Bracket.ScreenAsset,Window,Colorpicker)
					return Toggle
				end
				return Toggle
			end
			function Section:Slider(Slider)
				Slider = GetType(Slider,{},"table")
				Slider.Name = GetType(Slider.Name,"Slider","string")
				Slider.Flag = GetType(Slider.Flag,Slider.Name,"string")

				Slider.Min = GetType(Slider.Min,0,"number")
				Slider.Max = GetType(Slider.Max,100,"number")
				Slider.Precise = GetType(Slider.Precise,0,"number")
				Slider.Unit = GetType(Slider.Unit,"","string")
				Slider.Value = GetType(Slider.Value,Slider.Max / 2,"number")
				Slider.Callback = GetType(Slider.Callback,function() end,"function")
				Window.Elements[#Window.Elements + 1] = Slider
				Window.Flags[Slider.Flag] = Slider.Value
				if Slider.HighType then
					Assets:HighSlider(SectionContainer,Bracket.ScreenAsset,Window,Slider)
				else
					Assets:Slider(SectionContainer,Bracket.ScreenAsset,Window,Slider)
				end return Slider
			end
			function Section:Textbox(Textbox)
				Textbox = GetType(Textbox,{},"table")
				Textbox.Name = GetType(Textbox.Name,"Textbox","string")
				Textbox.Flag = GetType(Textbox.Flag,Textbox.Name,"string")

				Textbox.Value = GetType(Textbox.Value,"","string")
				Textbox.NumbersOnly = GetType(Textbox.NumbersOnly,false,"boolean")
				Textbox.Placeholder = GetType(Textbox.Placeholder,"Input here","string")
				Textbox.Callback = GetType(Textbox.Callback,function() end,"function")
				Window.Elements[#Window.Elements + 1] = Textbox
				Window.Flags[Textbox.Flag] = Textbox.Value

				Assets:Textbox(SectionContainer,Bracket.ScreenAsset,Window,Textbox)
				return Textbox
			end
			function Section:Keybind(Keybind)
				Keybind = GetType(Keybind,{},"table")
				Keybind.Name = GetType(Keybind.Name,"Keybind","string")
				Keybind.Flag = GetType(Keybind.Flag,Keybind.Name,"string")

				Keybind.Value = GetType(Keybind.Value,"NONE","string")
				Keybind.Mouse = GetType(Keybind.Mouse,false,"boolean")
				Keybind.Callback = GetType(Keybind.Callback,function() end,"function")
				Keybind.Blacklist = GetType(Keybind.Blacklist,{"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"},"table")
				Window.Elements[#Window.Elements + 1] = Keybind
				Window.Flags[Keybind.Flag] = Keybind.Value

				Assets:Keybind(SectionContainer,Bracket.ScreenAsset,Window,Keybind)
				return Keybind
			end
			function Section:Dropdown(Dropdown)
				Dropdown = GetType(Dropdown,{},"table")
				Dropdown.Name = GetType(Dropdown.Name,"Dropdown","string")
				Dropdown.Flag = GetType(Dropdown.Flag,Dropdown.Name,"string")
				Dropdown.List = GetType(Dropdown.List,{},"table")
				Window.Elements[#Window.Elements + 1] = Dropdown
				Window.Flags[Dropdown.Flag] = Dropdown.Value

				Assets:Dropdown(SectionContainer,Bracket.ScreenAsset,Window,Dropdown)
				return Dropdown
			end
			function Section:Colorpicker(Colorpicker)
				Colorpicker = GetType(Colorpicker,{},"table")
				Colorpicker.Name = GetType(Colorpicker.Name,"Colorpicker","string")
				Colorpicker.Flag = GetType(Colorpicker.Flag,Colorpicker.Name,"string")

				Colorpicker.Value = GetType(Colorpicker.Value,{1,1,1,0,false},"table")
				Colorpicker.Callback = GetType(Colorpicker.Callback,function() end,"function")
				Window.Elements[#Window.Elements + 1] = Colorpicker
				Window.Flags[Colorpicker.Flag] = Colorpicker.Value

				Assets:Colorpicker(SectionContainer,Bracket.ScreenAsset,Window,Colorpicker)
				return Colorpicker
			end
			return Section
		end
		return Tab
	end
	return Window
end

function Bracket:TableToColor(Table)
	if type(Table) ~= "table" then return Table end
	return Color3.fromHSV(Table[1],Table[2],Table[3])
end

function Bracket:Notification(Notification)
	Notification = GetType(Notification,{},"table")
	Notification.Title = GetType(Notification.Title,"Title","string")
	Notification.Description = GetType(Notification.Description,"Description","string")

	local NotificationAsset = GetAsset("Notification/ND")
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
		task.spawn(function()
			for Time = Notification.Duration,1,-1 do
				NotificationAsset.Title.Close.Text = Time
				task.wait(1)
			end
			NotificationAsset.Title.Close.Text = 0

			if Notification.Callback then
				Notification.Callback()
			end
			NotificationAsset:Destroy()
		end)
	else
		NotificationAsset.Title.Close.MouseButton1Click:Connect(function()
			NotificationAsset:Destroy()
		end)
	end
end

function Bracket:Notification2(Notification)
	Notification = GetType(Notification,{},"table")
	Notification.Title = GetType(Notification.Title,"Title","string")
	Notification.Duration = GetType(Notification.Duration,5,"number")
	Notification.Color = GetType(Notification.Color,Color3.new(1,0.5,0.25),"Color3")

	local NotificationAsset = GetAsset("Notification/NL")
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

	local function TweenSize(X,Y,Callback)
		NotificationAsset:TweenSize(
			UDim2.new(0,X,0,Y),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Linear,
			0.25,false,Callback
		)
	end

	TweenSize(NotificationAsset.Main.Size.X.Offset + 4,
	NotificationAsset.Main.Size.Y.Offset + 4,function()
		task.wait(Notification.Duration) TweenSize(0,
		NotificationAsset.Main.Size.Y.Offset + 4,function()
			if Notification.Callback then
				Notification.Callback()
			end NotificationAsset:Destroy()
		end)
	end)
end

return Bracket
