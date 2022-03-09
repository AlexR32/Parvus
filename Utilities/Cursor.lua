local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function AddDrawing(Type, Properties)
    local Drawing = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        Drawing[Property] = Value
    end
    return Drawing
end

getgenv().CursorConfig = {
    Enabled = true,
    Length = 16,
    Width = 11,

    Crosshair = {
        Enabled = true,
        Color = Color3.new(1,0.25,0.25),
        Size = 4,
        Gap = 2,
    }
}

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
    Color = CursorConfig.Crosshair.Color,
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

local CrosshairR = AddDrawing("Line", {
    Color = CursorConfig.Crosshair.Color,
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

local CrosshairT = AddDrawing("Line", {
    Color = CursorConfig.Crosshair.Color,
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

local CrosshairB = AddDrawing("Line", {
    Color = CursorConfig.Crosshair.Color,
    Thickness = 1.5,
    Transparency = 1,
    Visible = true,
    ZIndex = 3
})

RunService.RenderStepped:Connect(function()
    local CursorEnabled = CursorConfig.Enabled and UserInputService.MouseBehavior == Enum.MouseBehavior.Default
    local CrosshairEnabled = CursorConfig.Crosshair.Enabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default
    local Mouse = UserInputService:GetMouseLocation()
    --UserInputService.MouseIconEnabled = false

    Cursor.Visible = CursorEnabled
    CursorOutline.Visible = CursorEnabled

    CrosshairL.Visible = CrosshairEnabled
    CrosshairR.Visible = CrosshairEnabled
    CrosshairT.Visible = CrosshairEnabled
    CrosshairB.Visible = CrosshairEnabled

    if CursorConfig.Enabled then
        Cursor.PointA = Vector2.new(Mouse.X,Mouse.Y + CursorConfig.Length)
        Cursor.PointB = Vector2.new(Mouse.X,Mouse.Y)
        Cursor.PointC = Vector2.new(Mouse.X + CursorConfig.Width,Mouse.Y + CursorConfig.Width)

        CursorOutline.PointA = Cursor.PointA + Vector2.new(0,1)
        CursorOutline.PointB = Cursor.PointB
        CursorOutline.PointC = Cursor.PointC + Vector2.new(1,0)
    end
    if CursorConfig.Crosshair.Enabled then
        CrosshairL.Color = CursorConfig.Crosshair.Color
        CrosshairL.From = Vector2.new(Mouse.X - CursorConfig.Crosshair.Gap,Mouse.Y)
        CrosshairL.To = Vector2.new(Mouse.X - (CursorConfig.Crosshair.Size + CursorConfig.Crosshair.Gap),Mouse.Y)

        CrosshairR.Color = CursorConfig.Crosshair.Color
        CrosshairR.From = Vector2.new(Mouse.X + (CursorConfig.Crosshair.Gap + 1),Mouse.Y)
        CrosshairR.To = Vector2.new(Mouse.X + (CursorConfig.Crosshair.Size + (CursorConfig.Crosshair.Gap + 1)),Mouse.Y)

        CrosshairT.Color = CursorConfig.Crosshair.Color
        CrosshairT.From = Vector2.new(Mouse.X,Mouse.Y - CursorConfig.Crosshair.Gap)
        CrosshairT.To = Vector2.new(Mouse.X,Mouse.Y - (CursorConfig.Crosshair.Size + CursorConfig.Crosshair.Gap))

        CrosshairB.Color = CursorConfig.Crosshair.Color
        CrosshairB.From = Vector2.new(Mouse.X,Mouse.Y + (CursorConfig.Crosshair.Gap + 1))
        CrosshairB.To = Vector2.new(Mouse.X,Mouse.Y + (CursorConfig.Crosshair.Size + (CursorConfig.Crosshair.Gap + 1)))
    end
end)
