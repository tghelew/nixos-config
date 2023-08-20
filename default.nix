{ inputs, config, lib, pkgs, ... }:

with lib;
with lib.my;
{
  imports =
    [ inputs.home-manager.nixosModules.home-manager ]
    ++ (mapModulesRec' (toString ./modules) import);

  environment.variables.NIXOS_CONFIG = config.nixos-config.dir;
  environment.variables.NIXOS_CONFIG_BIN = config.nixos-config.binDir;

  # Configure nix and nixpkgs
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";
  nix =
    let filteredInputs = filterAttrs (n: _: n != "self") inputs;
        nixPathInputs  = mapAttrsToList (n: v: "${n}=${v}") filteredInputs;
        registryInputs = mapAttrs (_: v: { flake = v; }) filteredInputs;
    in {
      package = pkgs.nixFlakes;
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
        persitent = true;
        randomizedDelaySec = "10min";
      };
    };
  system.configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  system.stateVersion = "23.05";

  ## Some reasonable, global defaults
  # This is here to appease 'nix flake check' for generic hosts with no
  # hardware-configuration.nix or fileSystem config.
  fileSystems."/".device = mkDefault "/dev/disk/by-label/nixos";

  networking.useDHCP = mkDefault true;

  # Use the latest kernel
  boot = {
    kernelPackages = mkDefault pkgs.linuxPackages_latest;
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
    vim
    wget
    gnumake
    unzip
  ];
}
