
{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.hardware.fprint;
  configDir = config.nixos-config.configDir;
in {
  options.modules.hardware.fprint = {
    enable = mkBoolOpt false;
    tod = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      tod.enable = cfg.tod;
    };
  };
}
