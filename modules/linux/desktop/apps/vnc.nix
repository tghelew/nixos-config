{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.apps.vnc;
  configDir = config.nixos-config.configDir;

in {
  options.modules.desktop.apps.vnc = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    #TODO

  };
}
