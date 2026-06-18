
local mp = require 'mp'

local function mode()
 return mp.get_property_native("user-data/mpv_mode") or "auto"
end

local function detect()
 local r=(mp.get_property("gpu-renderer") or ""):lower()
 if r:find("nvidia") or r:find("rtx") or r:find("arc") or r:find("rx") then return "dgpu" end
 if r:find("intel") or r:find("vega") or r:find("radeon graphics") then return "igpu" end
 return "unknown"
end

mp.register_event("file-loaded",function()
 if mode()~="auto" then return end
 if detect()=="dgpu" then mp.command("apply-profile perceptual")
 else mp.command("apply-profile reference") end
end)
