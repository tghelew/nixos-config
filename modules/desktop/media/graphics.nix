# modules/desktop/media/graphics.nix

{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.media.graphics;
    configDir = config.nixos-config.configDir;
    withWayland = config.programs.hyprland.enable || config.programs.sway.enable;
in {
  options.modules.desktop.media.graphics = {
    enable         = mkBoolOpt false;
    tools.enable   = mkBoolOpt true;
    photoshop.enable  = mkBoolOpt true;
    illustrator.enable  = mkBoolOpt true;
    threed.enable  = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      (if cfg.tools.enable then [
        font-manager   # so many damned fonts...
        imagemagick    # for image manipulation from the shell
      ] ++ (if withWayland then [ swayimg ] else [])
       else []) ++

      # replaces illustrator & indesign
      (if cfg.illustrator.enable then [
        unstable.inkscape
      ] else []) ++

      # Replaces photoshop
      (if cfg.photoshop.enable then [
        gimp
      ] else []) ++

      # 3D modelling
      (if cfg.threed.enable then [
        blender
      ] else []);

    home.configFile = {
      "GIMP/2.10" = mkIf cfg.photoshop.enable { source = "${configDir}/gimp"; recursive = true; };
      "swayimg"   = mkIf (cfg.tools.enable && withWayland) { source = "${configDir}/swayimg"; };
    };


  };
}
