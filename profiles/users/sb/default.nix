{ self, pkgs, lib, ... }:
with lib; {
	# Allow unfree packages
	nixpkgs.config.allowUnfree = mkDefault true;

	# Flakes!
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	users.users.sb = {
		isNormalUser = true;
		description = "EVR-00";
		shell = pkgs.zsh;
		extraGroups = [ "networkmanager" "wheel" ];
	};

	# Required to source the necessary files for zsh
	programs.zsh.enable = true;

	home-manager.users.sb = {
		imports = [
			"${self}/home-manager/zsh.nix"
			./hyprland.nix
		];

		home = {
			username = "sb";
			homeDirectory = "/home/sb";
			packages = with pkgs; [
				xfce.thunar
				libsForQt5.kcalc
				alacritty

				webcord
				discord-canary
				firefox
				mpv
				qbittorrent

				# parsec-bin
				lutris

				# inkscape
				kdenlive
				krita
				gimp
				obs-studio
				pavucontrol
				vlc

				blender-hip
				audacity
				appimage-run
				ffmpeg

				wofi
				dunst
				eww
				font-awesome

				swaylock
				pywal

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

			enableNixpkgsReleaseCheck = true;
			stateVersion = "24.05";
		};

		programs.git = {
			enable = true;
			userName = "Subserial (EVR-00)";
			userEmail = "me@subserial.website";
			extraConfig = {
				core.editor = "vim";
				init.defaultBranch = "init";
			};
		};
	};
}
