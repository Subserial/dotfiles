{ self, lib, pkgs, ... }:
with lib; {

	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];
	boot.initrd = {
		availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
		kernelModules = ["vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
		luks = {
			yubikeySupport = true;
			devices."nixos-enc" = {
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
		options = [ "fmask=0022" "dmask=0022" ];
	};

	fileSystems."/" = {
		device = "/dev/nixos-vg/fsroot";
		fsType = "btrfs";
		options = [ "subvol=root" ];
	};

	fileSystems."/nix" = {
		device = "/dev/nixos-vg/fsroot";
		fsType = "btrfs";
		options = [ "subvol=nix" ];
	};

	fileSystems."/home" = {
		device = "/dev/nixos-vg/fsroot";
		fsType = "btrfs";
		options = [ "subvol=home" ];
	};

	swapDevices = [ { device = "/dev/nixos-vg/swap"; } ];

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

	services.xserver = {
		enable = true;
		desktopManager.plasma5.enable = true;
		libinput.enable = true;
		xkb = {
			layout = "us";
			variant = "";
		};
	};
	services.displayManager.sddm.enable = true;

	# Enable CUPS to print documents.
	services.printing.enable = true;

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

	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;

	environment.systemPackages = with pkgs; [
		vim
		git
		wget
		curl
	];

	# TODO: Key login
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = mkForce "no";
	};

	# Sops
	sops = {
		# TODO: Move persistent secrets from "/" to "/root".
		age.keyFile = "/root/.sops/secrets/library.age";
		secrets.password = {
			sopsFile = "${self}/secrets/library/password.txt";
			format = "binary";
			neededForUsers = true;
		};
	};

	# smart card interface
	services.pcscd.enable = true;

	system.stateVersion = "24.05";
}
