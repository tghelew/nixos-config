{ options, config, lib, pkgs, input, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.xkb;
    configDir = config.nixos-config.configDir;
in {
  options.modules.hardware.xkb = {
    enable = mkBoolOpt false;
  };
  config = mkIf cfg.enable {
	home.configFile = {
	  "xkb/symbols"= {
	    source = "${configDir}/xkb/symbols";
	    recursive = true;
	  };
	};
  };
}
