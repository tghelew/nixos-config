# Emacs is my main driver.

{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.my;
let cfg = config.modules.editors.emacs;
    configDir = config.nixos-config.configDir;
in {
  options.modules.editors.emacs = {
    enable = mkBoolOpt false;
    tlux = rec {
      enable = mkBoolOpt false;
      repoUrl = mkOpt types.str "git@github.com:tghelew/emacs.d";
      configRepoUrl = mkOpt types.str "git@github.com:tghelew/linux-emacs-private";
      repoPubKeyPath = mkOpt  types.str "$HOME/.ssh/id_github.pub";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (import inputs.emacs-overlay) ];

    user.packages = with pkgs; [
      ## Emacs itself
      binutils       # native-comp needs 'as', provided by this
      # 28.2 + native-comp
      ((emacsPackagesFor emacs-unstable).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))

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
    ];

    env = {
      PATH = [ "$XDG_CONFIG_HOME/emacs/bin" ];
      EMACSDIR = "$XDG_CONFIG_HOME/emacs";
      TLUXDIR = "$XDG_CONFIG_HOME/tlux";
      TLUXLOCALDIR = "$EMACSDIR/.local";
    };

    modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];

    fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];

    #NOTE: This is not strictly repoducable as it follow the main branch wihtout hash!
    #WARNING: ssh must be installed and properly configure to fetch this private repository
    system.userActivationScripts = mkIf cfg.tlux.enable {
      installTlux =
        let tluxScript =
              pkgs.writeShellApplication {
                name = "installTluxEmacs";
                runtimeInputs = with pkgs; [
                  git
                  openssh
                ];
                text = ''
                  if [[ ! -d "$XDG_CONFIG_HOME"/emacs && -f ${cfg.tlux.repoPubKeyPath} ]]; then
                    git clone --depth=1 --single-branch "${cfg.tlux.repoUrl}" "$XDG_CONFIG_HOME/emacs"
                    git clone "${cfg.tlux.configRepoUrl}" "$XDG_CONFIG_HOME/tlux"
                    echo -n "Tlux Configuration files installed! Do not forget to run: temacs install"
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
