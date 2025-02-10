{ config, options, lib, pkgs, ... }:
with lib;
with lib.my;
let cfg = config.modules.dev;
in {
  options.modules.dev = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
   environment.systemPackages = with pkgs; [
     lldb
   ] ++
   (linuxXorDarwin
     [gdb]
     []);
  };
}
