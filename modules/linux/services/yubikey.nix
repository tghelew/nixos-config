
{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.yubikey;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.yubikey = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.udev.packages = [ pkgs.yubikey-personalization ];
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    security.pam.yubico = {
      enable = true;
      debug = true;
      mode = "challenge+response";
    };

  environment.systemPackages = with pkgs; [
    pam_u2f
    yubikey-personalisation
    pamtester
  ];


  };
}
