{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.term;
in {
  options.modules.desktop.term = {
    default = mkOpt types.str "alacritty";
  };

  config = {
    #TODO: theme
    user.packages = with pkgs; [
      alcritty
    ];
    env.TERMINAL = cfg.default;
  };
}
