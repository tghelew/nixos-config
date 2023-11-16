{ inputs, config, lib, pkgs, ... }:
 with lib;
 with lib.my;
 {
   imports = [inputs.home-manager.darwinModules.home-manager ]
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
       packages = pkgs.nixFlakes;
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

       gc = {
         automatic = true;
         dates = "weekly";
         randomizedDelaySec = "10min";
         persistent = true;
         options = "--delete-older-than 15d";
       };
     };
   environment.systemPackages = with pkgs; [
     cached-nix-shell
     git
     dig
     wget
     gnumake
     unzip
     # App stored application download
     mas
   ];

   documentation = {
     enable = true;
     doc.enable = true;
     info.enable = true;
     man.enable = true;
   };
 }
