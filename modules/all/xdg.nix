# xdg.nix
#
# Set up and enforce XDG compliance. Other modules will take care of their own,
# but this takes care of the general cases.

{ config, lib, home-manager, ... }:

with lib;
with lib.my;
let
  xdgVariables = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_BIN_HOME    = "$HOME/.local/bin";
  };
in
{
  home-manager.users.${config.user.name}.xdg.enable = true;
  environment = linuxXorDarwin
    {sessionVariables = xdgVariables;}
    {variables = xdgVariables;};
}
