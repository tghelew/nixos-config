{ options, config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  #TODO: Setup waybar modules, themes for all apps
  cfg = config.modules.desktop.hypr;
  configDir = config.nixos-config.configDir;

in {

  options.modules.desktop.hypr = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    environment = {
    #   loginShellInit = ''
    #   # Will automatically open Hyprland when logged into tty1
    #   if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
    #     exec ${hypr-exec}
    #   fi
    # '';

      variables = {
        XDG_CURRENT_DESKTOP="Hyprland";
        XDG_SESSION_TYPE="wayland";
        XDG_SESSION_DESKTOP="Hyprland";
      };
      sessionVariables = {

        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        GDK_BACKEND = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
        MOZ_ENABLE_WAYLAND = "1";

      };
      systemPackages = with pkgs; [
        #NOTE: Check ./default.nix
        swaylock-effects
        swayidle
        dunst
        unstable.swww
        waybar
        libnotify
        wtype
      ];
    };

    # This is required!
    security.pam.services.swaylock = {
      text = ''auth include login '';
    };

    ##login manager (greetd)
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'dbus-launch Hyprland' " ;
          user = "${config.user.name}";
        };
      };
    };


    # Sudo: I hate entering my password
    security.sudo = {
     enable = true;
     execWheelOnly = true;
     wheelNeedsPassword = false;
    };


    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
      package = pkgs.unstable.hyprland;
    };

    programs.waybar = {
      enable = true;
      package = pkgs.unstable.waybar-hyprland;
    };

    modules.theme.onReload.hyprland = "${pkgs.hyprland}/bin/hyprctl reload";

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk
                       pkgs.unstable.xdg-desktop-portal-hyprland ];
    };

    systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=yes
  '';

    # Dunst service
    home.services.dunst = {
      Unit = {
        Description = "Notification manager working with Wayland";
        Documentation = "man:dunst(1)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.dunst}/bin/dunst";
      };

      Install = { WantedBy = [ "xdg-desktop-portal-hyprland.service"  ]; };
    };

    # Swayidle service
    home.services.swayidle = {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
        Environment = [ "PATH=${pkgs.bash}/bin/bash" ];
        ExecStart =
          "${pkgs.swayidle}/bin/swayidle -w";
      };

      Install = { WantedBy = [ "xdg-desktop-portal-hyprland.service"  ]; };
    };

    # SWWW service
    home.services.swww = {
      Unit = {
        Description = "Wallpaper manager for Wayland";
        Documentation = "man:swww(1)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.unstable.swww}/bin/swww init";
      };

      Install = { WantedBy = [ "xdg-desktop-portal-hyprland.service"  ]; };
    };

    home.configFile = {
      "hypr/hyprland.conf".text = import "${configDir}/hypr/hyprland.conf" { inherit config pkgs; };
      "hypr/rc.d" = {source = "${configDir}/hypr/rc.d"; recursive = true;};
      "swayidle" = {source = "${configDir}/swayidle"; recursive = true;};
    };
  };
}
