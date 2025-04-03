{ options, config, lib, pkgs, input, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.xkb;
    configDir = config.nixos-config.configDir;
    desktopType = config.modules.desktop.type;
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

  services.xserver.xkb = mkIf (desktopType == "x11") {
        extraLayouts = {
          "qwerty-fr" = {
            symbolsFile = ../../../config/xkb/symbols/us;
            description = "US qwerty with french symbol";
            languages = ["eng" "fre"];
          };
       };
    };
   };
}
