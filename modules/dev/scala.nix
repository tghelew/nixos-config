{ config, options, lib, pkgs, my, ... }:

#FIXME: properly support xdg
with lib;
with lib.my;
let devCfg = config.modules.dev;
    cfg = devCfg.scala;
in {
  options.modules.dev.scala = {
    enable = mkBoolOpt false;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = with pkgs; [
        scala
        jdk
        sbt
      ];
    })

  ];
}
