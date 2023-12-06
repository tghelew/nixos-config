{ pkgs, config, lib, inputs, ... }:

let
  configDir = config.nixos-config.configDir;
in
{

  imports = [
    ../home.nix
  ];

  modules = with config.modules; {

    darwin = {
      system.enable = true;
      #TODO: homebrew.enable = false;

    };

    desktop = {
      #TODO yabai.enable = false;


      media = {
        mpv.enable = true;
        graphics = {
          enable = true;
          tools.enable = true;
          photoshop.enable = true;
          illustrator.enable = true;
          threed.enable = true;
        };
      };

      term  = {
        default = "kitty";
        kitty.enable = true;
      };
    };

    dev = {
      enable = true;
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
      git.enable = true;
      gnupg = {
        enable = true;
        useTomb = false;
        secretKeysPath = "secret_ghelew_net";
      };
      tmux.enable = true;
      zsh.enable = true;
    };

    theme.active = "nord";

  };

  ## SSH config
  home.file.".ssh/config" = {source = "${configDir}/ssh/config";};
  #gnupg
  home.configFile."gnupg/gpg.conf" = {source = "${configDir}/gnupg/gpg.conf";};

}
