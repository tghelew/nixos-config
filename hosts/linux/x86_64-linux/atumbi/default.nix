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
    desktop = {
      hypr.enable = true;
      apps = {
        rofi.enable = true;
      };
      browsers = {
        default = "qutebrowser";
        brave.enable = false;
        firefox.enable = true;
        qutebrowser.enable = true;
      };
      media = {
        documents = {
          enable = true;
          pdf.enable = true;
        };
        graphics.enable = true;
        mpv.enable = true;
        recording.enable = true;
      };
      term = {
        default = "kitty";
        kitty.enable = true;
      };
      vm = {
        qemu.enable = true;
      };
      filemanager = {
        default = "yazi";
        yazi.enable = true;
      };
    };
    dev = {
      enable = true;
      rust.enable = false;
      python.enable = true;
    };
    editors = {
      emacs.enable = true;
      emacs.useForEmail = true;
      vim.enable = true;
      default = editors.emacs.defaultEditor;
    };
    hardware = {
      bluetooth = {
        enable = true;
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
      sudo = {
        enable = true;
        noPass = true;
      };
      docker.enable = true;
      openssh.enable = true;
    };
    theme = {
     wallpapers = true;
     active = "nord";
     lowResSize = 5;
     highResSize = 5;
    };
  };

  ## Local config
  hardware.graphics.enable = true;
  time.timeZone = "Europe/Zurich";

  #gnupg
  home.configFile."gnupg/gpg.conf" = {source = "${configDir}/gnupg/gpg.conf";};

  ## Personal backups
  #TODO: Backups to tomb

}
