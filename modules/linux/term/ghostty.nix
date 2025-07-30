# modules/all/desktop/term/ghostty.nix
#
{ options, config, inputs, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.term.ghostty;
  cfgTerm = config.modules.desktop.term;
  configDir = config.nixos-config.configDir;
in {

  options.modules.desktop.term.ghostty = {
    enable = mkBoolOpt false;

  };



  config = mkIf cfg.enable {

    env = {
      GHOSTTY_CONFIG_DIRECTORY = "$XDG_CONFIG_DIR/ghostty";
    };

    home.configFile = {
      "ghostty/config".source = "${configDir}/ghostty/config";
    };

    environment = {
      systemPackages = with pkgs; [
        ghostty
      ];
    };
  };
}
