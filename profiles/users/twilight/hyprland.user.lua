-- profiles/users/sb/hyprland.user.lua
-- Hyprland Lua Configuration for user sb

local home = os.getenv("HOME")
local terminal = "alacritty"
local fileManager = "thunar"
local menu = "wofi --show drun"

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1, bitdepth = 8 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- fetch colors from pywal
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

hl.on("hyprland.start", function()
	hl.exec_cmd("dunst")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("eww daemon")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-- user interface
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
	group = {
		col = {
			border_active = col_group_active,
			border_inactive = col_group_inactive,
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

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace"})

-- Curves & Animations
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
-- lmao
hl.curve("overshot", { type = "bezier", points = { { 0.68, -0.55 }, { 0.265, 1.55 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "layers", enabled = false })

-- Binds
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + M", hl.dsp.exit())

hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("F9", hl.dsp.exec_cmd(home .. "/.config/scripts/volume-down.sh"))
hl.bind("F10", hl.dsp.exec_cmd(home .. "/.config/scripts/volume-up.sh"))
hl.bind("SHIFT + F9", hl.dsp.exec_cmd(home .. "/.config/scripts/brightness-down.sh"))
hl.bind("SHIFT + F10", hl.dsp.exec_cmd(home .. "/.config/scripts/brightness-up.sh"))

hl.bind("Print", hl.dsp.exec_cmd('grim - | wl-copy'))
hl.bind(
	"SHIFT + Print",
	hl.dsp.exec_cmd('grim -g "$(slurp -w 0 -o)" "' .. home .. '/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png"')
)
hl.bind("CTRL + Print", hl.dsp.exec_cmd('grim -g "$(slurp -w 0 -o)" - | wl-copy'))

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
hl.bind("SUPER + Return", hl.dsp.workspace.toggle_special("scratch"))
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("SHIFT + F11", hl.dsp.window.fullscreen())

-- Workspace binds
local function is_current_workspace(name)
  local ws = hl.get_active_workspace()
  return ws and ws.name and ws.name == name
end

for i = 0, 9 do
	local key = tostring(i)
	local ws = (i == 0) and "10" or tostring(i)
	hl.bind("SUPER + " .. key, function()
    if is_current_workspace(ws) then return end
    hl.dispatch(hl.dsp.focus({ workspace = ws }))
  end)
	hl.bind("SUPER + SHIFT + " .. key, function()
    if is_current_workspace(ws) then return end
    hl.dispatch(hl.dsp.window.move({ workspace = ws }))
  end)
	hl.bind("SUPER + CTRL + " .. key, function()
		hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = "current" }))
    if is_current_workspace(ws) then return end
    hl.dispatch(hl.dsp.focus({ workspace = ws }))
	end)
end

-- Mouse binds
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspace rules
hl.workspace_rule({ workspace = "1", on_created_empty = terminal })
hl.workspace_rule({ workspace = "special:scratchpad", on_created_empty = "[float] " .. terminal })

-- Window rules
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

