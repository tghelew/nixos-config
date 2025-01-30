{ config, lib, pkgs, modulesPath, ... }:

{
  imports = ["${modulesPath}/installer/scan/not-detected.nix" ];

  boot = {

    initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci"];
    initrd.kernelModules = [];
    extraModulePackages = [];
    kernelParams = [
    ];
    extraModprobeConfig = ''
    '';

    # Refuse ICMP echo requests on my desktop/laptop;
    kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };


  # GPU
  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  hardware.graphics = {
    enable = false;
  };
  # Modules
  modules.hardware = {
    audio.enable = true;
    xkb.enable = true;
    fs = {
      enable = true;
      automount.enable = true;
    };
    sensors.enable = true;
    network = {
      enable = true;
      applet = true;
    };
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Storage
  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  swapDevices = [{device="/dev/vda2";}];
  #Misc
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking ={
    useDHCP = lib.mkDefault true;
    hostId = "a84f0a9f";
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
