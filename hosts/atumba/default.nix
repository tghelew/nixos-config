{ pkgs, config, lib, inputs, ... }:
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
        default = "qutebrowser";
        brave.enable = false;
        firefox.enable = true;
        qutebrowser.enable = true;
      };
      media = {
        documents.enable = true;
        graphics.enable = true;
        mpv.enable = true;
        recording.enable = true;
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
      emacs.tlux.enable = true;
      vim.enable = true;
    };
    shell = {
      direnv.enable = true;
      git.enable    = true;
      gnupg.enable  = true;
      tmux.enable   = true;
      zsh.enable    = true;
    };
    services = {
      ssh.enable = false;
      docker.enable = true;
    };
    # TODO: theme.active = "nord";
  };

  ## Local config
  networking.networkmanager.enable = true;


  ## Personal backups
  #TODO: Backups

}
