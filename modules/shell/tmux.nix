{ config, options, pkgs, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.tmux;
    configDir = config.nixos-config.configDir;
in {
  options.modules.shell.tmux = with types; {
    enable = mkBoolOpt false;
    rcFiles = mkOpt (listOf (either str path)) [];
    theme = mkOpt path null;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [ tmux ];

    modules.theme.onReload.tmux = "${pkgs.tmux}/bin/tmux source $TMUX_HOME/extraInit > /dev/null 2>&1 ";

    modules.shell.zsh = {
      rcFiles = [ "${configDir}/tmux/aliases.zsh" ];
    };

    home.configFile = {
      "tmux" = { source = "${configDir}/tmux"; recursive = true; };
      "tmux/theme" = mkIf (cfg.theme != null) {
        source = cfg.theme;
        recursive = true;
        executable = true;
      };
      "tmux/extraInit" = {
        text = ''
          #!/usr/bin/env bash
          # This file is auto-generated by nixos, don't edit by hand!
          ${concatMapStrings (path: "tmux source-file '${path}'\n") cfg.rcFiles}
          tmux run-shell '${pkgs.tmuxPlugins.copycat}/share/tmux-plugins/copycat/copycat.tmux'
          tmux run-shell '${pkgs.tmuxPlugins.prefix-highlight}/share/tmux-plugins/prefix-highlight/prefix_highlight.tmux'
          tmux run-shell '${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux'
          tmux run-shell '${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux'
        '';
        executable = true;
      };
    };

    env.TMUX_HOME = "$XDG_CONFIG_HOME/tmux";
  };
}
