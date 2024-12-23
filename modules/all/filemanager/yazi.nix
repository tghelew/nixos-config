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
    nerdfonts
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
  ];
    programs.yazi.enable = true;

    home.configFile = {
      "yazi/yazi.toml"= {source = "${configDir}/yazi/yazi.toml";};
      "yazi/keymap.toml" = {source = "${configDir}/yazi/keymap.toml";};
      "yazi/theme.toml".text = "
        [flavor]
         dark=default
         light=default ";

      "yazi/flavor/default.yazi"= mkIf (cfgFilemanager.theme != null) {
        text = import cfgFilemanager.theme config.modules.theme;
       };
    };
  };
}
