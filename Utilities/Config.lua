local HttpService = game:GetService("HttpService")
local Config = {Blacklisted = {
    "Head","Torso","HumanoidRootPart","Neck","Chest","Abdomen","Hips"
}}

local function Compare(Table,Preset)
    for Index,Value in pairs(Preset) do
        if Table[Index] == nil and not table.find(Config.Blacklisted,Value) then
            Table[Index] = Value
            Parvus.Utilities.UI:Notification2({
                Title = tostring(Index) .. " added to config",
                Color = Color3.new(0.5,1,0.5),
                Duration = 3
            })
        elseif typeof(Table[Index]) == "table" then
            Compare(Table[Index],Value)
        end
    end
    --[[
    for Index,Value in pairs(Table) do
        if Preset[Index] == nil then
            print(tostring(Index) .. " removed from config")
            Table[Index] = nil
        elseif typeof(Preset[Index]) == "table" and typeof(Value) == "table" then
            Compare(Preset[Index],Value)
        end
    end
    ]]
end

function Config:TableToColor(Table)
    if typeof(Table) ~= "table" then return end
    return Color3.fromHSV(Table[1],Table[2],Table[3])
end

function Config:WriteJSON(Name,Table)
    if not isfolder("Parvus") then makefolder("Parvus") end
    if not isfolder("Parvus/Configs") then makefolder("Parvus/Configs") end
    writefile("Parvus/Configs/"..Name..".json",HttpService:JSONEncode(Table))
end

function Config:ReadJSON(Name,Preset)
    if not isfile("Parvus/Configs/"..Name..".json") then Config:WriteJSON(Name,Preset) return Preset end
    local DecodedJSON = HttpService:JSONDecode(readfile("Parvus/Configs/"..Name..".json"))
    Compare(DecodedJSON,Preset)
    return DecodedJSON
end

return Config