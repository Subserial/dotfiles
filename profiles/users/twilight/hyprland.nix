{ ... }:
{
	wayland.windowManager.hyprland = {
		enable = true;
		settings = {
			# TODO: Pass these as options, maybe
			"$mod" = "SUPER";
			"$fileManager" = "thunar";
			"$menu" = "wofi --show drun";
			"$terminal" = "alacritty";

			monitor = [ ", preferred, auto, 1" ];
			exec-once = [
				"$terminal"
				"dunst"
				"eww daemon"
				"systemctl --user start hyprpolkitagent"
				# "sshfs scroll@canterlot:/shared ~/Shared -o _netdev,reconnect,identityfile=~/.ssh/sshfs_ed25519_sk"
			];
			env = [
				"XCURSOR_SIZE,24"
				"HYPRCURSOR_SIZE,24"
			];

			bind = [
				"$mod SHIFT, R, exec, hyprctl reload"
				"$mod, M, exit"

				"$mod, L, exec, ~/.config/scripts/lock.sh"
				", F9, exec, ~/.config/scripts/volume-down.sh"
				", F10, exec, ~/.config/scripts/volume-up.sh"

				", Print, exec, grim -t png \"/home/sb/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png\""
				"SHIFT, Print, exec, grim -t png -g \"$(slurp)\" \"/home/sb/Screenshots/$(date +%y-%m-%d-%H-%M-%S).png\""

				"$mod, Q, exec, $terminal"
				"$mod, E, exec, $fileManager"
				"$mod, F, exec, firefox"
				"$mod, R, exec, $menu"

				"$mod, C, killactive"
				"$mod, V, togglefloating"
				"$mod, J, togglesplit"
				"$mod, P, pseudo"
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
				"suppressevent maximize, class:.*"
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
			gestures.workspace_swipe = false;
		};
	};
}
