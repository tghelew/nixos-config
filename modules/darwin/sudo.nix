{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.sudo;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.sudo = {
    enable = mkBoolOpt false;
    noPass = mkBoolOpt false;
    extraConfig = with types; mkOpt (nullOr str) null;
  };

  config = mkIf cfg.enable {
    environment.etc =
     {
      "sudoers.d/01_keep_terminfo".text = ''
        Defaults:root,%wheel env_keep+=TERMINFO_DIRS
        Defaults:root,%wheel env_keep+=TERMINFO
      '';
      "sudoers.d/02_allow_users".text = ''
        ${config.user.name}   ALL = (ALL) ${if cfg.noPass then "NOPASSWD:" else ""}ALL
      '';
      "sudoers.d/99_extra_config".text = if (cfg.extraConfig != null) then cfg.extraConfig else '''' ;
    };
<<<<<<< HEAD:modules/darwin/sudo.nix
=======
    security.sudo = mkIf pkgs.stdenv.isLinux {
      enable = true;
      wheelNeedsPassword = true;
      configFile = ''
        ${config.user.name} ALL=(ALL) ${if cfg.noPass then "NOPASSWD: " else ""}ALL
      '';
    }; 
>>>>>>> origin/main:modules/all/services/sudo.nix
  };
}
