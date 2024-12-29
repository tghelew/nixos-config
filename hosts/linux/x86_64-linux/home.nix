{ config, lib, ... }:

with builtins;
with lib;
let blocklist = fetchurl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
in {
  networking.extraHosts = ''
    # Personal name
    172.22.22.1   ghelew.home gateway router
    10.22.22.1    internet fritz

    # DNS Server & mail server
    93.177.66.222 eshua
    46.23.94.97   eshub
    46.23.93.235  eshuc

    # Services and Backup FreeBSD
    172.22.22.5   tumba git blog backup

    # Laptop
    172.22.22.6   atumbi
    172.22.22.7   mungu

    # OpenBSD amsterdam host servers
    server11.openbsd.amsterdam  eshub.obsdams
    server22.openbsd.amsterdam  eshuc.obsdams
    ####################################################################
    # Block garbage
    ${optionalString (config.services.xserver.enable
      # Make sure to add additional WM DM
      || config.programs.hyprland.enable
      || config.programs.sway.enable)
        (readFile blocklist)}
  '';

  time.timeZone = mkDefault "Europe/Zurich";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  # For redshift, mainly
  location = (if config.time.timeZone == "Europe/Zurich" then {
    latitude = 47.37;
    longitude = 8.55;
  } else {});
}
