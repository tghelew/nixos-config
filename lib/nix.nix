{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
let sys = pkgs.stdenv.currentSystem;
in
{
  mkNixOsHost = path: attrs @ { system ? sys, ... }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {inherit lib system inputs;};
      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = mkDefault (removeSuffix ".nix" (baseNameOf path));
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        ../hosts/linux  # /default.nix
        (import path )
      ];
    };

  mkDarwinHost = path: attrs @ {system ? sys, ...}:     #TODO
    abort "Darwin Missing";

  mapHosts = dir: attrs @ { system ? system, ... }:
    mapModules dir
      (if pkgs.stdenv.isLinux then
        (hostPath: mkNixOsHost hostPath attrs)
        else if pkgs.stdenv.isDarwin then
          (hostPath: mkDarwinHost hostPath attrs)
      else
          abort "Non- Linux host are not available yet!"
      );
}
