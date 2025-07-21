{ options, config, lib, pkgs,... }:

with lib;
with lib.my;
let
  cfg = config.modules.services.backup;
  binDir = config.nixos-config.binDir;
in {
  options.modules.services.backup = {
    enable = mkBoolOpt false;
    frequency = with types; mkOpt (nullOr str) null;
  };

  config = mkIf cfg.enable {

    home.services.backup = {
      Unit = {
        Description = "Backup my linux machine";
        PartOf = [ "graphical.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${binDir}/backup";
      };

      Install = { WantedBy = [ "default.target"  ]; };
    };

    systemd.user.timers = {
    backup = {
      enable = true;
      unitConfig = {
        Description = "Backup Schedule";
      };
      timerConfig = {
        OnBootSec=60;
        Unit = "backup.service";
        OnCalendar = if (cfg.frequency == null) then "hourly" else cfg.frequency;
      };
      wantedBy = ["timers.target"];
      };
    };
  };
}
