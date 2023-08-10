# modules/desktop/term/wezterm.nix
#

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.term.wez;
  configDir = config.nixos-config.configDir;
in {
  options.modules.desktop.term.wez = {
    enable = mkBoolOpt false;

  };

  config = mkIf cfg.enable {

    env = {
      WEZDIR = "XDG_CONFIG_HOME/wezterm";
    };

    home.configFile = {
      "wezterm" = {source = "${configDir}/wezterm"; recursive = true; };
    };

    user.packages = with pkgs; [
      bat
      exa
      fd
      fzf
      jq
      ripgrep
      wezterm
      (makeDesktopItem {
        name = "Wezterm";
        desktopName = "Wezterm Terminal";
        genericName = "Default terminal";
        icon = "utilities-terminal";
        exec = "${wezterm}";
        categories = [ "Development" "System" "Utility" ];
      })
    ];
  };
}
