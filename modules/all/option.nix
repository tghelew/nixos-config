{ config, options, lib, home-manager, ... }:

with lib;
with lib.my;
{
  options = with types; {
    user = mkOpt attrs {};

    nixos-config = {
      dir = mkOpt path
        (removePrefix "/mnt"
          (findFirst pathExists (toString ../.) [
            "/mnt/etc/nixos-config"
            "/etc/nixos-config"
            "${config.user.home}/.config/nixos-config"
            "/mnt/etc/dotfiles"
            "/etc/dotfiles"
            "${config.user.home}/.config/dotfiles"
          ]));
      binDir     = mkOpt path "${config.nixos-config.dir}/bin";
      configDir  = mkOpt path "${config.nixos-config.dir}/config";
      modulesDir = mkOpt path "${config.nixos-config.dir}/modules";
      themesDir  = mkOpt path "${config.nixos-config.modulesDir}/all/themes";
    };

    home = {
      stateVersion = mkOpt' str "23.11" "Alias for state version";
      file         = mkOpt' attrs {} "Files to place directly in $HOME";
      configFile   = mkOpt' attrs {} "Files to place in $XDG_CONFIG_HOME";
      dataFile     = mkOpt' attrs {} "Files to place in $XDG_DATA_HOME";
      services     = mkOpt' attrs {} "Systemd or Launchd options from home-manager";
    };

    env = mkOption {
      type = attrsOf (oneOf [ str path (listOf (either str path)) ]);
      apply = mapAttrs
        (n: v: if isList v
               then concatMapStringsSep ":" (x: toString x) v
               else (toString v));
      default = {};
      description = "Additional Environment Variable to set";
    };

    myfonts.packages = mkOpt (listOf path) [];
  };

  config = {
    user =
      let user = builtins.getEnv "USER";
          name = if elem user [ "" "root" ] then "thierry" else user;
          description = if name == "thierry" then "Thierry Ghelew" else "The primary user account";
      in {
        inherit name;
        inherit description;
      } // linuxXorDarwin
        ({
          extraGroups = [ "wheel" ];
          isNormalUser = true;
          home = "/home/${name}";
          group = "users";
          uid = 1000;
        })
        ({
          home = "/Users/${name}";
        });

    home-manager = {
      useUserPackages = true;

      users.${config.user.name} = {
        home = {
          file = mkAliasDefinitions options.home.file;
          # Necessary for home-manager to work with flakes, otherwise it will
          # look for a nixpkgs channel.
          stateVersion = mkAliasDefinitions options.home.stateVersion;
        };
        xdg = {
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile   = mkAliasDefinitions options.home.dataFile;
        };

        systemd.user.services = linuxXorDarwin (mkAliasDefinitions options.home.services) {};
        launchd.agents = linuxXorDarwin {} (mkAliasDefinitions options.home.services);
      };
    };

    users.users.${config.user.name} = mkAliasDefinitions options.user;

    nix = {
      settings = let users = [ "root" config.user.name ]; in {
        trusted-users = users;
        allowed-users = users;
      };
      optimise.automatic = true;
    };

    env.PATH = [ "$NIXOS_CONFIG_BIN" "$XDG_BIN_HOME" "$PATH" ];

    environment.extraInit =
      concatStringsSep "\n"
        (mapAttrsToList (n: v: "export ${n}=\"${v}\"") config.env);

    fonts.packages = mkAliasDefinitions options.myfonts.packages;
  };
}
