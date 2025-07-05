# modules/browser/thunderbird.nix --- https://publishers.basicattentiontoken.org
#
# A FOSS and privacy-minded browser.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop.apps.thunderbird;
in {
  options.modules.desktop.apps.thunderbird = {
    enable = mkBoolOpt false;
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.thunderbird = {
      enable = true;
      preferences = {};
    };
  };
}
