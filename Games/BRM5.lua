local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = PlayerService.LocalPlayer

repeat task.wait() until Workspace:FindFirstChild("Enemies")
local AimbotTarget, SilentAimTarget, Aimbot,
NPCFolder, GroundTip, AircraftTip = nil, nil,
false, Workspace.Enemies, nil, nil

if Parvus.Debug then
    loadfile("Parvus/Utilities/Cursor.lua")()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Parvus/main/Utilities/Cursor.lua"))()
end

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
    NPCESP = {
        AllyColor = {0.25,1,0.25,0},
        EnemyColor = {1,0.25,0.25,0},

        TeamColor = false,
        TeamCheck = false,

        BoxVisible = false,
        Text = {
            Text = "Enemy NPC",
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
        TargetMode = "NPC",
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
    GameFeatures = {
        EnvEnable = false,
        EnvTime = 12,
        EnvFog = 0.25,

        NoRecoil = false,
        InstantHit = false,
        UnlockFiremodes = false,
        RapidFire = false,
        RapidFireValue = 1000,

        Speedhack = false,
        SpeedhackValue = 32,

        Vehicle = false,
        VehicleSpeed = 60,
        VehicleAcceleration = 1,

        Helicopter = false,
        HelicopterSpeed = 200
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
        SilentAim = "NONE",
        RapidFire = "NONE",
        Speedhack = "NONE",
        Vehicle = "NONE",
        Helicopter = "NONE"
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
            AimbotSection:Dropdown({Name = "Target Mode",Default = Parvus.Config.AimAssist.TargetMode,List = {"Player","NPC"},Callback = function(String)
                Parvus.Config.AimAssist.TargetMode = String
            end}):ToolTip("Affects Aimbot and Silent Aim")
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
    local NPCVisualsTab = Window:Tab({Name = "NPC Visuals"}) do
        local GlobalSection = NPCVisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.NPCESP.AllyColor),Callback = function(Color,Table)
                Parvus.Config.NPCESP.AllyColor = Table
            end})
            GlobalSection:Colorpicker({Name = "Enemy Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.NPCESP.EnemyColor),Callback = function(Color,Table)
                Parvus.Config.NPCESP.EnemyColor = Table
            end})
        end
        local BoxSection = NPCVisualsTab:Section({Name = "Box",Side = "Left"}) do
            BoxSection:Toggle({Name = "Enabled",Value = Parvus.Config.NPCESP.BoxVisible,Callback = function(Bool)
                Parvus.Config.NPCESP.BoxVisible = Bool
            end})
            BoxSection:Toggle({Name = "Text",Value = Parvus.Config.NPCESP.Text.Visible,Callback = function(Bool)
                Parvus.Config.NPCESP.Text.Visible = Bool
            end})
            BoxSection:Toggle({Name = "Text Autoscale",Value = Parvus.Config.NPCESP.Text.AutoScale,Callback = function(Bool)
                Parvus.Config.NPCESP.Text.AutoScale = Bool
            end})
            BoxSection:Slider({Name = "Text Size",Min = 14,Max = 28,Value = Parvus.Config.NPCESP.Text.Size,Callback = function(Number)
                Parvus.Config.NPCESP.Text.Size = Number
            end})
            BoxSection:Textbox({Name = "NPC Name",Text = Parvus.Config.NPCESP.Text.Text,Placeholder = "NPC Name",Callback = function(String)
                Parvus.Config.NPCESP.Text.Text = String
            end})
        end
        local HighlightSection = NPCVisualsTab:Section({Name = "Highlight",Side = "Left"}) do
            HighlightSection:Toggle({Name = "Enabled",Value = Parvus.Config.NPCESP.Highlight.Visible,Callback = function(Bool)
                Parvus.Config.NPCESP.Highlight.Visible = Bool
            end})
            HighlightSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.NPCESP.Highlight.Transparency,Callback = function(Number)
                Parvus.Config.NPCESP.Highlight.Transparency = Number
            end})
            HighlightSection:Colorpicker({Name = "Outline Color",Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.NPCESP.Highlight.OutlineColor),Callback = function(Color,Table)
                Parvus.Config.NPCESP.Highlight.OutlineColor = Table
            end})
            HighlightSection:Slider({Name = "Outline Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.NPCESP.Highlight.OutlineTransparency,Callback = function(Number)
                Parvus.Config.NPCESP.Highlight.OutlineTransparency = Number
            end})
        end
        local HeadCircleSection = NPCVisualsTab:Section({Name = "Head Circle",Side = "Right"}) do
            HeadCircleSection:Toggle({Name = "Enabled",Value = Parvus.Config.NPCESP.HeadCircle.Visible,Callback = function(Bool)
                Parvus.Config.NPCESP.HeadCircle.Visible = Bool
            end})
            HeadCircleSection:Toggle({Name = "Filled",Value = Parvus.Config.NPCESP.HeadCircle.Filled,Callback = function(Bool)
                Parvus.Config.NPCESP.HeadCircle.Filled = Bool
            end})
            HeadCircleSection:Toggle({Name = "Autoscale",Value = Parvus.Config.NPCESP.HeadCircle.AutoScale,Callback = function(Bool)
                Parvus.Config.NPCESP.HeadCircle.AutoScale = Bool
            end})
            HeadCircleSection:Slider({Name = "Radius",Min = 1,Max = 10,Value = Parvus.Config.NPCESP.HeadCircle.Radius,Callback = function(Number)
                Parvus.Config.NPCESP.HeadCircle.Radius = Number
            end})
            HeadCircleSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.NPCESP.HeadCircle.NumSides,Callback = function(Number)
                Parvus.Config.NPCESP.HeadCircle.NumSides = Number
            end})
        end
        --[[
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
        end
        ]]
    end
    local GameTab = Window:Tab({Name = Parvus.Current}) do
        local EnvSection = GameTab:Section({Name = "Environment"}) do
            EnvSection:Toggle({Name = "Enable",Value = Parvus.Config.GameFeatures.EnvEnable,Callback = function(Bool)
                Parvus.Config.GameFeatures.EnvEnable = Bool
            end})
            EnvSection:Slider({Name = "Clock Time",Min = 0,Max = 24,Value = Parvus.Config.GameFeatures.EnvTime,Callback = function(Number)
                Parvus.Config.GameFeatures.EnvTime = Number
            end})
            EnvSection:Slider({Name = "Fog Density",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.GameFeatures.EnvFog,Callback = function(Number)
                Parvus.Config.GameFeatures.EnvFog = Number
            end})
        end
        local WeaponSection = GameTab:Section({Name = "Weapon"}) do
            WeaponSection:Toggle({Name = "No Recoil",Value = Parvus.Config.GameFeatures.NoRecoil,Callback = function(Bool)
                Parvus.Config.GameFeatures.NoRecoil = Bool
            end})
            WeaponSection:Toggle({Name = "Instant Hit",Value = Parvus.Config.GameFeatures.InstantHit,Callback = function(Bool)
                Parvus.Config.GameFeatures.InstantHit = Bool
            end}):ToolTip("silent aim works better with it")
            WeaponSection:Toggle({Name = "Unlock Firemodes",Value = Parvus.Config.GameFeatures.UnlockFiremodes,Callback = function(Bool)
                Parvus.Config.GameFeatures.UnlockFiremodes = Bool
            end}):ToolTip("re-equip your weapon to make it work")
            local RapidFireToggle = WeaponSection:Toggle({Name = "Rapid Fire",Value = Parvus.Config.GameFeatures.RapidFire,Callback = function(Bool)
                Parvus.Config.GameFeatures.RapidFire = Bool
            end})
            RapidFireToggle:Keybind({Key = Parvus.Config.Binds.RapidFire,Callback = function(Bool,Key)
                Parvus.Config.Binds.RapidFire = Key or "NONE"
            end})
            RapidFireToggle:ToolTip("re-equip your weapon to disable")
            WeaponSection:Slider({Name = "Round Per Minute",Min = 45,Max = 1000,Value = Parvus.Config.GameFeatures.RapidFireValue,Callback = function(Number)
                Parvus.Config.GameFeatures.RapidFireValue = Number
            end})
        end
        local CharSection = GameTab:Section({Name = "Character"}) do
            CharSection:Toggle({Name = "Speedhack",Value = Parvus.Config.GameFeatures.Speedhack,Callback = function(Bool)
                Parvus.Config.GameFeatures.Speedhack = Bool
            end}):Keybind({Key = Parvus.Config.Binds.Speedhack,Callback = function(Bool,Key)
                Parvus.Config.Binds.Speedhack = Key or "NONE"
            end})
            CharSection:Slider({Name = "Speed",Min = 16,Max = 1000,Value = Parvus.Config.GameFeatures.SpeedhackValue,Callback = function(Number)
                Parvus.Config.GameFeatures.SpeedhackValue = Number
            end})
        end
        local VehSection = GameTab:Section({Name = "Vehicle Settings"}) do
            VehSection:Toggle({Name = "Enable",Value = Parvus.Config.GameFeatures.Vehicle,Callback = function(Bool)
                Parvus.Config.GameFeatures.Vehicle = Bool
            end}):Keybind({Key = Parvus.Config.Binds.Vehicle,Callback = function(Bool,Key)
                Parvus.Config.Binds.Vehicle = Key or "NONE"
            end})
            VehSection:Slider({Name = "Speed",Min = 0,Max = 1000,Value = Parvus.Config.GameFeatures.VehicleSpeed,Callback = function(Number)
                Parvus.Config.GameFeatures.VehicleSpeed = Number
            end})
            VehSection:Slider({Name = "Acceleration",Min = 1,Max = 50,Value = Parvus.Config.GameFeatures.VehicleAcceleration,Callback = function(Number)
                Parvus.Config.GameFeatures.VehicleAcceleration = Number
            end}):ToolTip("lower = faster")
        end
        local HeliSection = GameTab:Section({Name = "Helicopter Settings"}) do
            HeliSection:Toggle({Name = "Enable",Value = Parvus.Config.GameFeatures.Helicopter,Callback = function(Bool)
                Parvus.Config.GameFeatures.Helicopter = Bool
            end}):Keybind({Key = Parvus.Config.Binds.Helicopter,Callback = function(Bool,Key)
                Parvus.Config.Binds.Helicopter = Key or "NONE"
            end})
            HeliSection:Slider({Name = "Speed",Min = 0,Max = 500,Value = Parvus.Config.GameFeatures.HelicopterSpeed,Callback = function(Number)
                Parvus.Config.GameFeatures.HelicopterSpeed = Number
            end})
        end
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

    if Parvus.Config.AimAssist.TargetMode == "NPC" then
        for Index, Target in pairs(NPCFolder:GetChildren()) do
            local Hitbox = Target:FindFirstChild(Priority) or (Target:IsA("Model") and Target.PrimaryPart)
            local Health = Target:FindFirstChildOfClass("Humanoid") and Target:FindFirstChildOfClass("Humanoid").Health > 0
            if Hitbox and Health then
                local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if OnScreen and WallCheck(Visibility,Hitbox,Target) and FieldOfView > Magnitude then
                    FieldOfView = Magnitude
                    ClosestTarget = Hitbox
                end
            end
        end
    elseif Parvus.Config.AimAssist.TargetMode == "Player" then
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
    end

    return ClosestTarget
end

local function requireGameModule(Name)
    for Index, Instance in pairs(getloadedmodules()) do
        if Instance.Name == Name then
            return require(Instance)
        end
    end
end

local ControllerClass = requireGameModule("ControllerClass")
local controllerOld
while task.wait() do
    if ControllerClass and ControllerClass.LateUpdate then
        controllerOld = ControllerClass.LateUpdate
        break
    else
        ControllerClass = requireGameModule("ControllerClass")
    end
end
if ControllerClass and controllerOld then
    ControllerClass.LateUpdate = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.Speedhack then
            args[1].Speed = Parvus.Config.GameFeatures.SpeedhackValue
        end
        return controllerOld(...)
    end
end

local CharacterCamera = requireGameModule("CharacterCamera")
local cameraOld
while task.wait() do
    if CharacterCamera and CharacterCamera.Update then
        cameraOld = CharacterCamera.Update
        break
    else
        CharacterCamera = requireGameModule("CharacterCamera")
    end
end
if CharacterCamera and cameraOld then
    CharacterCamera.Update = function(...)
        local args = {...}
        args[1]._shakes = {}
        args[1]._bob = 0
        if Parvus.Config.GameFeatures.NoRecoil then
            args[1]._recoil.Velocity = Vector3.zero
        end
        return cameraOld(...)
    end
end

local TurretCamera = requireGameModule("TurretCamera")
local turretCamOld
while task.wait() do
    if TurretCamera and TurretCamera.Update then
        turretCamOld = TurretCamera.Update
        break
    else
        TurretCamera = requireGameModule("TurretCamera")
    end
end
if TurretCamera and turretCamOld then
    TurretCamera.Update = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.NoRecoil then
            args[1]._recoil.Velocity = Vector3.zero
        end
        return turretCamOld(...)
    end
end

local FirearmInventory = requireGameModule("FirearmInventory")
local firearmDischargeOld
local firearmNewOld
while task.wait() do
    if FirearmInventory and FirearmInventory._discharge and FirearmInventory.new then
        firearmDischargeOld = FirearmInventory._discharge
        firearmNewOld = FirearmInventory.new
        break
    else
        FirearmInventory = requireGameModule("FirearmInventory")
    end
end
if FirearmInventory and firearmDischargeOld and firearmNewOld then
    FirearmInventory._discharge = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.RapidFire then
            args[1]._config.Tune.RPM = Parvus.Config.GameFeatures.RapidFireValue
        end
        if Parvus.Config.GameFeatures.InstantHit then
            args[1]._config.Tune.Velocity = 9e9
        end
        return firearmDischargeOld(...)
    end
    FirearmInventory.new = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.UnlockFiremodes then
            if not table.find(args[2].Tune.Firemodes,1) then
                table.insert(args[2].Tune.Firemodes,1)
            end
            if not table.find(args[2].Tune.Firemodes,2) then
                table.insert(args[2].Tune.Firemodes,2)
            end
            if not table.find(args[2].Tune.Firemodes,3) then
                table.insert(args[2].Tune.Firemodes,3)
            end
            args[2].Mode = 1
        end
        return firearmNewOld(...)
    end
end

local GroundMovement = requireGameModule("GroundMovement")
local groundOld
while task.wait() do
    if GroundMovement and GroundMovement.Update then
        groundOld = GroundMovement.Update
        break
    else
        GroundMovement = requireGameModule("GroundMovement")
    end
end
if GroundMovement and groundOld then
    GroundMovement.Update = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.Vehicle then
            args[1]._tune.Speed = Parvus.Config.GameFeatures.VehicleSpeed
            args[1]._tune.Accelerate = Parvus.Config.GameFeatures.VehicleAcceleration
        end
        return groundOld(...)
    end
end

local HelicopterMovement = requireGameModule("HelicopterMovement")
local heliOld
while task.wait() do
    if HelicopterMovement and HelicopterMovement.Update then
        heliOld = HelicopterMovement.Update
        break
    else
        HelicopterMovement = requireGameModule("HelicopterMovement")
    end
end
if HelicopterMovement and heliOld then
    HelicopterMovement.Update = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.Helicopter then
            args[1]._tune.Speed = Parvus.Config.GameFeatures.HelicopterSpeed
        end
        return heliOld(...)
    end
end

local AircraftMovement = requireGameModule("AircraftMovement")
local aircraftDischargeOld
while task.wait() do
    if AircraftMovement and AircraftMovement._discharge then
        aircraftDischargeOld = AircraftMovement._discharge
        break
    else
        AircraftMovement = requireGameModule("AircraftMovement")
    end
end
if AircraftMovement and aircraftDischargeOld then
    AircraftMovement._discharge = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.InstantHit then
            args[1]._tune.Velocity = 9e9
        end
        AircraftTip = args[1]._tip
        return aircraftDischargeOld(...)
    end
end

local TurretMovement = requireGameModule("TurretMovement")
local turretOld
while task.wait() do
    if TurretMovement and TurretMovement._discharge then
        turretOld = TurretMovement._discharge
        break
    else
        TurretMovement = requireGameModule("TurretMovement")
    end
end
if TurretMovement and turretOld then
    TurretMovement._discharge = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.InstantHit then
            args[1]._tune.Velocity = 9e9
        end
        GroundTip = args[1]._tip
        return turretOld(...)
    end
end

local EnvironmentService = requireGameModule("EnvironmentService")
local environmentOld
while task.wait() do
    if EnvironmentService and EnvironmentService.Update then
        environmentOld = EnvironmentService.Update
        break
    else
        EnvironmentService = requireGameModule("EnvironmentService")
    end
end
if EnvironmentService and environmentOld then
    EnvironmentService.Update = function(...)
        local args = {...}
        if Parvus.Config.GameFeatures.EnvEnable then
            args[1]._atmoshperes.Default.Density = Parvus.Config.GameFeatures.EnvFog
            if args[1]._atmoshperes.Desert and args[1]._atmoshperes.Snow then
                args[1]._atmoshperes.Desert.Density = Parvus.Config.GameFeatures.EnvFog
                args[1]._atmoshperes.Snow.Density = Parvus.Config.GameFeatures.EnvFog
            end
        end
        return environmentOld(...)
    end
end

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if Parvus.Config.AimAssist.SilentAim.Enabled and SilentAimTarget then
        if getnamecallmethod() == "Raycast" then
            local Camera = Workspace.CurrentCamera
            local HitChance = math.random(0,100) <= Parvus.Config.AimAssist.SilentAim.HitChance
            if args[1] == Camera.CFrame.Position and HitChance then
                args[2] = SilentAimTarget.Position - Camera.CFrame.Position
            elseif AircraftTip and args[1] == AircraftTip.WorldCFrame.Position and HitChance then
                args[2] = SilentAimTarget.Position - AircraftTip.WorldCFrame.Position
            elseif GroundTip and args[1] == GroundTip.WorldCFrame.Position and HitChance then
                args[2] = SilentAimTarget.Position - GroundTip.WorldCFrame.Position
            end
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

    if Parvus.Config.GameFeatures.EnvEnable then
        Lighting.ClockTime = Parvus.Config.GameFeatures.EnvTime
    end
end)

for Index, NPC in pairs(NPCFolder:GetChildren()) do
    if NPC:WaitForChild("Vest",0.5) then
        Parvus.Utilities.ESP:Add("NPC", NPC, Parvus.Config.NPCESP)
    end
end
NPCFolder.ChildAdded:Connect(function(NPC)
    if NPC:WaitForChild("Vest",0.5) then
        Parvus.Utilities.ESP:Add("NPC", NPC, Parvus.Config.NPCESP)
    end
end)
NPCFolder.ChildRemoved:Connect(function(NPC)
    Parvus.Utilities.ESP:Remove(NPC)
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
