{ self, modulesPath, lib, pkgs, ... }:
with lib; {
	boot = {
		kernelModules = [ ];
		kernelParams = [
			"root=LABEL=BOOT"
			"boot.shell_on_fail"
			"copytoram"
		];
		supportedFilesystems = [ "ntfs" "xfs" ];
	};

	fileSystems."/" = {
		fsType = "tmpfs";
		options = [ "mode=0755" ];
	};

	fileSystems."/boot" = {
		device = "/dev/root";
		neededForBoot = true;
		noCheck = true;
	};

	# squashfs disk
	fileSystems."/nix/.ro-store" = {
		fsType = "squashfs";
		device = "/boot/nix-store.squashfs";
		options = [ "loop" ];
		neededForBoot = true;
	};

	fileSystems."/nix/.rw-store" = {
		fsType = "tmpfs";
		options = [ "mode=0755" ];
		neededForBoot = true;
	};

	fileSystems."/nix/store" = {
		fsType = "overlay";
		device = "overlay";
		options = [
			"lowerdir=/nix/.ro-store"
			"upperdir=/nix/.rw-store/store"
			"workdir=/nix/.rw-store/work"
		];
	};

	boot.initrd = {
		availableKernelModules = [ "squashfs" "iso9660" "uas" "overlay" "usbhid" "usb_storage" "sd_mod" ];
		kernelModules = [ "vfat" "loop" "overlay" ];
		luks = {
			yubikeySupport = true;
			devices."nixos-enc" = {
				device = "/dev/disk/by-partlabel/persist";
				yubikey = {
					slot = 2;
					twoFactor = false;
					gracePeriod = 5;
					keyLength = 64;
					saltLength = 16;
					storage = {
						device = "/dev/root";
						fsType = "vfat";
						path = "/crypt-storage/default";
					};
				};
			};
		};
	};

	fileSystems."/persist" = {
		device = "/dev/disk/by-label/HEARTH";
		fstype = "xfs";
	};

	networking.useDHCP = mkDefault true;
	nixpkgs.hostPlatform = mkDefault "x86_64-linux";
	hardware.cpu.intel.updateMicrocode = true;
	hardware.enableRedistributableFirmware = true;

	powerManagement.cpuFreqGovernor = mkDefault "powersave";

	# Bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Network and time
	networking = {
		hostName = "cloudsdale";
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

	services.displayManager.gdm = {
		enable = true;
		wayland = true;
	};

	xdg = {
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
	services.printing = {
		enable = true;
		drivers = [ pkgs.cnijfilter2 ];
	};
	services.avahi = {
		enable = true;
		nssmdns4 = true;
		openFirewall = true;
	};

	# Enable sound with pipewire.
	security.rtkit.enable = true;
	services.pulseaudio.enable = false;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
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

	environment.sessionVariables = {
		# Chromium/Electron Ozone support
		NIXOS_OZONE_WL = "1";
	};

	virtualisation = {
		containers.enable = true;
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
		# requires `exec-once systemctl --user start hyprpolkitagent`
		hyprpolkitagent
		# Wifi in an emergency
		wirelesstools
	];

	# TODO: Key login
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = mkForce "no";
	};

	# Impermanence
	users.mutableUsers = false;

	# smart card interface
	services.pcscd.enable = true;

	# network shares
	services.gvfs.enable = true;

	# power button config
	# services.logind.powerKey = "poweroff";

	system.stateVersion = "25.11";
}
