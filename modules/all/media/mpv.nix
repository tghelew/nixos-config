{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.media.mpv;
  configDir = config.nixos-config.configDir;
in {
  options.modules.desktop.media.mpv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      unstable.mpv
      #unstable.mpvc  # CLI controller for mpv
      ffmpeg
      unstable.yt-dlp
    ];

    home.configFile = {
      "mpv" = {source = "${configDir}/mpv"; recursive = true;};
      "yt-dl" = {source = "${configDir}/yt-dl"; recursive = true;};
    };

  };
}
