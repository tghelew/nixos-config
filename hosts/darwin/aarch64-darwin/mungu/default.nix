{ pkgs, config, lib, inputs, ... }:

let
  configDir = config.nixos-config.configDir;
in
{

  imports = [
#TODO: home.nix
  ];

  modules = with config.modules;{

  };

}
