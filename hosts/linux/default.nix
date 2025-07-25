{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      inputs.programs-sqlite.nixosModules.programs-sqlite
    ]
    ++ (mapModulesRec' (toString ../../modules/all) import)
    ++ (mapModulesRec' (toString ../../modules/linux) import);

  environment.variables.NIXOS_CONFIG = config.nixos-config.dir;
  environment.variables.NIXOS_CONFIG_BIN = config.nixos-config.binDir;

  # Configure nix and nixpkgs
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix =
    let filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs  = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in {
      package = pkgs.nixVersions.stable;
      extraOptions = "experimental-features = nix-command flakes";
      nixPath = nixPathInputs ++ [
        "nixpkgs-overlays=${config.nixos-config.dir}/overlays"
        "nixos-config=${config.nixos-config.dir}"
      ];
      registry = registryInputs // { nixos-config.flake = inputs.self; };
      settings = {
        substituters = [
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;
      };
      #  automatic garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        persistent = true;
        randomizedDelaySec = "10min";
      };
    };
  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "24.11";
  home.stateVersion = config.system.stateVersion;

  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  networking.useDHCP = mkDefault true;

  # Use the latest kernel
  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages;
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = mkDefault true;
    };
  };

  # Just the bear necessities...
  environment.systemPackages = with pkgs; [
    cached-nix-shell
    git
    unstable.git-credential-oauth
    dig
    vim
    wget
    gnumake
    unzip
    file
  ];
  # documentation
  documentation = {
    enable = true;
    doc.enable = true;
    info.enable = true;
    # nixos.includeAllModules = true;
    man = {
      enable = true;
      generateCaches = true;
      mandoc.enable = false;
    };
  };
}
