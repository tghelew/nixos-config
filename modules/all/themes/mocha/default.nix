# modules/themes/nord/default.nix --- a nord inspired theme

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.theme;
    desktop = config.modules.desktop;
    themesDir = config.nixos-config.themesDir;
    desktopType = config.modules.desktop.type;
in {
  config = mkIf (cfg.active == "mocha") (mkMerge [
    # Desktop-agnostic configuration
    {
     modules = {
        theme = {
          wallpapers = lib.mkDefault true;
          gtk = {
            theme = "Catppuccin";
            iconTheme = "Papirus-Dark";
            cursorTheme = "catppucin-mocha-dark-cursors";
          };
          fonts = {
            sans.name = "FiraCode";
            sans.size = 7;
            mono.name = "JetBrains Mono Nerd Font";
            mono.size = 7;
            icons.name = "JetBrains Mono Nerd Font";
            icons.size = 7;
            highres.name = "JetBrains Mono Nerd Font";
            lowres.name = "JetBrains Mono Nerd Font";
            highres.size = 12;
            lowres.size = 10;
          };
          colors = {
            black         = "#1e1e2e";
            red           = "#cc6666";
            green         = "#b5bd68";
            yellow        = "#f0c674";
            blue          = "#81a2be";
            magenta       = "#c9b4cf";
            cyan          = "#8abeb7";
            silver        = "#e2e2dc";
            grey          = "#5B6268";
            white         = "#C18E76";


            brightred     = "#de935f";
            brightgreen   = "#0189cc";
            brightyellow  = "#f9a03f";
            brightblue    = "#8be9fd";
            brightmagenta = "#ff79c6";
            brightcyan    = "#0189cc";
            brightblack   = "#ccd0da";
            brightwhite   = "#dc8a78";

            dimblack         = "#181825";
            dimred           = "#f5c2e7";
            dimgreen         = "#a6e3a1";
            dimyellow        = "#f9e2af";
            dimblue          = "#89b4fa";
            dimmagenta       = "#cba6f7";
            dimcyan          = "#b4befe";
            dimgrey          = "#6c7086";
            dimwhite         = "#C18E76";

            types.bg        = "#2e3440";
            types.fg        = "#c5c8c6";
            types.dimfg    = cfg.colors.silver;
            types.panelfg = "#e2e2dc";
            types.panelbg = "#161719";
            types.border  = "#0d0d0d";
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
        nerd-fonts.jetbrains-mono
        siji
        font-awesome
        material-design-icons
        weather-icons
      ];
    })

    (mkIf (desktopType!= null) {
      user.packages = with pkgs; [
        catppuccin-gtk
        catppuccin-papirus-folders
        catppuccin-cursors.mochaDark
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
          "polybar" = { source = ./config/polybar; recursive = true;};
        })
        
        (mkIf (desktop.herbst.enable) {
          "dunst/dunstrc".text = import ./config/dunstrc theme;
          "mpv/theme.conf".text = import ./config/mpv/theme.conf theme;
          "polybar" = { source = ./config/polybar; recursive = true;};
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
