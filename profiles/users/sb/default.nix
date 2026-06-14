{
  self,
  pkgs,
  lib,
  localPackages,
  ...
}:
with lib;
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = mkDefault true;
  nixpkgs.config.rocmSupport = true;

  nixpkgs.overlays = [
    (_: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686;
      };
    })
  ];

  # Flakes!
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.extraGroups.vboxusers.members = [ "sb" ];

  users.users.sb = {
    isNormalUser = true;
    description = "EVR-00";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
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
        thunar
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
        gimp
        obs-studio
        pavucontrol
        vlc
        kdePackages.kate

        blender
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

        localPackages.pyzo
      ];
      sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      file.".config/hypr/paper".source = ./paper;
      file.".config/hypr/lock".source = ./lock;

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
      signing.format = null;
      settings = {
        user.name = "Subserial (EVR-00)";
        user.email = "me@subserial.website";
        core.editor = "vim";
        core.autocrlf = "input";
        init.defaultBranch = "main";
      };
    };

    programs.pywal.enable = true;
    xdg.mimeApps = {
      enable = true;
      associations.removed = {
        "inode/directory" = "kate.desktop";
      };
    };

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        localPackages.vimPlugins.vimini
      ];
      settings = { };
      extraConfig = ''
        				set ts=2 sw=2
        				set smartindent
        			'';
    };
  };
}
