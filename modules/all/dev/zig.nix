{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let devCfg = config.modules.dev;
    cfg = devCfg.zig;
    configDir = config.nixos-config.configDir;
in {
  options.modules.dev.zig = {
    enable = mkBoolOpt false;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = with pkgs; [zig zls gdb];

    }

    )
 ];

}
