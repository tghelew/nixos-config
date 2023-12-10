# modules/themes/nord/default.nix --- a nord inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
    themesDir = config.nixos-config.themesDir;
    withXserver = pkgs.stdenv.isLinux && config.services.xserver.enable;
    withWayland = pkgs.stdenv.isLinux && config.modules.desktop.hypr.enable;
in {
  config = mkIf (cfg.active == "nord") (mkMerge [
    # Desktop-agnostic configuration
    {
     modules = {
        theme = {
          wallpapers = mkDefault ./config/wallpaper;
          gtk = {
            theme = "Nordic";
            iconTheme = "Paper";
            cursorTheme = "Paper";
          };
          fonts = {
            sans.name = "Fira Sans";
            sans.size = 10;
            mono.name = "Fira Code";
            mono.size = 12;
            icons.name = "Fira Code Nerd Font";
            icons.size = 8;
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

        shell.zsh.rcFiles  = [ ./config/zsh/prompt.zsh ];
        shell.tmux.theme = ./config/tmux;
        desktop.browsers = mkIf (desktop.browser.default != null) {
          firefox.chromePath = ./config/firefox;
        };
      };
    }

    # Desktop (X11) theming
      # Compositor
      (linuxXorDarwin
        {
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
        }
        #Darwin
         {})

    (mkIf (withXserver || withWayland) {
      user.packages = with pkgs; [
        nordic
        paper-icon-theme # for rofi
      ];
      myfonts = {
        packages = with pkgs; [
          fira-code
          fira-code-symbols
          open-sans
          jetbrains-mono
          siji
          font-awesome
          material-design-icons
          weather-icons
        ];
      };

      # Other dotfiles
      home.configFile = with config.modules; mkMerge [
        (mkIf withXserver {
          # Sourced from sessionCommands in modules/themes/default.nix
          "xtheme/90-theme" = mkIf withXserver {
            source = ./config/Xresources;
          };
        })
        (mkIf desktop.apps.rofi.enable {
          "rofi/theme" = { source = ./config/rofi; recursive = true; };
        })

        (mkIf (desktop.hypr.enable) {
          "waybar/config".text = builtins.toJSON (import ./config/waybar/config theme);
          "waybar/style.css".text = import ./config/waybar/style.css theme;
          "dunst/dunstrc".text = import ./config/dunstrc theme;
          "hypr/rc.d/theme.conf".text = import ./config/hypr/theme.conf theme;
          "mpv/theme.conf".text = import ./config/mpv/theme.conf theme;
          "swaylock/config".text = with theme; ''
            # Swaylock - Effect
            screenshots
            grace=5
            fade-in=0.2
            effect-blur=7x5
            effect-vignette=0.5:0.5

            # Swaylock
            #indicator
            daemonize
            indicator-radius=100
            indicator-thickness=10
            font=${fonts.sans.name}
            font-size=${toString fonts.sans.size}
            color=${builtins.replaceStrings ["#"] [""] colors.types.bg}
            ring-color=${builtins.replaceStrings ["#"] [""] colors.grey}
            key-hl-color=${builtins.replaceStrings ["#"] [""] colors.green}
            text-color=${builtins.replaceStrings ["#"] [""] colors.dimwhite}
            inside-color=${builtins.replaceStrings ["#"] [""] colors.dimblue}
            inside-clear-color=${builtins.replaceStrings ["#"] [""] colors.dimwhite}
            inside-wrong-color=${builtins.replaceStrings ["#"] [""] colors.red}
            inside-ver-color=${builtins.replaceStrings ["#"] [""] colors.blue}
            separator-color=${builtins.replaceStrings ["#"] [""] colors.black}

          '';

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
