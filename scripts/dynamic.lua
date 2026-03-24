
local mp = require 'mp'

local hist={}
local last=0
local cur=nil
local timer=nil

local function mode()
 return mp.get_property_native("user-data/mpv_mode") or "auto"
end

local function avg()
 local s=0 for _,v in ipairs(hist) do s=s+v end return s/#hist
end

local function push(v)
 table.insert(hist,v)
 if #hist>5 then table.remove(hist,1) end
end

local function apply(p)
 if cur~=p then mp.command("apply-profile "..p) cur=p end
end

local function tick()
 if mode()~="auto" then return end
 local d=mp.get_property_number("vo-drop-frame-count",0)
 local delta=d-last
 last=d
 push(delta)
 if #hist<5 then return end
 local a=avg()
 if a>=4 then
  if cur=="perceptual" then apply("reference")
  elseif cur=="reference" then apply("low-power") end
 elseif a<=1 then
  if cur=="low-power" then apply("reference")
  elseif cur=="reference" then apply("perceptual") end
 end
end

mp.register_event("file-loaded",function()
 hist={}
 last=mp.get_property_number("vo-drop-frame-count",0)
 cur=mp.get_property("profile") or "perceptual"
 if timer then timer:kill() end
 timer=mp.add_periodic_timer(2,tick)
end)
