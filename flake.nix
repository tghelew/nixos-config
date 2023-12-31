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

      darwin = {                                                           # MacOS Package Management
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

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];

      forSystems = fn: systems: nixpkgs.lib.genAttrs systems (system: fn system);
      forAllSystems = fn: forSystems fn (linuxSystems ++ darwinSystems);

      mkPkgs = pkgs: system: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;  # forgive me Stallman senpai
        overlays = extraOverlays ++ (pkgs.lib.attrValues self.overlays.${system});
      };
      pkgsFor  = system:  mkPkgs nixpkgs system [ self.overlays.${system}.default ];
      pkgsFor' = system:  mkPkgs nixpkgs-unstable system [];

      libFor = system:
        let
          pkgs = pkgsFor system;
        in
        nixpkgs.lib.extend
        (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });

      overlay = system: {
        default =
          final: prev: {
            unstable = pkgsFor' system;
            my = self.packages.${system};
          };
      } // ((libFor system).my.mapModules ./overlays import);

      package = system:
        let
          lib = (libFor system);
          pkgs = (pkgsFor system);
        in
          if (! lib.my.isDirNixEmpty ./packages) then
            lib.my.mapModules ./packages/all (p: pkgs.callPackage p {}) //
            lib.mkIf pkgs.stdenv.isLinux (lib.my.mapModules ./packages/linux (p: pkgs.callPackage p {})) //
            lib.mkIf pkgs.stdenv.isDarwin (lib.my.mapModules ./packages/darwin (p: pkgs.callPackage p {}))
          else
            {};

      myNixOSModules = forSystems (system:
        let
          lib = (libFor system);
          pkgs = (pkgsFor system);
        in
          lib.my.mapModulesRec ./modules import
      ) linuxSystems;

      myNixOSConfigurations = map (system:
        let
          lib = libFor system;
          path =  ./hosts/linux/${system};
        in
          if builtins.pathExists path then
            lib.my.mapHosts path {inherit system;}
          else {}) linuxSystems;

      devShell = system:
        let
          lib = (libFor system);
          pkgs = (pkgsFor system);
        in
          {
            default = import ./shells { inherit pkgs; };
          } // lib.my.mapModulesRec ./shells (path: import path {inherit pkgs;});

      app = system:
        let
          lib = (libFor system);
          pkgs = (pkgsFor system);
        in {
          default = {
            type = "app";
            program = ./bin/hey;
          };
        };

    in
    {
      lib = forAllSystems libFor;

      overlays = forAllSystems overlay;

      packages = forAllSystems package;

      nixosModules =
        { nixos-config = import ./hosts/linux; } // myNixOSModules;

      nixosConfigurations = builtins.foldl' (a: b: a // b) {} myNixOSConfigurations;

      devShells = forAllSystems devShell;

      templates = {
        default = self.templates.full;
        full = {
          path = ./.;
          description = "A grossly incandescent nixos config";
        };
      } // import ./templates;

      apps = forAllSystems app;
    };
}
