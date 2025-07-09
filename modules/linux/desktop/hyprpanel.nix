{ config, lib, pkgs,... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.hyprpanel;
    configDir = config.nixos-config.configDir;
in
{
  options.modules.desktop.hyprpanel = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {

    services.upower = {
     enable = true;
    };

    environment.systemPackages = with pkgs; [
      gvfs
      dart-sass
      libgtop
      hyprpanel
    ];
  };

}
