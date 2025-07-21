{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.i3;
  theme = config.modules.theme;
  configDir = config.nixos-config.configDir;
  binDir = config.nixos-config.binDir;
  dataHome = config.modules.xdg.dataHome;

in
{

  options.modules.desktop.i3 = {
    enable = mkBoolOpt false;
  };

  config =  mkIf cfg.enable {

    modules.desktop.type = "x11";
    environment.systemPackages = with pkgs; [
      xorg.xmodmap
      mesa-demos
      dunst
      polybarFull
    ];
    services = {
      displayManager.defaultSession = "none+i3";
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
          i3.enable = true;
        };
      };
    };
    services.xserver.xrandrHeads = [

      {
        output = "DP-2-2";
        primary = true;
        monitorConfig = ''
          Option "PreferredMode" "2560x1440_60.00"
          Modeline "2560x1440_60.00"  311.83  2560 2744 3024 3488  1440 1441 1444 1490  -HSync +Vsync
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
         Option "Rotate" "Left"
        '';
      }
    ];

    # Login screen theme
    services.xserver = {
      xautolock = {
        enable = true;
        locker = "${binDir}/i3/i3lock";
        time = 15;
      };
      displayManager ={
        autoLogin.enable = true;
        autoLogin.user = config.user.name;
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


    programs.i3lock = {
      enable = true;
    };
  };
}
