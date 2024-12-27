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


   ################################################################################
    172.22.22.1   ghelew.home gateway router
    10.22.22.1    internet fritz

    # DNS Server & mail server
    93.177.66.222 eshua
    46.23.94.97   eshub
    46.23.93.235  eshuc

    # Services and Backup FreeBSD
    172.22.22.5   tumba git blog backup

    # OpenBSD amsterdam host servers
    server11.openbsd.amsterdam  eshub.obsdams
    server22.openbsd.amsterdam  eshuc.obsdams

   ################################################################################
    #Block garbage
    ${(readFile blocklist)}
    '';
  };

  time.timeZone = mkDefault "Europe/Zurich";
}
