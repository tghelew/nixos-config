{ config, lib, pkgs, modulesPath, ... }:

{
  imports = ["${modulesPath}/installer/scan/not-detected.nix" ];

  boot = {

    initrd.availableKernelModules = [ "bluetooth" "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
    initrd.kernelModules = ["i915" "bluetooth"];
    initrd.luks.reusePassphrases = true;
    initrd.luks.devices = {
      crypted = {
        device = "/dev/disk/by-partuuid/09b23c8e-a1d5-46a4-b3a1-525c5776eaf5";
        header = "/dev/disk/by-partuuid/0a139090-c68e-44a8-8293-6ca6d359d089";
        allowDiscards = true;
        preLVM = true;
      };
    };
    kernelModules = [ "kvm-intel" "i915"];
    extraModulePackages = [];
    kernelParams = [
      # HACK Disables fixes for spectre, meltdown, L1TF and a number of CPU
      #      vulnerabilities. Don't copy this blindly! And especially not for
      #      mission critical or server/headless builds exposed to the world.
      "mitigations=off"
    ];
    extraModprobeConfig = ''
      options bbswitch use_acpi_to_detect_card_state=1
      options thinkpad_acpi force_load=1 fan_control=1
    '';

    # Refuse ICMP echo requests on my desktop/laptop;
    kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = 1;
  };

  # acpi
  environment.systemPackages = with pkgs; [
    acpi
  ];

  # GPU
  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libvdpau-va-gl
      intel-media-sdk
    ];
  };
  # Modules
  modules.hardware = {
    audio.enable = true;
    xkb.enable = true;
    fs = {
      enable = true;
      ssd.enable = true;
      zfs.enable = true;
      zfs.autoSnapshot = true;
      automount.enable = true;
    };
    sensors.enable = true;
    network = {
      enable = true;
      applet = true;
    };
    # not supported
    fprint.enable = false;
  };

  # CPU
  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Storage
  fileSystems."/" =
    { device = "rpool/system/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/users/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/local/nix";
      fsType = "zfs";
    };

  fileSystems."/var" =
    { device = "rpool/system/var";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  fileSystems."/data" =
    { device = "/dev/disk/by-label/DATA";
      fsType = "vfat";
      options = [
        "defaults"
        "uid=${config.user.name}"
        "gid=users"
      ];
    };
  swapDevices = [];
  #Misc
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking ={
    useDHCP = lib.mkDefault true;
    hostId = "a84f0a8f";
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
