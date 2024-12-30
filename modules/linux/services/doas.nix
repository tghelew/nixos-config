{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.doas;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.doas = {
    enable = mkBoolOpt false;
    noPass = mkBoolOpt false;
    extraConfig = with types; mkOpt (nullOr str) null;
  };

  config = mkIf cfg.enable {
      security.doas = {
         enable = true;
         wheelNeedsPassword = true;
	 extraConfig = ''
	 permit ${if cfg.noPass then "" else "persist"} keepenv ${if cfg.noPass then "nopass" else " "} ${config.user.name} as root
	 '';
      };
  };
}
