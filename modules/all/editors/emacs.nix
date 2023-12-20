# Emacs is my main driver.

{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.emacs;
    configDir = config.nixos-config.configDir;
    defaultEditorScript = with pkgs; writeShellScriptBin "default-editor"
    ''
     ${emacs-unstable}/bin/emacsclient "$@" -a ""
    '';
    os = if pkgs.stdenv.isDarwin then "darwin" else "linux";
in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    defaultEditor = mkOpt types.str "${defaultEditorScript}/bin/default-editor";
    useForEmail = mkBoolOpt false;
    package = mkOpt types.package pkgs.emacs-unstable;
    tlux = rec {
      enable = mkBoolOpt false;
      repoUrl = mkOpt types.str "git@github.com:tghelew/emacs.d";
      configRepoUrl = mkOpt types.str "git@github.com:tghelew/${os}-emacs-private";
      repoPubKeyPath = mkOpt  types.str "${config.user.home}/.ssh/id_github.pub";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (import inputs.emacs-overlay) ];

    environment.systemPackages = with pkgs; [
      ## Emacs itself
      binutils       # native-comp needs 'as', provided by this
    ] ++
      # 28.2 + native-comp
      (linuxXorDarwin [
        ((emacsPackagesFor cfg.package).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))
      ] [cfg.package]) ++
      [
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
      PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];
      EMACSDIR = "$XDG_CONFIG_HOME/emacs/";
      TLUXDIR = "$XDG_CONFIG_HOME/tlux/";
      TLUXLOCALDIR = "$XDG_CONFIG_HOME/emacs/.local/";
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
                  if [[ ! -d "$XDG_CONFIG_HOME"/emacs && -f ${cfg.tlux.repoPubKeyPath} ]]; then
                    echo "Setting up Tlux Emacs."
                    git clone --depth=1 --single-branch "${cfg.tlux.repoUrl}" "$XDG_CONFIG_HOME/emacs"
                    git clone "${cfg.tlux.configRepoUrl}" "$XDG_CONFIG_HOME/tlux"
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
  };
}
