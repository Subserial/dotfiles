{ inputs, pkgs, ... }:
{
	home.packages = with pkgs; [
		grim
		slurp
		hyprpaper
		hyprsunset
		wayshot
	];

	services.hypridle = {
		enable = true;
		settings = {
			general = {
				lock_cmd = "pidof hyprlock || hyprlock";
				before_sleep_cmd = "loginctl lock-session";
				after_sleep_cmd = "hyprctl dispatch dpms on";
			};
		};
	};

	home.file.".config/hypr/lock".source = ./lock;

	programs.hyprlock = {
		enable = true;
		settings = {
			source = "$HOME/.config/hypr/lock/macchiato.conf";
			"$accent" = "$mauve";
			"$accentAlpha" = "$mauveAlpha";
			"$font" = "JetBrainsMono Nerd Font";

			general.hide_cursor = true;
			animations = {
				enabled = true;
				bezier = "linear, 1, 1, 0, 0";
				animation = [
					"fadeIn, 1, 5, linear"
					"fadeOut, 1, 5, linear"
					"inputFieldDots, 1, 2, linear"
				];
			};
			background = {
				monitor = "";
				# path = "screenshot";
				blur_passes = 0;
				color = "$base";
			};

			label = [
				{
					monitor = "";
					text = "Layout: $LAYOUT";
					color = "$text";
					font_size = 25;
					font_family = "$font";
					position = "30, -30";
					halign = "left";
					valign = "top";
				}
				{
					monitor = "";
					text = "$TIME";
					color = "$text";
					font_size = 90;
					font_family = "$font";
					position = "-30, 0";
					halign = "right";
					valign = "top";
				}
				{
					monitor = "";
					text = "cmd[update:10000] date +\"%A, %d %B %Y\"";
					color = "$text";
					font_size = 25;
					font_family = "$font";
					position = "-30, -150";
					halign = "right";
					valign = "top";
				}
			];

			image = [
				{
					monitor = "";
					path = "$HOME/.config/hypr/lock/face.png";
					size = 100;
					border_color = "$accent";
					position = "0, 75";
					halign = "center";
					valign = "center";
				}
			];

			input-field = {
				monitor = "";
				size = "300, 60";
				outline_thickness = 4;
				dots_size = 0.2;
				dots_spacing = 0.2;
				dots_center = true;
				outer_color = "$accent";
				inner_color = "$surface0";
				font_color = "$text";
				fade_on_empty = false;
				placeholder_text = "<span foreground=\"##$textAlpha\"><i>Logged in as </i><span foreground=\"##$accentAlpha\">$USER</span></span>";
				hide_input = false;
				check_color = "$accent";
				fail_color = "$red";
				fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
				capslock_color = "$yellow";
				position = "0, -47";
				halign = "center";
				valign = "center";
			};
		};
	};

	wayland.windowManager.hyprland = {
		enable = true;
		settings = {
			# TODO: Pass these as options, maybe
			"$mod" = "SUPER";
			"$fileManager" = "thunar";
			"$menu" = "wofi --show drun";
			"$terminal" = "alacritty";

			monitor = [
				"eDP-1, disable"
				"Unknown-1, disable"
				"DP-1, 1920x1080@60, 0x0, 1, bitdepth, 8"
				"HDMI-A-1, 1920x1080@75, 0x1080, 1, bitdepth, 8"
			];
			exec-once = [
				"dunst"
				"hypridle"
				"hyprpaper"
				"hyprsunset"
				"eww daemon"
				"systemctl --user start hyprpolkitagent"
				# "sshfs user@host:/shared ~/Shared -o _netdev,reconnect,identityfile=~/.ssh/sshfs_ed25519"
			];
			env = [
				"XCURSOR_SIZE,24"
				"HYPRCURSOR_SIZE,24"
				"AQ_DRM_DEVICES,/dev/dri/card1"
			];

			bind = [
				"$mod SHIFT, R, exec, hyprctl reload"
				"$mod, M, exit"

				"$mod, L, exec, loginctl lock-session"
				"$mod SHIFT, L, exec, systemctl suspend"
				", F9, exec, ~/.config/scripts/volume-down.sh"
				", F10, exec, ~/.config/scripts/volume-up.sh"
				"SHIFT, F9, exec, hyprctl hyprsunset gamma -10"
				"SHIFT, F10, exec, hyprctl hyprsunset gamma +10"
				"$mod SHIFT, T, exec, ~/.config/scripts/toggle-touchpad.sh"

				", Print, exec, wayshot -f \"/home/sb/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png\""
				"SHIFT, Print, exec, wayshot -s \"$(slurp -b ffffffaa -w 0)\" -f \"/home/sb/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png\""
				"CTRL, Print, exec, wayshot -s \"$(slurp -o -w 0)\" -f \"/home/sb/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png\""

				"$mod, Q, exec, $terminal"
				"$mod, E, exec, $fileManager"
				"$mod, F, exec, firefox"
				"$mod, R, exec, $menu"

				"$mod, C, killactive"
				"$mod, V, togglefloating"
				"$mod, J, togglesplit" # dwindle
				"$mod, P, pseudo" # dwindle
				"$mod, G, togglegroup"
				"$mod, H, lockactivegroup, toggle"
				"ALT, Tab, changegroupactive"
				"SHIFT, F11, fullscreen"
			]
			# From the hyprland wiki: build binds to workspace selectors
			++ (
				builtins.concatLists (builtins.genList (
					x: let
						xs = toString x;
						ws = if x == 0 then "10" else xs;
					in [
						"$mod, ${xs}, workspace, ${ws}"
						"$mod SHIFT, ${xs}, movetoworkspace, ${ws}"
						"$mod CTRL, ${xs}, focusworkspaceoncurrentmonitor, ${ws}"
					]
				)
				10)
			);
			bindm = [
				"$mod, mouse:272, movewindow"
				"$mod, mouse:273, resizewindow"
			];
			windowrulev2 = [
				# "workspace 1, class:(steam)"
				# "noinitialfocus, class:(steam)"
				"workspace 4, class:(discord)"
				"opacity 1.0 0.8, class:(discord)"
				"suppressevent maximize, class:.*"
				"opacity 0.8 0.8, class:(Alacritty)"
			];
			input = {
				kb_layout = "us";
				follow_mouse = 2;
				float_switch_override_focus = 0;
				touchpad.natural_scroll = true;
				sensitivity = 0;
			};
			general = {
				gaps_in = 5;
				gaps_out = 10;
				border_size = 1;
				"col.active_border" = "rgba(cc33ccee) rgba(3333ffee) 45deg";
				"col.inactive_border" = "rgba(660066aa)";
			};
			decoration = {
				rounding = 10;
				blur = {
					enabled = true;
					size = 3;
					passes = 1;
				};
				shadow = {
					enabled = true;
					range = 4;
					render_power = 3;
					color = "rgba(1a1a1aee)";
				};
			};
			animations = {
				enabled = true;
				bezier = [
					"myBezier, 0.05, 0.9, 0.1, 1.05"
					"overshot, 0.68, -0.55, 0.265, 1.55" # lmao
				];
				animation = [
					"windows, 1, 7, myBezier"
					"windowsOut, 1, 7, default, popin 80%"
					"border, 1, 10, default"
					"borderangle, 1, 8, default"
					"fade, 1, 7, default"
					"workspaces, 1, 6, default"
					"layers, 1, 7, default, fade"
				];
			};
			dwindle = {
				pseudotile = true;
				preserve_split = true;
			};
		};
	};
	services.hyprpaper = {
		enable = true;
		settings = {
			ipc = false;
			splash = true;
			preload = [
				"/home/rdash/.config/hypr/paper/1755272.jpg"
			];
			wallpaper = [
				", /home/rdash/.config/hypr/paper/1755272.jpg"
			];
		};
	};
}
