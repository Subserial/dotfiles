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

	# Required to source the necessary files for zsh
	programs.zsh.enable = true;

	home-manager.users.twilight = {
		imports = [ 
			"${self}/modules/home-manager/zsh.nix"
		];

		home = {
			username = "twilight";
			homeDirectory = "/home/twilight";
			packages = with pkgs; [
				firefox
				kate
				gparted
				# management utils
				fwupd
				pciutils
			];
			sessionVariables = {
				EDITOR = "vim";
				VISUAL = "vim";
			};

			enableNixpkgsReleaseCheck = true;
			stateVersion = "24.05";
		};
	};
}
