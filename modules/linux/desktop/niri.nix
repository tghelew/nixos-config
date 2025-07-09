
{ options, config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let inherit (inputs) niri;
  cfg = config.modules.desktop.niri;
  configDir = config.nixos-config.configDir;
  binDir = config.nixos-config.binDir;
  dataHome = config.modules.xdg.dataHome;

in {

  options.modules.desktop.niri = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    modules.desktop.type = "wayland";

    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    environment = {

      variables = {
        XDG_CURRENT_DESKTOP="Niri";
        XDG_SESSION_TYPE="wayland";
        XDG_SESSION_DESKTOP="Niri";

      };
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1";
      };

      systemPackages = with pkgs; [
        mako
        waybar
        swaylock-effects
        swaybg
        swayidle
        xwayland-satellite
        copyq
        internal.tomatrix
      ];
    };

    #login manager (greetd)
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings = {
        Autologin = {
          Session = "niri";
          User = "thierry";

        };
      };

    };
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };


    modules.shell = {
      zsh.rcFiles = [ "${configDir}/niri/completions.zsh" ];
    };

    modules.theme.onReload.niri = "${pkgs.niri}/bin/niri validate";

    systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=yes
  '';

    # Swayidle service
    home.services.swayidle = {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = [ "graphical.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swayidle}/bin/swayidle -w";
      };

      Install = { WantedBy = [ "niri.service"  ]; };
    };
    home.configFile = {
      "swayidle/config".text = import "${configDir}/swayidle/config" {inherit pkgs config;};
      "mako/config".source = "${configDir}/mako/config";
      "niri/config.kdl".source = "${configDir}/niri/config.kdl";
    };
  };
}
