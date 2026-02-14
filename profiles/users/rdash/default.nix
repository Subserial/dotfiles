{ self, pkgs, lib, extraPackages, ... }:
with lib; {
	nixpkgs.config.allowUnfree = mkDefault true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	users.users.rdash = {
		isNormalUser = true;
		description = "RBD-##";
		shell = pkgs.zsh;
		extraGroups = [ "networkmanager" "wheel" "podman" ];
	};

	# Required to source the necessary files for zsh
	programs.zsh.enable = true;

	home-manager.users.rdash = {
		imports = [
			"${self}/home-manager/zsh.nix"
			./hyprland.nix
		];

		home = {
			username = "rdash";
			homeDirectory = "/home/rdash";
			packages = with pkgs; [
				appimage-run
				ffmpeg
				steam
				discord-canary
				gimp
				qbittorrent
				pavucontrol
				vlc
				kdePackages.kate
				audacity
				alacritty

				xfce.thunar
				kdePackages.kcalc

				wofi
				dunst
				font-awesome

				pywal
				jq

				brightnessctl
				sshfs
			];
			sessionVariables = {
				EDITOR = "vim";
				VISUAL = "vim";
			};

			# file.".mozilla/firefox/defaultProfile/chrome".source = "${extraPackages.wavefox}/chrome";

			file.".config/hypr/paper".source = ./paper;
			file.".config/scripts" = {
				source = "${self}/scripts";
				recursive = true;
			};
			file.".source".source = "${self}";

			file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanila-DMZ";

			enableNixpkgsReleaseCheck = true;
			stateVersion = "25.11";
		};

		programs.git = {
			enable = true;
			settings = {
				user.name = "Subserial (RBD-##)";
				user.email = "me@subserial.website";
				core.editor = "vim";
				core.autocrlf = "input";
				init.defaultBranch = "main";
			};
		};

		programs.firefox = {
			enable = true;
			languagePacks = [ "en-US" ];
			profiles."defaultProfile" = {
				name = "RainbowDash";
				settings = {
					"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
				};
			};
		};

		programs.pywal.enable = true;
		xdg.mimeApps = {
			enable = true;
			associations.removed = {
				"inode/directory" = "kate.desktop";
			};
		};
	};
}
