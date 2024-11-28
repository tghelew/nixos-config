
{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.yubikey;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.yubikey = {
    enable = mkBoolOpt false;
    yubiid = with types; mkOpt int 0;
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      pam_u2f
      yubikey-personalization
      yubikey-manager
      pamtester
   ];

    services.udev.packages = [ pkgs.yubikey-personalization ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    security.pam.yubico = {
      enable = true;
      debug = true;
      mode = "challenge-response";
      id = [ "${yubiid}" ];
    };
  };
}
