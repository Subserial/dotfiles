{ self, lib, pkgs, ... }:
with lib; {
	boot = {
		kernelModules = [ ];
		kernelParams = [
			"video=card0-DP-3:1920x1080@75"
			"video=card0-HDMI-A-1:1920x1080@60"
		];
		extraModulePackages = [ ];
		supportedFilesystems = [ "ntfs" ];
		initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "usbhid" "sd_mod" ];
	};

	fileSystems."/" = {
		device = "/dev/disk/by-uuid/39074725-5d59-400f-826f-2b33340d243e";
		fsType = "ext4";
	};

	fileSystems."/nix" = {
		device = "/dev/disk/by-uuid/4acecb3a-6388-4f9f-b212-16e38272b9d9";
		fsType = "ext4";
	};

	fileSystems."/game" = {
		device = "/dev/disk/by-uuid/b655feef-7b07-4f41-bb95-5370ce64a656";
		fsType = "ext4";
	};

	fileSystems."/work" = {
		device = "/dev/disk/by-uuid/6fc1c4a9-13d6-4bda-a6a5-4693fdf6e6dd";
		fsType = "ext4";
	};

	fileSystems."/home" = {
		device = "/dev/disk/by-uuid/8576f90a-04bf-4175-b3e3-6bcbb764aa50";
		fsType = "ext4";
	};

	fileSystems."/boot" = {
		device = "/dev/disk/by-uuid/6DEC-A028";
		fsType = "vfat";
	};

	swapDevices = [ { device = "/dev/disk/by-uuid/56a84e1d-0e8a-487a-86dc-95277bd97eba"; } ];

	networking.useDHCP = mkDefault true;
	nixpkgs.hostPlatform = mkDefault "x86_64-linux";
	hardware.cpu.intel.updateMicrocode = true;
	hardware.enableRedistributableFirmware = true;

	powerManagement.cpuFreqGovernor = mkDefault "powersave";

	# Bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Graphics
	hardware.opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
	};

	# Network and time
	networking = {
		hostName = "everfree";
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

	# version gc
	nix.gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 60d";
	};

	# Login aesthetics
	boot.plymouth.enable = true;
	boot.plymouth.theme = "breeze";

	# XServer
	services.xserver = {
		enable = true;
		videoDrivers = [ "modesetting" ];
		xkb = {
			layout = "us";
			variant = "";
		};
		displayManager.gdm = {
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
	sound.enable = true;
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
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
	systemd.user.services.polkit-kde-authentication-agent-1 = {
		description = "polkit-kde-authentication-agent-1";
		wantedBy = [ "graphical-session.target" ];
		wants = [ "graphical-session.target" ];
		after = [ "graphical-session.target" ];
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
			Restart = "on-failure";
			RestartSec = 1;
			TimeoutStopSec = 10;
		};
	};

	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;

	environment.sessionVariables = {
		# Chromium/Electron Ozone support
		NIXOS_OZONE_WL = "1";
	};

	virtualisation.docker = {
		enable = true;
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};

	environment.systemPackages = with pkgs; [
		vim
		git
		wget
		curl
		docker-client
		# Wifi in an emergency
		wirelesstools
		# Graphics
		mesa
	];

	# TODO: Key login
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = mkForce "no";
	};

	# Sops
	sops = {
		age.keyFile = "/root/.sops/secrets/everfree.age";
		secrets.password = {
			sopsFile = "${self}/secrets/everfree/password.txt";
			format = "binary";
			neededForUsers = true;
		};
	};

	# smart card interface
	services.pcscd.enable = true;

	# network shares
	services.gvfs.enable = true;

	# power button config
	# services.logind.powerKey = "poweroff";

	system.stateVersion = "24.05";
}
