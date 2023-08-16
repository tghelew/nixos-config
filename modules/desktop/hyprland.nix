{ options, config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  #TODO: Setup waybar modules, themes for all apps
  cfg = config.modules.desktop.hypr;
  configDir = config.nixos-config.configDir;
  hypr-exec =  "exec dbus-launch Hyprland";

in {

  options.modules.desktop.hypr = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    environment = {
      loginShellInit = ''
      # Will automatically open Hyprland when logged into tty1
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec ${hypr-exec}
      fi
    '';

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
        dunst
        swww
        waybar
        libnotify
      ];
    };

    #TODO: Check if needed
    # security.pam.services.swaylock = {
    #   text = ''auth include login '';
    # };


    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    config.modules.theme.onReload.hyprland = "${pkgs.hyprland}/bin/hyprctl reload";

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

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];	# Install cached version so rebuild should not be required
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    systemd.user.services."dunst" = {
      enable = true;
      description = "";
      wantedBy = [ "default.target" ];
      serviceConfig.Restart = "always";
      serviceConfig.RestartSec = 2;
      serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
    };

    home.configFile = {
      "hypr/hyperland.conf" = {
        text = import configDir.hyprland/hyperland.conf config pkgs;
      };
      "hypr/hyperland/rc.d" = {source = "${configDir}/hyprland/rc.d"; recursive = true;};
    };
  };
}
