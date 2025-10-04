{ self, pkgs, lib, ... }:
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
				kdePackages.kcalc
				alacritty

				webcord
				discord-canary
				firefox
				thunderbird
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

				pywal
				jq

				sshfs

				prismlauncher
			];
			sessionVariables = {
				EDITOR = "vim";
				VISUAL = "vim";
			};

			file.".config/hypr/paper".source = ./paper;

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
				core.autocrlf = "input";
				init.defaultBranch = "main";
			};
		};

		programs.pywal.enable = true;
	};
}
