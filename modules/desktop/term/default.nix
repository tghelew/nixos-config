{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.term;
    configDir = config.nixos-config.configDir;
in {
  options.modules.desktop.term = {
    default = mkOpt types.str "alacritty";
    theme = mkOpt (types.nullOr types.path) null;
  };

  config = {
    user.packages = with pkgs; [
      alacritty
    ];
    env.TERMINAL = cfg.default;

    home.configFile."alacritty/alacritty.yml" = {source = "${configDir}/alacritty/alacritty.yml";};
    home.configFile."alacritty/extra.yml" = mkIf (cfg.theme != null) {
      text = import cfg.theme config.modules.theme;
    };
  };
}
