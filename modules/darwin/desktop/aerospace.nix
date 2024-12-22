{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.aerospace;
  homebrew = config.modules.darwin.homebrew;
  karabiner = config.modules.desktop.karabiner;
  configDir = config.nixos-config.configDir;
in
{
  options = {
    modules.desktop.aerospace.enable = mkOption {
      description = "Enable Aerospace Tiling window manager";
      default = false;
      example = false;
    };
  };

  config = mkIf cfg.enable {
    assertions = [ {
      assertion =  karabiner.enable == false;
      message = "I don't think it's a good idea to mix both Karabiner and Aerospace";
    } ];
    services = {
      aerospace= {
        enable = true;
        package = pkgs.unstable.aerospace;
        settings = {
          after-login-command = [];

          # You can use it to add commands that run after AeroSpace startup.
          # 'after-startup-command' is run after 'after-login-command'
          # Available commands : https://nikitabobko.github.io/AeroSpace/commands
          after-startup-command = [];

          # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;

          # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
          # The 'accordion-padding' specifies the size of accordion padding
          # You can set 0 to disable the padding feature
          accordion-padding = 30;

          # Possible values: tiles|accordion
          default-root-container-layout = "tiles";

          # Possible values: horizontal|vertical|auto
          # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
          #               tall monitor (anything higher than wide) gets vertical orientation
          default-root-container-orientation = "vertical";

          # Mouse follows focus when focused monitor changes
          # Drop it from your config, if you don't like this behavior
          # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
          # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
          # Fallback value (if you omit the key): on-focused-monitor-changed = []
          on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

          # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
          # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
          # Also see: https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
          automatically-unhide-macos-hidden-apps = true;

          # Possible values: (qwerty|dvorak)
          # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
          key-mapping = {
            preset = "qwerty";
          };
          gaps = {
            inner.horizontal = 16;
            inner.vertical =   16;
            outer.left =       8;
            outer.bottom =     8;
            outer.top =        8;
            outer.right =      8;
          };
          mode.main.binding = {
            # All possible keys:
            # - Letters.        a, b, c, ..., z
            # - Numbers.        0, 1, 2, ..., 9
            # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
            # - F-keys.         f1, f2, ..., f20
            # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
            #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
            # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
            #                   keypadMinus, keypadMultiply, keypadPlus
            # - Arrows.         left, down, up, right

            # All possible modifiers: cmd, alt, ctrl, shift

            # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

            # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
            # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
            cmd-enter = ''exec-and-forget osascript -e '
                            tell application "Kitty"
                                do script
                                activate
                            end tell'
            '';
            # Meh Key= cmd-ctrl-alt-shift --> Moving to workspace, binding mode
            # Meuh= ctrl-alt-shift --> Default for command in workspace
            #
            # See: https://nikitabobko.github.io/AeroSpace/commands#layout
            cmd-ctrl-alt-shift-slash = "layout tiles horizontal vertical";
            cmd-ctrl-alt-shift-comma = "layout accordion horizontal vertical";

            # See: https://nikitabobko.github.io/AeroSpace/commands#focus
            ctrl-alt-shift-h = "move left";
            ctrl-alt-shift-j = "move down";
            ctrl-alt-shift-k = "move up";
            ctrl-alt-shift-l = "move right";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move
            cmd-h = "focus left";
            cmd-j = "focus down";
            cmd-k = "focus up";
            cmd-l = "focus right";


            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
            ctrl-alt-shift-1 = "workspace 1";
            ctrl-alt-shift-2 = "workspace 2";
            ctrl-alt-shift-3 = "workspace 3";
            ctrl-alt-shift-4 = "workspace 4";
            ctrl-alt-shift-5 = "workspace 5";
            ctrl-alt-shift-6 = "workspace 6";
            ctrl-alt-shift-7 = "workspace 7";
            ctrl-alt-shift-8 = "workspace 8";
            ctrl-alt-shift-9 = "workspace 9";
            ctrl-alt-shift-c = "workspace C";
            ctrl-alt-shift-w = "workspace W";
            ctrl-alt-shift-t = "workspace T";

            # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
            cmd-ctrl-alt-shift-1 = "move-node-to-workspace 1";
            cmd-ctrl-alt-shift-2 = "move-node-to-workspace 2";
            cmd-ctrl-alt-shift-3 = "move-node-to-workspace 3";
            cmd-ctrl-alt-shift-4 = "move-node-to-workspace 4";
            cmd-ctrl-alt-shift-5 = "move-node-to-workspace 5";
            cmd-ctrl-alt-shift-6 = "move-node-to-workspace 6";
            cmd-ctrl-alt-shift-7 = "move-node-to-workspace 7";
            cmd-ctrl-alt-shift-8 = "move-node-to-workspace 8";
            cmd-ctrl-alt-shift-9 = "move-node-to-workspace 9";
            cmd-ctrl-alt-shift-c = "move-node-to-workspace C";
            cmd-ctrl-alt-shift-w = "move-node-to-workspace W";
            cmd-ctrl-alt-shift-t = "move-node-to-workspace T";

            # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
            cmd-ctrl-alt-shift-tab = "workspace-back-and-forth";
            # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
            #alt-shift-tab = "move-workspace-to-monitor --wrap-around next"


            # See: https://nikitabobko.github.io/AeroSpace/commands#resize
            cmd-ctrl-alt-shift-r = "mode resize";

            # See: https://nikitabobko.github.io/AeroSpace/commands#mode
            cmd-ctrl-alt-shift-semicolon = "mode service";

          };
          mode.service.binding = {

            esc = ["reload-config" "mode main"];
            r = ["flatten-workspace-tree" "mode main"]; # reset layout
            f = ["layout floating tiling" "mode main"]; # Toggle between floating and tiling layout
            backspace = ["close-all-windows-but-current" "mode main"];

            # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
            #s = ["layout sticky tiling", "mode main"]

            cmd-ctrl-alt-shift-h = ["join-with left" "mode main"];
            cmd-ctrl-alt-shift-j = ["join-with down" "mode main"];
            cmd-ctrl-alt-shift-k = ["join-with up" "mode main"];
            cmd-ctrl-alt-shift-l = ["join-with right" "mode main"];

            down = "volume down";
            up = "volume up";
            shift-down = ["volume set 0" "mode main"];

          };
          mode.resize.binding = {
            ctrl-alt-shift-h = "resize smart -50";
            ctrl-alt-shift-l = "resize smart +50";
            ctrl-alt-shift-q = "mode main";
          };

        };

      };
    };
  };

}
