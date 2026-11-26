-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can split this configuration into multiple files using require:
-- local colors = require("myColors")


-- ################
-- ### MONITORS ###
-- ################

-- See https://wiki.hypr.land/Configuring/Monitors/
-- Syntax: hl.monitor.add(name, resolution, position, scale) or string shorthand
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

terminal = "wezterm"
web = "project-chromium"
fileManager = "thunar"
menu = "vicinae toggle"
editor = "neovim"

-- #################
-- ### AUTOSTART ###
-- #################

-- Autostart necessary processes, status bars, daemons, and Vicinae at launch
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")
    
    -- Start the Vicinae command palette server daemon
    hl.exec_cmd("vicinae server")
end)


-- #############################
-- ### ENVIRONMENT VARIABLES ###
-- #############################

-- See https://wiki.hypr.land/Configuring/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-- #####################
-- ### LOOK AND FEEL ###
-- #####################

-- General layout configured for Master instead of Dwindle
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = "rgba(33ccffee)",
            inactive_border = "rgba(595959aa)",
        },
        layout = "master",
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout = "us",
        kb_variant = "altgr-intl",
        kb_model = "",
        kb_options = "caps:hyper",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification
        scroll_factor = 0.3,
        touchpad = {
            natural_scroll = false,
        },

    },
})



-- ###################
-- ### KEYBINDINGS ###
-- ###################

-- See https://wiki.hypr.land/Configuring/Keywords/
local mainMod = "ALT" -- Sets ALT as main modifier

-- Set programs (referencing your previously configured programs)
local menu = "vicinae toggle"

-- Active Keybinds
-- -- Quit Hyprland with CTRL + ALT + BACKSPACE
hl.bind("CTRL + ALT + Backspace", function()
    hl.dispatch.exec_cmd("hyprshutdown")
end)

hl.bind(mainMod .. "+ F4", hl.dsp.window.close())
hl.bind(mainMod .. "+ SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "+ Escape",hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. "+ G", hl.dsp.group.toggle())
hl.bind(mainMod .. "+ SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

-- Move focus with mainMod + h/l keys
hl.bind(mainMod .. "+ h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. "+ l", hl.dsp.focus({ direction = "r" }))

hl.bind(mainMod .. "+ SHIFT + h", hl.dsp.window.move({ into_group = "l" }))
hl.bind(mainMod .. "+ SHIFT + l", hl.dsp.window.move({ into_group = "r" }))
hl.bind(mainMod .. "+ SHIFT + k", hl.dsp.window.move({ into_group = "u" }))
hl.bind(mainMod .. "+ SHIFT + j", hl.dsp.window.move({ into_group = "d" }))

-- hl.bind(mainMod .. "+ SHIFT + h", hl.dsp.window.move({ direction = "l", group_aware = true }))
-- hl.bind(mainMod .. "+ SHIFT + l", hl.dsp.window.move({ direction = "r", group_aware = true }))

hl.bind(mainMod .. "+ l", hl.dsp.group.next())
hl.bind(mainMod .. "+ h", hl.dsp.group.prev())

-- Switch workspaces with mainMod + [1-3]
-- hl.bind(mainMod .. "+ 1", hl.dsp.exec_cmd("focus-or-launch WezTerm wezterm"))
hl.bind(mainMod .. "+ 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. "+ 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. "+ 3", hl.dsp.focus({ workspace = 3 }))

-- Move active window to a workspace with mainMod + SHIFT + [1-3]
hl.bind(mainMod .. "+ SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. "+ SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. "+ SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))

-- -- Laptop multimedia keys for volume and LCD brightness
-- hl.bindel("", "XF86AudioRaiseVolume", "exec", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
-- hl.bindel("", "XF86AudioLowerVolume", "exec", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
-- hl.bindel("", "XF86AudioMute", "exec", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
-- hl.bindel("", "XF86AudioMicMute", "exec", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
-- hl.bindel("", "XF86MonBrightnessUp", "exec", "brightnessctl -e4 -n2 set 5%+")
-- hl.bindel("", "XF86MonBrightnessDown", "exec", "brightnessctl -e4 -n2 set 5%-")

-- -- Media controls (Requires playerctl)
-- hl.bindl("", "XF86AudioNext", "exec", "playerctl next")
-- hl.bindl("", "XF86AudioPause", "exec", "playerctl play-pause")
-- hl.bindl("", "XF86AudioPlay", "exec", "playerctl play-pause")
-- hl.bindl("", "XF86AudioPrev", "exec", "playerctl previous")

-- Screenshots
hl.bind("SUPER + Z", hl.dsp.exec_cmd('grim -g "$(slurp)" - | tee "$SCREENSHOT_NAME" | wl-copy'))
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd('grim -g "$(hyprctl activewindow -j | jq -r \'"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])"\')" - | tee "$SCREENSHOT_NAME" | wl-copy'))
hl.bind("SUPER + ALT + Z", hl.dsp.exec_cmd('grim - | tee "$SCREENSHOT_NAME" | wl-copy'))
