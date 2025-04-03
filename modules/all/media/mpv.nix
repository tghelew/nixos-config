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
      unstable.ffmpeg-full
      unstable.yt-dlp
    ];

    home.configFile = {
      "mpv" = {source = "${configDir}/mpv"; recursive = true;};
      "yt-dlp" = {source = "${configDir}/yt-dlp"; recursive = true;};
    };

  };
}
