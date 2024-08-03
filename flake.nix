{
	description = "subsy's system config";
	
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";

		# Hardware tweaks
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		sops-nix = {
			url = "github:Mic92/sops-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs @ {self, nixpkgs, ... }:
	let
		specialArgs.self = ./.;
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
					./modules/amd-egpu.nix
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
