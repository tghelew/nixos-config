{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.term;
    configDir = config.nixos-config.configDir;
in {
  options.modules.desktop.term = {
    default = mkOpt (types.nullOr types.str) null;
    theme = mkOpt (types.nullOr types.path) null;
  };

  config = {
    user.packages = with pkgs; [
      bat
      eza
      fd
      fzf
      jq
      ripgrep
    ];
    environment = mkIf pkgs.stdenv.isDarwin {
      etc = {
        terminfo = {
          source = "${pkgs.ncurses}/share/terminfo";
        };
      };

      systemPackages = [
        pkgs.ncurses
      ];
    };
    env.TERMINAL = optionals (cfg.default != null) cfg.default;

  };
}
