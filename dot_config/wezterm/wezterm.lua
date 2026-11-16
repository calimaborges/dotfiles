local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find("darwin") ~= nil

config.font = wezterm.font("FantasqueSansM Nerd Font")
config.font_size = is_macos and 15.0 or 11.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.hide_tab_bar_if_only_one_tab = true

config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseIn",
	fade_in_duration_ms = 150,
	fade_out_function = "EaseOut",
	fade_out_duration_ms = 150,
}
config.colors = {
	visual_bell = "#44475a",
}

wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
