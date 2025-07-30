{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.herbst;
  theme = config.modules.theme;
  configDir = config.nixos-config.configDir;
  binDir = config.nixos-config.binDir;
  dataHome = config.modules.xdg.dataHome;

in
{

  options.modules.desktop.herbst = {
    enable = mkBoolOpt false;
  };

  config =  mkIf cfg.enable {

    modules.desktop.type = "x11";
    environment.systemPackages = with pkgs; [
      xorg.xmodmap
      mesa-demos
      dunst
      polybarFull
      wmctrl
    ];
    services = {
      displayManager.defaultSession = "none+herbstluftwm";
      xserver = {
        enable = true;
        displayManager = {
          lightdm.enable = true;
          lightdm.greeters.mini = {
            enable = true;
            user = config.user.name;
          };
        };
        windowManager = {
          herbstluftwm.enable = true;
        };
      };
    };
    services.xserver.xrandrHeads = [

      {
        output = "DP-2-2";
        primary = true;
        monitorConfig = ''
          Option "PreferredMode" "1920x1080_60.00"
        '';
      }

      {
        output = "eDP1";
        primary = false;
        monitorConfig = ''
          Option "Enable" "false"
          Option "Ignore" "true"
        '';
      }


      {
        output = "DP-2-1";
        primary = false;
        monitorConfig = ''
         Option "PreferredMode" "2560x1440_60.00"
         Option "LeftOf" "DP-2-2"
        '';
      }
    ];

    services.displayManager = {
        autoLogin.enable = true;
        autoLogin.user = config.user.name;
    };
    # Login screen theme
    services.xserver = {
      xautolock = {
        enable = true;
        locker = "${binDir}/i3/i3lock";
        time = 15;
      };
      displayManager ={
        lightdm = {
          greeters.mini.extraConfig = ''
            [greeter]
            show-password-label = false

            [greeter-theme]
            text-color = "${theme.colors.magenta}"
            password-background-color = "${theme.colors.black}"
            window-color = "${theme.colors.types.border}"
            border-color = "${theme.colors.types.border}"
            password-border-radius = 0.01em
            password-input-width = 20
            font = "${theme.fonts.sans.name}"
            font-size = 1.2em
          '';
        };
      };
    };

    # Dunst service
    home.services.dunst = {
      Unit = {
        Description = "Notification manager working with Wayland";
        Documentation = "man:dunst(1)";
        PartOf = [ "graphical.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.dunst}/bin/dunst";
      };

      Install = { WantedBy = [ "default.target"  ]; };
    };

    home.configFile = {
      "herbstluftwm" = {source = "${configDir}/herbstluftwm"; recursive = true;};
    };


    programs.i3lock = {
      enable = true;
      package= pkgs.i3lock-color;
    };
  };
}
