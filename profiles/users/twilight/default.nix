{ self, pkgs, lib, ... }:
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
				firefox
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

				sshfs
			];
			sessionVariables = {
				EDITOR = "vim";
				VISUAL = "vim";
			};

			file.".gitconfig".source = ./gitconfig.txt;

			file.".config/scripts" = {
				source = "${self}/scripts";
				recursive = true;
			};
			
			file.".icons/default".source = "${pkgs.vanilla-dmz}/share/icons/Vanilla-DMZ";

			enableNixpkgsReleaseCheck = true;
			stateVersion = "24.05";
		};

		programs.git = {
			enable = true;
			userName = "Subserial (TWI-01)";
			userEmail = "me@subserial.website";
			extraConfig = {
				core.editor = "vim";
				core.autocrlf = "input";
				init.defaultBranch = "main";
			};
		};

		programs.pywal.enable = true;
	};
}
