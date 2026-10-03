-- profiles/users/sb/hyprland.user.lua
-- Hyprland Lua Configuration for user sb

local home = os.getenv("HOME")
local terminal = "alacritty"
local fileManager = "thunar"
local menu = "wofi --show drun"

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1", disabled = true })
hl.monitor({ output = "Unknown-1", disabled = true })
hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "0x0", scale = 1, bitdepth = 8 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75", position = "0x1080", scale = 1, bitdepth = 8 })

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")

---------------------------------
---- PALETTE & THEME (PYWAL) ----
---------------------------------
local function load_wal_colors()
	local f = io.open(home .. "/.cache/wal/colors", "r")
	if not f then
		return nil
	end
	local lines = {}
	for line in f:lines() do
		local cleaned = line:gsub("%s+", "")
		if cleaned ~= "" then
			table.insert(lines, cleaned)
		end
	end
	f:close()
	return lines
end

local function hex_to_rgba(hex, alpha)
	if not hex then
		return nil
	end
	hex = hex:gsub("#", "")
	return "rgba(" .. hex .. (alpha or "ee") .. ")"
end

local wal = load_wal_colors()
local col_active_1 = (wal and hex_to_rgba(wal[5], "ee")) or "rgba(cc33ccee)"
local col_active_2 = (wal and hex_to_rgba(wal[2], "ee")) or "rgba(3333ffee)"
local col_inactive = (wal and hex_to_rgba(wal[1], "aa")) or "rgba(660066aa)"
local col_group_active = (wal and hex_to_rgba(wal[5], "ee")) or "rgba(cc33ccee)"
local col_group_inactive = (wal and hex_to_rgba(wal[1], "aa")) or "rgba(660066aa)"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("dunst")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("eww daemon")
	hl.exec_cmd(home .. "/.config/eww/scripts/open-bars.sh")
	hl.exec_cmd(home .. "/.config/eww/scripts/event-watcher.sh")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
	input = {
		kb_layout = "us",
		follow_mouse = 2,
		float_switch_override_focus = 0,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		col = {
			active_border = { colors = { col_active_1, col_active_2 }, angle = 45 },
			inactive_border = col_inactive,
		},
	},
	decoration = {
		rounding = 10,
		dim_inactive = true,
		dim_strength = 0.08,
		blur = {
			enabled = true,
			size = 5,
			passes = 2,
		},
		shadow = {
			enabled = true,
			range = 16,
			render_power = 3,
			color = "rgba(00000073)",
		},
	},
	group = {
		col = {
			border_active = col_group_active,
			border_inactive = col_group_inactive,
		},
		groupbar = {
			font_family = "JetBrainsMono Nerd Font",
			font_size = 10,
			height = 20,
			col = {
				active = col_group_active,
				inactive = col_group_inactive,
			},
		},
	},
	dwindle = {
		preserve_split = true,
	},
	binds = {
		workspace_back_and_forth = true,
		allow_workspace_cycles = true,
	},
})

-- Curves & Animations
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.68, -0.55 }, { 0.265, 1.55 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "layers", enabled = false })

----------------------
---- KEY BINDINGS ----
----------------------
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + M", hl.dsp.exit())

hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("F9", hl.dsp.exec_cmd(home .. "/.config/scripts/volume-down.sh"))
hl.bind("F10", hl.dsp.exec_cmd(home .. "/.config/scripts/volume-up.sh"))
hl.bind("SHIFT + F9", hl.dsp.exec_cmd(home .. "/.config/eww/scripts/brightness.sh step -10"))
hl.bind("SHIFT + F10", hl.dsp.exec_cmd(home .. "/.config/eww/scripts/brightness.sh step +10"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd(home .. "/.config/scripts/toggle-touchpad.sh"))

hl.bind("Print", hl.dsp.exec_cmd('grim "' .. home .. '/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png"'))
hl.bind(
	"SHIFT + Print",
	hl.dsp.exec_cmd('grim -g "$(slurp -w 0 -o)" "' .. home .. '/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png"')
)
hl.bind("CTRL + Print", hl.dsp.exec_cmd('grim -g "$(slurp -w 0 -o)" | wl-copy'))

hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + F", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + space", hl.dsp.exec_cmd(home .. "/.config/eww/scripts/toggle-control-center.sh"))

hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + J", hl.dsp.layout("rotatesplit 90"))
hl.bind("SUPER + P", hl.dsp.exec_cmd(home .. "/.config/eww/scripts/display-select.sh toggle"))
hl.bind("SUPER + ALT + P", hl.dsp.window.pseudo())
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + H", hl.dsp.group.lock_active("toggle"))
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous_per_monitor" }))
hl.bind("SUPER + grave", hl.dsp.focus({ workspace = "previous_per_monitor" }))
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen())

local monitor_last_ws = {}
local monitor_prev_ws = {}

for _, m in ipairs(hl.get_monitors() or {}) do
	if m.name and m.active_workspace and m.active_workspace.name then
		monitor_last_ws[m.name] = m.active_workspace.name
	end
end

hl.on("workspace.active", function(ws)
	if not ws or not ws.monitor then
		return
	end
	local mon = ws.monitor.name
	local name = ws.name
	if monitor_last_ws[mon] ~= name then
		monitor_prev_ws[mon] = monitor_last_ws[mon]
		monitor_last_ws[mon] = name
	end
end)

local function move_or_focus_workspace(ws_name)
	if ws_name == "0" then
		ws_name = "name:0"
	end

	local cur_mon = hl.get_active_monitor()
	if not cur_mon then
		hl.dispatch(hl.dsp.focus({ workspace = ws_name }))
		return
	end

	local ws = hl.get_workspace(ws_name)
	if not ws then
		hl.dispatch(hl.dsp.focus({ workspace = ws_name }))
		ws = hl.get_workspace(ws_name)
	end

	if ws and ws.monitor and ws.monitor.name ~= cur_mon.name then
		local other_mon = ws.monitor
		-- Pre-capture other_mon's previous workspace before the move triggers workspace.active fallback
		local prev_ws = monitor_prev_ws[other_mon.name]
		if not prev_ws or prev_ws == ws_name or prev_ws == ws.name or prev_ws == "0" then
			prev_ws = nil
		end

		hl.dispatch(hl.dsp.workspace.move({ workspace = ws_name, monitor = cur_mon.name }))
		hl.dispatch(hl.dsp.focus({ workspace = ws_name }))

		if prev_ws then
			local target_prev = (prev_ws == "0") and "name:0" or prev_ws
			other_mon:set_workspace({ workspace = target_prev })
			monitor_last_ws[other_mon.name] = prev_ws
		else
			local other_active = other_mon.active_workspace
			if not other_active or other_active.is_empty or other_active.windows == 0 then
				for _, w in ipairs(hl.get_workspaces()) do
					if
						w.monitor
						and w.monitor.name == other_mon.name
						and w.name ~= ws.name
						and not w.is_empty
						and w.windows > 0
					then
						other_mon:set_workspace({ workspace = w.name })
						break
					end
				end
			end
		end
	else
		hl.dispatch(hl.dsp.focus({ workspace = ws_name }))
	end
end

--------------------
---- WORKSPACES ----
--------------------
-- Workspaces 0 through 9
for i = 0, 9 do
	local key = tostring(i)
	local ws = (i == 0) and "name:0" or tostring(i)
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
	hl.bind("SUPER + CTRL + " .. key, function()
		move_or_focus_workspace(ws)
	end)
end

----------------------------
---- WORKSPACE SELECTOR ----
----------------------------
hl.define_submap("workspace_selector", function()
	for i = 0, 9 do
		local key = tostring(i)
		local ws = (i == 0) and "name:0" or tostring(i)
		hl.bind(key, function()
			move_or_focus_workspace(ws)
			hl.dispatch(hl.dsp.submap("reset"))
		end, { submap = "workspace_selector" })
	end
end)

-- Mouse binds
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

----------------------
---- WINDOW RULES ----
----------------------
hl.window_rule({
	name = "steam-workspace",
	match = { class = "steam" },
	workspace = "1",
})

hl.window_rule({
	name = "float-steam-dialogs",
	match = { class = "steam", title = ".+" },
	float = false,
})

hl.window_rule({
	name = "steam-no-initial-focus",
	match = { class = "steam" },
	no_initial_focus = true,
})

hl.window_rule({
	name = "discord-workspace",
	match = { class = "discord" },
	workspace = "4",
})

hl.window_rule({
	name = "discord-opacity",
	match = { class = "discord" },
	opacity = "1.0 0.9",
})

hl.window_rule({
	name = "alacritty-opacity",
	match = { class = "Alacritty" },
	opacity = "0.9 0.9",
})

hl.window_rule({
	name = "suppress-maximize",
	match = { class = ".*" },
	suppress_event = "maximize",
})
