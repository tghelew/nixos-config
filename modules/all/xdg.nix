# xdg.nix
#
# Set up and enforce XDG compliance. Other modules will take care of their own,
# but this takes care of the general cases.

{ config, lib, home-manager, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.xdg;
in
{
  options.modules.xdg = {
    enable = mkBoolOpt true;
    cacheHome = mkOpt types.str "${config.user.home}/.cache";
    configHome = mkOpt types.str "${config.user.home}/.config";
    dataHome = mkOpt types.str "${config.user.home}/.local/share";
    binHome = mkOpt types.str "${config.user.home}/.local/bin";
  };

  config =
    let
      xdgVariables = {
        XDG_CACHE_HOME  = cfg.cacheHome;
        XDG_CONFIG_HOME = cfg.configHome;
        XDG_DATA_HOME   = cfg.dataHome;
        XDG_BIN_HOME    = cfg.binHome;
      };
    in mkIf cfg.enable {
      home-manager.users.${config.user.name}.xdg.enable = true;
      environment = linuxXorDarwin
        {sessionVariables = xdgVariables;}
        {variables = xdgVariables;};
    };

}
