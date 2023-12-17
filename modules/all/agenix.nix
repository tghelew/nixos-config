# modules/agenix.nix -- encrypt secrets in nix store

{ options, config, inputs, lib, pkgs, ... }:

with builtins;
with lib;
with lib.my;
let inherit (inputs) agenix;
    os = linuxXorDarwin "linux" "darwin";
    secretsDir = "${toString ../../hosts/${os}}/${pkgs.system}/${config.networking.hostName}/secrets";
    secretsFile = "${secretsDir}/secrets.nix";
in {
  imports = [ (linuxXorDarwin agenix.nixosModules.age agenix.darwinModules.age) ];
  environment.systemPackages = [ agenix.packages.${pkgs.system}.default ];

  age = {
    secrets =
      if pathExists secretsFile
      then mapAttrs' (n: v: nameValuePair (removeSuffix ".age" n) {
        file = "${secretsDir}/${n}";
        owner = mkDefault config.user.name;
        mode = if (v ? mode) then v.mode else "600";
        symlink = if (v ? symlink) then v.symlink else true;
        path = if  (v ? path) then
                (replaceStrings ["~"] ["${config.user.home}"] (toString v.path))
               else "${config.age.secretsDir}/${n}";
      }) (import secretsFile)
      else {};
    identityPaths =
      options.age.identityPaths.default ++ (filter pathExists [
        "${config.user.home}/.ssh/private/id_ed25519"
        "${config.user.home}/.ssh/private/id_rsa"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key"
      ]);
  };
}
