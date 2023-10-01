{ config, lib, ... }:

with builtins;
with lib;
let blocklist = fetchurl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
in {
  networking.extraHosts = ''
    192.168.1.1   router.home

    # Hosts
    # Block garbage
    ${optionalString (config.services.xserver.enable
      # Make sure to add additional WM DM
      || config.programs.hyprland.enable
      || config.programs.sway.enable)
        (readFile blocklist)}
  '';

  ## Location config -- since Toronto is my 127.0.0.1
  time.timeZone = mkDefault "Europe/Zurich";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  # For redshift, mainly
  location = (if config.time.timeZone == "Europe/Zurich" then {
    latitude = 47.37;
    longitude = 8.55;
  } else {});
}
