# modules/themes/nord/default.nix --- a nord inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
    withXserver = config.services.xserver.enable;
    withWayland = programs.hyperland.enable || programs.sway.enale;
in {
  config = mkIf (cfg.active == "nord") (mkMerge [
    # Desktop-agnostic configuration
    {
      modules = {
        theme = {
          wallpaper = mkDefault .config/wallpapers;
          gtk = {
            theme = "Nordic";
            iconTheme = "Paper";
            cursorTheme = "Paper";
          };
          fonts = {
            sans.name = "Fira Sans";
            mono.name = "Fira Code";
          };
          colors = {
            black         = "#3b4252";
            red           = "#bf616a";
            green         = "#a3be8c";
            yellow        = "#ebcb8b";
            blue          = "#81a1c1";
            magenta       = "#b48ead";
            cyan          = "#88c0d0";
            white         = "#e5e9f0";
            silver        = "#e5e9f0";
            grey          = "#e5e9f0";

            brightblack   = "#4c566a";
            brightred     = "#bf616a";
            brightgreen   = "#a3be8c";
            brightyellow  = "#ebcb8b";
            brightblue    = "#81a1c1";
            brightmagenta = "#b48ead";
            brightcyan    = "#8fbcbb";
            brightwhite   = "#eceff4";

            dimblack      = "#373e4d";
            dimred        = "#94545d";
            dimgreen      = "#809575";
            dimyellow     = "#b29e75";
            dimblue       = "#68809a";
            dimmagenta    = "#8c738c";
            dimcyan       = "#6d96a5";
            dimwhite      = "#aeb3bb";

            types.bg        = "#2e3440";
            types.fg        = "#d8dee9";
            types.dim_fg    = cfg.colors.silver;
            types.panelbg   = cfg.colors.types.bg;
            types.panelfg   = cfg.colors.types.fg;
            types.border    = cfg.colors.types.bg;
            types.error     = cfg.colors.red;
            types.warning   = cfg.colors.yellow;
            types.highlight = cfg.colors.white;
          };
        };

        shell.zsh.rcFiles  = [ ./config/zsh/prompt.zsh ];
        shell.tmux.rcFiles = [ ./config/tmux.conf ];
        desktop.browsers = {
          firefox.chromePath = ./config/firefox;
        };
      };
    }

    # Desktop (X11) theming
    (mkIf (withXserver || withWayland) {
      user.packages = with pkgs; [
        nordic
        paper-icon-theme # for rofi
      ];
      fonts = {
        fonts = with pkgs; [
          fira-code
          fira-code-symbols
          open-sans
          jetbrains-mono
          siji
          font-awesome
        ];
      };

      # Compositor
      services.picom = mkIf withXserver {
        fade = true;
        fadeDelta = 1;
        fadeSteps = [ 0.01 0.012 ];
        shadow = true;
        shadowOffsets = [ (-10) (-10) ];
        shadowOpacity = 0.22;
        # activeOpacity = "1.00";
        # inactiveOpacity = "0.92";
        settings = {
          shadow-radius = 12;
          # blur-background = true;
          # blur-background-frame = true;
          # blur-background-fixed = true;
          blur-kern = "7x7box";
          blur-strength = 320;
        };
      };

      # Login screen theme
      services.xserver.displayManager.lightdm.greeters.mini.extraConfig = ''
        text-color = "${cfg.colors.magenta}"
        password-background-color = "${cfg.colors.black}"
        window-color = "${cfg.colors.types.border}"
        border-color = "${cfg.colors.types.border}"
      '';

      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        (mkif withXserver {
          # Sourced from sessionCommands in modules/themes/default.nix
          "xtheme/90-theme" = mkIf withXserver {
            source = ./config/Xresources;
          };
        })
        (mkIf desktop.apps.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })

        (mkIf (desktop.hyprland.enable){
          "waybar" = {source = ./config/waybar; recursive = true;};
          "dunst/dunstrc".text = import ./config/dunstrc cfg;
        })
        (mkIf desktop.media.graphics.vector.enable {
          "inkscape/templates/default.svg".source = ./config/inkscape/default-template.svg;
        })
        (mkIf desktop.browsers.qutebrowser.enable {
          "qutebrowser/extra/theme.py".source = ./config/qutebrowser/theme.py;
        })
      ];
    })
  ]);
}
