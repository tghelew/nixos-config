# flake.nix --- entry point
#
# Author:  Thierry Ghelew
# URL:     https://github.com/tghelew/nixos-config
# License: MIT
#
# Mainly inspired and sometimes copied from https://github.com/hlissner/dotfiles

{
  description = "My Personal NixOS and <possibly> Nix configurations";

  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";                   # Default Stable Nix Packages
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";       # Unstable Nix Packages

      home-manager = {                                                    # User Package Management
        url = "github:nix-community/home-manager/release-23.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      macos = {                                                           # MacOS Package Management
        url = "github:lnl7/nix-darwin/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # nur = {                                                             # NUR Packages
      #   url = "github:nix-community/NUR";
      # };

      emacs-overlay = {                                                   # Emacs Overlays
        url = "github:nix-community/emacs-overlay";
        flake = false;
      };

      # tlux-emacs = {                                                    # My tlux-emacs nix configuration
      #   url = "github:nix-community/nix-doom-emacs";
      #   inputs.nixpkgs.follows = "nixpkgs";
      #   inputs.emacs-overlay.follows = "emacs-overlay";
      # };

      hyprland = {                                                        # Official Hyprland flake
        url = "github:hyprwm/Hyprland";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };

      agenix = {                                                          # Secret management in Nix Store
        url =  "github:ryantm/agenix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixos-hardware = {
        url = "github:nixos/nixos-hardware";
      };
    };

  outputs = inputs @ {self ,nixpkgs ,nixpkgs-unstable
    ,home-manager
    ,macos
    ,emacs-overlay
    ,hyprland
    ,agenix
    ,nixos-harware
    ,... }:

    let
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      mkPkgs = pkgs: system: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs  = mkPkgs nixpkgs "${system}"[ self.overlay ];
      pkgs' = mkPkgs nixpkgs-unstable "${system}" [];

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

    in
    {
      lib = lib.my;

      overlay =
        final: prev: {
          unstable = pkgs';
          my = self.packages."${system}";
        };

      overlays =
        mapModules ./overlays import;

      packages."${system}" =
        mapModules ./packages (p: pkgs.callPackage p {});

      nixosModules =
        { nixos-config = import ./.; } // mapModulesRec ./modules import;

      nixosConfigurations =
        mapHosts ./hosts {};

      devShell."${system}" =
        import ./shell.nix { inherit pkgs; };
    };
}
