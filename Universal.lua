local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = PlayerService.LocalPlayer
local AimbotTarget, SilentAimTarget, Aimbot = nil, nil, false

Parvus.Config = Parvus.Utilities.Config:ReadJSON(Parvus.Current, {
    PlayerESP = {
        AllyColor = {0.25,1,0.25,0},
        EnemyColor = {1,0.25,0.25,0},

        TeamColor = false,
        TeamCheck = false,

        BoxVisible = false,
        Text = {
            Visible = false,
            AutoScale = true,
            Size = 16
        },
        HeadCircle = {
            Visible = false,
            Filled = true,
            AutoScale = true,
            Radius = 8,
            NumSides = 4
        },
        Highlight = {
            Visible = false,
            Transparency = 0.5,
            OutlineColor = {1,1,1,0},
            OutlineTransparency = 1
        }
    },
    AimAssist = {
        TeamCheck = false,
        SilentAim = {
            Enabled = false,
            WallCheck = false,
            HitChance = 100,
            FieldOfView = 50,
            Priority = "Head",
            Circle = {
                Visible = false,
                Transparency = 0.5,
                Color = {0.25,0.25,1,0},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        },
        Aimbot = {
            Enabled = false,
            WallCheck = false,
            Sensitivity = 0.25,
            FieldOfView = 100,
            Priority = "Head",
            Circle = {
                Visible = true,
                Transparency = 0.5,
                Color = {1,0.25,0.25,0},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        }
    },
    UI = {
        Enabled = true,
        Keybind = "RightShift",
        Color = {0.5,0.25,0.5,0},
        TileSize = 74,
        Background = "Floral",
        BackgroundId = "rbxassetid://5553946656",
        BackgroundColor = {0,0,0,0},
        BackgroundTransparency = 0
    },
    Binds = {
        Aimbot = "MouseButton2",
        SilentAim = "NONE"
    }
})

local Window = Parvus.Utilities.UI:Window({Name = "Parvus Hub",Enabled = Parvus.Config.UI.Enabled,Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.UI.Color),Position = UDim2.new(0.2,-248,0.5,-248)}) do
    local AimAssistTab = Window:Tab({Name = "Aim Assist"}) do
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.Aimbot.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Enabled = Bool
            end})
            AimbotSection:Toggle({Name = "Team Check",Side = "Left",Value = Parvus.Config.AimAssist.TeamCheck,Callback = function(Bool)
                Parvus.Config.AimAssist.TeamCheck = Bool
            end}):ToolTip("Affects Aimbot and Silent Aim")
            AimbotSection:Toggle({Name = "Visibility Check",Value = Parvus.Config.AimAssist.Aimbot.WallCheck,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.WallCheck = Bool
            end})
            AimbotSection:Keybind({Name = "Keybind",Key = Parvus.Config.Binds.Aimbot,Mouse = true,Callback = function(Bool,Key)
                Parvus.Config.Binds.Aimbot = Key or "NONE"
                Aimbot = Parvus.Config.AimAssist.Aimbot.Enabled and Bool
            end})
            AimbotSection:Slider({Name = "Smoothness",Min = 0,Max = 100,Value = Parvus.Config.AimAssist.Aimbot.Sensitivity * 100,Unit = "%",Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.Sensitivity = Number / 100
            end})
            AimbotSection:Slider({Name = "Field of View",Min = 0,Max = 500,Value = Parvus.Config.AimAssist.Aimbot.FieldOfView,Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.FieldOfView = Number
            end})
            AimbotSection:Dropdown({Name = "Priority",Default = Parvus.Config.AimAssist.Aimbot.Priority,List = {"Head","HumanoidRootPart"},Callback = function(String)
                Parvus.Config.AimAssist.Aimbot.Priority = String
            end})
        end
        local SilentAimSection = AimAssistTab:Section({Name = "Silent Aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.SilentAim.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.Enabled = Bool
            end}):Keybind({Key = Parvus.Config.Binds.SilentAim,Mouse = true,Callback = function(Bool,Key)
                Parvus.Config.Binds.SilentAim = Key or "NONE"
            end})
            SilentAimSection:Toggle({Name = "Visibility Check",Value = Parvus.Config.AimAssist.SilentAim.WallCheck,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.WallCheck = Bool
            end})
            SilentAimSection:Slider({Name = "Hit Chance",Min = 0,Max = 100,Value = Parvus.Config.AimAssist.SilentAim.HitChance,Unit = "%",Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.HitChance = Number
            end})
            SilentAimSection:Slider({Name = "Field of View",Min = 0,Max = 500,Value = Parvus.Config.AimAssist.SilentAim.FieldOfView,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.FieldOfView = Number
            end})
            SilentAimSection:Dropdown({Name = "Priority",Default = Parvus.Config.AimAssist.SilentAim.Priority,List = {"Head","HumanoidRootPart"},Callback = function(String)
                Parvus.Config.AimAssist.SilentAim.Priority = String
            end})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.PlayerESP.AllyColor),Callback = function(Color,Table)
                Parvus.Config.PlayerESP.AllyColor = Table
            end})
            GlobalSection:Colorpicker({Name = "Enemy Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.PlayerESP.EnemyColor),Callback = function(Color,Table)
                Parvus.Config.PlayerESP.EnemyColor = Table
            end})
            GlobalSection:Toggle({Name = "Use Team Color",Value = Parvus.Config.PlayerESP.TeamColor,Callback = function(Bool)
                Parvus.Config.PlayerESP.TeamColor = Bool
            end})
            GlobalSection:Toggle({Name = "Team Check",Value = Parvus.Config.PlayerESP.TeamCheck,Callback = function(Bool)
                Parvus.Config.PlayerESP.TeamCheck = Bool
            end})
        end
        local BoxSection = VisualsTab:Section({Name = "Box",Side = "Left"}) do
            BoxSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.BoxVisible,Callback = function(Bool)
                Parvus.Config.PlayerESP.BoxVisible = Bool
            end})
            BoxSection:Toggle({Name = "Text",Value = Parvus.Config.PlayerESP.Text.Visible,Callback = function(Bool)
                Parvus.Config.PlayerESP.Text.Visible = Bool
            end})
            BoxSection:Toggle({Name = "Text Autoscale",Value = Parvus.Config.PlayerESP.Text.AutoScale,Callback = function(Bool)
                Parvus.Config.PlayerESP.Text.AutoScale = Bool
            end})
            BoxSection:Slider({Name = "Text Size",Min = 14,Max = 28,Value = Parvus.Config.PlayerESP.Text.Size,Callback = function(Number)
                Parvus.Config.PlayerESP.Text.Size = Number
            end})
        end
        local HighlightSection = VisualsTab:Section({Name = "Highlight",Side = "Left"}) do
            HighlightSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Highlight.Visible,Callback = function(Bool)
                Parvus.Config.PlayerESP.Highlight.Visible = Bool
            end})
            HighlightSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Highlight.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Highlight.Transparency = Number
            end})
            HighlightSection:Colorpicker({Name = "Outline Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.PlayerESP.Highlight.OutlineColor),Callback = function(Color,Table)
                Parvus.Config.PlayerESP.Highlight.OutlineColor = Table
            end})
            HighlightSection:Slider({Name = "Outline Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Highlight.OutlineTransparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Highlight.OutlineTransparency = Number
            end})
        end
        local HeadCircleSection = VisualsTab:Section({Name = "Head Circle",Side = "Right"}) do
            HeadCircleSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.HeadCircle.Visible,Callback = function(Bool)
                Parvus.Config.PlayerESP.HeadCircle.Visible = Bool
            end})
            HeadCircleSection:Toggle({Name = "Filled",Value = Parvus.Config.PlayerESP.HeadCircle.Filled,Callback = function(Bool)
                Parvus.Config.PlayerESP.HeadCircle.Filled = Bool
            end})
            HeadCircleSection:Toggle({Name = "Autoscale",Value = Parvus.Config.PlayerESP.HeadCircle.AutoScale,Callback = function(Bool)
                Parvus.Config.PlayerESP.HeadCircle.AutoScale = Bool
            end})
            HeadCircleSection:Slider({Name = "Radius",Min = 1,Max = 10,Value = Parvus.Config.PlayerESP.HeadCircle.Radius,Callback = function(Number)
                Parvus.Config.PlayerESP.HeadCircle.Radius = Number
            end})
            HeadCircleSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.PlayerESP.HeadCircle.NumSides,Callback = function(Number)
                Parvus.Config.PlayerESP.HeadCircle.NumSides = Number
            end})
        end
        local AFoVSection = VisualsTab:Section({Name = "Aimbot FoV Circle",Side = "Right"}) do
            AFoVSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.Aimbot.Circle.Visible,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Circle.Visible = Bool
            end})
            AFoVSection:Toggle({Name = "Filled",Value = Parvus.Config.AimAssist.Aimbot.Circle.Filled,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Circle.Filled = Bool
            end})
            AFoVSection:Colorpicker({Name = "Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.AimAssist.Aimbot.Circle.Color),Callback = function(Color,Table)
                Parvus.Config.AimAssist.Aimbot.Circle.Color = Table
            end})
            AFoVSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.AimAssist.Aimbot.Circle.Transparency,Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.Circle.Transparency = Number
            end})
            AFoVSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.AimAssist.Aimbot.Circle.Thickness,Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.Circle.Thickness = Number
            end})
            AFoVSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.AimAssist.Aimbot.Circle.NumSides,Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.Circle.NumSides = Number
            end})
        end
        local SAFoVSection = VisualsTab:Section({Name = "Silent Aim FoV Circle",Side = "Right"}) do
            SAFoVSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.SilentAim.Circle.Visible,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.Circle.Visible = Bool
            end})
            SAFoVSection:Toggle({Name = "Filled",Value = Parvus.Config.AimAssist.SilentAim.Circle.Filled,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.Circle.Filled = Bool
            end})
            SAFoVSection:Colorpicker({Name = "Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.AimAssist.SilentAim.Circle.Color),Callback = function(Color,Table)
                Parvus.Config.AimAssist.SilentAim.Circle.Color = Table
            end})
            SAFoVSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.AimAssist.SilentAim.Circle.Transparency,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.Circle.Transparency = Number
            end})
            SAFoVSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.AimAssist.SilentAim.Circle.Thickness,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.Circle.Thickness = Number
            end})
            SAFoVSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.AimAssist.SilentAim.Circle.NumSides,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.Circle.NumSides = Number
            end})
        end
        --[[
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
        end
        ]]
    end
    local SettingsTab = Window:Tab({Name = "Settings"}) do
        local MenuSection = SettingsTab:Section({Name = "Menu",Side = "Left"}) do
            MenuSection:Toggle({Name = "Enabled",Value = Window.Enabled,Callback = function(Bool) 
                Window:Toggle(Bool)
            end}):Keybind({Key = Parvus.Config.UI.Keybind,Callback = function(Bool,Key)
                Parvus.Config.UI.Keybind = Key or "NONE"
            end})
            MenuSection:Toggle({Name = "Close On Exec",Value = not Parvus.Config.UI.Enabled,Callback = function(Bool) 
                Parvus.Config.UI.Enabled = not Bool
            end})
            MenuSection:Colorpicker({Name = "Color",Color = Window.Color,Callback = function(Color,Table)
                Parvus.Config.UI.Color = Table
                Window:ChangeColor(Color)
            end})
        end
        SettingsTab:Button({Name = "Server Hop",Side = "Left",Callback = function()
            local x = {}
            for _, v in ipairs(HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
                if type(v) == "table" and v.id ~= game.JobId then
                    x[#x + 1] = v.id
                end
            end
            if #x > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
            else
                Parvus.Utilities.UI:Notification("Parvus Hub","Couldn't find a server",5)
            end
        end})
        SettingsTab:Button({Name = "Join Discord Server",Side = "Left",Callback = function()
            local Request = (syn and syn.request) or request
            Request({
                ["Url"] = "http://localhost:6463/rpc?v=1",
                ["Method"] = "POST",
                ["Headers"] = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com"
                },
                ["Body"] = HttpService:JSONEncode({
                    ["cmd"] = "INVITE_BROWSER",
                    ["nonce"] = string.lower(HttpService:GenerateGUID(false)),
                    ["args"] = {
                        ["code"] = "JKywVqjV6m"
                    }
                })
            })
        end}):ToolTip("Join for support, updates and more!")
        local BackgroundSection = SettingsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Dropdown({Name = "Image",Default = Parvus.Config.UI.Background,
            List = {"Legacy","Hearts","Abstract","Hexagon","Circles","Lace With Flowers","Floral"},
            Callback = function(String)
                Parvus.Config.UI.Background = String
                if String == "Legacy" then
                    Window.Background.Image = "rbxassetid://2151741365"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://2151741365"
                elseif String == "Hearts" then
                    Window.Background.Image = "rbxassetid://6073763717"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6073763717"
                elseif String == "Abstract" then
                    Window.Background.Image = "rbxassetid://6073743871"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6073743871"
                elseif String == "Hexagon" then
                    Window.Background.Image = "rbxassetid://6073628839"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6073628839"
                elseif String == "Circles" then
                    Window.Background.Image = "rbxassetid://6071579801"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6071579801"
                elseif String == "Lace With Flowers" then
                    Window.Background.Image = "rbxassetid://6071575925"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6071575925"
                elseif String == "Floral" then
                    Window.Background.Image = "rbxassetid://5553946656"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://5553946656"
                end
            end})
            Window.Background.Image = Parvus.Config.UI.BackgroundId
            BackgroundSection:Textbox({Name = "Custom Image",Text = "",Placeholder = "rbxassetid://ImageId",Callback = function(String)
                Window.Background.Image = String
                Parvus.Config.UI.BackgroundId = String
            end})
            Window.Background.ImageColor3 = Parvus.Utilities.Config:TableToColor(Parvus.Config.UI.BackgroundColor)
            BackgroundSection:Colorpicker({Name = "Color",Color = Window.Background.ImageColor3,Callback = function(Color,Table)
                Parvus.Config.UI.BackgroundColor = Table
                Window.Background.ImageColor3 = Color
            end})
            Window.Background.ImageTransparency = Parvus.Config.UI.BackgroundTransparency
            BackgroundSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Window.Background.ImageTransparency,Callback = function(Number)
                Parvus.Config.UI.BackgroundTransparency = Number
                Window.Background.ImageTransparency = Number
            end})
            Window.Background.TileSize = UDim2.new(0,Parvus.Config.UI.TileSize,0,Parvus.Config.UI.TileSize)
            BackgroundSection:Slider({Name = "Tile Offset",Min = 74, Max = 296,Value = Window.Background.TileSize.X.Offset,Callback = function(Number)
                Parvus.Config.UI.TileSize = Number
                Window.Background.TileSize = UDim2.new(0,Number,0,Number)
            end})
        end
        local CreditsSection = SettingsTab:Section({Name = "Credits",Side = "Right"}) do
            CreditsSection:Label({Text = "Thanks to Jan for this awesome background patterns."})
            CreditsSection:Label({Text = "Thanks to Infinite Yield Team for server hop."})
            CreditsSection:Label({Text = "Thanks to coasts for his Universal ESP."})
            CreditsSection:Label({Text = "Thanks to el3tric for Bracket V2."})
            CreditsSection:Label({Text = "And thanks to AlexR32#0157 for making this script."})
            CreditsSection:Label({Text = "❤️ ❤️ ❤️ ❤️"})
        end
    end
end

local function TeamCheck(Target)
    if Parvus.Config.AimAssist.TeamCheck then
        return LocalPlayer.Team ~= Target.Team
    end
    return true
end

local function WallCheck(Enabled,Hitbox,Character)
    if Enabled and Character then
        local Camera = Workspace.CurrentCamera
        local RaycastParameters = RaycastParams.new()
        RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character,Character}
        RaycastParameters.IgnoreWater = true
        
        if Workspace:Raycast(Camera.CFrame.Position, Hitbox.Position - Camera.CFrame.Position, RaycastParameters) then
            return false
        end
    end
    return true
end

local function GetTarget(FoV,Priority,Visibility)
    local Camera = Workspace.CurrentCamera
    local FieldOfView = FoV
    local ClosestTarget = nil

    for Index, Target in pairs(PlayerService:GetPlayers()) do
        local Character = Target.Character
        local Hitbox = (Character and Character:FindFirstChild(Priority)) or (Character and (Character:IsA("Model") and Character.PrimaryPart))
        local Health = Character and (Character:FindFirstChildOfClass("Humanoid") and Character:FindFirstChildOfClass("Humanoid").Health > 0)
        if Target ~= LocalPlayer and Hitbox and Health and TeamCheck(Target) then
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
            local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
            if OnScreen and WallCheck(Visibility,Hitbox,Character) and FieldOfView > Magnitude then
                FieldOfView = Magnitude
                ClosestTarget = Hitbox
            end
        end
    end

    return ClosestTarget
end

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if Parvus.Config.AimAssist.SilentAim.Enabled and SilentAimTarget then
        local Camera = Workspace.CurrentCamera
        local HitChance = math.random(0,100) <= Parvus.Config.AimAssist.SilentAim.HitChance
        if getnamecallmethod() == "Raycast" and HitChance then
            args[2] = SilentAimTarget.Position - Camera.CFrame.Position
        elseif getnamecallmethod() == "FindPartOnRayWithIgnoreList" and HitChance then
            args[1] = Ray.new(args[1].Origin,SilentAimTarget.Position - Camera.CFrame.Position)
        end
    end
    return __namecall(self, unpack(args))
end)

local AimbotCircle = Drawing.new("Circle")
local SilentAimCircle = Drawing.new("Circle")
RunService.Heartbeat:Connect(function()
    AimbotCircle.Visible = Parvus.Config.AimAssist.Aimbot.Circle.Visible
    if AimbotCircle.Visible then
        AimbotCircle.Transparency = Parvus.Config.AimAssist.Aimbot.Circle.Transparency
        AimbotCircle.Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.AimAssist.Aimbot.Circle.Color)
        AimbotCircle.Thickness = Parvus.Config.AimAssist.Aimbot.Circle.Thickness
        AimbotCircle.NumSides = Parvus.Config.AimAssist.Aimbot.Circle.NumSides
        AimbotCircle.Radius = Parvus.Config.AimAssist.Aimbot.FieldOfView
        AimbotCircle.Filled = Parvus.Config.AimAssist.Aimbot.Circle.Filled
        AimbotCircle.Position = UserInputService:GetMouseLocation()
    end
    SilentAimCircle.Visible = Parvus.Config.AimAssist.SilentAim.Circle.Visible
    if SilentAimCircle.Visible then
        SilentAimCircle.Transparency = Parvus.Config.AimAssist.SilentAim.Circle.Transparency
        SilentAimCircle.Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.AimAssist.SilentAim.Circle.Color)
        SilentAimCircle.Thickness = Parvus.Config.AimAssist.SilentAim.Circle.Thickness
        SilentAimCircle.NumSides = Parvus.Config.AimAssist.SilentAim.Circle.NumSides
        SilentAimCircle.Radius = Parvus.Config.AimAssist.SilentAim.FieldOfView
        SilentAimCircle.Filled = Parvus.Config.AimAssist.SilentAim.Circle.Filled
        SilentAimCircle.Position = UserInputService:GetMouseLocation()
    end

    if Parvus.Config.AimAssist.SilentAim.Enabled then
        SilentAimTarget = GetTarget(
            Parvus.Config.AimAssist.SilentAim.FieldOfView,
            Parvus.Config.AimAssist.SilentAim.Priority,
            Parvus.Config.AimAssist.SilentAim.WallCheck
        )
    else
        SilentAimTarget = nil
    end
    if Aimbot then
        AimbotTarget = GetTarget(
            Parvus.Config.AimAssist.Aimbot.FieldOfView,
            Parvus.Config.AimAssist.Aimbot.Priority,
            Parvus.Config.AimAssist.Aimbot.WallCheck
        )

        if AimbotTarget then
            local Camera = Workspace.CurrentCamera
            local Mouse = UserInputService:GetMouseLocation()
            local TargetOnScreen = Camera:WorldToViewportPoint(AimbotTarget.Position)
            mousemoverel((TargetOnScreen.X - Mouse.X) * Parvus.Config.AimAssist.Aimbot.Sensitivity, (TargetOnScreen.Y - Mouse.Y) * Parvus.Config.AimAssist.Aimbot.Sensitivity)
        end
    else
        AimbotTarget = nil
    end
end)

for Index, Player in pairs(PlayerService:GetPlayers()) do
    if Player ~= LocalPlayer then
        Parvus.Utilities.ESP:Add("Player", Player, Parvus.Config.PlayerESP)
    end
end
PlayerService.PlayerAdded:Connect(function(Player)
    Parvus.Utilities.ESP:Add("Player", Player, Parvus.Config.PlayerESP)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    if Player == LocalPlayer then Parvus.Utilities.Config:WriteJSON(Parvus.Current,Parvus.Config) end
    Parvus.Utilities.ESP:Remove(Player)
end)
