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
        swaylock
        swayidle
        dunst
        unstable.swww
        waybar
        libnotify
        wtype
      ];
    };

    ##login manager (greetd)
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions Hyprland --cmd dbus-launch Hyprland " ;
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
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=yes
  '';

    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };

    home.configFile = {
      "hypr/hyprland.conf".text = import "${configDir}/hypr/hyprland.conf" { inherit config pkgs; };
      "hypr/rc.d" = {source = "${configDir}/hypr/rc.d"; recursive = true;};
      "swayidle" = {source = "${configDir}/swayidle"; recursive = true;};
    };
  };
}
