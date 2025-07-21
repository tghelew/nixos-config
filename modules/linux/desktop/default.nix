{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.desktop;
    binDir = config.nixos-config.binDir;
in {
  options.modules.desktop = {
    type = with types; mkOpt (nullOr str) null;
  };

  config = mkIf (cfg.type != null)  {
    assertions =
      let isEnabled = _: v: v.enable or false;
           hasDesktopEnabled = cfg:
             (anyAttrs isEnabled cfg)
             || !(anyAttrs (_: v: isAttrs v && anyAttrs isEnabled v) cfg);
        in [
          {
            assertion = (countAttrs isEnabled cfg) < 3;
            message = "Can't have more than one desktop environment enabled at a time";
          }
          {
            assertion = hasDesktopEnabled cfg;
            message = "Can't enable a desktop sub-module without a desktop environment";
          }
          {
            assertion = cfg.type != null || !(anyAttrs isEnabled cfg);
            message = "Downstream desktop module did not set modules.desktop.type";
          }
        ];

    user.packages = with pkgs; [
      libqalculate  # calculator cli w/ currency conversion
      qgnomeplatform        # QPlatformTheme for a better Qt application inclusion in GNOME
      libsForQt5.qtstyleplugin-kvantum # SVG-based Qt5 theme engine plus a config tool and extra theme
      xdg-utils
      brightnessctl
      usbutils
      mesa-demos
      system-config-printer
      simple-scan
    ] ++ optionals (cfg.type == "x11") [
      feh       # image viewer
      xclip
      xdotool
      xorg.xwininfo
      xorg.xmodmap
    ]
    ++ optionals (cfg.type == "wayland") [
        wl-clipboard
        wlr-randr
        handlr
        wev
        swappy
        btop
        libsForQt5.polkit-kde-agent
    ];

    fonts = {
      fontDir.enable = true;
      enableGhostscriptFonts = true;
      packages = with pkgs; [
        ubuntu_font_family
        dejavu_fonts
        #symbola
        meslo-lgs-nf
        mononoki
        font-awesome
        fira-mono
        fira-code
      ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts) ;
    };


    ## Apps/Services
    services.picom = mkIf (cfg.type == "x11") {
      enable = true;
      backend = "glx";
      vSync = true;
      opacityRules = [
        # "100:class_g = 'Firefox'"
        # "100:class_g = 'Vivaldi-stable'"
        "100:class_g = 'VirtualBox Machine'"
        # Art/image programs where we need fidelity
        "100:class_g = 'Gimp'"
        "100:class_g = 'Inkscape'"
        "100:class_g = 'aseprite'"
        "100:class_g = 'krita'"
        "100:class_g = 'feh'"
        "100:class_g = 'mpv'"
        "100:class_g = 'Rofi'"
        "100:class_g = 'Peek'"
        "99:_NET_WM_STATE@:32a = '_NET_WM_STATE_FULLSCREEN'"
      ];
      shadowExclude = [
        # Put shadows on notifications, the scratch popup and rofi only
        "! name~='(rofi|scratch|Dunst)$'"
      ];
      settings = {
        blur-background-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'Rofi'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        # Unredirect all windows if a full-screen opaque window is detected, to
        # maximize performance for full-screen windows. Known to cause
        # flickering when redirecting/unredirecting windows.
        unredir-if-possible = true;

        # GLX backend: Avoid using stencil buffer, useful if you don't have a
        # stencil buffer. Might cause incorrect opacity when rendering
        # transparent content (but never practically happened) and may not work
        # with blur-background. My tests show a 15% performance boost.
        # Recommended.
        glx-no-stencil = true;

        # Use X Sync fence to sync clients' draw calls, to make sure all draw
        # calls are finished before picom starts drawing. Needed on
        # nvidia-drivers with GLX backend for some users.
        xrender-sync-fence = true;
      };
    };

    ## Printer/Scanner
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    hardware.sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan pkgs.epsonscan2];

    };
    services.udev.packages = [ pkgs.sane-airscan pkgs.epsonscan2 ];

    # Try really hard to get QT to respect my GTK theme.
    env.GTK_DATA_PREFIX = [ "${config.system.path}" ];
    env.QT_QPA_PLATFORMTHEME = "gnome";

    services.xserver.displayManager.sessionCommands = mkIf (cfg.type == "x11") ''
      # GTK2_RC_FILES must be available to the display manager.
      export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
    '';

    # Clean up leftovers, as much as we can
    system.userActivationScripts.cleanupHome = ''
      pushd "${config.user.home}"
      rm -rf .compose-cache .nv .pki .dbus .fehbg
      [ -s .xsession-errors ] || rm -f .xsession-errors*
      popd
    '';

  };
}
