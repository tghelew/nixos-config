# modules/desktop/term/kitty.nix
#

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.term.kitty;
  cfgTerm = config.modules.desktop.term;
  configDir = config.nixos-config.configDir;
in {
  options.modules.desktop.term.kitty = {
    enable = mkBoolOpt false;

  };

  config = mkIf cfg.enable {

    env = {
      KITTY_CONFIG_DIRECTORY = "$XDG_CONFIG_DIR/kitty";
    };

    home.configFile = {
      "kitty/kitty.conf".source = "${configDir}/kitty/kitty.conf";
      "kitty/keyboard.conf".source = "${configDir}/kitty/keyboard.conf";
      "kitty/theme.conf" = mkIf (cfgTerm.theme != null) {
        text = import cfgTerm.theme config.modules.theme;
      };

    };

    environment = mkIf pkgs.stdenv.isLinux {
      systemPackages = with pkgs.unstable; [
        kitty
        (makeDesktopItem {
            name = "Kitty Single Instance";
            desktopName = "Kitty Single Instance Terminal";
            genericName = "Default terminal";
            icon = "utilities-terminal";
            exec = "${kitty}/bin/kitty --single-instance";
            categories = [ "Development" "System" "Utility" ];
        })
      ];
    };
  };
}
