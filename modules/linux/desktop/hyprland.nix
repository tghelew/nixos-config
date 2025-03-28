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

      variables = {
        XDG_CURRENT_DESKTOP="Hyprland";
        XDG_SESSION_TYPE="wayland";
        XDG_SESSION_DESKTOP="Hyprland";

      };
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1";
      };

      systemPackages = with pkgs; [
        copyq
        libnotify
        hyprpaper
        hypridle
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
          # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'dbus-launch Hyprland' " ;
          command = toString (pkgs.writeShellScript "hyprland-wrapper" ''
          trap 'systemctl --user stop hyprland-session.target; sleep 1' EXIT
          exec Hyprland >/dev/null
          '');
          user =config.user.name;
        };
      };
    };

    # hardware.graphics = {
    #   package = pkgs.mesa;
    #   package32 = pkgs.pkgsi686Linux.mesa;
    # };

    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland = {
        enable = true;
      };
    };

     systemd.user.targets.hyprland-session = {
      unitConfig = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    modules.theme.onReload.hyprland = "${pkgs.hyprland}/bin/hyprctl reload";

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
