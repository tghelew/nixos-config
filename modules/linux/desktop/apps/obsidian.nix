{ config, lib, pkgs, ... }:

  with lib;
  with lib.my;
  let
    cfg = config.modules.desktop.apps.obsidian;
    pkg = pkgs.obsidian;
    configDir = config.nixos-config.configDir;

  in {
    options.modules.desktop.apps.obsidian = {
      enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
      user.packages = with pkgs; [
        pkg
      ];
    };
}
