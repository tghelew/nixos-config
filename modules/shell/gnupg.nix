{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.shell.gnupg;
in {
  options.modules.shell.gnupg = with types; {
    enable   = mkBoolOpt false;
    cacheTTL = mkOpt int 7200;  # 2hr
    useTomb = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    env.GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
    environment.systemPackages = with pkgs;[
      pinentry-curses
    ];

    programs.gnupg.agent.enable = true;

    user.packages = mkIf cfg.useTomb [ pkgs.tomb  pkgs.steghide];

    home.configFile."gnupg/gpg-agent.conf" = {
      text = ''
        default-cache-ttl ${toString cfg.cacheTTL}
        pinentry-program ${pkgs.pinentry.gtk2}/bin/pinentry
      '';
    };
  };
}
