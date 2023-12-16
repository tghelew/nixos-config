{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.ssh;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.ssh = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.openssh.authorizedKeys.keyFiles =
      if elem config.user.name [ "tghelew" "thierry" ]
      then [
        "${configDir}/ssh/id_rsa.pub"
        "${configDir}/ssh/id_admin.pub"
      ]
      else [];
  };
}
