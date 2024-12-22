{ inputs, config, lib, pkgs, ... }:
 with lib;
 with lib.my;
 {
   imports =
     [
       inputs.home-manager.darwinModules.home-manager
       inputs.nix-homebrew.darwinModules.nix-homebrew
     ]
     ++ (mapModulesRec' (toString ../../modules/all) import)
     ++ (mapModulesRec' (toString ../../modules/darwin) import);

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
         # optimise = true ;
       };

       gc = {
         automatic = true;
         interval = {
           Hour = 5;
           Minute = 22;
           Weekday = 0;
         };
         options = "--delete-older-than 15d";
       };
     };
   services = {
     nix-daemon.enable = true;
   };

   programs.nix-index.enable = true;

   environment.systemPackages = with pkgs; [
     git
     dig
     wget
     gnumake
     unzip
     # App stored application download
     mas

     btop
     dockutil
     # Spotlight killer ?
     raycast
   ];

   documentation = {
     enable = true;
     doc.enable = true;
     info.enable = true;
     man.enable = true;
   };
 }
