{ config, options, lib, pkgs, ... }:
let
  cfg = config.modules.darwin.system;
in
with lib;
with lib.my;
{
  options = with types; {
    modules.darwin.system = {
      enable = mkBoolOpt false;
    };
  };

  config = mkIf cfg.enable {
    home.stateVersion = "23.11";
    system = {
      stateVersion = 4;
      defaults = {
        LaunchServices = {
          LSQuarantine = false;
        };

        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          ApplePressAndHoldEnabled = false;
          AppleEnableMouseSwipeNavigateWithScrolls = true;
          AppleEnableSwipeNavigateWithScrolls = true;

          # 120, 90, 60, 30, 12, 6, 2
          KeyRepeat = 2;

          # 120, 94, 68, 35, 25, 15
          InitialKeyRepeat = 15;

          "com.apple.mouse.tapBehavior" = 1;
          "com.apple.sound.beep.volume" = 0.0;
          "com.apple.sound.beep.feedback" = 0;
        };

        dock = {
          autohide = true;
          show-recents = false;
          launchanim = true;
          mouse-over-hilite-stack = true;
          orientation = "bottom";
          tilesize = 48;
        };

        finder = {
          _FXShowPosixPathInTitle = false;
        };

        trackpad = {
          Clicking = true;
          TrackpadThreeFingerDrag = true;
        };
      };

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
    security = {
      pam.enableSudoTouchIdAuth = true;
    };
  };
}
