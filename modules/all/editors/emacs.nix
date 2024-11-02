# Emacs is my main driver.

{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.emacs;
    configDir = config.nixos-config.configDir;
    defaultEditorScript = with pkgs; writeShellApplication {
      name = "memacs";
      runtimeInputs = [];
      meta = with lib; {
        description = "A wrapper around emacsclient";
        longDescription = ''
              A wrapper around emacsclient to graphical emacs
              client. If an emacs server is not already launch a new server will be created.
        '';
        license = licenses.mit;
        platforms = platforms.all;
      };
      text = ''nohup ${cfg.package}/bin/emacsclient -cna ' ' "$@" &> /dev/null'';
    };
    os = if pkgs.stdenv.isDarwin then "darwin" else "linux";
    emacspkgs = pkgs.emacs;

in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    defaultEditor = mkOpt types.str "${cfg.package}/bin/emacsclient -tna '' ";
    package = mkOpt types.package pkgs.emacs-unstable;
    useForEmail = mkBoolOpt false;
    autostart = mkBoolOpt pkgs.stdenv.isDarwin;
    tlux = rec {
      enable = mkBoolOpt false;
      repoUrl = mkOpt types.str "git@github.com:tghelew/emacs.d";
      configRepoUrl = mkOpt types.str "git@github.com:tghelew/${os}-emacs-private";
      repoPubKeyPath = mkOpt  types.str "${config.user.home}/.ssh/id_github.pub";
    };
  };

  config = mkIf cfg.enable (mkMerge [{

    assertions = [ {
      assertion = ! cfg.autostart || pkgs.stdenv.isDarwin;
      message = "Option ${cfg}.autostart is not yet supported on ${pkgs.stdenv.hostPlatform.system}";
    } ];

    nixpkgs.overlays = [ (import inputs.emacs-overlay) ];


   environment.systemPackages = with pkgs; [

      binutils       # native-comp needs 'as', provided by this
    ## Emacs itself
    ((emacsPackagesFor cfg.package).emacsWithPackages
      (epkgs: [ epkgs.vterm ]))
    ] ++
      (linuxXorDarwin
        [
          #Linux
        ]
        [
          #Darwin
          coreutils-prefixed
        ]) ++
      [
        # MyEmacs
        defaultEditorScript
        ## Doom dependencies
        git
        (ripgrep.override {withPCRE2 = true;})
        gnutls              # for TLS connectivity

        ## Optional dependencies
        fd                  # faster projectile indexing
        imagemagick         # for image-dired
        (mkIf (config.programs.gnupg.agent.enable)
          pinentry-emacs)   # in-emacs gnupg prompts
        zstd                # for undo-fu-session/undo-tree compression

        ## Module dependencies
        # :checkers spell
        (aspellWithDicts (ds: with ds; [ en en-computers en-science fr ]))
        # :tools editorconfig
        editorconfig-core-c # per-project style config
        # :tools lookup & :lang org +roam
        sqlite
        # :lang latex & :lang org (latex previews)
        texlive.combined.scheme-medium
        # export to html
        pandoc
        # dired video thumbmailer
        ffmpegthumbnailer
        # Video/Audio metadata info
        mediainfo
        # tar & unzip
        gnutar
        unzip ] ++
      # Used for email
      optionals cfg.useForEmail
      [mu isync ];

    env = {
      PATH = [ "${config.modules.xdg.configHome}/emacs/bin" ];
      EMACSDIR = "${config.modules.xdg.configHome}/emacs/";
      TLUXDIR = "${config.modules.xdg.configHome}/tlux/";
      TLUXLOCALDIR = "${config.modules.xdg.configHome}/emacs/.local/";
    };

    modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];

    myfonts.packages = with pkgs;
      [
        nerdfonts
      ];

    #NOTE: This is not strictly repoducable as it follow the main branch wihtout hash!
    #WARNING: ssh must be installed and properly configure to fetch this private repository
    system.userActivationScripts = mkIf (cfg.tlux.enable && pathExists cfg.tlux.repoPubKeyPath) {
      symlinkEmacs =
      ''
        echo "[SymLinkEmacs]"
        if [[ ! -h "$HOME/.emacs.d" ]]; then
            echo "Setting emacs default folder."
            ln -s "${config.env.EMACSDIR}" "$HOME/.emacs.d"
            echo "Done."
        fi
      '';
      installTlux =
        let tluxScript =
              pkgs.writeShellApplication {
                name = "installTluxEmacs";
                runtimeInputs = with pkgs; [
                  git
                  openssh
                ];
                text = ''
                echo "[InstallTlux]"
                  if [[ ! -d "${config.env.EMACSDIR}" && -f ${cfg.tlux.repoPubKeyPath} ]]; then
                    echo "Setting up Tlux Emacs."
                    git clone --depth=1 --single-branch "${cfg.tlux.repoUrl}" "${config.env.EMACSDIR}"
                    git clone "${cfg.tlux.configRepoUrl}" "${config.env.TLUXDIR}"
                    echo "Tlux Configuration files installed! Do not forget to run: temacs install"
                  fi
                '';
              };
        in
        ''
          ${tluxScript}/bin/installTluxEmacs
        '';
    };

    nix.settings = {
      substituters = ["https://nix-community.cachix.org"];	# Install cached version so rebuild should not be required
      trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };
  }

   (mkIf cfg.autostart {
     home.services.emacs= let
       launchScript = pkgs.writeShellApplication {
         name = "launchEmacs";
         text = ''
          _notify() {
            local message="$1"
            if hash osascript 2>/dev/null; then
              osascript -e "display notification \"$message\" with title \"Emacs Daemon Launch\""
            elif hash notify-send 2>dev/null; then
              notify-send "Emacs Daemon Launch" "$message"
            else
              echo "No notification program can be found" 1>&2
            fi
          }

          _notify "Attempting to start Emacs..."
          if ${cfg.package}/bin/emacs --fg-daemon; then
            _notify "Emacs has started."
          else
            _notify "Failed to start Emacs."
          fi
         '';

       };
     in {
       enable = true;
       config = {
         enable = true;
         EnvironmentVariables = {
           PATH = config.env.PATH;
           EMACSDIR = config.env.EMACSDIR;
           TLUXDIR = config.env.TLUXDIR;
           TLUXLOCALDIR = config.env.TLUXLOCALDIR;
         };
         KeepAlive = true;
         ProgramArguments = ["${launchScript}/bin/launchEmacs"];
       };
     };
   })
 ]);
}
