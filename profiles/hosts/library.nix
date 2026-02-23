{ self, lib, pkgs, ... }:
with lib; {

	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];
	boot.initrd = {
		availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
		kernelModules = ["vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
		luks = {
			yubikeySupport = true;
			devices."encrypted" = {
				device = "/dev/nvme0n1p2";
				yubikey = {
					slot = 2;
					twoFactor = false;
					gracePeriod = 10;
					keyLength = 64;
					saltLength = 16;
					storage = {
						device = "/dev/nvme0n1p1";
						fsType = "vfat";
						path = "/crypt-storage/default";
					};
				};
			};
		};
	};

	fileSystems."/boot" = {
		device = "/dev/nvme0n1p1";
		fsType = "vfat";
		options = [ "fmask=0077" "dmask=0077" ];
	};

	fileSystems."/" = {
		device = "/dev/partitions/data";
		fsType = "xfs";
	};

	fileSystems."/nix" = {
		device = "/dev/partitions/nix";
		fsType = "xfs";
	};

	fileSystems."/game" = {
		device = "/dev/partitions/game";
		fsType = "xfs";
	};

	networking.useDHCP = mkDefault true;
	nixpkgs.hostPlatform = mkDefault "x86_64-linux";
	hardware.cpu.intel.updateMicrocode = true;
	hardware.enableRedistributableFirmware = true;

	# Bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking = {
		hostName = "library";
		networkmanager.enable = true;
	};

	time.timeZone = "America/Los_Angeles";

	i18n = {
		defaultLocale = "en_US.UTF-8";
		extraLocaleSettings = {
			LC_ADDRESS = "en_US.UTF-8";
			LC_IDENTIFICATION = "en_US.UTF-8";
			LC_MEASUREMENT = "en_US.UTF-8";
			LC_MONETARY = "en_US.UTF-8";
			LC_NAME = "en_US.UTF-8";
			LC_NUMERIC = "en_US.UTF-8";
			LC_PAPER = "en_US.UTF-8";
			LC_TELEPHONE = "en_US.UTF-8";
			LC_TIME = "en_US.UTF-8";
		};
	};

	# Login aesthetics
	boot.plymouth.enable = true;
	boot.plymouth.theme = "breeze";

	# XServer
	services.xserver = {
		enable = true;
		xkb = {
			layout = "us";
			variant = "";
		};
	};

	services.displayManager = {
		gdm = {
			enable = true;
			wayland = true;
		};
	};

	xdg = {
		autostart.enable = true;
		portal = {
			enable = true;
			extraPortals = with pkgs; [
				xdg-desktop-portal-gtk
				xdg-desktop-portal-hyprland
			];
		};
	};

	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
	};

	# Enable CUPS to print documents.
	services.printing.enable = true;

	# Enable sound with pipewire.
	security.rtkit.enable = true;
	services.pulseaudio.enable = false;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;
	};

	# Bluetooth!
	services.blueman.enable = true;
	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true;
		settings = {
			General = {
				Enable = "Source,Sink,Media,Socket";
			};
		};
	};

	# Polkit
	security.polkit.enable = true;

	home-manager.useUserPackages = true;

	# Optional, hint Electron apps to use Wayland:
	environment.sessionVariables = {
		NIXOS_OZONE_WL = "1";
	};

	virtualisation = {
		containers.enable = true;
		containers.registries.search = [ "docker.io" ];
		podman = {
			enable = true;
			dockerCompat = true;
			defaultNetwork.settings.dns_enabled = true;
		};
	};

	environment.systemPackages = with pkgs; [
		vim
		git
		wget
		curl
		# Wifi in an emergency
		wirelesstools
		podman-compose
	];

	# Dev sanity (intellij)
	programs.nix-ld.enable = true;

	# TODO: Key login
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = mkForce "no";
	};


	# Sops
	sops = {
		age.keyFile = "/root/.config/sops/age/keys.txt";
		secrets.password = {
			sopsFile = "${self}/secrets/library/password.txt";
			format = "binary";
			neededForUsers = true;
		};
	};

	# Impermanence
	users.mutableUsers = false;

	# smart card interface
	services.pcscd.enable = true;

	# network shares
	services.gvfs.enable = true;

	# power button config
	services.logind.settings.Login.HandlePowerKey = "ignore";

	system.stateVersion = "24.05";
}
