local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local SilentAim,Aimbot,Trigger = nil,false,false

LocalPlayer.PlayerScripts:WaitForChild("Client")
local Objectives = Workspace.World.Objectives
local NPCFolder = Workspace.Entities.Infected
local Items = Workspace.Ignore.Items

local RayModule = require(ReplicatedStorage.SharedModules.Utilities.Ray)
local Bullet = require(LocalPlayer.PlayerScripts.Modules.Other.Bullet)
local Interact = require(LocalPlayer.PlayerScripts.Client.Interact)
--local GuiModule = require(LocalPlayer.PlayerScripts.Client.Gui)
--local Client = getsenv(LocalPlayer.PlayerScripts.Client)
--local GlobalTable = getupvalue(Client.RHit,2)

--[[local OCIFunction = nil
for Index,Function in pairs(getgc()) do
    if islclosure(Function) and getconstants(Function)[1] == "GetCC" then
        OCIFunction = Function
    end
end if not OCIFunction then return end]]

-- Game Database
local ItemPickups = {
    {"50 Cal",false},{"Ammo",false},{"Bandages",false},{"Barbed Wire",false},
    {"Body Armor",false},{"Clap Bomb",false},{"Energy Drink",false},{"Frag",false},
    {"Gas Mask",false},{"Jack",false},{"Medkit",false},{"Molotov",false},{"Nerve Gas",false}
}

local KnownBodyParts = {
    {"Head",true},{"HumanoidRootPart",true},{"Torso",false},
    {"Right Arm",false},{"Left Arm",false},
    {"Right Leg",false},{"Left Leg",false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212),Parvus.Game.Name),
    Position = UDim2.new(0.5,-248 * 3,0.5,-248)
}) do

    local CombatTab = Window:Tab({Name = "Combat"}) do
        --[[local AimbotSection = CombatTab:Section({Name = "Aimbot",Side = "Left"}) do
            AimbotSection:Toggle({Name = "Enabled",Flag = "Aimbot/Enabled",Value = false})
            :Keybind({Flag = "Aimbot/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

            AimbotSection:Toggle({Name = "Always Enabled",Flag = "Aimbot/AlwaysEnabled",Value = false})

            AimbotSection:Toggle({Name = "Distance Check",Flag = "Aimbot/DistanceCheck",Value = false})
            AimbotSection:Toggle({Name = "Visibility Check",Flag = "Aimbot/VisibilityCheck",Value = false})
            AimbotSection:Slider({Name = "Sensitivity",Flag = "Aimbot/Sensitivity",Min = 0,Max = 100,Value = 20,Unit = "%"})
            AimbotSection:Slider({Name = "Field Of View",Flag = "Aimbot/FieldOfView",Min = 0,Max = 500,Value = 100,Unit = "r"})
            AimbotSection:Slider({Name = "Distance Limit",Flag = "Aimbot/DistanceLimit",Min = 25,Max = 1000,Value = 250,Unit = "studs"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            AimbotSection:Dropdown({Name = "Priority",Flag = "Aimbot/Priority",List = PriorityList})
            AimbotSection:Dropdown({Name = "Body Parts",Flag = "Aimbot/BodyParts",List = BodyPartsList})
        end
        local AFOVSection = CombatTab:Section({Name = "Aimbot FOV Circle",Side = "Left"}) do
            AFOVSection:Toggle({Name = "Enabled",Flag = "Aimbot/FOVCircle/Enabled",Value = true})
            AFOVSection:Toggle({Name = "Filled",Flag = "Aimbot/FOVCircle/Filled",Value = false})
            AFOVSection:Colorpicker({Name = "Color",Flag = "Aimbot/FOVCircle/Color",Value = {1,0.66666662693024,1,0.25,false}})
            AFOVSection:Slider({Name = "NumSides",Flag = "Aimbot/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            AFOVSection:Slider({Name = "Thickness",Flag = "Aimbot/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end]]
        local SilentAimSection = CombatTab:Section({Name = "Silent Aim",Side = "Left"}) do
            SilentAimSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false}):Keybind({Mouse = true,Flag = "SilentAim/Keybind"})

            SilentAimSection:Toggle({Name = "Distance Check",Flag = "SilentAim/DistanceCheck",Value = false})
            SilentAimSection:Toggle({Name = "Visibility Check",Flag = "SilentAim/VisibilityCheck",Value = false})
            SilentAimSection:Slider({Name = "Hit Chance",Flag = "SilentAim/HitChance",Min = 0,Max = 100,Value = 100,Unit = "%"})
            SilentAimSection:Slider({Name = "Field Of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 100,Unit = "r"})
            SilentAimSection:Slider({Name = "Distance Limit",Flag = "SilentAim/DistanceLimit",Min = 25,Max = 1000,Value = 250,Unit = "studs"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            SilentAimSection:Dropdown({Name = "Priority",Flag = "SilentAim/Priority",List = PriorityList})
            SilentAimSection:Dropdown({Name = "Body Parts",Flag = "SilentAim/BodyParts",List = BodyPartsList})
        end
        local SAFOVSection = CombatTab:Section({Name = "Silent Aim FOV Circle",Side = "Right"}) do
            SAFOVSection:Toggle({Name = "Enabled",Flag = "SilentAim/FOVCircle/Enabled",Value = true})
            SAFOVSection:Toggle({Name = "Filled",Flag = "SilentAim/FOVCircle/Filled",Value = false})
            SAFOVSection:Colorpicker({Name = "Color",Flag = "SilentAim/FOVCircle/Color",
            Value = {0.6666666865348816,0.6666666269302368,1,0.25,false}})
            SAFOVSection:Slider({Name = "NumSides",Flag = "SilentAim/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            SAFOVSection:Slider({Name = "Thickness",Flag = "SilentAim/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end
        --[[local TriggerSection = CombatTab:Section({Name = "Trigger",Side = "Right"}) do
            TriggerSection:Toggle({Name = "Enabled",Flag = "Trigger/Enabled",Value = false})
            :Keybind({Flag = "Trigger/Keybind",Value = "MouseButton2",Mouse = true,DisableToggle = true,
            Callback = function(Key,KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})

            TriggerSection:Toggle({Name = "Always Enabled",Flag = "Trigger/AlwaysEnabled",Value = false})
            TriggerSection:Toggle({Name = "Hold Mouse Button",Flag = "Trigger/HoldMouseButton",Value = false})

            TriggerSection:Toggle({Name = "Distance Check",Flag = "Trigger/DistanceCheck",Value = false})
            TriggerSection:Toggle({Name = "Visibility Check",Flag = "Trigger/VisibilityCheck",Value = false})

            TriggerSection:Slider({Name = "Click Delay",Flag = "Trigger/Delay",Min = 0,Max = 1,Precise = 2,Value = 0.15,Unit = "sec"})
            TriggerSection:Slider({Name = "Distance Limit",Flag = "Trigger/DistanceLimit",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
            TriggerSection:Slider({Name = "Field Of View",Flag = "Trigger/FieldOfView",Min = 0,Max = 500,Value = 25,Unit = "r"})

            local PriorityList,BodyPartsList = {{Name = "Closest",Mode = "Button",Value = true},{Name = "Random",Mode = "Button"}},{}
            for Index,Value in pairs(KnownBodyParts) do
                PriorityList[#PriorityList + 1] = {Name = Value[1],Mode = "Button",Value = false}
                BodyPartsList[#BodyPartsList + 1] = {Name = Value[1],Mode = "Toggle",Value = Value[2]}
            end

            TriggerSection:Dropdown({Name = "Priority",Flag = "Trigger/Priority",List = PriorityList})
            TriggerSection:Dropdown({Name = "Body Parts",Flag = "Trigger/BodyParts",List = BodyPartsList})
        end
        local TFOVSection = CombatTab:Section({Name = "Trigger FOV Circle",Side = "Right"}) do
            TFOVSection:Toggle({Name = "Enabled",Flag = "Trigger/FOVCircle/Enabled",Value = true})
            TFOVSection:Toggle({Name = "Filled",Flag = "Trigger/FOVCircle/Filled",Value = false})
            TFOVSection:Colorpicker({Name = "Color",Flag = "Trigger/FOVCircle/Color",Value = {0.0833333358168602,0.6666666269302368,1,0.25,false}})
            TFOVSection:Slider({Name = "NumSides",Flag = "Trigger/FOVCircle/NumSides",Min = 3,Max = 100,Value = 14})
            TFOVSection:Slider({Name = "Thickness",Flag = "Trigger/FOVCircle/Thickness",Min = 1,Max = 10,Value = 2})
        end]]
    end
    local VisualsSection = Parvus.Utilities:ESPSection(Window,"Visuals","ESP/NPC",true,true,true,true,true,true) do
        VisualsSection:Colorpicker({Name = "Ally Color",Flag = "ESP/NPC/Ally",Value = {0.3333333432674408,0.6666666269302368,1,0,false}})
        VisualsSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/NPC/Enemy",Value = {1,0.6666666269302368,1,0,false}})
        VisualsSection:Toggle({Name = "Team Check",Flag = "ESP/NPC/TeamCheck",Value = false})
        VisualsSection:Toggle({Name = "Use Team Color",Flag = "ESP/NPC/TeamColor",Value = false})
        VisualsSection:Toggle({Name = "Distance Check",Flag = "ESP/NPC/DistanceCheck",Value = false})
        VisualsSection:Slider({Name = "Distance",Flag = "ESP/NPC/Distance",Min = 25,Max = 1000,Value = 250,Unit = "studs"})
    end
    local MiscTab = Window:Tab({Name = "Miscellaneous"}) do
        local WeaponSection = MiscTab:Section({Name = "Weapon",Side = "Left"}) do
            WeaponSection:Toggle({Name = "Wallbang",Flag = "TWR/Wallbang",Value = false}):ToolTip("Silent Aim required")
            WeaponSection:Toggle({Name = "Instant Hit",Flag = "TWR/InstantHit",Value = false}):ToolTip("Silent Aim required\nAlso enables Wallbang")
            WeaponSection:Divider()
            WeaponSection:Toggle({Name = "Unlimited Ammo Mag",Flag = "TWR/InfMag",Value = false})
            WeaponSection:Toggle({Name = "Unlimited Ammo Pool",Flag = "TWR/InfPool",Value = false})
            --[[WeaponSection:Divider()
            WeaponSection:Toggle({Name = "Damage Multiplier",Flag = "TWR/Damage/Enabled",Value = false})
            WeaponSection:Slider({Name = "",Flag = "TWR/Damage/Value",Min = 100,Max = 200,Value = 100,Unit = "%",Wide = true})]]
            --[[WeaponSection:Divider()
            WeaponSection:Toggle({Name = "Firerate Multiplier",Flag = "TWR/Firerate/Enabled",Value = false})
            WeaponSection:Slider({Name = "",Flag = "TWR/Firerate/Value",Min = 100,Max = 200,Value = 100,Unit = "%",Wide = true})
            WeaponSection:Divider()
            WeaponSection:Toggle({Name = "Recoil Control",Flag = "TWR/Recoil/Enabled",Value = false})
            WeaponSection:Slider({Name = "Recoil Shake",Flag = "TWR/Recoil/RecoilShake",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WeaponSection:Slider({Name = "Verticle Recoil",Flag = "TWR/Recoil/VerticleRecoil",Min = 0,Max = 100,Value = 0,Unit = "%"})
            WeaponSection:Slider({Name = "Horizontal Recoil",Flag = "TWR/Recoil/HorizontalRecoil",Min = 0,Max = 100,Value = 0,Unit = "%"})]]
        end
        local ItemSection = MiscTab:Section({Name = "Item ESP",Side = "Left"}) do local Items = {}
            ItemSection:Toggle({Name = "Enabled",Flag = "TWR/ESP/Items/Enabled",Value = false})
            ItemSection:Toggle({Name = "Distance Check",Flag = "TWR/ESP/Items/DistanceCheck",Value = false})
            ItemSection:Slider({Name = "Distance",Flag = "TWR/ESP/Items/Distance",Min = 25,Max = 5000,Value = 1000,Unit = "studs"})

            for Index,Data in pairs(ItemPickups) do
                local ItemFlag = "TWR/ESP/Items/" .. Data[1]
                Window.Flags[ItemFlag .. "/Enabled"] = Data[2]

                Items[#Items + 1] = {
                    Name = Data[1],Mode = "Toggle",Value = Data[2],
                    Colorpicker = {Flag = ItemFlag .. "/Color",Value = {1,0,1,0.5,false}},
                    Callback = function(Selected,Option) Window.Flags[ItemFlag .. "/Enabled"] = Option.Value end
                }
            end
            
            ItemSection:Dropdown({Name = "ESP List",Flag = "TWR/Items",List = Items})
        end
    end Parvus.Utilities:SettingsSection(Window,"End",false)
end Parvus.Utilities.InitAutoLoad(Window)

Parvus.Utilities:SetupWatermark(Window)
Parvus.Utilities.Drawing.SetupCursor(Window)
Parvus.Utilities.Drawing.SetupCrosshair(Window.Flags)
--Parvus.Utilities.Drawing.FOVCircle("Aimbot",Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("Trigger",Window.Flags)
Parvus.Utilities.Drawing.FOVCircle("SilentAim",Window.Flags)

local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

local function Raycast(Origin,Direction,Filter)
    WallCheckParams.FilterDescendantsInstances = Filter
    return Workspace:Raycast(Origin,Direction,WallCheckParams)
end
local function InEnemyTeam(Enabled,Player)
    if not Enabled then return true end
    return LocalPlayer.Team ~= Player.Team
end
local function IsDistanceLimited(Enabled,Distance,Limit)
    if not Enabled then return end
    return Distance >= Limit
end
local function IsVisible(Enabled,Origin,Position,Character)
    if not Enabled then return true end
    return not Raycast(Origin,Position - Origin,
    {Character,LocalPlayer.Character})
end
local function GetClosest(Enabled,
    VisibilityCheck,DistanceCheck,DistanceLimit,
    FieldOfView,Priority,BodyParts
)

    if not Enabled then return end
    local CameraPosition,Closest = Camera.CFrame.Position,nil
    for Index,NPC in pairs(NPCFolder:GetChildren()) do
        for Index,BodyPart in pairs(BodyParts) do
            BodyPart = NPC:FindFirstChild(BodyPart)
            if not BodyPart then continue end

            local BodyPartPosition = BodyPart.Position
            local Distance = (BodyPartPosition - CameraPosition).Magnitude
            if IsDistanceLimited(DistanceCheck,Distance,DistanceLimit) then continue end
            if not IsVisible(VisibilityCheck,CameraPosition,BodyPartPosition,NPC) then continue end

            local ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            if not OnScreen then continue end

            local Magnitude = (Vector2.new(ScreenPosition.X,ScreenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
            if Magnitude >= FieldOfView then continue end

            if Priority == "Random" then
                Priority = KnownBodyParts[math.random(#KnownBodyParts)][1]
                BodyPart = NPC:FindFirstChild(Priority)
                if not BodyPart then continue end

                BodyPartPosition = BodyPart.Position
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            elseif Priority ~= "Closest" then
                BodyPart = NPC:FindFirstChild(Priority)
                if not BodyPart then continue end

                BodyPartPosition = BodyPart.Position
                ScreenPosition,OnScreen = Camera:WorldToViewportPoint(BodyPartPosition)
            end

            FieldOfView,Closest = Magnitude,{NPC,NPC,BodyPart,ScreenPosition}
        end
    end

    return Closest
end
--[[local function AimAt(Hitbox,Sensitivity)
    if not Hitbox then return end

    local MouseLocation = UserInputService:GetMouseLocation()
    mousemoverel(Vector2.new(
        (Hitbox[4].X - MouseLocation.X) * Sensitivity,
        (Hitbox[4].Y - MouseLocation.Y) * Sensitivity
    ))
end]]

--[[OldOCIFunction = nil
OldOCIFunction = hookfunction(OCIFunction,function(...)
    local ToReturn = OldOCIFunction(...)
    print("OCI",repr(ToReturn),repr({...}))

    for Index,Weapon in pairs(ToReturn.WC) do
        Weapon.Pool = 0
        Weapon.Mag = 1
    end return ToReturn
end)]]

local OldNamecall = nil
OldNamecall = hookmetamethod(game,"__namecall",function(Self,...)
    if getnamecallmethod() == "FireServer" then
        local Args = {...}

        if Args[1] == "CheatKick" then
            return
        end
    end

    return OldNamecall(Self,...)
end)

local OldCast = RayModule.Cast
RayModule.Cast = function(...)
    local Args = {...}

    if SilentAim and Args[4] == Enum.RaycastFilterType.Blacklist then
        if Window.Flags["TWR/Wallbang"] then
            Args[4] = Enum.RaycastFilterType.Whitelist
            Args[3] = {SilentAim[2]}
        end
        if math.random(100) <= Window.Flags["SilentAim/HitChance"] then
            if Window.Flags["TWR/InstantHit"] then
                local LookVector = SilentAim[3].CFrame * CFrame.new(0,0,-2)
                Args[1] = LookVector.Position
                Args[2] = SilentAim[3].Position - LookVector.Position
            else
                Args[1] = Camera.CFrame.Position
                Args[2] = SilentAim[3].Position - Camera.CFrame.Position
            end
        end

        return OldCast(unpack(Args))
    end

    return OldCast(...)
end

--[[local OldBulletUpdate = Bullet.Update
Bullet.Update = function(Self,...)
    if Window.Flags["TWR/Damage/Enabled"] then
        Self.damage = Self.damage * Window.Flags["TWR/Damage/Value"] / 100
    end
    return OldBulletUpdate(Self,...)
end]]

local OldInteractUpdate = Interact.Update
Interact.Update = function(Self,...)
    local Args = {...}

    if Args[1].Equipped then
        local Weapon = Args[3][Args[1].Equipped]
        local WeaponStats = Args[1].WeaponModule.Stats

        if WeaponStats.Mag and Window.Flags["TWR/InfMag"] then
            Weapon.Mag = WeaponStats.Mag
        end

        if WeaponStats.Pool and Window.Flags["TWR/InfPool"] then
            Weapon.Pool = WeaponStats.Pool
        end

        --[[if WeaponStats.RPM and Window.Flags["TWR/Firerate/Enabled"] then
            Weapon.RPM = WeaponStats.RPM * Window.Flags["TWR/Firerate/Value"]
        end

        print(repr(Weapon))
        if WeaponStats.RecoilShake and WeaponStats.VerticleRecoil and WeaponStats.HorizontalRecoil then
            local Enabled = Window.Flags["TWR/Recoil/Enabled"]
            Weapon.RecoilShake = Enabled and WeaponStats.RecoilShake * Window.Flags["TWR/Recoil/RecoilShake"] / 100 or WeaponStats.RecoilShake
            Weapon.VerticleRecoil = Enabled and WeaponStats.VerticleRecoil * Window.Flags["TWR/Recoil/VerticleRecoil"] / 100 or WeaponStats.VerticleRecoil
            Weapon.HorizontalRecoil = Enabled and WeaponStats.HorizontalRecoil * Window.Flags["TWR/Recoil/HorizontalRecoil"] / 100 or WeaponStats.HorizontalRecoil
        end]]

        return OldInteractUpdate(Self,unpack(Args))
    end

    return OldInteractUpdate(...)
end

--[[Parvus.Utilities.NewThreadLoop(0,function()
    if not (Aimbot or Window.Flags["Aimbot/AlwaysEnabled"]) then return end

    AimAt(GetClosest(
        Window.Flags["Aimbot/Enabled"],
        Window.Flags["Aimbot/VisibilityCheck"],
        Window.Flags["Aimbot/DistanceCheck"],
        Window.Flags["Aimbot/DistanceLimit"],
        Window.Flags["Aimbot/FieldOfView"],
        Window.Flags["Aimbot/Priority"][1],
        Window.Flags["Aimbot/BodyParts"]
    ),Window.Flags["Aimbot/Sensitivity"] / 100)
end)]]
Parvus.Utilities.NewThreadLoop(0,function()
    SilentAim = GetClosest(
        Window.Flags["SilentAim/Enabled"],
        Window.Flags["SilentAim/VisibilityCheck"],
        Window.Flags["SilentAim/DistanceCheck"],
        Window.Flags["SilentAim/DistanceLimit"],
        Window.Flags["SilentAim/FieldOfView"],
        Window.Flags["SilentAim/Priority"][1],
        Window.Flags["SilentAim/BodyParts"]
    )
end)
--[[Parvus.Utilities.NewThreadLoop(0,function()
    if not (Trigger or Window.Flags["Trigger/AlwaysEnabled"]) then return end
    --if not iswindowactive() then return end

    local TriggerClosest = GetClosest(
        Window.Flags["Trigger/Enabled"],
        Window.Flags["Trigger/VisibilityCheck"],
        Window.Flags["Trigger/DistanceCheck"],
        Window.Flags["Trigger/DistanceLimit"],
        Window.Flags["Trigger/FieldOfView"],
        Window.Flags["Trigger/Priority"][1],
        Window.Flags["Trigger/BodyParts"]
    ) if not TriggerClosest then return end

    task.wait(Window.Flags["Trigger/Delay"]) mouse1press()
    if Window.Flags["Trigger/HoldMouseButton"] then
        while task.wait() do
            TriggerClosest = GetClosest(
                Window.Flags["Trigger/Enabled"],
                Window.Flags["Trigger/VisibilityCheck"],
                Window.Flags["Trigger/DistanceCheck"],
                Window.Flags["Trigger/DistanceLimit"],
                Window.Flags["Trigger/FieldOfView"],
                Window.Flags["Trigger/Priority"][1],
                Window.Flags["Trigger/BodyParts"]
            ) if not TriggerClosest or not Trigger then break end
        end
    end mouse1release()
end)]]

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

for Index,Item in pairs(Items:GetChildren()) do
    Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.PrimaryPart.Position,
    "TWR/ESP/Items","TWR/ESP/Items/" .. Item.Name,Window.Flags)
end
Items.ChildAdded:Connect(function(Item)
    repeat task.wait(1) until Item.PrimaryPart
    Parvus.Utilities.Drawing:AddObject(Item,Item.Name,Item.PrimaryPart.Position,
    "TWR/ESP/Items","TWR/ESP/Items/" .. Item.Name,Window.Flags)
end)
Items.ChildRemoved:Connect(function(Item)
    Parvus.Utilities.Drawing:RemoveObject(Item)
end)

for Index,NPC in pairs(NPCFolder:GetChildren()) do
    Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
end
NPCFolder.ChildAdded:Connect(function(NPC)
    Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
end)
NPCFolder.ChildRemoved:Connect(function(NPC)
    Parvus.Utilities.Drawing:RemoveESP(NPC)
end)
