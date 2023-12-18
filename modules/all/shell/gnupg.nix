{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.shell.gnupg;
  pinentry = linuxXorDarwin
    "${pkgs.pinentry-gtk2}/bin/pinentry"
    "${pkgs.pinentry_mac}/Contents/MacOS/pinentry-mac";
in {
  options.modules.shell.gnupg = with types; {
    enable   = mkBoolOpt false;
    cacheTTL = mkOpt int 7200;  # 2hr
    useTomb = mkBoolOpt true;
    secretKeysPath = mkOpt (nullOr str) null;
  };


  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !pkgs.stdenv.isDarwin || !cfg.useTomb;
        message = "GnuPG: Tomb can only be used on Linux systems";
      }
    ];

    env.GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
    environment.systemPackages = with pkgs;[
      gnupg
      pinentry-curses
    ];

    programs.gnupg.agent.enable = true;

    user.packages = mkIf cfg.useTomb [ pkgs.tomb  pkgs.steghide];

    home.configFile."gnupg/gpg-agent.conf" = {
      text = ''
        allow-loopback-pinentry
        allow-emacs-pinentry
        default-cache-ttl ${toString cfg.cacheTTL}
        pinentry-program ${pinentry}
      '';
    };

    system.userActivationScripts = {
      setupGnuPG =
        let
          secretPath =
            if cfg.secretKeysPath != null &&
               builtins.hasAttr cfg.secretKeysPath config.age.secrets then

              config.age.secrets."${cfg.secretKeysPath}".path

            else null;

          gpgScript =
              pkgs.writeShellApplication {
                name = "setupGnuPG";
                runtimeInputs = with pkgs; [
                  gnupg
                  findutils
                  coreutils
                ];
                text = lib.concatMapStrings (s: s + "\n")
                  [
                    ''
                    echo "[SetupGnuPG]"
                    echo "Re-Setting GnuPG: ${config.env.GNUPGHOME} folder security."
                    if [[ ! -d "${config.env.GNUPGHOME}" ]]; then
                      umask 077
                      mkdir -p "${config.env.GNUPGHOME}"
                    else
                        find "${config.env.GNUPGHOME}" -type d -exec chmod 700 {} \;
                        find "${config.env.GNUPGHOME}" -type f -exec chmod 600 {} \;
                    fi
                    echo "Done"
                  ''

                    (if (secretPath != null) then
                      ''
                        if [[ -r "${secretPath}"  ]]; then
                          echo "Trying to import GnuPG secret keys"
                          gpg --import ${secretPath}
                          echo  "Done"
                        fi
                      ''
                      else
                      ""
                    )
                  ];
              };
        in
        ''
          ${gpgScript}/bin/setupGnuPG
        '';
    };
  };
}
