{ config, lib, ... }:

with builtins;
with lib;
let blocklist = fetchurl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
in {
  networking.extraHosts = ''
    192.168.1.1   router.home

    # DNS Server & Soon mail server
    137.220.54.49 eshub
    46.23.94.97   eshua

    # Hosts
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
