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
          "reMarkable Desktop"              = 1276493162;
          "NordVPN"                         = 905953485;
          "Yubico Authenticator"            = 1497506650;
        };
        casks = [
          "libreoffice"
          "libreoffice-language-pack"
          "microsoft-teams"
          "yubico-yubikey-manager"
          "vmware-fusion"
          "obsidian"
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
          { path = "/System/Applications/System Settings.app/"; }
          { path = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/"; }
          { path = "/Applications/reMarkable.app/"; }
          { path = "/Applications/LibreOffice.app/"; }
          { path = "/Applications/Obsidian.app/"; }
          { path = "/System/Applications/Music.app/"; }
          { path = "/Applications/kitty.app/"; }

          # TODO: Setup neovim
        ];

      };

      filemanager = {
        default = "yazi";
        yazi.enable = true;
      };

      karabiner.enable = false;
      aerospace.enable = true;

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
          slack.enable = false;
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

    theme = {
      active = "nord";
      highResSize = 12;
      lowResSize = 7;
    };
  };

  #gnupg
  home.configFile."gnupg/gpg.conf" = {source = "${configDir}/gnupg/gpg.conf";};

}
