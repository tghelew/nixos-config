{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let hwCfg = config.modules.hardware;
    cfg = hwCfg.network;
in {
  options.modules.hardware.network = {
    enable = mkBoolOpt false;
    applet = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;
    environment.systemPackages = mkIf cfg.applet (
      with pkgs; [
        networkmanagerapplet
      ]);
  };
}
