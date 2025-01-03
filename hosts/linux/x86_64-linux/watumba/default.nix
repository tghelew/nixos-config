{ pkgs, config, lib, inputs, ... }:

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
        documents.enable = false;
        graphics.enable = true;
        mpv.enable = true;
        recording.enable = false;
      };
      term = {
        default = "kitty";
        kitty.enable = true;
      };
      vm = {
        qemu.enable = false;
      };
    };
    dev = {
      enable = true;
      rust.enable = true;
      python.enable = true;
    };
    editors = {
      emacs.enable = true;
      emacs.useForEmail = false;
      emacs.tlux.enable = true;
      vim.enable = true;
      default = editors.emacs.defaultEditor;
    };
    shell = {
      direnv.enable = true;
      git.enable    = true;
      gnupg = {
        enable = true;
        useTomb = true;
      };
      #NOTE: Do I need tmux locally ?
      tmux.enable   = true;
      zsh.enable    = true;
    };
    services = {
      ssh.enable = true;
      docker.enable = false;
    };
    theme.active = "nord";
  };

  ## Local config
  hardware.graphics.enable = true;
  time.timeZone = "Europe/Zurich";

  ## SSH config
  home.file.".ssh/config" = {source = "${configDir}/ssh/config";};
  #gnupg
  home.configFile."gnupg/gpg.conf" = {source = "${configDir}/gnupg/gpg.conf";};

  ## Personal backups
  #TODO: Backups to tomb

}
