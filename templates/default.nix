{

  minimal = {
    path = ./minimal;
    description = "A mininal NixOS configuration";
  };

  # Hosts
  host-desktop = {
    path = ./hosts/desktop;
    description = "A starter hosts/* config for someone's daily driver";
  };
  # TODO: host-vultr
  # TODO: host-vm

  # Projects
  # TODO project-rust
  # TODO project-haskell
}
