# xdg.nix
#
# Set up and enforce XDG compliance. Other modules will take care of their own,
# but this takes care of the general cases.

{ config, home-manager, ... }:
{
  home-manager.users.${config.user.name}.xdg.enable = true;

  # xdg-mine

  environment = {
    sessionVariables = {
      # These are the defaults, and xdg.enable does set them, but due to load
      # order, they're not set before environment.variables are set, which could
      # cause race conditions.
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_BIN_HOME    = "$HOME/.local/bin";
    };
    variables = {
      # Conform more programs to XDG conventions. The rest are handled by their
      # respective modules.
      __GL_SHADER_DISK_CACHE_PATH = "$XDG_CACHE_HOME/nv";
      ASPELL_CONF = ''
        per-conf $XDG_CONFIG_HOME/aspell/aspell.conf;
        personal $XDG_CONFIG_HOME/aspell/en_US.pws;
        repl $XDG_CONFIG_HOME/aspell/en.prepl;
      '';
      HISTFILE        = "$XDG_DATA_HOME/bash/history";
      LESSHISTFILE    = "$XDG_CACHE_HOME/lesshst";
      WGETRC          = "$XDG_CONFIG_HOME/wgetrc";

      # INPUTRC         = "$XDG_CONFIG_HOME/readline/inputrc";
      # CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    };
  };
}
