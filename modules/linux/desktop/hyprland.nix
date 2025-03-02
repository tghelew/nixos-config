{ options, config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.hypr;
  configDir = config.nixos-config.configDir;
  binDir = config.nixos-config.binDir;
  dataHome = config.modules.xdg.dataHome;

in {

  options.modules.desktop.hypr = {
    enable = mkBoolOpt false;
    hyprsome = mkBoolOpt false;
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
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };

      systemPackages = with pkgs; [
        copyq
        libnotify
        hyprpaper
        hypridle
        hyprpaper
        hyprlock
        hyprpicker
        wtype
      ];# ++ [ mkIf cfg.hyprsome internal.hyprsome ];
    };

    # This is required!
    security.pam.services.hyprlock = {
      text = ''auth include login '';
    };
    # services.displayManager.sddm = {
    #   enable = true;
    #   wayland.enable = true;
    #   autoNumlock = true;
    # };
    #login manager (greetd)

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'dbus-launch Hyprland' " ;
          user = "${config.user.name}";
        };
      };
    };



    programs.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
    };

    modules.theme.onReload.hyprland = "${pkgs.hyprland}/bin/hyprctl reload";

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk];
                       #pkgs.xdg-desktop-portal-hyprland ];
    };

    systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=yes
  '';

    home.services.hyprpaper = {
      Unit = {
        Description = "Randomly Choose a wallpaper";
        Documentation = "wallpicker --help";
        PartOf = [ "graphical.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${binDir}/hypr/wallpicker -p ${dataHome}/wallpapers";
      };

      Install = { WantedBy = [ "xdg-desktop-portal-hyprland.service"  ]; };
    };
    systemd.user.timers = {
    hyprpaper = {
      description = "Hyprpaper rotation schedule";
      timerConfig = {
        OnBootSec=5;
        Unit = "hyprpaper";
        OnCalendar = "30min";
      };
    };
  };
    home.configFile = {
      "hypr/hyprland.conf".text = import "${configDir}/hypr/hyprland.conf" { inherit config pkgs; };
      "hypr/rc.d" = {source = "${configDir}/hypr/rc.d"; recursive = true;};
      "hypr/hyprpaper.conf".source = "${configDir}/hypr/hyprpaper.conf";
      "hypr/hyprlock.conf".source = "${configDir}/hypr/hyprlock.conf";
      "hypr/hypridle.conf".source = "${configDir}/hypr/hypridle.conf";
    };
  };
}
