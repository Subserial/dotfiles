{
  self,
  lib,
  pkgs,
  ...
}:
with lib;
{
  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      "video=DP-5:1920x1080@75"
      "video=HDMI-A-1:1920x1080@60"
    ];
    supportedFilesystems = [ "ntfs" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "uas"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      luks = {
        devices."encrypted" = {
          device = "/dev/nvme0n1p2";
          crypttabExtraOpts = [ "fido2-device=auto" ];
        };
      };
      systemd.enable = true;
    };
  };

  fileSystems."/" = {
      device = "/dev/partitions/data";
      fsType = "xfs";
  };

  fileSystems."/boot" = {
      device = "/dev/nvme0n1p2";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/game" = {
      device = "/dev/partitions/game";
      fsType = "xfs";
  };

  fileSystems."/home" = { 
      device = "/dev/partitions/home";
      fsType = "xfs";
  };

  fileSystems."/nix" = {
      device = "/dev/partitions/nix";
      fsType = "xfs";
  };

  swapDevices = [ ];

  networking.useDHCP = mkDefault true;
  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  powerManagement.cpuFreqGovernor = mkDefault "powersave";

  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
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
    videoDrivers = lib.mkForce [
      "amdgpu"
      "modesetting"
    ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.gdm = {
    enable = true;
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
    podman-compose
    # hypr polkit
    # requires `exec-once systemctl --user start hyprpolkitagent`
    hyprpolkitagent
    # Wifi in an emergency
    wirelesstools
    # graphics extras
    libva-vdpau-driver
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
    age.keyFile = "/root/.sops/secrets/everfree.age";
    secrets.password = {
      sopsFile = "${self}/secrets/everfree/password.txt";
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
  # services.logind.powerKey = "poweroff";

  # virtualbox
  virtualisation.virtualbox.host.enable = true;
  # users.extraGroups.vboxusers.members = [ "user" ];

  system.stateVersion = "24.05";
}
