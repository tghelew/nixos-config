# Disabling theme module should never leave a system non-functional.

{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.theme;
  desktopType = config.modules.desktop.type;
  themesDir = config.nixos-config.themesDir;
in
{
  options.modules.theme = with types; {
    active = mkOption {
      type = nullOr str;
      default = null;
      apply = v: let theme = builtins.getEnv "THEME"; in
                 if theme != "" then theme else v;
      description = ''
        Name of the theme to enable. Can be overridden by the THEME environment
        variable. Themes can also be hot-swapped with 'hey theme $THEME'.
      '';
    };
    highResSize = mkOption {
      type = nullOr int;
      default = null;
    };
    lowResSize = mkOption {
      type = nullOr int;
      default = null;
    };

    wallpapers = mkBoolOpt false;
    loginWallpaper = mkBoolOpt false;

    gtk = {
      theme = mkOpt str "";
      iconTheme = mkOpt str "";
      cursorTheme = mkOpt str "";
    };

    onReload = mkOpt (attrsOf lines) {};

    fonts = {
      mono = {
        name = mkOpt str "Monospace";
        size = mkOpt int 7;
      };
      sans = {
        name = mkOpt str "Sans";
        size = mkOpt int 7;
      };

      icons = {
        name = mkOpt str "Icons";
        size = mkOpt int 7;

      };

      highres = {
        name = mkOpt str "Icons";
        size = mkOption {
          type = int;
          default = 12;
          apply = v: if (cfg.highResSize != null) then cfg.highResSize else v;
        };

      };

      lowres = {
        name = mkOpt str "Icons";
        size = mkOption {
          type = int;
          default = 12;
          apply = v: if (cfg.lowResSize != null) then cfg.lowResSize else v;
        };

      };
    };

    colors = {
      black         = mkOpt str "#000000"; # 0
      red           = mkOpt str "#FF0000"; # 1
      green         = mkOpt str "#00FF00"; # 2
      yellow        = mkOpt str "#FFFF00"; # 3
      blue          = mkOpt str "#0000FF"; # 4
      magenta       = mkOpt str "#FF00FF"; # 5
      cyan          = mkOpt str "#00FFFF"; # 6
      silver        = mkOpt str "#BBBBBB"; # 7
      grey          = mkOpt str "#888888"; # 8
      brightblack   = mkOpt str "#000000"; # 9
      brightred     = mkOpt str "#FF8800"; # 9
      brightgreen   = mkOpt str "#00FF80"; # 10
      brightyellow  = mkOpt str "#FF8800"; # 11
      brightblue    = mkOpt str "#0088FF"; # 12
      brightmagenta = mkOpt str "#FF88FF"; # 13
      brightcyan    = mkOpt str "#88FFFF"; # 14

      brightwhite   = mkOpt str "#FFFFFF"; # 15
      white         = mkOpt str "#FFFFFF"; # 16
      #-----------------------------------------
      dimblack      = mkOpt str "#000000"; # 17
      dimred        = mkOpt str "#FF0000"; # 18
      dimgreen      = mkOpt str "#00FF00"; # 19
      dimyellow     = mkOpt str "#FFFF00"; # 20
      dimblue       = mkOpt str "#0000FF"; # 21
      dimmagenta    = mkOpt str "#FF00FF"; # 23
      dimcyan       = mkOpt str "#00FFFF"; # 24
      dimwhite      = mkOpt str "#FFFFFF"; # 25
      dimgrey       = mkOpt str "#888888"; # 26

      # Color classes
      types = {
        bg        = mkOpt str cfg.colors.black;
        fg        = mkOpt str cfg.colors.white;
        dimfg     = mkOpt str cfg.colors.silver;
        panelbg   = mkOpt str cfg.colors.types.bg;
        panelfg   = mkOpt str cfg.colors.types.fg;
        border    = mkOpt str cfg.colors.types.bg;
        error     = mkOpt str cfg.colors.red;
        warning   = mkOpt str cfg.colors.yellow;
        highlight = mkOpt str cfg.colors.white;
      };
    };
  };

  config = mkIf (cfg.active != null) (mkMerge [
    # Read xresources files in ~/.config/xtheme/* to allow modular configuration
    # of Xresources.
    (mkIf (desktopType == "x11") (
      let xrdb = ''cat "$XDG_CONFIG_HOME"/xtheme/* | ${pkgs.xorg.xrdb}/bin/xrdb -load'';
      in {
        home.configFile."xtheme.init" = {
          text = xrdb;
          executable = true;
        };
        modules.theme.onReload.xtheme = xrdb;
      }))


    ( mkIf (desktopType == "x11") {
      home.configFile."xtheme/00-init".text = with cfg.colors; ''
      #define bg   ${types.bg}
      #define fg   ${types.fg}
      #define blk  ${black}
      #define red  ${red}
      #define grn  ${green}
      #define ylw  ${yellow}
      #define blu  ${blue}
      #define mag  ${magenta}
      #define cyn  ${cyan}
      #define wht  ${white}
      #define bblk ${grey}
      #define bred ${brightred}
      #define bgrn ${brightgreen}
      #define bylw ${brightyellow}
      #define bblu ${brightblue}
      #define bmag ${brightmagenta}
      #define bcyn ${brightcyan}
      #define bwht ${silver}
        '';
      home.configFile."xtheme/05-colors".text = ''
          *.foreground: fg
          *.background: bg
          *.color0:  blk
          *.color1:  red
          *.color2:  grn
          *.color3:  ylw
          *.color4:  blu
          *.color5:  mag
          *.color6:  cyn
          *.color7:  wht
          *.color8:  bblk
          *.color9:  bred
          *.color10: bgrn
          *.color11: bylw
          *.color12: bblu
          *.color13: bmag
          *.color14: bcyn
          *.color15: bwht
        '';
      home.configFile."xtheme/05-fonts".text = with cfg.fonts.mono;
        ''
          *.font: xft:${name}:pixelsize=${toString(size)}
          Emacs.font: ${name}:pixelsize=${toString(size)}
        '';})

    ( linuxXorDarwin
      # Linux
      {
      # GTK
      home.configFile = {
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          ${optionalString (cfg.gtk.theme != "")
            ''gtk-theme-name=${cfg.gtk.theme}''}
          ${optionalString (cfg.gtk.iconTheme != "")
            ''gtk-icon-theme-name=${cfg.gtk.iconTheme}''}
          ${optionalString (cfg.gtk.cursorTheme != "")
            ''gtk-cursor-theme-name=${cfg.gtk.cursorTheme}''}
          gtk-fallback-icon-theme=gnome
          gtk-application-prefer-dark-theme=true
          gtk-xft-hinting=1
          gtk-xft-hintstyle=hintfull
          gtk-xft-rgba=none
        '';
        # GTK2 global theme (widget and icon theme)
        "gtk-2.0/gtkrc".text = ''
          ${optionalString (cfg.gtk.theme != "")
            ''gtk-theme-name="${cfg.gtk.theme}"''}
          ${optionalString (cfg.gtk.iconTheme != "")
            ''gtk-icon-theme-name="${cfg.gtk.iconTheme}"''}
          gtk-font-name="Sans ${toString(cfg.fonts.sans.size)}"
        '';
        # QT4/5 global theme
        "Trolltech.conf".text = ''
          [Qt]
          ${optionalString (cfg.gtk.theme != "")
            ''style=${cfg.gtk.theme}''}
        '';
      };

      fonts.fontconfig.defaultFonts = {
        sansSerif = [ cfg.fonts.sans.name ];
        monospace = [ cfg.fonts.mono.name ];
      };
    }
    #Darwin
    {})

    (mkIf (cfg.wallpapers)
      # Set the wallpapers ourselves so we don't need .background-image and/or
      # .fehbg polluting $HOME
      # NOTE: This is not activiated with wayland
      (let wCfg = config.services.xserver.desktopManager.wallpaper;
           commandX = ''
             if [ -d "$XDG_DATA_HOME/wallpapers" ]; then
               ${pkgs.feh}/bin/feh --bg-${wCfg.mode} --recursive --randomize \
                 --no-fehbg \
                 $XDG_DATA_HOME/wallpapers
             fi
          '';
           commandW = ''
             if [ -d "$XDG_DATA_HOME/wallpapers" ]; then
               [ -f "$XDG_DATA_HOME/wallpapers/current" ] && \
                  ${pkgs.coreutils-full}/bin/rm -f "$XDG_DATA_HOME/wallpapers/current"
               img=$(${pkgs.findutils}/bin/find $XDG_DATA_HOME/wallpapers -type f -o -type l \
               | ${pkgs.coreutils-full}/bin/sort -R \
               | ${pkgs.coreutils-full}/bin/tail -1)
               ${pkgs.coreutils-full}/bin/ln -sf $img $XDG_DATA_HOME/wallpapers/current
             fi
           '';
       in {
         modules.theme.onReload.wallpaper = if (desktopType == "x11")  then commandX else commandW;
       }))

    # (mkIf (cfg.loginWallpaper != null) {
    #   services.xserver.displayManager.lightdm.background = cfg.loginWallpaper;
    # })

    (mkIf (cfg.wallpapers && cfg.active != null) {
      home.dataFile = {
        "wallpapers" = {source ="${themesDir}/${cfg.active}/config/wallpaper" ; recursive = true;};
      };})

    (mkIf (cfg.onReload != {})
      (let reloadTheme =
             with pkgs; (writeScriptBin "reloadTheme" ''
               #!${stdenv.shell}
               echo "Reloading current theme: ${cfg.active}"
               ${concatStringsSep "\n"
                 (mapAttrsToList (name: script: ''
                   echo "[${name}]"
                   ${script}
                 '') cfg.onReload)}
             '');
       in {
         user.packages = [ reloadTheme ];
         system.userActivationScripts.reloadTheme = ''
           [ -z "$NORELOAD" ] && ${reloadTheme}/bin/reloadTheme
         '';
       }))
  ]);
}
