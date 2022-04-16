local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = PlayerService.LocalPlayer
local Aimbot, SilentAim, PredictedVelocity, PredictedGravity, GravityCorrection, Tortoiseshell
= false, nil, 1600, 150, 2, require(ReplicatedStorage.TS)

local BanReasons = {
    "Unsafe function",
    "Camera object", -- Crash
    "Geometry deleted", -- Crash
    "Deleted remote", -- Crash
    "Looking hard",
    "Unbound gloop", -- Crash
    "_G", -- Crash
    "Alternate mode",
    "Shooting hard",
    "Fallback config",
    "Int check",
    "Coregui instance",
    "Floating",
    "Root",
    "Hitbox extender"
}

Parvus.Config = Parvus.Utilities.Config:ReadJSON(Parvus.Current, {
    PlayerESP = {
        AllyColor = {0.3333333432674408,1,1,0,false},
        EnemyColor = {1,1,1,0,false},

        TeamColor = false,
        TeamCheck = true,
        Highlight = {
            Enabled = false,
            Transparency = 0.5,
            OutlineColor = {0,0,0,0.5,false}
        },
        Box = {
            Enabled = false,
            Outline = true,
            Filled = false,
            Thickness = 1,
            Transparency = 1,
            Info = {
                Enabled = false,
                AutoScale = true,
                Transparency = 1,
                Size = 16
            }
        },
        Other = {
            Head = {
                Enabled = false,
                AutoScale = true,
                Filled = true,
                Radius = 8,
                NumSides = 4,
                Thickness = 1,
                Transparency = 1
            },
            Tracer = {
                Enabled = false,
                Thickness = 1,
                Transparency = 1,
                From = "ScreenBottom"
            },
            Arrow = {
                Enabled = false,
                Filled = true,
                Width = 16,
                Height = 16,
                Thickness = 1,
                Transparency = 1,
                DistanceFromCenter = 80
            }
        }
    },
    AimAssist = {
        AutoShoot = false,
        Trigger = {
            Enabled = false,
            WallCheck = true,
            DynamicFoV = false,
            FieldOfView = 10,
            Priority = {"Head","Neck","Chest","Abdomen","Hips"},
            Delay = 0.15,
            HoldTime = 0,
            Prediction = {
                Enabled = true,
                Velocity = 1600,
            },
            Circle = {
                Visible = true,
                Transparency = 0.5,
                Color = {1,1,1,0.5,false},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        },
        SilentAim = {
            Enabled = false,
            WallCheck = false,
            DynamicFoV = false,
            HitChance = 100,
            FieldOfView = 50,
            Priority = {"Head"},
            Circle = {
                Visible = true,
                Transparency = 0.5,
                Color = {0.6666666865348816,1,1,0.5,false},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        },
        Aimbot = {
            Enabled = false,
            WallCheck = false,
            DynamicFoV = false,
            Sensitivity = 0.25,
            FieldOfView = 100,
            Priority = {"Head","Neck","Chest","Abdomen","Hips"},
            Prediction = {
                Enabled = false,
                Velocity = 1600,
            },
            Circle = {
                Visible = true,
                Transparency = 0.5,
                Color = {1,1,1,0.5,false},
                Thickness = 1,
                NumSides = 100,
                Filled = false
            }
        }
    },
    GameFeatures = {
        WeaponModification = {
            Enabled = false,
            WeaponScale = 0,
            CameraScale = 0,
            RecoilScale = 0,
            BulletDrop = 0
        },
        WeaponCustomization = {
            Enabled = false,
            HideTextures = true,
            Color = {1,0.75,1,0.5,true},
            Transparency = 0.5,
            Reflectance = 0,
            Material = "Neon"
        },
        ArmsCustomization = {
            Enabled = false,
            HideTextures = true,
            Color = {1,0,1,0.5,false},
            Transparency = 0.5,
            Reflectance = 0,
            Material = "Neon"
        },
        Character = {
            Fly = {
                Enabled = false,
                Speed = 100
            },
            AntiAim = {
                Enabled = false,
                Pitch = -1.5,
                PitchRandom = 1
            }
        },
        Environment = {
            Enabled = false,
            ExposureCompensation = -2
        }
    },
    UI = {
        Enabled = true,
        Keybind = "RightShift",
        Color = {0.8333333134651184,0.5,0.5,0,false},
        TileSize = 74,
        Watermark = true,
        Background = "Floral",
        BackgroundId = "rbxassetid://5553946656",
        BackgroundColor = {1,0,0,0,false},
        BackgroundTransparency = 0,
        Cursor = {
            Enabled = false,
            Length = 16,
            Width = 11,

            Crosshair = {
                Enabled = false,
                Color = {1,1,1,0,false},
                Size = 4,
                Gap = 2,
            }
        }
    },
    Binds = {
        Aimbot = "MouseButton2",
        SilentAim = "NONE",
        Fly = "NONE"
    }
})

local GetFPS = Parvus.Utilities.SetupFPS()
Parvus.Utilities.Drawing:Cursor(Parvus.Config.UI.Cursor)
Parvus.Utilities.Drawing:FoVCircle(Parvus.Config.AimAssist.Aimbot)
Parvus.Utilities.Drawing:FoVCircle(Parvus.Config.AimAssist.Trigger)
Parvus.Utilities.Drawing:FoVCircle(Parvus.Config.AimAssist.SilentAim)
local Window = Parvus.Utilities.UI:Window({Name = "Parvus Hub — " .. Parvus.Current,Enabled = Parvus.Config.UI.Enabled,
Color = Parvus.Utilities.Config:TableToColor(Parvus.Config.UI.Color),Position = UDim2.new(0.2,-248,0.5,-248)}) do
    local AimAssistTab = Window:Tab({Name = "Combat"}) do
        local AimbotSection = AimAssistTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.Aimbot.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Enabled = Bool
            end})
            AimbotSection:Toggle({Name = "Prediction",Value = Parvus.Config.AimAssist.Aimbot.Prediction.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Prediction.Enabled = Bool
            end})
            AimbotSection:Toggle({Name = "Visibility Check",Value = Parvus.Config.AimAssist.Aimbot.WallCheck,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.WallCheck = Bool
            end})
            AimbotSection:Toggle({Name = "Dynamic FoV",Value = Parvus.Config.AimAssist.Aimbot.DynamicFoV,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.DynamicFoV = Bool
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
            AimbotSection:Dropdown({Name = "Priority",Default = Parvus.Config.AimAssist.Aimbot.Priority,List = {
                {Name = "Head",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "Neck",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "Chest",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "Abdomen",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Aimbot.Priority = Selected
                end},
                {Name = "Hips",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Aimbot.Priority = Selected
                end}
            }})
        end
        local AFoVSection = AimAssistTab:Section({Name = "Aimbot FoV Circle",Side = "Left"}) do
            AFoVSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.Aimbot.Circle.Visible,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Circle.Visible = Bool
            end})
            AFoVSection:Toggle({Name = "Filled",Value = Parvus.Config.AimAssist.Aimbot.Circle.Filled,Callback = function(Bool)
                Parvus.Config.AimAssist.Aimbot.Circle.Filled = Bool
            end})
            AFoVSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.AimAssist.Aimbot.Circle.Color,Callback = function(HSVAR)
                Parvus.Config.AimAssist.Aimbot.Circle.Color = HSVAR
            end})
            AFoVSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.AimAssist.Aimbot.Circle.NumSides,Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.Circle.NumSides = Number
            end})
            AFoVSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.AimAssist.Aimbot.Circle.Thickness,Callback = function(Number)
                Parvus.Config.AimAssist.Aimbot.Circle.Thickness = Number
            end})
        end
        local TFoVSection = AimAssistTab:Section({Name = "Trigger FoV Circle",Side = "Left"}) do
            TFoVSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.Trigger.Circle.Visible,Callback = function(Bool)
                Parvus.Config.AimAssist.Trigger.Circle.Visible = Bool
            end})
            TFoVSection:Toggle({Name = "Filled",Value = Parvus.Config.AimAssist.Trigger.Circle.Filled,Callback = function(Bool)
                Parvus.Config.AimAssist.Trigger.Circle.Filled = Bool
            end})
            TFoVSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.AimAssist.Trigger.Circle.Color,Callback = function(HSVAR)
                Parvus.Config.AimAssist.Trigger.Circle.Color = HSVAR
            end})
            TFoVSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.AimAssist.Trigger.Circle.NumSides,Callback = function(Number)
                Parvus.Config.AimAssist.Trigger.Circle.NumSides = Number
            end})
            TFoVSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.AimAssist.Trigger.Circle.Thickness,Callback = function(Number)
                Parvus.Config.AimAssist.Trigger.Circle.Thickness = Number
            end})
        end
        local SilentAimSection = AimAssistTab:Section({Name = "Silent Aim",Side = "Right"}) do
            SilentAimSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.SilentAim.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.Enabled = Bool
            end}):Keybind({Key = Parvus.Config.Binds.SilentAim,Mouse = true,Callback = function(Bool,Key)
                Parvus.Config.Binds.SilentAim = Key or "NONE"
            end})
            SilentAimSection:Toggle({Name = "AutoShoot (Beta)",Value = Parvus.Config.AimAssist.AutoShoot,Callback = function(Bool)
                Parvus.Config.AimAssist.AutoShoot = Bool
            end}):ToolTip("Silent Aim will not work with this being toggled")
            SilentAimSection:Toggle({Name = "Visibility Check",Value = Parvus.Config.AimAssist.SilentAim.WallCheck,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.WallCheck = Bool
            end})
            SilentAimSection:Toggle({Name = "Dynamic FoV",Value = Parvus.Config.AimAssist.SilentAim.DynamicFoV,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.DynamicFoV = Bool
            end})
            SilentAimSection:Slider({Name = "Hit Chance",Min = 0,Max = 100,Value = Parvus.Config.AimAssist.SilentAim.HitChance,Unit = "%",Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.HitChance = Number
            end})
            SilentAimSection:Slider({Name = "Field of View",Min = 0,Max = 500,Value = Parvus.Config.AimAssist.SilentAim.FieldOfView,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.FieldOfView = Number
            end})
            SilentAimSection:Dropdown({Name = "Priority",Default = Parvus.Config.AimAssist.SilentAim.Priority,List = {
                {Name = "Head",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "Neck",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "Chest",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "Abdomen",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.SilentAim.Priority = Selected
                end},
                {Name = "Hips",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.SilentAim.Priority = Selected
                end}
            }})
        end
        local SAFoVSection = AimAssistTab:Section({Name = "Silent Aim FoV Circle",Side = "Right"}) do
            SAFoVSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.SilentAim.Circle.Visible,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.Circle.Visible = Bool
            end})
            SAFoVSection:Toggle({Name = "Filled",Value = Parvus.Config.AimAssist.SilentAim.Circle.Filled,Callback = function(Bool)
                Parvus.Config.AimAssist.SilentAim.Circle.Filled = Bool
            end})
            SAFoVSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.AimAssist.SilentAim.Circle.Color,Callback = function(HSVAR)
                Parvus.Config.AimAssist.SilentAim.Circle.Color = HSVAR
            end})
            SAFoVSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.AimAssist.SilentAim.Circle.NumSides,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.Circle.NumSides = Number
            end})
            SAFoVSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.AimAssist.SilentAim.Circle.Thickness,Callback = function(Number)
                Parvus.Config.AimAssist.SilentAim.Circle.Thickness = Number
            end})
        end
        local TriggerSection = AimAssistTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Value = Parvus.Config.AimAssist.Trigger.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.Trigger.Enabled = Bool
            end})
            TriggerSection:Toggle({Name = "Prediction",Value = Parvus.Config.AimAssist.Trigger.Prediction.Enabled,Callback = function(Bool)
                Parvus.Config.AimAssist.Trigger.Prediction.Enabled = Bool
            end})
            TriggerSection:Toggle({Name = "Visibility Check",Value = Parvus.Config.AimAssist.Trigger.WallCheck,Callback = function(Bool)
                Parvus.Config.AimAssist.Trigger.WallCheck = Bool
            end})
            TriggerSection:Toggle({Name = "Dynamic FoV",Value = Parvus.Config.AimAssist.Trigger.DynamicFoV,Callback = function(Bool)
                Parvus.Config.AimAssist.Trigger.DynamicFoV = Bool
            end})
            TriggerSection:Slider({Name = "Field of View",Min = 0,Max = 500,Value = Parvus.Config.AimAssist.Trigger.FieldOfView,Callback = function(Number)
                Parvus.Config.AimAssist.Trigger.FieldOfView = Number
            end})
            TriggerSection:Slider({Name = "Delay",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.AimAssist.Trigger.Delay,Callback = function(Number)
                Parvus.Config.AimAssist.Trigger.Delay = Number
            end})
            TriggerSection:Slider({Name = "Hold Time",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.AimAssist.Trigger.HoldTime,Callback = function(Number)
                Parvus.Config.AimAssist.Trigger.HoldTime = Number
            end})
            TriggerSection:Dropdown({Name = "Priority",Default = Parvus.Config.AimAssist.Trigger.Priority,List = {
                {Name = "Head",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "Neck",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "Chest",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "Abdomen",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Trigger.Priority = Selected
                end},
                {Name = "Hips",Mode = "Toggle",Callback = function(Selected)
                    Parvus.Config.AimAssist.Trigger.Priority = Selected
                end}
            }})
        end
    end
    local VisualsTab = Window:Tab({Name = "Visuals"}) do
        local GlobalSection = VisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Ally Color",HSVAR = Parvus.Config.PlayerESP.AllyColor,Callback = function(HSVAR)
                Parvus.Config.PlayerESP.AllyColor = HSVAR
            end})
            GlobalSection:Colorpicker({Name = "Enemy Color",HSVAR = Parvus.Config.PlayerESP.EnemyColor,Callback = function(HSVAR)
                Parvus.Config.PlayerESP.EnemyColor = HSVAR
            end})
            GlobalSection:Toggle({Name = "Team Check",Value = Parvus.Config.PlayerESP.TeamCheck,Callback = function(Bool)
                Parvus.Config.PlayerESP.TeamCheck = Bool
            end})
            GlobalSection:Toggle({Name = "Use Team Color",Value = Parvus.Config.PlayerESP.TeamColor,Callback = function(Bool)
                Parvus.Config.PlayerESP.TeamColor = Bool
            end})
        end
        local BoxSection = VisualsTab:Section({Name = "Boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Box.Enabled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Box.Enabled = Bool
            end})
            BoxSection:Toggle({Name = "Filled",Value = Parvus.Config.PlayerESP.Box.Filled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Box.Filled = Bool
            end})
            BoxSection:Toggle({Name = "Outline",Value = Parvus.Config.PlayerESP.Box.Outline,Callback = function(Bool)
                Parvus.Config.PlayerESP.Box.Outline = Bool
            end})
            BoxSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.PlayerESP.Box.Thickness,Callback = function(Number)
                Parvus.Config.PlayerESP.Box.Thickness = Number
            end})
            BoxSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Box.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Box.Transparency = Number
            end})
            BoxSection:Divider({Text = "Text / Info"})
            BoxSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Box.Info.Enabled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Box.Info.Enabled = Bool
            end})
            BoxSection:Toggle({Name = "Autoscale",Value = Parvus.Config.PlayerESP.Box.Info.AutoScale,Callback = function(Bool)
                Parvus.Config.PlayerESP.Box.Info.AutoScale = Bool
            end})
            BoxSection:Slider({Name = "Size",Min = 14,Max = 28,Value = Parvus.Config.PlayerESP.Box.Info.Size,Callback = function(Number)
                Parvus.Config.PlayerESP.Box.Info.Size = Number
            end})
            BoxSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Box.Info.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Box.Info.Transparency = Number
            end})
        end
        local OoVSection = VisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Other.Arrow.Enabled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Other.Arrow.Enabled = Bool
            end})
            OoVSection:Toggle({Name = "Filled",Value = Parvus.Config.PlayerESP.Other.Arrow.Filled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Other.Arrow.Filled = Bool
            end})
            OoVSection:Slider({Name = "Height",Min = 14,Max = 28,Value = Parvus.Config.PlayerESP.Other.Arrow.Height,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Arrow.Height = Number
            end})
            OoVSection:Slider({Name = "Width",Min = 14,Max = 28,Value = Parvus.Config.PlayerESP.Other.Arrow.Width,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Arrow.Width = Number
            end})
            OoVSection:Slider({Name = "Distance From Center",Min = 80,Max = 200,Value = Parvus.Config.PlayerESP.Other.Arrow.DistanceFromCenter,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Arrow.DistanceFromCenter = Number
            end})
            OoVSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.PlayerESP.Other.Arrow.Thickness,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Arrow.Thickness = Number
            end})
            OoVSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Other.Arrow.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Arrow.Transparency = Number
            end})
        end
        local HeadSection = VisualsTab:Section({Name = "Head Circles",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Other.Head.Enabled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Other.Head.Enabled = Bool
            end})
            HeadSection:Toggle({Name = "Filled",Value = Parvus.Config.PlayerESP.Other.Head.Filled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Other.Head.Filled = Bool
            end})
            HeadSection:Toggle({Name = "Autoscale",Value = Parvus.Config.PlayerESP.Other.Head.AutoScale,Callback = function(Bool)
                Parvus.Config.PlayerESP.Other.Head.AutoScale = Bool
            end})
            HeadSection:Slider({Name = "Radius",Min = 1,Max = 10,Value = Parvus.Config.PlayerESP.Other.Head.Radius,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Head.Radius = Number
            end})
            HeadSection:Slider({Name = "NumSides",Min = 3,Max = 100,Value = Parvus.Config.PlayerESP.Other.Head.NumSides,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Head.NumSides = Number
            end})
            HeadSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.PlayerESP.Other.Head.Thickness,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Head.Thickness = Number
            end})
            HeadSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Other.Head.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Head.Transparency = Number
            end})
        end
        local TracerSection = VisualsTab:Section({Name = "Tracers",Side = "Right"}) do
            TracerSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Other.Tracer.Enabled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Other.Tracer.Enabled = Bool
            end})
            TracerSection:Dropdown({Name = "Mode",Default = {
                Parvus.Config.PlayerESP.Other.Tracer.From == "ScreenBottom" and "From Bottom" or "From Mouse"
            },List = {
                {Name = "From Bottom",Mode = "Button",Callback = function()
                    Parvus.Config.PlayerESP.Other.Tracer.From = "ScreenBottom"
                end},
                {Name = "From Mouse",Mode = "Button",Callback = function()
                    Parvus.Config.PlayerESP.Other.Tracer.From = "Mouse"
                end}
            }})
            TracerSection:Slider({Name = "Thickness",Min = 1,Max = 10,Value = Parvus.Config.PlayerESP.Other.Tracer.Thickness,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Tracer.Thickness = Number
            end})
            TracerSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Other.Tracer.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Other.Tracer.Transparency = Number
            end})
        end
        local HighlightSection = VisualsTab:Section({Name = "Highlights",Side = "Right"}) do
            HighlightSection:Toggle({Name = "Enabled",Value = Parvus.Config.PlayerESP.Highlight.Enabled,Callback = function(Bool)
                Parvus.Config.PlayerESP.Highlight.Enabled = Bool
            end})
            HighlightSection:Slider({Name = "Transparency",Min = 0,Max = 1,Precise = 2,Value = Parvus.Config.PlayerESP.Highlight.Transparency,Callback = function(Number)
                Parvus.Config.PlayerESP.Highlight.Transparency = Number
            end})
            HighlightSection:Colorpicker({Name = "Outline Color",HSVAR = Parvus.Config.PlayerESP.Highlight.OutlineColor,Callback = function(HSVAR)
                Parvus.Config.PlayerESP.Highlight.OutlineColor = HSVAR
            end})
        end
    end
    local GameTab = Window:Tab({Name = Parvus.Current}) do
        local GCSection = GameTab:Section({Name = "Weapon Customization",Side = "Left"}) do
            GCSection:Toggle({Name = "Enabled",Value = Parvus.Config.GameFeatures.WeaponCustomization.Enabled,Callback = function(Bool) 
                Parvus.Config.GameFeatures.WeaponCustomization.Enabled = Bool
            end})
            GCSection:Toggle({Name = "Hide Textures",Value = Parvus.Config.GameFeatures.WeaponCustomization.HideTextures,Callback = function(Bool) 
                Parvus.Config.GameFeatures.WeaponCustomization.HideTextures = Bool
            end})
            GCSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.GameFeatures.WeaponCustomization.Color,Callback = function(HSVAR)
                Parvus.Config.GameFeatures.WeaponCustomization.Color = HSVAR
            end})
            GCSection:Slider({Name = "Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = Parvus.Config.GameFeatures.WeaponCustomization.Reflectance,Callback = function(Number)
                Parvus.Config.GameFeatures.WeaponCustomization.Reflectance = Number
            end})
            GCSection:Dropdown({Name = "Material",Default = {Parvus.Config.GameFeatures.WeaponCustomization.Material},List = {
                {Name = "SmoothPlastic",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.WeaponCustomization.Material = "SmoothPlastic"
                end},
                {Name = "ForceField",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.WeaponCustomization.Material = "ForceField"
                end},
                {Name = "Neon",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.WeaponCustomization.Material = "Neon"
                end},
                {Name = "Glass",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.WeaponCustomization.Material = "Glass"
                end}
            }})
        end
        local CMSection = GameTab:Section({Name = "Weapon Modification",Side = "Left"}) do
            CMSection:Toggle({Name = "Enabled",Value = Parvus.Config.GameFeatures.WeaponModification.Enabled,Callback = function(Bool) 
                Parvus.Config.GameFeatures.WeaponModification.Enabled = Bool
            end})
            CMSection:Slider({Name = "Weapon Shake",Min = 0,Max = 100,Value = Parvus.Config.GameFeatures.WeaponModification.WeaponScale * 100,Unit = "%",Callback = function(Number)
                Parvus.Config.GameFeatures.WeaponModification.WeaponScale = Number / 100
            end})
            CMSection:Slider({Name = "Camera Shake",Min = 0,Max = 100,Value = Parvus.Config.GameFeatures.WeaponModification.CameraScale * 100,Unit = "%",Callback = function(Number)
                Parvus.Config.GameFeatures.WeaponModification.CameraScale = Number / 100
            end})
            CMSection:Slider({Name = "Recoil Scale",Min = 0,Max = 100,Value = Parvus.Config.GameFeatures.WeaponModification.RecoilScale * 100,Unit = "%",Callback = function(Number)
                Parvus.Config.GameFeatures.WeaponModification.RecoilScale = Number / 100
            end})
            CMSection:Slider({Name = "Bullet Drop",Min = 0,Max = 100,Value = Parvus.Config.GameFeatures.WeaponModification.BulletDrop * 100,Unit = "%",Callback = function(Number)
                Parvus.Config.GameFeatures.WeaponModification.BulletDrop = Number / 100
            end})
            CMSection:Label({Text = "Respawn to make it work"})
        end
        local EnvSection = GameTab:Section({Name = "Environment",Side = "Left"}) do
            EnvSection:Toggle({Name = "Enable",Value = Parvus.Config.GameFeatures.Environment.Enabled,Callback = function(Bool)
                Parvus.Config.GameFeatures.Environment.Enabled = Bool
                Lighting.ExposureCompensation = Bool and Parvus.Config.GameFeatures.Environment.ExposureCompensation or 0
            end})
            EnvSection:Slider({Name = "Exposure Compensation",Min = -5,Max = 5,Precise = 2,Value = Parvus.Config.GameFeatures.Environment.ExposureCompensation,Callback = function(Number)
                Parvus.Config.GameFeatures.Environment.ExposureCompensation = Number
                if Parvus.Config.GameFeatures.Environment.Enabled then
                    Lighting.ExposureCompensation = Number
                end
            end})
        end
        local ACSection = GameTab:Section({Name = "Arms Customization",Side = "Right"}) do
            ACSection:Toggle({Name = "Enabled",Value = Parvus.Config.GameFeatures.ArmsCustomization.Enabled,Callback = function(Bool) 
                Parvus.Config.GameFeatures.ArmsCustomization.Enabled = Bool
            end})
            ACSection:Toggle({Name = "Hide Textures",Value = Parvus.Config.GameFeatures.ArmsCustomization.HideTextures,Callback = function(Bool) 
                Parvus.Config.GameFeatures.ArmsCustomization.HideTextures = Bool
            end})
            ACSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.GameFeatures.ArmsCustomization.Color,Callback = function(HSVAR)
                Parvus.Config.GameFeatures.ArmsCustomization.Color = HSVAR
            end})
            ACSection:Slider({Name = "Reflectance",Min = 0,Max = 0.95,Precise = 2,Value = Parvus.Config.GameFeatures.ArmsCustomization.Reflectance,Callback = function(Number)
                Parvus.Config.GameFeatures.ArmsCustomization.Reflectance = Number
            end})
            ACSection:Dropdown({Name = "Material",Default = {Parvus.Config.GameFeatures.ArmsCustomization.Material},List = {
                {Name = "SmoothPlastic",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.ArmsCustomization.Material = "SmoothPlastic"
                end},
                {Name = "ForceField",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.ArmsCustomization.Material = "ForceField"
                end},
                {Name = "Neon",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.ArmsCustomization.Material = "Neon"
                end},
                {Name = "Glass",Mode = "Button",Callback = function()
                    Parvus.Config.GameFeatures.ArmsCustomization.Material = "Glass"
                end}
            }})
        end
        local CharSection = GameTab:Section({Name = "Character",Side = "Right"}) do
            CharSection:Toggle({Name = "Fly",Value = Parvus.Config.GameFeatures.Character.Fly.Enabled,Callback = function(Bool) 
                Parvus.Config.GameFeatures.Character.Fly.Enabled = Bool
            end}):Keybind({Key = Parvus.Config.Binds.Fly,Callback = function(Bool,Key)
                Parvus.Config.Binds.Fly = Key or "NONE"
            end})
            CharSection:Slider({Name = "Speed",Min = 10,Max = 100,Value = Parvus.Config.GameFeatures.Character.Fly.Speed,Callback = function(Number)
                Parvus.Config.GameFeatures.Character.Fly.Speed = Number
            end})
            CharSection:Toggle({Name = "Anti-Aim",Value = Parvus.Config.GameFeatures.Character.AntiAim.Enabled,Callback = function(Bool) 
                Parvus.Config.GameFeatures.Character.AntiAim.Enabled = Bool
            end}):Keybind({Key = Parvus.Config.Binds.AntiAim,Callback = function(Bool,Key)
                Parvus.Config.Binds.AntiAim = Key or "NONE"
            end})
            CharSection:Slider({Name = "Pitch",Min = -1.5,Max = 1.5,Precise = 2,Value = Parvus.Config.GameFeatures.Character.AntiAim.Pitch,Callback = function(Number)
                Parvus.Config.GameFeatures.Character.AntiAim.Pitch = Number
            end})
            CharSection:Slider({Name = "Pitch Random",Min = 0,Max = 1.5,Precise = 2,Value = Parvus.Config.GameFeatures.Character.AntiAim.PitchRandom,Callback = function(Number)
                Parvus.Config.GameFeatures.Character.AntiAim.PitchRandom = Number
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
            MenuSection:Toggle({Name = "Watermark",Value = Parvus.Config.UI.Watermark,Callback = function(Bool) 
                Parvus.Config.UI.Watermark = Bool
                if not Parvus.Config.UI.Watermark then
                    Parvus.Utilities.UI:Watermark()
                end
            end})
            MenuSection:Toggle({Name = "Close On Exec",Value = not Parvus.Config.UI.Enabled,Callback = function(Bool) 
                Parvus.Config.UI.Enabled = not Bool
            end})
            MenuSection:Toggle({Name = "Custom Mouse",Value = Parvus.Config.UI.Cursor.Enabled,Callback = function(Bool) 
                Parvus.Config.UI.Cursor.Enabled = Bool
            end})
            MenuSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.UI.Color,Callback = function(HSVAR,Color)
                Parvus.Config.UI.Color = HSVAR
                Window:SetColor(Color)
            end})
        end
        local CrosshairSection = SettingsTab:Section({Name = "Custom Crosshair",Side = "Left"}) do
            CrosshairSection:Toggle({Name = "Enabled",Value = Parvus.Config.UI.Cursor.Crosshair.Enabled,Callback = function(Bool) 
                Parvus.Config.UI.Cursor.Crosshair.Enabled = Bool
            end})
            CrosshairSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.UI.Cursor.Crosshair.Color,Callback = function(HSVAR)
                Parvus.Config.UI.Cursor.Crosshair.Color = HSVAR
            end})
            CrosshairSection:Slider({Name = "Size",Min = 0,Max = 100,Value = Parvus.Config.UI.Cursor.Crosshair.Size,Callback = function(Number)
                Parvus.Config.UI.Cursor.Crosshair.Size = Number
            end})
            CrosshairSection:Slider({Name = "Gap",Min = 0,Max = 100,Value = Parvus.Config.UI.Cursor.Crosshair.Gap,Callback = function(Number)
                Parvus.Config.UI.Cursor.Crosshair.Gap = Number
            end})
        end
        SettingsTab:Button({Name = "Rejoin",Side = "Left",Callback = function()
            if #PlayerService:GetPlayers() <= 1 then
                LocalPlayer:Kick("\nRejoining...")
                task.wait()
                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
            else
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end})
        SettingsTab:Button({Name = "Server Hop",Side = "Left",Callback = function()
            local Servers = {}
            local Request = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local DataDecoded = HttpService:JSONDecode(Request).data
            for Index,ServerData in ipairs(DataDecoded) do
                if type(ServerData) == "table" and ServerData.id ~= game.JobId then
                    table.insert(Servers,ServerData.id)
                end
            end
            if #Servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)])
            else
                Parvus.Utilities.UI:Notification({
                    Title = "Parvus Hub",
                    Description = "Couldn't find a server",
                    Duration = 5
                })
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
                        ["code"] = "sYqDpbPYb7"
                    }
                })
            })
        end}):ToolTip("Join for support, updates and more!")
        local BackgroundSection = SettingsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Dropdown({Name = "Image",Default = {Parvus.Config.UI.Background},List = {
                {Name = "Legacy",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://2151741365"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://2151741365"
                end},
                {Name = "Hearts",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073763717"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6073763717"
                end},
                {Name = "Abstract",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073743871"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6073743871"
                end},
                {Name = "Hexagon",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073628839"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6073628839"
                end},
                {Name = "Circles",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071579801"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6071579801"
                end},
                {Name = "Lace With Flowers",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071575925"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://6071575925"
                end},
                {Name = "Floral",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://5553946656"
                    Parvus.Config.UI.BackgroundId = "rbxassetid://5553946656"
                end}
            }})
            Window.Background.Image = Parvus.Config.UI.BackgroundId
            Window.Background.ImageTransparency = Parvus.Config.UI.BackgroundColor[4]
            Window.Background.TileSize = UDim2.new(0,Parvus.Config.UI.TileSize,0,Parvus.Config.UI.TileSize)
            Window.Background.ImageColor3 = Parvus.Utilities.Config:TableToColor(Parvus.Config.UI.BackgroundColor)
            BackgroundSection:Textbox({Name = "Custom Image",Text = "",Placeholder = "ImageId",Callback = function(String)
                Window.Background.Image = "rbxassetid://" .. String
                Parvus.Config.UI.BackgroundId = "rbxassetid://" .. String
            end})
            BackgroundSection:Colorpicker({Name = "Color",HSVAR = Parvus.Config.UI.BackgroundColor,Callback = function(HSVAR,Color)
                Parvus.Config.UI.BackgroundColor = HSVAR
                Window.Background.ImageColor3 = Color
                Window.Background.ImageTransparency = HSVAR[4]
            end})
            BackgroundSection:Slider({Name = "Tile Offset",Min = 74, Max = 296,Value = Window.Background.TileSize.X.Offset,Callback = function(Number)
                Parvus.Config.UI.TileSize = Number
                Window.Background.TileSize = UDim2.new(0,Number,0,Number)
            end})
        end
        local CreditsSection = SettingsTab:Section({Name = "Credits",Side = "Right"}) do
            CreditsSection:Label({Text = "This script was made by AlexR32#0157"})
            CreditsSection:Divider()
            CreditsSection:Label({Text = "Thanks to Jan for this awesome background patterns."})
            CreditsSection:Label({Text = "Thanks to Infinite Yield Team for server hop."})
            CreditsSection:Label({Text = "Thanks to Blissful for Offscreen Arrows."})
            CreditsSection:Label({Text = "Thanks to coasts for his Universal ESP."})
            CreditsSection:Label({Text = "Thanks to el3tric for Bracket V2."})
            CreditsSection:Label({Text = "❤️ ❤️ ❤️ ❤️"})
        end
    end
end

--local DefaultRecoil = {}
local Notify = Instance.new("BindableEvent")
local BodyVelocity = Instance.new("BodyVelocity")
BodyVelocity.Velocity = Vector3.zero
BodyVelocity.MaxForce = Vector3.zero

--[[for Index,Config in pairs(getgc(true)) do
    if type(Config) == "table"
    and rawget(Config,"Recoil")
    and type(Config.Recoil) == "table"
    and Config.Recoil.Default then
        DefaultRecoil[Config.Model] = {
            WeaponScale = Config.Recoil.Default.WeaponScale,
            CameraScale = Config.Recoil.Default.CameraScale,
            RecoilScale = Config.Recoil.Default.RecoilScale
        }
    end
end]]

for Index,Property in pairs({"ExposureCompensation"}) do
    if Parvus.Config.GameFeatures.Environment.Enabled then
        Lighting[Property] = Parvus.Config.GameFeatures.Environment[Property]
    end
    Lighting:GetPropertyChangedSignal(Property):Connect(function()
        if Parvus.Config.GameFeatures.Environment.Enabled then
            Lighting[Property] = Parvus.Config.GameFeatures.Environment[Property]
        end
    end)
end

Notify.Event:Connect(function(Text)
    Parvus.Utilities.UI:Notification2({
        Title = Text,
        Color = Color3.new(1,0.5,0.25),
        Duration = 3
    })
end)

local function FindGunModel()
    for Index,Instance in pairs(Workspace:GetChildren()) do
        if Instance:FindFirstChild("AnimationController") then
            return Instance
        end
    end
end

local function InputToVelocity()
    local Camera = Workspace.CurrentCamera
    local Velocities = {}

    Velocities[1] = UserInputService:IsKeyDown(Enum.KeyCode.W)
    and Camera.CFrame.LookVector or Vector3.zero
    Velocities[2] = UserInputService:IsKeyDown(Enum.KeyCode.S)
    and -Camera.CFrame.LookVector or Vector3.zero
    Velocities[3] = UserInputService:IsKeyDown(Enum.KeyCode.A)
    and -Camera.CFrame.RightVector or Vector3.zero
    Velocities[4] = UserInputService:IsKeyDown(Enum.KeyCode.D)
    and Camera.CFrame.RightVector or Vector3.zero
    Velocities[5] = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    and Vector3.new(0,1,0) or Vector3.zero
    Velocities[6] = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    and Vector3.new(0,-1,0) or Vector3.zero
    
    return (
        Velocities[1] +
        Velocities[2] +
        Velocities[3] +
        Velocities[4] +
        Velocities[5] +
        Velocities[6]
    )
end

local function PlayerFly(Config)
    if not Config.Enabled then
        BodyVelocity.MaxForce = Vector3.zero
        return
    end
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        BodyVelocity.Parent = LocalPlayer.Character.PrimaryPart
        BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        BodyVelocity.Velocity = InputToVelocity() * Config.Speed
    end
end

--[[
-- this shit is laggy as hell dont use in your scripts bruh
local function UpdateRecoil()
    for Index,Config in pairs(getgc(true)) do
        if type(Config) == "table"
        and rawget(Config,"Controller")
        and rawget(Config,"Model") then
            if Config.Recoil and Config.Recoil.Default and
                DefaultRecoil[Config.Model] then

                local Modified = Parvus.Config.GameFeatures.WeaponModification
                local Default = DefaultRecoil[Config.Model]

                Config.Recoil.Default.WeaponScale = Modified.Enabled
                and Default.WeaponScale * Modified.WeaponScale
                or Default.WeaponScale

                Config.Recoil.Default.CameraScale = Modified.Enabled
                and Default.CameraScale * Modified.CameraScale
                or Default.CameraScale

                Config.Recoil.Default.RecoilScale = Modified.Enabled
                and Default.RecoilScale * Modified.RecoilScale
                or Default.RecoilScale
            end
        end
    end
end]]

local function CustomizeGun(Config)
    if not Config.Enabled then return end
    local GunModel = FindGunModel()
    if GunModel then
        for Index,Instance in pairs(GunModel.Body:GetDescendants()) do
            if Config.HideTextures and Instance:IsA("Texture") then
                Instance.Transparency = 1
            elseif Instance:IsA("BasePart") and Instance.Transparency < 1
            and Instance.Reflectance < 1 then
                Instance.Color = Parvus.Utilities.Config:TableToColor(Config.Color)
                Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
                Instance.Reflectance = Config.Reflectance
                Instance.Material = Config.Material
            end
        end
    end
end

local function CustomizeArms(Config)
    if not Config.Enabled then return end
    for Index,Instance in pairs(Workspace.Arms:GetDescendants()) do
        if Config.HideTextures and Instance:IsA("Texture") then
            Instance.Transparency = 1
        elseif Instance:IsA("BasePart") and Instance.Transparency < 1
        and Instance.Reflectance < 1 then
            Instance.Color = Parvus.Utilities.Config:TableToColor(Config.Color)
            Instance.Transparency = Config.Color[4] > 0.95 and 0.95 or Config.Color[4]
            Instance.Reflectance = Config.Reflectance
            Instance.Material = Config.Material
        end
    end
end

local function Raycast(Origin,Direction,Table)
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    RaycastParams.FilterDescendantsInstances = Table
    RaycastParams.IgnoreWater = true
    return Workspace:Raycast(Origin,Direction,RaycastParams)
end

local function TeamCheck(Player)
    return LocalPlayer.Team ~= Player.Team
    or tostring(Player.Team) == "FFA"
end

local function WallCheck(Enabled,Hitbox)
    if not Enabled then return true end
    local Camera = Workspace.CurrentCamera
    return not Raycast(
        Camera.CFrame.Position,
        Hitbox.Position - Camera.CFrame.Position,
        {Workspace.Geometry,Workspace.Terrain}
    )
end

local function Trigger(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    local FieldOfView = Config.FieldOfView
    local ClosestHitbox = nil

    for Index, Player in pairs(PlayerService:GetPlayers()) do
        local Character = Player.Character and Player.Character:FindFirstChild("Hitbox")
        if Player ~= LocalPlayer and TeamCheck(Player) then
            for Index, HumanoidPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                if Hitbox then
                    local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
                    local HitboxGravityCorrection = Vector3.new(0,HitboxDistance / PredictedGravity,0) / 2 --GravityCorrection
                    local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Config.Prediction.Enabled
                    and Hitbox.Position + HitboxGravityCorrection + HitboxVelocityCorrection or Hitbox.Position)

                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    FieldOfView = Config.DynamicFoV and (120 - Workspace.CurrentCamera.FieldOfView) * 4 or FieldOfView

                    if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox) then
                        FieldOfView = Magnitude
                        ClosestHitbox = Hitbox
                    end
                end
            end
        end
    end

    if ClosestHitbox then
        task.wait(Config.Delay)
        mouse1press()
        task.wait(Config.HoldTime)
        mouse1release()
    end
end

local function AutoShoot(Hitbox,Enabled)
    if not Hitbox or not Enabled then return end

    local GunModel = FindGunModel()
    if GunModel and LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("Backpack")
    and LocalPlayer.Character.Backpack:FindFirstChild("Items")
    and LocalPlayer.Character.Backpack.Items:FindFirstChild(GunModel.Name) then
        local GunFolder = LocalPlayer.Character.Backpack.Items[GunModel.Name]
        local Ammo = LocalPlayer.Character.Backpack.Items[GunModel.Name].State:FindFirstChild("Ammo")
        if Ammo and Ammo.Server.Value > 0 then
            local ID = Tortoiseshell.Projectiles:GetID()
            local LookVector = Tortoiseshell.Input.Reticle:LookVector()
            Tortoiseshell.Network:Fire("Item_Paintball","AltAim",GunFolder,true)
            Tortoiseshell.Network:Fire("Item_Paintball","Shoot",GunFolder,
            Tortoiseshell.Input.Reticle:GetPosition(),{{
            (LookVector + Vector3.new(0, 2 / 1000, 0)).Unit,ID}})
            Tortoiseshell.Network:Fire("Projectiles","__Hit",ID,
            Hitbox[2].Position,Hitbox[2],LookVector,Hitbox[1])
        else
            Tortoiseshell.Network:Fire("Item_Paintball","Reload",GunFolder)
        end
    end
end

local function GetHitbox(Config)
    if not Config.Enabled then return end
    local Camera = Workspace.CurrentCamera
    local FieldOfView = Config.FieldOfView
    local ClosestHitbox = nil

    for Index, Player in pairs(PlayerService:GetPlayers()) do
        local Character = Player.Character and Player.Character:FindFirstChild("Hitbox")
        if Player ~= LocalPlayer and TeamCheck(Player) then
            for Index, HumanoidPart in pairs(Config.Priority) do
                local Hitbox = Character and Character:FindFirstChild(HumanoidPart)
                if Hitbox then
                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Hitbox.Position)
                    local Magnitude = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                    FieldOfView = Config.DynamicFoV and (120 - Workspace.CurrentCamera.FieldOfView) * 4 or FieldOfView
                    if OnScreen and Magnitude < FieldOfView and WallCheck(Config.WallCheck,Hitbox) then
                        FieldOfView = Magnitude
                        ClosestHitbox = {Player,Hitbox}
                    end
                end
            end
        end
    end

    return ClosestHitbox
end

local function AimAt(Hitbox,Config)
    if not Hitbox then return end
    Hitbox = Hitbox[2]
    local Camera = Workspace.CurrentCamera
    local Mouse = UserInputService:GetMouseLocation()

    local HitboxDistance = (Hitbox.Position - Camera.CFrame.Position).Magnitude
    local HitboxGravityCorrection = Vector3.new(0,HitboxDistance / PredictedGravity,0) / 2 --GravityCorrection
    local HitboxVelocityCorrection = (Hitbox.AssemblyLinearVelocity * HitboxDistance) / PredictedVelocity

    local HitboxOnScreen = Camera:WorldToViewportPoint(Config.Prediction.Enabled
    and Hitbox.Position + HitboxGravityCorrection + HitboxVelocityCorrection or Hitbox.Position)
    mousemoverel(
        (HitboxOnScreen.X - Mouse.X) * Config.Sensitivity,
        (HitboxOnScreen.Y - Mouse.Y) * Config.Sensitivity
    )
end

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if getnamecallmethod() == "FireServer" then
        for Index, Reason in pairs(BanReasons) do
            if typeof(args[2]) == "string" and string.match(args[2],Reason) then
                return
            end
        end
    end
    return __namecall(self, ...)
end)

local OldNetworkFire = Tortoiseshell.Network.Fire
Tortoiseshell.Network.Fire = function(self, ...)
    local args = {...}

    if SilentAim and Parvus.Config.AimAssist.SilentAim.Enabled
    and not Parvus.Config.AimAssist.AutoShoot then
        if args[2] == "__Hit" and math.random(0,100) <= Parvus.Config.AimAssist.SilentAim.HitChance then
            args[4] = SilentAim[2].Position
            args[5] = SilentAim[2]
            args[7] = SilentAim[1]

            local GunModel = FindGunModel()
            if GunModel then
                Notify:Fire("Hit " .. SilentAim[1].Name .. " in the " .. SilentAim[2].Name .. " with " .. GunModel.Name)
            end
        end
    end

    if Parvus.Config.GameFeatures.Character.AntiAim.Enabled and args[3] == "Look" then
        args[4] = Parvus.Config.GameFeatures.Character.AntiAim.Pitch < -0
        and Parvus.Config.GameFeatures.Character.AntiAim.Pitch + Random.new():NextNumber(0,
        Parvus.Config.GameFeatures.Character.AntiAim.PitchRandom)
        or Parvus.Config.GameFeatures.Character.AntiAim.Pitch - Random.new():NextNumber(0,
        Parvus.Config.GameFeatures.Character.AntiAim.PitchRandom)
    end

    return OldNetworkFire(self, unpack(args))
end

local OldInitProjectile = Tortoiseshell.Projectiles.InitProjectile
local Projectiles = getupvalue(OldInitProjectile,1)
Tortoiseshell.Projectiles.InitProjectile = function(self, ...)
    local args = {...}
    if args[4] == LocalPlayer.Character then
        PredictedVelocity = Projectiles[args[1]].Speed
        PredictedGravity = Projectiles[args[1]].Gravity
    end
    return OldInitProjectile(self, ...)
end

local OldGetConfig = Tortoiseshell.Items.GetConfig
Tortoiseshell.Items.GetConfig = function(self, weapon)
    local Config = OldGetConfig(self, weapon)
    local Modified = Parvus.Config.GameFeatures.WeaponModification
    --if Config.Proejctile and Config.Proejctile.GravityCorrection
    --and Config.Controller == "Paintball" then
        --GravityCorrection = Config.Proejctile.GravityCorrection
    --end
    if Modified.Enabled and Config.Recoil and Config.Recoil.Default then
        Config.Recoil.Default.WeaponScale = 
        Config.Recoil.Default.WeaponScale * Modified.WeaponScale

        Config.Recoil.Default.CameraScale = 
        Config.Recoil.Default.CameraScale * Modified.CameraScale

        Config.Recoil.Default.RecoilScale = 
        Config.Recoil.Default.RecoilScale * Modified.RecoilScale
    end
    return Config
end

local OldCastGeometryAndEnemies = Tortoiseshell.Raycast.CastGeometryAndEnemies
Tortoiseshell.Raycast.CastGeometryAndEnemies = function(self, ...)
    local args = {...}
    local Modified = Parvus.Config.GameFeatures.WeaponModification
    if Modified.Enabled and args[4] and args[4].Gravity then
        args[4].Gravity = args[4].Gravity * Modified.BulletDrop
    end
    return OldCastGeometryAndEnemies(self, unpack(args))
end

RunService.Heartbeat:Connect(function()
    SilentAim = GetHitbox(Parvus.Config.AimAssist.SilentAim)
    if Aimbot then AimAt(
        GetHitbox(Parvus.Config.AimAssist.Aimbot),
        Parvus.Config.AimAssist.Aimbot)
    end

    if Parvus.Config.UI.Watermark then
        Parvus.Utilities.UI:Watermark({
            Enabled = true,
            Title = string.format(
                "Parvus Hub — %s\nTime: %s - %s\nFPS: %i/s\nPing: %i ms",
                Parvus.Current,os.date("%X"),os.date("%x"),GetFPS(),math.round(Stats.PerformanceStats.Ping:GetValue())
            )
        })
    end

    AutoShoot(SilentAim,Parvus.Config.AimAssist.AutoShoot)
    PlayerFly(Parvus.Config.GameFeatures.Character.Fly)
    CustomizeGun(Parvus.Config.GameFeatures.WeaponCustomization)
    CustomizeArms(Parvus.Config.GameFeatures.ArmsCustomization)
end)

Parvus.Utilities.NewThreadLoop(0,function()
    Trigger(Parvus.Config.AimAssist.Trigger)
end)

for Index, Player in pairs(PlayerService:GetPlayers()) do
    if Player ~= LocalPlayer then
        Parvus.Utilities.Drawing:AddESP("Player", Player, Parvus.Config.PlayerESP)
    end
end
PlayerService.PlayerAdded:Connect(function(Player)
    Parvus.Utilities.Drawing:AddESP("Player", Player, Parvus.Config.PlayerESP)
end)
PlayerService.PlayerRemoving:Connect(function(Player)
    if Player == LocalPlayer then Parvus.Utilities.Config:WriteJSON(Parvus.Current,Parvus.Config) end
    Parvus.Utilities.Drawing:RemoveESP(Player)
end)
