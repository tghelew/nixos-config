{ pkgs, config, lib, inputs, ... }:

with lib;
with lib.my;

let
  configDir = config.nixos-config.configDir;
in
{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = with config.modules;{
    dev = {
      enable = true;
      python.enable = true;
    };
    editors = {
      emacs.enable = true;
      vim.enable = true;
      default = editors.emacs.defaultEditor;
    };
    hardware = {
      bluetooth = {
        enable = false;
      };
    };
    shell = {
      direnv.enable = true;
      git.enable    = true;
      gnupg = {
        enable = true;
        useTomb = true;
      };
      tmux.enable   = true;
      zsh.enable    = true;
    };
    services = {
      ssh = {
        enable = true;
        publicKeyFiles = mapAttrsToList (name: _:  "${configDir}/ssh/${name}")
          (filterAttrs (name: value: (hasSuffix ".pub" name) && ( value == "regular"))
            (builtins.readDir "${configDir}/ssh"));
      };
      doas = {
        enable = true;
        noPass = true;
      };
      docker.enable = false;
      openssh.enable = true;
    };
    theme = {
     wallpapers = false;
     active = "nord";
     lowResSize = 5;
     highResSize = 5;
    };
  };

  ## Local config
  hardware.graphics.enable = false;
  time.timeZone = "Europe/Zurich";

  #gnupg
  home.configFile."gnupg/gpg.conf" = {source = "${configDir}/gnupg/gpg.conf";};
}
