local mp = require 'mp'
local utils = require 'mp.utils'

-- Profiles must match mpv.conf
local profiles = {
    {title = "Perceptual (Default)", profile = "perceptual"},
    {title = "Reference (Accurate)", profile = "reference"},
    {title = "Low Power", profile = "low-power"},
}

-- Track current profile manually (mpv doesn't expose stacked profiles cleanly)
local current = "perceptual"

local function apply_profile(p)
    mp.command("apply-profile " .. p)
    current = p
    mp.osd_message("Profile: " .. p, 2)
end

local function build_menu()
    local items = {}

    for _, p in ipairs(profiles) do
        local prefix = (p.profile == current) and "✔ " or ""
        table.insert(items, {
            title = prefix .. p.title,
            value = p.profile
        })
    end

    return items
end

local function show_menu()
    mp.commandv(
        "script-message-to",
        "uosc",
        "open-menu",
        "select",
        "Select Profile",
        utils.format_json({
            items = build_menu(),
            callback = "profile_menu_select"
        })
    )
end

function profile_menu_select(profile)
    apply_profile(profile)
end

mp.register_script_message("profile_menu_select", profile_menu_select)

-- Keybinding (safe, no conflict)
mp.add_key_binding("Ctrl+p", "performance-profile-menu", show_menu)