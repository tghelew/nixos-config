{ config, lib, ... }:

with builtins;
with lib;
let blocklist = fetchurl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
in
{
  environment.etc.hosts = {
    enable = true;
    copy = true;
    text = ''
    # Default DNS
    127.0.0.1     localhost
    ::1           localhost
    255.255.255.255   broadcasthost

    # Personal name
    172.22.22.1   router.home

    # DNS Server & Soon mail server
    137.220.54.49 eshub
    46.23.94.97   eshua
    # OpenBSD amsterdam host servers
    server11.openbsd.amsterdam  eshua.obsdams

    #Block garbage
    ${(readFile blocklist)}
    '';
  };

  time.timeZone = mkDefault "Europe/Zurich";
}
