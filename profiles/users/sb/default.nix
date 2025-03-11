{ self, overlays, pkgs, lib, ... }:
with lib; {
	# Allow unfree packages
	nixpkgs.config.allowUnfree = mkDefault true;

	# Flakes!
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.extraGroups.vboxusers.members = [ "sb" ];

	users.users.sb = {
		isNormalUser = true;
		description = "EVR-00";
		shell = pkgs.zsh;
		extraGroups = [ "networkmanager" "wheel" ];
	};

	# required for swaylock
	security.pam.services.swaylock = {};

	# Required to source the necessary files for zsh
	programs.zsh.enable = true;

	home-manager.users.sb = {
		imports = [
			"${self}/home-manager/zsh.nix"
			./hyprland.nix
		];

		nixpkgs.overlays = [ overlays.hyprland_x86 ];

		home = {
			username = "sb";
			homeDirectory = "/home/sb";
			packages = with pkgs; [
				xfce.thunar
				kdePackages.kcalc
				alacritty

				webcord
				discord-canary
				firefox
				mpv
				qbittorrent

				# parsec-bin
				lutris
				steam

				# inkscape
				kdePackages.kdenlive
				krita
				gimp
				obs-studio
				pavucontrol
				vlc
				kdePackages.kate

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
				jq
				grim
				slurp

				sshfs

				prismlauncher
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
			userName = "Subserial (EVR-00)";
			userEmail = "me@subserial.website";
			extraConfig = {
				core.editor = "vim";
				init.defaultBranch = "init";
			};
		};

		programs.pywal.enable = true;
	};
}
