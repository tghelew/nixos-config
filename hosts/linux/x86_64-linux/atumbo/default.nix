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
      niri = {
        enable = true;
        confInternal = true;
      };
      hypr.enable = false;
      hyprpanel.enable = false;
      i3.enable = false;
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
        };
      };
      term = {
        default = "kitty";
        ghostty.enable = false;
        kitty.enable = true;
      };
      vm = {
        virtualbox.enable = false;
      };
      filemanager = {
        default = "yazi";
        yazi.enable = true;
      };
    };
    dev = {
      enable = true;
      zig.enable = true;
      rust.enable = true;
      python.enable = true;
      lua.enable = true;
    };
    editors = {
      emacs.enable = true;
      emacs.useForEmail = false;
      emacs.systemd = true;
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
      nushell.enable = false;
    };
    services = {
      backup = {
        enable = true;
        frequency = null;
      };
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
      docker.enable = false;
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

}
