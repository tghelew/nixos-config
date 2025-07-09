{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.git;
    configDir = config.nixos-config.configDir;
in {
  options.modules.shell.git = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      #FIXME: failing on darwin gitAndTools.git-annex
      unstable.gitAndTools.gh
      gitAndTools.git-open
      gitAndTools.lfs
      gitAndTools.diff-so-fancy
      (mkIf config.modules.shell.gnupg.enable
        gitAndTools.git-crypt)
      act
      git-lfs
    ];

    home.configFile = {
      "git/config".source = "${configDir}/git/config";
      "git/ignore".source = "${configDir}/git/ignore";
      "git/attributes".source = "${configDir}/git/attributes";
    };

    modules.shell = {
      zsh.rcFiles = [ "${configDir}/git/aliases.zsh" ];
      nushell.rcFiles = [ "${configDir}/git/aliases.nu" ];
    };
  };
}
