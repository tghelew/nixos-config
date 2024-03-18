{ config, lib, pkgs, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.karabiner;
  xdgConfigHome = config.modules.xdg.configHome;
in
{
  #WARNING : Make sure to enale SPI:
  #https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection

  options = {
    modules.desktop.karabiner = {
      enable = mkBoolOpt false;
      repoUrl = mkOpt types.str "git@github.com:tghelew/karabiner-config";
      repoPubKeyPath = mkOpt  types.str "${config.user.home}/.ssh/id_github.pub";
      karabinerDir = mkOpt  types.str "${xdgConfigHome}/karabiner";
    };
  };

  config = mkIf cfg.enable {
    services.karabiner-elements.enable = true;

    #NOTE: This is not strictly repoducable as it follow the main branch wihtout hash!
    #WARNING: ssh must be installed and properly configure
    system.userActivationScripts = mkIf (pathExists cfg.repoPubKeyPath) {
      setupKarabiner =
        let script =
              pkgs.writeShellApplication {
                name = "setupKarabiner";
                runtimeInputs = with pkgs; [
                  git
                  openssh
                ];
                text = ''
                  echo "[KarabinerConfig]"
                  if [[ ! -d "${xdgConfigHome}/karabiner-origin" && ! -d "${cfg.karabinerDir}/.git" ]]; then
                    echo "[KarabinerConfig]: Backup original karabiner config"
                    mv "${xdgConfigHome}/karabiner" "${xdg.configHome}/karabiner-origin"
                  fi
                  if [[ ! -d "${cfg.karabinerDir}" && -f ${cfg.repoPubKeyPath} ]]; then
                    echo "[KarabinerConfig]: Cloning Config"
                    git clone --depth=1 --single-branch "${cfg.repoUrl}" "${cfg.karbinerConfig}"
                  fi
                  echo "[KarabinerConfig]: Trying to relaunch the service"
                  if launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server >/dev/null 2>&1; then
                    echo "[KarabinerConfig]: service sucessfully launched"
                  else
                    echo "[KarabinerConfig]: Failed to launch service"
                  fi
                '';
              };
        in
        ''
          ${script}/bin/setupKarabiner
        '';
    };
  };

}
