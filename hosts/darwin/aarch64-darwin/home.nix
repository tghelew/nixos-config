{ config, lib, ... }:

with builtins;
with lib;
let blocklist = fetchurl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
in
{
  environment.etc.hosts = {
    enable = true;
    text = ''
    # Default DNS
    127.0.0.1     localhost
    ::1           localhost
    255.255.255.255   broadcasthost

    # Personal name
    172.22.22.1   router.home

    # DNS Server & Soon mail server
    93.177.66.222 eshua
    46.23.94.97   eshub
    46.23.93.235  eshuc
    #To delete
    137.220.54.49 obsd
    # OpenBSD amsterdam host servers
    server11.openbsd.amsterdam  eshub.obsdams
    server22.openbsd.amsterdam  eshuc.obsdams

    #Block garbage
    ${(readFile blocklist)}
    '';
  };

  time.timeZone = mkDefault "Europe/Zurich";
}
