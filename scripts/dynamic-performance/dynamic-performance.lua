local mp = require 'mp'

------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------

local CHECK_INTERVAL = 2
local DROP_THRESHOLD = 5
local RECOVERY_TIME = 10

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local last_drop_count = 0
local stable_time = 0
local current_profile = "perceptual"

local manual_override = false

------------------------------------------------------------
-- PROFILE CONTROL
------------------------------------------------------------

local function apply_profile(p)
    if current_profile ~= p then
        mp.command("apply-profile " .. p)
        current_profile = p
        mp.osd_message("Auto profile → " .. p, 2)
        mp.msg.info("Dynamic switch → " .. p)
    end
end

------------------------------------------------------------
-- MANUAL OVERRIDE
------------------------------------------------------------

local function toggle_override()
    manual_override = not manual_override

    if manual_override then
        mp.osd_message("Manual override: ON", 2)
        mp.msg.info("Manual override enabled")
    else
        mp.osd_message("Manual override: OFF", 2)
        mp.msg.info("Manual override disabled")
    end
end

------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------

local function check_performance()
    if manual_override then
        return
    end

    local drop = mp.get_property_number("vo-drop-frame-count", 0)
    local delta = drop - last_drop_count
    last_drop_count = drop

    if delta >= DROP_THRESHOLD then
        stable_time = 0

        if current_profile == "perceptual" then
            apply_profile("reference")

        elseif current_profile == "reference" then
            apply_profile("low-power")
        end

    else
        stable_time = stable_time + CHECK_INTERVAL

        if stable_time >= RECOVERY_TIME then
            if current_profile == "low-power" then
                apply_profile("reference")

            elseif current_profile == "reference" then
                apply_profile("perceptual")
            end

            stable_time = 0
        end
    end
end

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------

local function on_file_loaded()
    last_drop_count = mp.get_property_number("vo-drop-frame-count", 0)
    stable_time = 0
    current_profile = "perceptual"

    mp.add_periodic_timer(CHECK_INTERVAL, check_performance)
end

------------------------------------------------------------
-- KEYBINDING
------------------------------------------------------------

mp.add_key_binding("Ctrl+o", "toggle-override", toggle_override)

------------------------------------------------------------
-- EVENTS
------------------------------------------------------------

mp.register_event("file-loaded", on_file_loaded)
