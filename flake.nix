{
	description = "subsy's system config";
	
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		# Hardware tweaks
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		# Hyprland
		hyprland.url = "github:hyprwm/Hyprland";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		wavefox = {
			url = "github:QNetITQ/WaveFox?ref=refs/tags/v1.8.136";
			flake = false;
		};
	};

	outputs = inputs @ {self, nixpkgs, ... }:
	let
		specialArgs.self = ./.;
		specialArgs.extraPackages = {
			wavefox = inputs.wavefox;
		};
		specialArgs.overlays = {
			hyprland_x86 = (self: super: { hyprland = inputs.hyprland.packages.x86_64-linux.hyprland; });
		};
		superuser.personalPublicKeys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJTDi1aJeU501aY7olJyoD1H7IVHrh1/rmxHHj1SDSYu sb@everfree"
		];
	in {
		nixosConfigurations = {
			library = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				inherit specialArgs;
				modules = [
					inputs.nixos-hardware.nixosModules.dell-xps-15-9570-nvidia
					inputs.home-manager.nixosModules.home-manager
					inputs.sops-nix.nixosModules.sops
					./modules/home-manager-settings.nix
					./profiles/hosts/library.nix
					./profiles/users/twilight
					({ config, ... }: { 
						users.users.twilight = {
							hashedPasswordFile = config.sops.secrets.password.path;
							openssh.authorizedKeys.keys = superuser.personalPublicKeys;
						};
					})
				];
			};
			everfree = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				inherit specialArgs;
				modules = [
					inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
					inputs.home-manager.nixosModules.home-manager
					inputs.sops-nix.nixosModules.sops
					inputs.nixos-hardware.nixosModules.common-gpu-amd
					./modules/i2c.nix
					./modules/amd-egpu.nix
					./modules/home-manager-settings.nix
					./profiles/hosts/everfree.nix
					./profiles/users/sb
					({ config, ... }: {
						users.users.sb = {
							hashedPasswordFile = config.sops.secrets.password.path;
							openssh.authorizedKeys.keys = superuser.personalPublicKeys;
						};
					})
				];
			};
		};		
	};	
}
