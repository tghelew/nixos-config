{ inputs, config, options, lib, pkgs, nix-homebrew, ... }:
let
  cfg = config.modules.darwin.homebrew;
in
with lib;
with lib.my;

{
  options = with types; {
    modules.darwin.homebrew = {
      enable = mkBoolOpt false;
      casks = mkOpt' (listOf (either str attrs)) [] "Alias for 'homebrew.casks'";
      brews = mkOpt' (listOf (either str attrs)) [] "Alias for 'homebrew.brews'";
      masApps = mkOpt' (attrsOf ints.positive) {} "Alias for 'homebrew.masApps'";
    };
  };

  config = mkIf cfg.enable {
    nix-homebrew = {
      user = config.user.name;
      enable = true;
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
        "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      };
      mutableTaps = false;
      autoMigrate = true;
    };

    homebrew = {
      enable = true;
      onActivation = {
        upgrade = true;
        autoUpdate = false;
      };

      brews = mkAliasDefinitions options.modules.darwin.homebrew.brews;
      casks = mkAliasDefinitions options.modules.darwin.homebrew.casks;
      masApps = mkAliasDefinitions options.modules.darwin.homebrew.masApps;
    };


   environment.systemPackages = with pkgs; [
     # App stored application download
     # Generally used with Homebrew
     mas
   ];

  };
}
