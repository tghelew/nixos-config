{ lib, ... }:

with builtins;
{
  xor = e1: e2:
    (e1 || e2) && (!e1 || !e2);
}
