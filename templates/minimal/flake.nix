{
  description = " Tlux Nix[OS] config.";

  inputs = {
    nixos-config.url = "github:tghelew/nixos-config";
  };

  outputs = inputs @ { nixos-config, ... }: {
    nixosConfigurations = nixos-config.lib.mapHosts ./hosts {
      imports = [

      ];
    };
  };
}
