{ pkgs, config, lib, inputs, ... }:

with lib;
with lib.my;
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
      homebrew = {
        enable = true;
        masApps = {
          # make sure to login to app store first!
          "reMarkable Desktop" = 1276493162;
          "NordVPN"            = 905953485;
        };
        casks = [
          "libreoffice"
          "libreoffice-language-pack"
        ];
      };
    };

    desktop = {
      dock = {
        enable = true;
        entries = [
          { path = "/System/Applications/Launchpad.app/"; }
          { path = "/System/Applications/Messages.app/"; }
          { path = "/System/Applications/FaceTime.app/"; }
          { path = "/System/Applications/Mail.app/"; }
          { path = "/System/Applications/Calendar.app/"; }
          { path = "/System/Applications/Reminders.app/"; }
          { path = "/System/Applications/Notes.app/"; }
          { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
          { path = "/Applications/reMarkable.app/"; }
          { path = "/Applications/LibreOffice.app/"; }
          { path = "/System/Applications/Music.app/"; }
          { path = "${pkgs.kitty}/Applications/kitty.app/"; }
          # TODO: Setup neovim
        ];

      };

      karabiner.enable = true;

      media = {
        mpv.enable = true;
        graphics = {
          enable = true;
          tools.enable = true;
          photoshop.enable = true;
          illustrator.enable = true;
          threed.enable = true;
        };
        comms = {
          enable = true;
          slack.enable = true;
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

    services = {
      ssh = {
        enable = true;
        publicKeyFiles = mapAttrsToList (name: _:  "${configDir}/ssh/${name}")
          (filterAttrs (name: value: (hasSuffix ".pub" name) && ( value == "regular"))
            (builtins.readDir "${configDir}/ssh"));
      };
      sudo = {
        enable = true;
        noPass = true;
      };
    };

    theme.active = "nord";

  };

  #gnupg
  home.configFile."gnupg/gpg.conf" = {source = "${configDir}/gnupg/gpg.conf";};

}
