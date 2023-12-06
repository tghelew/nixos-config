{ inputs, lib, pkgs, ... }:

with lib;
with lib.my;
let sys = pkgs.stdenv.hostPlatform.system;
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

  mkDarwinHost = path: attrs @ {system ? sys, ...}:
    lib.darwin.darwinSystem {
      inherit system;
      specialArgs = {inherit lib system inputs;};
      modules = [
        ../hosts/darwin # default.nix
        (import path)
      ];

    };


  # linuxXorDarwin :: exLinux -> exDarwin  -> ex
  linuxXorDarwin = linux: darwin:
    if pkgs.stdenv.isLinux then linux
    else if  pkgs.stdenv.isDarwin then darwin
      else abort "Unsupported host: " + sys;


  mapHosts = dir: attrs @ { system ? system, ... }:
    mapModules dir
      (linuxXorDarwin
        (hostPath: mkNixOsHost hostPath attrs)
        (hostPath: mkDarwinHost hostPath attrs));
}
