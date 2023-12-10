{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop;
in {
  config = {

    user.packages = with pkgs; [
      libqalculate  # calculator cli w/ currency conversion
    ] ;

    fonts.fontDir.enable = true;
    myfonts = {
      packages = with pkgs; [
        symbola
        meslo-lgs-nf
        mononoki
        nerdfonts
        fira-mono
        fira-code
      ];
    };


    ## Apps/Services

    # Clean up leftovers, as much as we can
    system.userActivationScripts.cleanupHome = ''
      pushd "${config.user.home}"
      #TODO: Add cleanup here
      popd
    '';
  };
}
