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

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("dunst")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("eww daemon")
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
		border_size = 1,
		col = {
			active_border = { colors = { "rgba(cc33ccee)", "rgba(3333ffee)" }, angle = 45 },
			inactive_border = "rgba(660066aa)",
		},
	},
	decoration = {
		rounding = 10,
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
		},
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
	},
	dwindle = {
		preserve_split = true,
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
hl.animation({ leaf = "layers", enabled = true, speed = 7, bezier = "default", style = "fade" })

----------------------
---- KEY BINDINGS ----
----------------------
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + M", hl.dsp.exit())

hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("F9", hl.dsp.exec_cmd(home .. "/.config/scripts/volume-down.sh"))
hl.bind("F10", hl.dsp.exec_cmd(home .. "/.config/scripts/volume-up.sh"))
hl.bind("SHIFT + F9", hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10"))
hl.bind("SHIFT + F10", hl.dsp.exec_cmd("hyprctl hyprsunset gamma +10"))
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

hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + J", hl.dsp.layout("rotatesplit 90"))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + H", hl.dsp.group.lock_active("toggle"))
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen())

local function move_or_focus_workspace(ws_name)
	local cur_mon = hl.get_active_monitor()
	if not cur_mon then
		hl.dispatch(hl.dsp.focus({ workspace = ws_name }))
		return
	end

	local ws = hl.get_workspace(ws_name)
	if not ws or not ws.monitor or ws.monitor.name == cur_mon.name then
		hl.dispatch(hl.dsp.focus({ workspace = ws_name }))
		return
	end

	local other_mon = ws.monitor
	hl.dispatch(hl.dsp.workspace.move({ workspace = ws_name, monitor = cur_mon.name }))
	hl.dispatch(hl.dsp.focus({ workspace = ws_name }))

	local other_active = other_mon.active_workspace
	if not other_active or other_active.is_empty or other_active.windows == 0 then
		for _, w in ipairs(hl.get_workspaces()) do
			if
				w.monitor
				and w.monitor.name == other_mon.name
				and w.name ~= ws_name
				and not w.is_empty
				and w.windows > 0
			then
				other_mon:set_workspace({ workspace = w.name })
				return
			end
		end
	end
end

-- Workspaces
for i = 1, 10 do
	local key = tostring(i % 10)
	local ws = tostring(i)
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
	hl.bind("SUPER + CTRL + " .. key, function()
		move_or_focus_workspace(ws)
	end)
end

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
