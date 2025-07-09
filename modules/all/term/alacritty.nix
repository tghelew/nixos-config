{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.term.alacritty;
  cfgTerm = config.modules.desktop.term;
  configDir = config.nixos-config.configDir;
in
{
  options.modules.desktop.term.alacritty = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {

    user.packages = with pkgs; [
      alacritty
      # (optionals pkgs.stdenv.isLinux  (makeDesktopItem {
      #   name = "Alacritty Single Instance";
      #   desktopName = "Alacritty Single Instance";
      #   genericName = "Default terminal";
      #   icon = "utilities-terminal";
      #   exec = "${alacritty} msg create-window || ${alacritty}";
      #   categories = [ "Development" "System" "Utility" ];
      # }))
    ];
    home.configFile."alacritty/alacritty.yml".text =
      import "${configDir}/alacritty/alacritty.yml" { inherit config pkgs; };

    home.configFile."alacritty/extra.yml" = mkIf (cfgTerm.theme != null) {
      text = import cfgTerm.theme config.modules.theme;
    };
  };

}
