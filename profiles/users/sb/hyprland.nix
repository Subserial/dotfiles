{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    grim
    slurp
    hyprpaper
    hyprsunset
    wl-clipboard-rs
  ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      source = "$HOME/.config/hypr/lock/macchiato.conf";
      "$accent" = "$mauve";
      "$accentAlpha" = "$mauveAlpha";
      "$font" = "JetBrainsMono Nerd Font";

      general.hide_cursor = true;
      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
          "inputFieldDots, 1, 2, linear"
        ];
      };
      background = {
        monitor = "";
        # path = "screenshot";
        blur_passes = 0;
        color = "$base";
      };

      label = [
        {
          monitor = "";
          text = "Layout: $LAYOUT";
          color = "$text";
          font_size = 25;
          font_family = "$font";
          position = "30, -30";
          halign = "left";
          valign = "top";
        }
        {
          monitor = "";
          text = "$TIME";
          color = "$text";
          font_size = 90;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:10000] date +\"%A, %d %B %Y\"";
          color = "$text";
          font_size = 25;
          font_family = "$font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];

      image = [
        {
          monitor = "";
          path = "$HOME/.config/hypr/lock/face.png";
          size = 100;
          border_color = "$accent";
          position = "0, 75";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = {
        monitor = "";
        size = "300, 60";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "$accent";
        inner_color = "$surface0";
        font_color = "$text";
        fade_on_empty = false;
        placeholder_text = "<span foreground=\"##$textAlpha\"><i>Logged in as </i><span foreground=\"##$accentAlpha\">$USER</span></span>";
        hide_input = false;
        check_color = "$accent";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -47";
        halign = "center";
        valign = "center";
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = ''
      -- Load user configuration
      dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.user.lua")
    '';
  };

  systemd.user.services.seed-hyprland-config = {
    Unit = {
      Description = "Seed Hyprland user config from active OS profile if missing";
      Before = [
        "graphical-session-pre.target"
        "hyprland-session.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [
        "graphical-session-pre.target"
        "default.target"
      ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "seed-hyprland-config" ''
        CONFIG_DIR="$HOME/.config/hypr"
        CONFIG_FILE="$CONFIG_DIR/hyprland.user.lua"
        SOURCE_FILE="${./hyprland.user.lua}"

        mkdir -p "$CONFIG_DIR"
        if [ ! -e "$CONFIG_FILE" ]; then
          cp "$SOURCE_FILE" "$CONFIG_FILE"
          chmod u+w "$CONFIG_FILE"
        fi
      '';
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = false;
      splash = true;
      preload = [
        "/home/sb/.config/hypr/paper/946739-top.jpg"
        "/home/sb/.config/hypr/paper/946739-bottom.jpg"
      ];
      wallpaper = [
        {
          monitor = "DP-1";
          path = "/home/sb/.config/hypr/paper/946739-top.jpg";
          fit_mode = "cover";
        }
        {
          monitor = "HDMI-A-1";
          path = "/home/sb/.config/hypr/paper/946739-bottom.jpg";
          fit_mode = "cover";
        }
      ];
    };
  };
}
