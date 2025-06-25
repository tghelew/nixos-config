{ config, lib, pkgs, colors, fonts, ... }:
with lib;
with lib.my;
let cfg = config.modules.desktop.filemanager.yazi;
    cfgFilemanager = config.modules.desktop.filemanager;
    configDir = config.nixos-config.configDir;
in {
  options.modules.desktop.filemanager.yazi = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
  environment.systemPackages = with pkgs; [
    ffmpeg
    p7zip
    jq
    poppler
    fd
    ripgrep
    fzf
    zoxide
    imagemagick
    wl-clipboard
    unstable.yazi
  ];

    home.configFile = {
      "yazi/yazi.toml"= {source = "${configDir}/yazi/yazi.toml";};
      "yazi/keymap.toml" = {source = "${configDir}/yazi/keymap.toml";};
      "yazi/theme.toml".text = ''
        [flavor]
         dark="default"
         light="default"
      '';
      "yazi/flavors/default.yazi/flavor.toml"= mkIf (cfgFilemanager.theme != null) {
        text = import cfgFilemanager.theme config.modules.theme;
       };
    };
  };
}
