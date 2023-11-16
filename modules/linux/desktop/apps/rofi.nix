{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.apps.rofi;
  pkgRofi = if config.services.xserver.enable
             then pgks.rofi
             else pkgs.rofi-wayland;
  configDir = config.nixos-config.configDir;

in {
  options.modules.desktop.apps.rofi = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # link recursively so other modules can link files in its folder
    # home.xdg.configFile."rofi" = {
    #   source = <config/rofi>;
    #   recursive = true;
    # };

    user.packages = with pkgs; [
      (writeScriptBin "rofi" ''
        #!${stdenv.shell}
        exec ${pkgRofi}/bin/rofi -terminal "${config.modules.desktop.term.default}" -m -1 "$@"
       '')
      pwgen # for rofi-pass

    ];
    home.configFile = {
      "rofi/scripts" = {source ="${configDir}/rofi/scripts"; recursive = true; };
    };
  };
}
