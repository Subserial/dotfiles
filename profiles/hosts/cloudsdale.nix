{ self, modulesPath, lib, pkgs, ... }:
with lib; {
	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
	];
	boot = {
		kernelModules = [ ];
		kernelParams = [ "copytoram" ];
		supportedFilesystems = [ "ntfs" "xfs" ];
		initrd = {
			availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
			kernelModules = [ "vfat" ];
			luks = {
				yubikeySupport = true;
				devices."nixos-enc" = {
					device = "/dev/sda2";
					yubikey = {
						slot = 2;
						twoFactor = false;
						gracePeriod = 30;
						keyLength = 64;
						saltLength = 16;
						storage = {
							device = "/dev/sda1";
							fsType = "vfat";
							path = "/crypt-storage/default";
						};
					};
				};
			};
		};
	};

	fileSystems."/boot" = {
		device = "/dev/sda1";
		fsType = "vfat";
		options = [ "fmask=0077" "dmask=0077" ];
	};

	fileSystems."/mnt/disk" = {
		device = "/dev/sda2";
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
		# videoDrivers = [ "modesetting" "fbdev" ];
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
