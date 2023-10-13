{ config, options, lib, pkgs, ... }:
#TODO: Haskell
#FIXME: properly support xdg
with lib;
with lib.my;
let cfg = config.modules.dev;
in {
  options.modules.dev = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    documentation.dev.enable = true;
  };
}
