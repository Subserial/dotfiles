{ self, pkgs, lib, extraPackages, ... }:
with lib; {	
	# Allow unfree packages
	nixpkgs.config.allowUnfree = mkDefault true;

	# Flakes!
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	users.users.twilight = {
		isNormalUser = true;
		description = "TWI-01";
		shell = pkgs.zsh;
		extraGroups = [ "networkmanager" "wheel" ];
	};

	# required for swaylock
	security.pam.services.swaylock = {};

	# Required to source the necessary files for zsh
	programs.zsh.enable = true;

	home-manager.users.twilight = {
		imports = [ 
			"${self}/home-manager/zsh.nix"
			./hyprland.nix
		];

		home = {
			username = "twilight";
			homeDirectory = "/home/twilight";
			packages = with pkgs; [
				appimage-run
				ffmpeg

				lutris
				steam

				kdePackages.kdenlive
				discord-canary
				krita
				gimp
				qbittorrent
				obs-studio
				pavucontrol
				vlc
				kdePackages.kate

				blender-hip
				audacity

				alacritty
				xfce.thunar
				kdePackages.kcalc
				wofi
				dunst
				font-awesome

				swaylock
				pywal
				jq
				grim
				slurp

				brightnessctl
				hyprsunset
				sshfs
			];
			sessionVariables = {
				EDITOR = "vim";
				VISUAL = "vim";
			};

			file.".mozilla/firefox/defaultProfile/chrome".source = "${extraPackages.wavefox}/chrome";

			file.".config/hypr/paper".source = ./paper;
			file.".config/scripts".source = "${self}/scripts";

			file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

			enableNixpkgsReleaseCheck = true;
			stateVersion = "24.05";
		};

		programs.firefox = {
			enable = true;
			languagePacks = [ "en-US" ];
			profiles."defaultProfile" = {
				name = "Twilight";
				settings = {
					"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
				};
			};
		};

		programs.git = {
			enable = true;
			settings = {
				user.name = "Subserial (TWI-01)";
				user.email = "me@subserial.website";
				core.editor = "vim";
				core.autocrlf = "input";
				init.defaultBranch = "main";
			};
		};

		programs.pywal.enable = true;
	};
}
