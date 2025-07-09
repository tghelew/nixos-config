# modules/themes/nord/default.nix --- a nord inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
    desktop = config.modules.desktop;
    themesDir = config.nixos-config.themesDir;
    desktopType = config.modules.desktop.type;
in {
  config = mkIf (cfg.active == "nord") (mkMerge [
    # Desktop-agnostic configuration
    {
     modules = {
        theme = {
          wallpapers = lib.mkDefault true;
          gtk = {
            theme = "Nordic";
            iconTheme = "Paper";
            cursorTheme = "Paper";
          };
          fonts = {
            sans.name = "Fira Sans";
            sans.size = 7;
            mono.name = "Fira Code";
            mono.size = 7;
            icons.name = "Fira Code Nerd Font";
            icons.size = 7;
            highres.name = "Fira Code Nerd Font";
            lowres.name = "Fira Code Nerd Font";
            highres.size = 12;
            lowres.size = 10;
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
            dimgrey       = "#6d84ab";

            types.bg        = "#2e3440";
            types.fg        = "#d8dee9";
            types.dimfg    = cfg.colors.silver;
            types.panelbg   = cfg.colors.types.bg;
            types.panelfg   = cfg.colors.types.fg;
            types.border    = cfg.colors.types.bg;
            types.error     = cfg.colors.red;
            types.warning   = cfg.colors.yellow;
            types.highlight = cfg.colors.white;
          };
        };

        # The file needs to start with an underscore to prevent it to load automatically
        desktop.term.theme = "${themesDir}/${cfg.active}/config/_${config.modules.desktop.term.default}.nix";
        desktop.filemanager.theme = "${themesDir}/${cfg.active}/config/_${config.modules.desktop.filemanager.default}.nix";

        shell.zsh.rcInit=''
          [[ $TERM == "linux" ]] && source ${./config/zsh/prompt.zsh}
          [[ $TERM != "linux" ]] && source ${./config/zsh/xprompt.zsh}
        '';
        # shell.zsh.rcFiles  = [ (if desktop.hypr.enable then ./config/zsh/xprompt.zsh else ./config/zsh/prompt.zsh) ];
        shell.tmux.theme = ./config/tmux;
        desktop.browsers = mkIf (config.modules.desktop.browsers.default != null) {
          firefox.chromePath = ./config/firefox;
        };
      };
    }

    # Desktop (X11) theming
      # Compositor
      (linuxXorDarwin
        {
          services.picom = mkIf (desktopType == "x11") {
            enable = true;
            fade = true;
            fadeDelta = 1;
            fadeSteps = [ 0.01 0.012 ];
            shadow = true;
            shadowOffsets = [ (-10) (-10) ];
            shadowOpacity = 0.22;
            activeOpacity = 0.90;
            inactiveOpacity = 0.70;
            settings = {
              shadow-radius = 12;
              # blur-background = true;
              # blur-background-frame = true;
              # blur-background-fixed = true;
              blur-kern = "7x7box";
              blur-strength = 320;
            };
          };
        }
        #Darwin
         {})

    (mkIf (desktopType != null) {
      myfonts.packages = with pkgs; [
        fira-code
        fira-code-symbols
        open-sans
        jetbrains-mono
        siji
        font-awesome
        material-design-icons
        weather-icons
      ];
    })

    (mkIf (desktopType!= null) {
      user.packages = with pkgs; [
        nordic
        paper-icon-theme # for rofi
      ];



      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        (mkIf (desktopType == "x11") {
          # Sourced from sessionCommands in modules/themes/default.nix
          "xtheme/90-theme" = {
            source = ./config/Xresources;
          };
        })
        (mkIf desktop.apps.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })

        (mkIf (desktop.i3.enable) {
          "dunst/dunstrc".text = import ./config/dunstrc theme;
          "mpv/theme.conf".text = import ./config/mpv/theme.conf theme;
        })

        (mkIf (desktop.hypr.enable) {
          "hypr/rc.d/theme.conf".text = import ./config/hypr/theme.conf theme;
          "mpv/theme.conf".text = import ./config/mpv/theme.conf theme;

        })

        (mkIf (desktop.niri.enable) {
          "waybar/config".text = builtins.toJSON (import ./config/waybar/config theme);
          "waybar/style.css".text = import ./config/waybar/style.css theme;
          "mako/theme".text = import ./config/mako/config theme;
          "swaylock/config".source = ./config/swaylock/config;
        })

        (mkIf (shell.nushell.enable) {
          "starship.toml".source = ./config/starship.toml;
        })
        (mkIf desktop.media.graphics.illustrator.enable {
          "inkscape/templates/default.svg".source = ./config/inkscape/default-template.svg;
        })
        (mkIf desktop.browsers.qutebrowser.enable {
          "qutebrowser/extra/theme.py".source = ./config/qutebrowser/theme.py;
        })
      ];
    })
  ]);
}
