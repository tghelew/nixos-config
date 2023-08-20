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

      emacs-overlay = {                                                   # Emacs Overlays
        url = "github:nix-community/emacs-overlay";
      };

      agenix = {                                                          # Secret management in Nix Store
        url =  "github:ryantm/agenix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ {self ,nixpkgs ,nixpkgs-unstable,... }:

    let
      inherit (lib.my) mapModules mapModulesRec mapHosts;

      system = "x86_64-linux";

      mkPkgs = pkgs: system: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
        overlays = extraOverlays ++ (lib.attrValues self.overlays);
      };
      pkgs  = mkPkgs nixpkgs "${system}" [ self.overlays.default ];
      pkgs' = mkPkgs nixpkgs-unstable "${system}" [];

      lib = nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

    in
    {
      lib = lib.my;

      overlays = {
        default =
          final: prev: {
            unstable = pkgs';
            my = self.packages."${system}";
          };
      } // (mapModules ./overlays import);

      packages."${system}" =
        mapModules ./packages (p: pkgs.callPackage p {});

      nixosModules =
        { nixos-config = import ./.; } // mapModulesRec ./modules import;

      nixosConfigurations =
        mapHosts ./hosts {};

      devShells."${system}" = {
        default = import ./shell.nix { inherit pkgs; };
      };

      templates = {
        default = self.templates.full;
        full = {
          path = ./.;
          description = "A grossly incandescent nixos config";
        };
      } // import ./templates;

      apps."${system}".default = {
        type = "app";
        program = ./bin/hey;
      };
    };
}
