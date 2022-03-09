local HttpService = game:GetService("HttpService")
local Config = {}

local function Compare(Table,Default)
    for Index,Value in pairs(Default) do
        if Table[Index] == nil then
            Table[Index] = Value
            print(tostring(Index) .. " added to config")
        elseif typeof(Table[Index]) == "table" and typeof(Value) == "table" then
            Compare(Table[Index],Value)
        end
    end
    for Index,Value in pairs(Table) do
        if Default[Index] == nil then
            print(tostring(Index) .. " removed from config")
            Table[Index] = nil
        elseif typeof(Default[Index]) == "table" and typeof(Value) == "table" then
            Compare(Default[Index],Value)
        end
    end
end

function Config:TableToColor(Table)
    if typeof(Table) ~= "table" then return end
    return Color3.new(Table[1],Table[2],Table[3])
end

function Config:WriteJSON(Name,Table)
    if not isfolder("Parvus") then makefolder("Parvus") end
    if not isfolder("Parvus/Configs") then makefolder("Parvus/Configs") end
    writefile("Parvus/Configs/"..Name..".json",HttpService:JSONEncode(Table))
end

function Config:ReadJSON(Name,DefaultTable)
    if not isfile("Parvus/Configs/"..Name..".json") then Config:WriteJSON(Name,DefaultTable) return DefaultTable end
    local DecodedTable = HttpService:JSONDecode(readfile("Parvus/Configs/"..Name..".json"))
    Compare(DecodedTable,DefaultTable)
    return DecodedTable
end

return Config