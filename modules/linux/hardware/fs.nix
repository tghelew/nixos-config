{ config, options, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.hardware.fs;
in {
  options.modules.hardware.fs = {
    enable = mkBoolOpt false;
    zfs.enable = mkBoolOpt false;
    zfs.autoSnapshot = mkBoolOpt false;
    ssd.enable = mkBoolOpt false;
    automount.enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.udevil.enable = true;

      # Support for more filesystems, mostly to support external drives
      environment.systemPackages = with pkgs; [
        sshfs
        exfat     # Windows drives
        ntfs3g    # Windows drives
        hfsprogs  # MacOS drives
        parted    # partitioning
      ];
    }

    (mkIf (!cfg.zfs.enable && cfg.ssd.enable) {
      services.fstrim.enable = true;
    })

    (mkIf cfg.zfs.enable (mkMerge [
      {
        boot.loader.grub.copyKernels = true;
        boot.supportedFilesystems = [ "zfs" ];
        boot.zfs.devNodes = "/dev/mapper /dev/disk/by-id";
        services.zfs.autoScrub.enable = true;
        services.zfs.autoSnapshot.enable = cfg.zfs.autoSnapshot;
      }

      (mkIf cfg.ssd.enable {
        # Will only TRIM SSDs; skips over HDDs
        services.fstrim.enable = false;
        services.zfs.trim.enable = true;
      })

    ]))
    (mkIf cfg.automount.enable {
      services.udisks2.enable = true;
    })
  ]);
}
