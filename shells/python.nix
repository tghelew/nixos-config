{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let nixBin =
      writeShellScriptBin "nix" ''
        ${nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
      '';
in mkShell {
  name="nix shell for python development";
  buildInputs = [
    git
    nix-zsh-completions

    (python3.withPackages (ps: with ps;
      [
        python-lsp-server
      ] ++ python-lsp-server.optional-dependencies.all))
  ];
  shellHook = ''
    export FLAKE="$(pwd)"
    export PATH="$FLAKE/bin:${nixBin}/bin:$PATH"
  '';
}
