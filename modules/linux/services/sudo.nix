{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.sudo;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.sudo = {
    enable = mkBoolOpt false;
    noPass = mkBoolOpt false;
    extraConfig = with types; mkOpt (nullOr str) null;
  };

  config = mkIf cfg.enable {
      security.sudo = {
         enable = true;
         wheelNeedsPassword = false;
         configFile = ''
         ${config.user.name}   ALL = ${if cfg.noPass then "NOPASSWD:" else ""} ALL
        '';
         extraConfig = if isNull cfg.extraConfig then "" else cfg.extraconfig;
      };
  };
}
