# xdg.nix
#
# Set up and enforce XDG compliance. Other modules will take care of their own,
# but this takes care of the general cases.

{ config, lib, home-manager, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.xdg;
  xdgVariables = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
    XDG_CACHE_HOME  = "${config.user.home}/.cache";
    XDG_CONFIG_HOME = "${config.user.home}/.config";
    XDG_DATA_HOME   = "${config.user.home}/.local/share";
    XDG_BIN_HOME    = "${config.user.home}/.local/bin";
  };
in
{
  options.modules.xdg = {
    enable = mkBoolOpt true;
    cacheHome = mkOpt types.str xdgVariables.XDG_CACHE_HOME;
    configHome = mkOpt types.str xdgVariables.XDG_CONFIG_HOME;
    dataHome = mkOpt types.str xdgVariables.XDG_DATA_HOME;
    binHome = mkOpt types.str xdgVariables.XDG_BIN_HOME;
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.user.name}.xdg.enable = true;
    environment = linuxXorDarwin
      {sessionVariables = xdgVariables;}
      {variables = xdgVariables;};
  };

}
