{ pkgs, config, lib, ... }:
{
  imports = [
    ../home.nix
    ./hardware-configuration.nix
  ];

  ## Modules
  modules = {
    desktop = {
      hypr.enable = true;
      apps = {
        rofi.enable = true;
      };
      browsers = {
        default = "brave";
        brave.enable = true;
        firefox.enable = true;
        qutebrowser.enable = true;
      };
      media = {
        documents.enable = true;
        graphics.enable = true;
        mpv.enable = true;
      };
      term = {
        default = "wezterm";
        wezterm.enable = true;
      };
      vm = {
        qemu.enable = true;
      };
    };
    dev = {
      rust.enable = true;
      python.enable = true;
    };
    editors = {
      default = "emacs";
      emacs.enable = true;
    };
    shell = {
      direnv.enable = true;
      git.enable    = true;
      gnupg.enable  = true;
      tmux.enable   = true;
      zsh.enable    = true;
    };
    services = {
      ssh.enable = true;
      docker.enable = true;
      # Needed occasionally to help the parental units with PC problems
      # teamviewer.enable = true;
    };
    theme.active = "";
  };


  ## Local config
  programs.ssh.startAgent = false;
  services.openssh.startWhenNeeded = false;

  networking.networkmanager.enable = true;
}
