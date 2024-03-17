# modules/desktop/media/comms.nix

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.comms;
in {
  options.modules.desktop.media.comms = {
    enable = mkBoolOpt false;
    slack.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      (mkIf cfg.slack.enable slack)
    ];

  };
}
