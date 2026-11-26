local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local is_macos = wezterm.target_triple:find("darwin") ~= nil

config.font = wezterm.font("FantasqueSansM Nerd Font")
config.font_size = is_macos and 15.0 or 11.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

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
config.term = "wezterm"
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = false

local projects_root = wezterm.home_dir .. "/projects"

local function session_name(project_directory)
	return project_directory:sub(#projects_root + 2)
end

local function session_directory(workspace)
	if workspace:find("^[^/]+/[^/]+$") then
		return projects_root .. "/" .. workspace
	end
end

local function list_project_sessions()
    local chezmoi_directory = wezterm.home_dir .. "/.local/share/chezmoi"
	local _, found_directories = wezterm.run_child_process({
		"find",
		projects_root,
		"-mindepth",
		"2",
		"-maxdepth",
		"2",
		"-type",
		"d",
		"-not",
		"-path",
		"*/.*",
	})
	local sessions = {}
	for project_directory in found_directories:gmatch("[^\n]+") do
		table.insert(sessions, { id = project_directory, label = session_name(project_directory) })
	end
    table.insert(sessions, { id = chezmoi_directory, label = "chezmoi" })
	table.sort(sessions, function(first, second)
		return first.label < second.label
	end)
	return sessions
end

local open_selected_project_session = wezterm.action_callback(function(window, pane, project_directory, name)
	if not project_directory then
		return
	end
	window:perform_action(act.SwitchToWorkspace({ name = name, spawn = { cwd = project_directory } }), pane)
end)

local show_project_picker = wezterm.action_callback(function(window, pane)
	local sessions = list_project_sessions()
	if #sessions == 0 then
		window:toast_notification("WezTerm", "No projects found in " .. projects_root)
		return
	end
	window:perform_action(
		act.InputSelector({
			title = "Open project session",
			choices = sessions,
			fuzzy = true,
			action = open_selected_project_session,
		}),
		pane
	)
end)

local function open_session_names()
	local oldest_window_ids = {}
	for _, mux_window in ipairs(wezterm.mux.all_windows()) do
		local name = mux_window:get_workspace()
		local window_id = mux_window:window_id()
		oldest_window_ids[name] = math.min(oldest_window_ids[name] or window_id, window_id)
	end
	local names = {}
	for name in pairs(oldest_window_ids) do
		table.insert(names, name)
	end
	table.sort(names, function(first, second)
		return oldest_window_ids[first] < oldest_window_ids[second]
	end)
	return names
end

local function switch_to_open_session(window, pane, name)
	if not name then
		return
	end
	window:perform_action(act.SwitchToWorkspace({ name = name }), pane)
end

local switch_to_selected_open_session = wezterm.action_callback(switch_to_open_session)

local show_open_session_picker = wezterm.action_callback(function(window, pane)
	local choices = {}
	for session_number, name in ipairs(open_session_names()) do
		table.insert(choices, { id = name, label = session_number .. "  " .. name })
	end
	window:perform_action(
		act.InputSelector({
			title = "Switch session",
			choices = choices,
			fuzzy = true,
			action = switch_to_selected_open_session,
		}),
		pane
	)
end)

local function switch_to_session_number(session_number)
	return wezterm.action_callback(function(window, pane)
		switch_to_open_session(window, pane, open_session_names()[session_number])
	end)
end

local function spawn_tab_in_session_directory(window, pane)
	local directory = session_directory(window:active_workspace())
	window:perform_action(act.SpawnCommandInNewTab({ cwd = directory }), pane)
end

local spawn_session_tab = wezterm.action_callback(spawn_tab_in_session_directory)

wezterm.on("new-tab-button-click", function(window, pane, button)
	if button ~= "Left" then
		return
	end
	spawn_tab_in_session_directory(window, pane)
	return false
end)

wezterm.on("update-status", function(window)
	local active = window:active_workspace()
	local cells = {}
	for session_number, name in ipairs(open_session_names()) do
		local is_active = name == active
		table.insert(cells, { Attribute = { Intensity = is_active and "Bold" or "Normal" } })
		table.insert(cells, { Foreground = { AnsiColor = is_active and "Green" or "White" } })
		table.insert(cells, { Text = " " .. session_number .. " " .. name .. " " })
	end
	window:set_left_status(wezterm.format(cells))
	window:set_right_status("")
end)

local keys = {
	{ key = "o", mods = "SUPER", action = show_project_picker },
	{ key = "j", mods = "SUPER", action = show_open_session_picker },
	{ key = "t", mods = "SUPER", action = spawn_session_tab },
	{ key = "t", mods = "CTRL|SHIFT", action = spawn_session_tab },
}
for session_number = 1, 9 do
	table.insert(keys, {
		key = tostring(session_number),
		mods = "CTRL",
		action = switch_to_session_number(session_number),
	})
end
config.keys = keys

wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
