local Request = (syn and syn.request)
or (http and http.request) or request
local LoadArgs = {%s}

local function HTTPGet(Url)
    local Responce = Request({Url = Url,Method = "GET"})
    if Responce then return Responce.Body end
end

loadstring(LoadArgs[1] and readfile("Parvus/Loader.lua") or
HTTPGet("%sLoader.lua"))(unpack(LoadArgs))
