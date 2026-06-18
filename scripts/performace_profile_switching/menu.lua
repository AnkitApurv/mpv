
local mp = require 'mp'
local utils = require 'mp.utils'

local function get_mode()
    return mp.get_property_native("user-data/mpv_mode") or "auto"
end

local function set_mode(m)
    mp.set_property_native("user-data/mpv_mode", m)
    mp.osd_message("Mode → "..m,1)
end

local profiles = {"perceptual","reference","low-power"}

local function menu_select(choice)
    if choice == "__mode__" then
        if get_mode()=="auto" then set_mode("manual") else set_mode("auto") end
        return
    end
    set_mode("manual")
    mp.command("apply-profile "..choice)
end

local function open()
    local items = {}
    table.insert(items,{title="Mode: "..get_mode().." (toggle)",value="__mode__"})
    table.insert(items,{title="────────",disabled=true})
    local active = mp.get_property("profile")
    for _,p in ipairs(profiles) do
        table.insert(items,{title=(p==active and "✔ " or "")..p,value=p})
    end

    mp.commandv("script-message-to","uosc","open-menu","select","Control",
        utils.format_json({items=items,callback="menu_select"}))
end

mp.register_script_message("menu_select",menu_select)
mp.add_key_binding("Ctrl+p","menu",open)
