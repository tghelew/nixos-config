{ options, config, lib, pkgs, hyprland, ... }:

with lib;
with lib.my;
let
  #TODO: Setup waybar modules, themes for all apps
  cfg = config.modules.desktop.hypr;
  configDir = config.nix0s-config.configDir;
  hypr-exec =  "exec dbus-launch Hyprland";

in {

  options.modules.desktop.hypr = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    # environment.systemPackages = with pkgs; [
    #   waybar
    #   dunst
    #   gammastep
    # ];

    environment = {
      loginShellInit = ''
      # Will automatically open Hyprland when logged into tty1
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        ${exec}
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
        swaylock
        wl-clipboard
        wlr-randr
        swappy
        slurp
      ];
    };

    security.pam.services.swaylock = {
      text = ''
     auth include login
    '';
    };

    programs.hyperland = {
      hyprland = {
        enable = true;
        xwayland = {
          enable = true;
          hidpi = true;
        };
        package = hyprland.packages.${pkgs.system}.hyprland;
      };
    };

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
  };
}
