{ self, lib, ... }:
let
  inherit (lib)  hasSuffix id;
  inherit (self) mapModulesRec';
in
with builtins;
rec {
  xor = e1: e2:
    (e1 || e2) && (!e1 || !e2);

  # isDirNixEmpty :: path -> Bool
  # Return true if the directory contains at least one nix file
  # This check recusively in DIR for files with name like *.nix
  isDirNixEmpty = dir:
    (countIf (e: hasSuffix ".nix" e) (mapModulesRec' dir id)) <= 0;

  # countIf :: predicate -> list -> Integer
  # Count the number of element of a list that satisfy a predicate
  countIf = pred: list: length (filter pred list);

}
