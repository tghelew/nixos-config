{ options, config, lib, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.ssh;
  configDir = config.nixos-config.configDir;
in {
  options.modules.services.ssh = with types; {
    enable = mkBoolOpt false;
    publicKeyFiles = mkOpt (listOf str) [];
  };

  config = mkIf cfg.enable {
    user.openssh.authorizedKeys.keyFiles =
      if elem config.user.name [ "tghelew" "thierry" ]
      then [
        "${configDir}/ssh/id_rsa.pub"
        "${configDir}/ssh/id_admin.pub"
      ]
      else [];

      home.file =
        {".ssh/config".source = "${configDir}/ssh/config";}
        //
        (genAttrs' cfg.publicKeyFiles
          (p:
            {
              name = ".ssh/${builtins.baseNameOf p}";
              value = {source = p;};
            }));
  };
}
