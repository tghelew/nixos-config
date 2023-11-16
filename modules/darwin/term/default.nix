{ config, lib, pkgs, ... }:

{
  #TODO
  environment = {
    etc = {
      terminfo = {
        source = "${pkgs.ncurses}/share/terminfo";
      };
    };

    systemPackages = [
      pkgs.ncurses
    ];
  };
}
