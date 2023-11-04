{

  minimal = {
    path = ./minimal;
    description = "A mininal NixOS configuration";
  };

  # Hosts
  host-linux-desktop = {
    path = ./hosts/linux/desktop;
    description = "A starter hosts/linux/* config for someone's daily driver";
  };

  host-darwin-desktop = {
    path = ./hosts/darwin/desktop;
    description = "A starter hosts/darwin/* config for someone's daily driver";
  };
  # TODO: host-vultr
  # TODO: host-vm

  # Projects
  # TODO project-rust
  # TODO project-haskell
}
