local InsertService = game:GetService("InsertService")
local MainModule = InsertService:LoadLocalAsset("rbxassetid://7974127463")

local function GetModule(Module)
	return loadstring(MainModule[Module].Source)()
end

local Library = {}
local Get = {
	Utilities = GetModule("Utilities"),
	
	Notification = GetModule("Notification"),
	Window = GetModule("Window"),
	
	Tab = GetModule("Tab"),
	Section = GetModule("Section"),
	
	Divider = GetModule("Divider"),
	Label = GetModule("Label"),
	Button = GetModule("Button"),
	Toggle = GetModule("Toggle"),
	Slider = GetModule("Slider"),
	Textbox = GetModule("Textbox"),
	Keybind = GetModule("Keybind"),
	Dropdown = GetModule("Dropdown"),
	Colorpicker = GetModule("Colorpicker"),

	Element = function(Module,Element)
		return MainModule[Module][Element]
	end
}

function Library:Notification(Title,Description,Duration,Callback)
	Title = Get.Utilities:GetType(Title,{"string","number"}) or "Title"
	Description = Get.Utilities:GetType(Description,{"string","number"}) or "Description"
	Callback = Get.Utilities:GetType(Callback,"function")
	local LocalNotification = Get.Notification(Get,Title,Description,Duration,Callback)
end

function Library:Window(Window)
	Window = Get.Utilities:GetType(Window, "table") or {}
	Window.Name = Get.Utilities:GetType(Window.Name, "string") or "Window"
	Window.Color = Get.Utilities:GetType(Window.Color, "Color3") or Color3.new(1,0.5,0.25)
	Window.Size = Get.Utilities:GetType(Window.Size, "UDim2") or UDim2.new(0,496,0,496)
	Window.Position = Get.Utilities:GetType(Window.Position, "UDim2") or UDim2.new(0.5,-248,0.5,-248)

	if Window.Enabled == nil then Window.Enabled = true end
	Window.RainbowHue = 0
	Window.Colorable = {}

	local LocalScreen = Get.Window(Get,Window)
	function Window:Tab(Tab)
		Tab = Get.Utilities:GetType(Tab, "table") or {}
		Tab.Name = Get.Utilities:GetType(Tab.Name, "string") or "Tab"
		local LocalTab = Get.Tab(LocalScreen, Window, Get, Tab)
		
		function Tab:Divider(Divider)
			Divider = Get.Utilities:GetType(Divider, "table") or {}
			Divider.Text = Get.Utilities:GetType(Divider.Text, "string") or nil
			Divider.Side = Get.Utilities:GetType(Divider.Side, "string") or nil

			local LocalDivider = Get.Divider(Get.Utilities:ChooseTabSide(Divider.Side,LocalTab),Get,Divider)
			return Divider
		end
		function Tab:Label(Label)
			Label = Get.Utilities:GetType(Label, "table") or {}
			Label.Text = Get.Utilities:GetType(Label.Text, "string") or "Label"
			Label.Side = Get.Utilities:GetType(Label.Side, "string") or nil

			local LocalLabel = Get.Label(Get.Utilities:ChooseTabSide(Label.Side,LocalTab),Get,Label)
			return Label
		end
		function Tab:Button(Button)
			Button = Get.Utilities:GetType(Button, "table") or {}
			Button.Name = Get.Utilities:GetType(Button.Name, "string") or "Button"
			Button.Side = Get.Utilities:GetType(Button.Side, "string") or nil

			Button.Callback = Get.Utilities:GetType(Button.Callback, "function") or function() print("Hello World!") end
			local LocalButton = Get.Button(Get.Utilities:ChooseTabSide(Button.Side,LocalTab),LocalScreen,Window,Get,Button)
			return Button
		end
		function Tab:Toggle(Toggle)
			Toggle = Get.Utilities:GetType(Toggle, "table") or {}
			Toggle.Name = Get.Utilities:GetType(Toggle.Name, "string") or "Toggle"
			Toggle.Side = Get.Utilities:GetType(Toggle.Side, "string") or nil

			Toggle.Value = Get.Utilities:GetType(Toggle.Value, "boolean") or false
			Toggle.Callback = Get.Utilities:GetType(Toggle.Callback, "function") or print
			local LocalToggle = Get.Toggle(Get.Utilities:ChooseTabSide(Toggle.Side,LocalTab),LocalScreen,Window,Get,Toggle)
			return Toggle
		end
		function Tab:Slider(Slider)
			Slider = Get.Utilities:GetType(Slider, "table") or {}
			Slider.Name = Get.Utilities:GetType(Slider.Name, "string") or "Slider"
			Slider.Side = Get.Utilities:GetType(Slider.Side, "string") or nil

			Slider.Min = Get.Utilities:GetType(Slider.Min, "number") or 0
			Slider.Max = Get.Utilities:GetType(Slider.Max, "number") or 100
			Slider.Precise = Get.Utilities:GetType(Slider.Precise, "number") or 0
			Slider.Unit = Get.Utilities:GetType(Slider.Unit, "string") or ""
			Slider.Value = Get.Utilities:GetType(Slider.Value, "number") or (Slider.Max / 2)
			Slider.Callback = Get.Utilities:GetType(Slider.Callback, "function") or print
			local LocalSlider = Get.Slider(Get.Utilities:ChooseTabSide(Slider.Side,LocalTab),LocalScreen,Window,Get,Slider)
			return Slider
		end
		function Tab:Textbox(Textbox)
			Textbox = Get.Utilities:GetType(Textbox, "table") or {}
			Textbox.Name = Get.Utilities:GetType(Textbox.Name, "string") or "Textbox"
			Textbox.Side = Get.Utilities:GetType(Textbox.Side, "string") or nil

			Textbox.Text = Get.Utilities:GetType(Textbox.Text, "string") or ""
			Textbox.Placeholder = Get.Utilities:GetType(Textbox.Placeholder, "string") or "Textbox"
			Textbox.NumbersOnly = Get.Utilities:GetType(Textbox.NumbersOnly, "boolean") or false
			Textbox.Callback = Get.Utilities:GetType(Textbox.Callback, "function") or print
			local LocalSlider = Get.Textbox(Get.Utilities:ChooseTabSide(Textbox.Side,LocalTab),LocalScreen,Window,Get,Textbox)
			return Textbox
		end
		function Tab:Keybind(Keybind)
			Keybind = Get.Utilities:GetType(Keybind, "table") or {}
			Keybind.Name = Get.Utilities:GetType(Keybind.Name, "string") or "Keybind"
			Keybind.Side = Get.Utilities:GetType(Keybind.Side, "string") or nil

			Keybind.Key = Get.Utilities:GetType(Keybind.Key, "string") or "NONE"
			Keybind.Mouse = Get.Utilities:GetType(Keybind.Mouse, "boolean") or false
			Keybind.Callback = Get.Utilities:GetType(Keybind.Callback, "function") or print
			Keybind.Blacklist = Get.Utilities:GetType(Keybind.Blacklist, "table") or {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}
			local LocalKeybind = Get.Keybind(Get.Utilities:ChooseTabSide(Keybind.Side,LocalTab),LocalScreen,Window,Get,Keybind)
			return Keybind
		end
		function Tab:Dropdown(Dropdown)
			Dropdown = Get.Utilities:GetType(Dropdown, "table") or {}
			Dropdown.Name = Get.Utilities:GetType(Dropdown.Name, "string") or "Dropdown"
			Dropdown.Side = Get.Utilities:GetType(Dropdown.Side, "string") or nil

			Dropdown.Callback = Get.Utilities:GetType(Dropdown.Callback, "function") or print
			local LocalDropdown = Get.Dropdown(Get.Utilities:ChooseTabSide(Dropdown.Side,LocalTab),LocalScreen,Window,Get,Dropdown)
			return Dropdown
		end
		function Tab:Colorpicker(Colorpicker)
			Colorpicker = Get.Utilities:GetType(Colorpicker, "table") or {}
			Colorpicker.Name = Get.Utilities:GetType(Colorpicker.Name, "string") or "Colorpicker"
			Colorpicker.Side = Get.Utilities:GetType(Colorpicker.Side, "string") or nil
			
			Colorpicker.Color = Get.Utilities:GetType(Colorpicker.Color, "Color3") or Color3.new(1,0,0)
			Colorpicker.Callback = Get.Utilities:GetType(Colorpicker.Callback, "function") or print
			local LocalColorpicker = Get.Colorpicker(Get.Utilities:ChooseTabSide(Colorpicker.Side,LocalTab),LocalScreen,Window,Get,Colorpicker)
			return Colorpicker
		end
		function Tab:Section(Section)
			Section = Get.Utilities:GetType(Section, "table") or {}
			Section.Name = Get.Utilities:GetType(Section.Name, "string") or "Section"
			Section.Side = Get.Utilities:GetType(Section.Side, "string") or nil
			local LocalSection = Get.Section(Get.Utilities:ChooseTabSide(Section.Side,LocalTab),Get,Section)
			
			function Section:Divider(Divider)
				Divider = Get.Utilities:GetType(Divider, "table") or {}
				Divider.Text = Get.Utilities:GetType(Divider.Text, "string") or nil
				
				local LocalDivider = Get.Divider(LocalSection.Container,Get,Divider)
				return Divider
			end
			function Section:Label(Label)
				Label = Get.Utilities:GetType(Label, "table") or {}
				Label.Text = Get.Utilities:GetType(Label.Text, "string") or "Label"

				local LocalLabel = Get.Label(LocalSection.Container,Get,Label)
				return Label
			end
			function Section:Button(Button)
				Button = Get.Utilities:GetType(Button, "table") or {}
				Button.Name = Get.Utilities:GetType(Button.Name, "string") or "Button"

				Button.Callback = Get.Utilities:GetType(Button.Callback, "function") or function() print("Hello World!") end
				local LocalButton = Get.Button(LocalSection.Container,LocalScreen,Window,Get,Button)
				return Button
			end
			function Section:Toggle(Toggle)
				Toggle = Get.Utilities:GetType(Toggle, "table") or {}
				Toggle.Name = Get.Utilities:GetType(Toggle.Name, "string") or "Toggle"

				Toggle.Value = Get.Utilities:GetType(Toggle.Value, "boolean") or false
				Toggle.Callback = Get.Utilities:GetType(Toggle.Callback, "function") or print
				local LocalToggle = Get.Toggle(LocalSection.Container,LocalScreen,Window,Get,Toggle)
				return Toggle
			end
			function Section:Slider(Slider)
				Slider = Get.Utilities:GetType(Slider, "table") or {}
				Slider.Name = Get.Utilities:GetType(Slider.Name, "string") or "Slider"

				Slider.Min = Get.Utilities:GetType(Slider.Min, "number") or 0
				Slider.Max = Get.Utilities:GetType(Slider.Max, "number") or 100
				Slider.Precise = Get.Utilities:GetType(Slider.Precise, "number") or 0
				Slider.Unit = Get.Utilities:GetType(Slider.Unit, "string") or ""
				Slider.Value = Get.Utilities:GetType(Slider.Value, "number") or (Slider.Max / 2)
				Slider.Callback = Get.Utilities:GetType(Slider.Callback, "function") or print
				local LocalSlider = Get.Slider(LocalSection.Container,LocalScreen,Window,Get,Slider)
				return Slider
			end
			function Section:Textbox(Textbox)
				Textbox = Get.Utilities:GetType(Textbox, "table") or {}
				Textbox.Name = Get.Utilities:GetType(Textbox.Name, "string") or "Textbox"
				Textbox.Side = Get.Utilities:GetType(Textbox.Side, "string") or nil

				Textbox.Text = Get.Utilities:GetType(Textbox.Text, "string") or "Sample Text"
				Textbox.Placeholder = Get.Utilities:GetType(Textbox.Placeholder, "string") or "Textbox"
				Textbox.NumbersOnly = Get.Utilities:GetType(Textbox.NumbersOnly, "boolean") or false
				Textbox.Callback = Get.Utilities:GetType(Textbox.Callback, "function") or print
				local LocalSlider = Get.Textbox(LocalSection.Container,LocalScreen,Window,Get,Textbox)
				return Textbox
			end
			function Section:Keybind(Keybind)
				Keybind = Get.Utilities:GetType(Keybind, "table") or {}
				Keybind.Name = Get.Utilities:GetType(Keybind.Name, "string") or "Keybind"

				Keybind.Key = Get.Utilities:GetType(Keybind.Key, "string") or "NONE"
				Keybind.Mouse = Get.Utilities:GetType(Keybind.Mouse, "boolean") or false
				Keybind.Callback = Get.Utilities:GetType(Keybind.Callback, "function") or print
				Keybind.Blacklist = Get.Utilities:GetType(Keybind.Blacklist, "table") or {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}
				local LocalKeybind = Get.Keybind(LocalSection.Container,LocalScreen,Window,Get,Keybind)
				return Keybind
			end
			function Section:Dropdown(Dropdown)
				Dropdown = Get.Utilities:GetType(Dropdown, "table") or {}
				Dropdown.Name = Get.Utilities:GetType(Dropdown.Name, "string") or "Dropdown"

				Dropdown.Callback = Get.Utilities:GetType(Dropdown.Callback, "function") or print
				local LocalDropdown = Get.Dropdown(LocalSection.Container,LocalScreen,Window,Get,Dropdown)
				return Dropdown
			end
			function Section:Colorpicker(Colorpicker)
				Colorpicker = Get.Utilities:GetType(Colorpicker, "table") or {}
				Colorpicker.Name = Get.Utilities:GetType(Colorpicker.Name, "string") or "Colorpicker"
				
				Colorpicker.Color = Get.Utilities:GetType(Colorpicker.Color, "Color3") or Color3.new(1,0,0)
				Colorpicker.Callback = Get.Utilities:GetType(Colorpicker.Callback, "function") or print
				local LocalColorpicker = Get.Colorpicker(LocalSection.Container,LocalScreen,Window,Get,Colorpicker)
				return Colorpicker
			end
			return Section
		end
		return Tab
	end
	return Window
end

return Library
