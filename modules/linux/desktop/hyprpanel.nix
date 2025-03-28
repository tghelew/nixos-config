{ config, lib, pkgs, inputs, ... }:

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

    nixpkgs.overlays = [ inputs.hyprpanel.overlay ];

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
