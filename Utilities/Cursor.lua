local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function TableToColor(Table)
    if typeof(Table) ~= "table" then return end
    return Color3.new(Table[1],Table[2],Table[3])
end

local function AddDrawing(Type, Properties)
    local Drawing = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        Drawing[Property] = Value
    end
    return Drawing
end

return function(CursorConfig)
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
    Color = TableToColor(CursorConfig.Crosshair.Color),
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

local CrosshairR = AddDrawing("Line", {
    Color = TableToColor(CursorConfig.Crosshair.Color),
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

local CrosshairT = AddDrawing("Line", {
    Color = TableToColor(CursorConfig.Crosshair.Color),
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

local CrosshairB = AddDrawing("Line", {
    Color = TableToColor(CursorConfig.Crosshair.Color),
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

RunService.RenderStepped:Connect(function()
    local CursorEnabled = CursorConfig.Enabled and UserInputService.MouseBehavior == Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
    local CrosshairEnabled = CursorConfig.Crosshair.Enabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default and not UserInputService.MouseIconEnabled
    local Mouse = UserInputService:GetMouseLocation()

    Cursor.Visible = CursorEnabled
    CursorOutline.Visible = CursorEnabled

    CrosshairL.Visible = CrosshairEnabled
    CrosshairR.Visible = CrosshairEnabled
    CrosshairT.Visible = CrosshairEnabled
    CrosshairB.Visible = CrosshairEnabled

    if CursorEnabled then
        Cursor.PointA = Vector2.new(Mouse.X,Mouse.Y + CursorConfig.Length)
        Cursor.PointB = Vector2.new(Mouse.X,Mouse.Y)
        Cursor.PointC = Vector2.new(Mouse.X + CursorConfig.Width,Mouse.Y + CursorConfig.Width)

        CursorOutline.PointA = Cursor.PointA + Vector2.new(0,1)
        CursorOutline.PointB = Cursor.PointB
        CursorOutline.PointC = Cursor.PointC + Vector2.new(1,0)
    end
    if CrosshairEnabled then
        local Color = TableToColor(CursorConfig.Crosshair.Color)
        CrosshairL.Color = Color
        CrosshairL.From = Vector2.new(Mouse.X - CursorConfig.Crosshair.Gap,Mouse.Y)
        CrosshairL.To = Vector2.new(Mouse.X - (CursorConfig.Crosshair.Size + CursorConfig.Crosshair.Gap),Mouse.Y)

        CrosshairR.Color = Color
        CrosshairR.From = Vector2.new(Mouse.X + (CursorConfig.Crosshair.Gap + 1),Mouse.Y)
        CrosshairR.To = Vector2.new(Mouse.X + (CursorConfig.Crosshair.Size + (CursorConfig.Crosshair.Gap + 1)),Mouse.Y)

        CrosshairT.Color = Color
        CrosshairT.From = Vector2.new(Mouse.X,Mouse.Y - CursorConfig.Crosshair.Gap)
        CrosshairT.To = Vector2.new(Mouse.X,Mouse.Y - (CursorConfig.Crosshair.Size + CursorConfig.Crosshair.Gap))

        CrosshairB.Color = Color
        CrosshairB.From = Vector2.new(Mouse.X,Mouse.Y + (CursorConfig.Crosshair.Gap + 1))
        CrosshairB.To = Vector2.new(Mouse.X,Mouse.Y + (CursorConfig.Crosshair.Size + (CursorConfig.Crosshair.Gap + 1)))
    end
end)
end