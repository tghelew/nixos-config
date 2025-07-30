{ config, lib, pkgs, modulesPath, ... }:

{
  imports = ["${modulesPath}/installer/scan/not-detected.nix" ];

  boot = {

    initrd.availableKernelModules = [ "bluetooth" "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc"];
    initrd.kernelModules = ["i915" "bluetooth" "nouveau"];
    kernelModules = ["i915" "nouveau"];
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
    # Kernel : zfs failed to build with latest
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # acpi
  environment.systemPackages = with pkgs; [
    acpi
  ];

  # GPU
  hardware = {

    nvidia = {
       # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      open = false;

      # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.legacy_535;

      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
        sync.enable = true;


      };
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        libvdpau-va-gl
        intel-media-sdk
      ];
    };
  };
  # Modules
  modules.hardware = {
    audio.enable = true;
    xkb.enable = true;
    fs = {
      enable = true;
      ssd.enable = true;
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
    { device = "/dev/vg/root";
      fsType = "xfs";
    };

  fileSystems."/home" =
    { device = "/dev/vg/home";
      fsType = "xfs";
    };

  fileSystems."/nix" =
    { device = "/dev/vg/nix";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  swapDevices = [ {device = "/dev/vg/swap";}];

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
