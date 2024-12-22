#!/usr/bin/env nix-shell
#! nix-shell -i zsh -p zsh git
# Deploy and install this nixos system.

zparseopts -E -F -D -- -flake:=aflake \
                       -user::=auser \
                       -host:=ahost \
                       -dest::=adest \
                       -root::=aroot || exit 1

local root="${aroot[2]:-/mnt}"
local flake="${aflake[2]:-$/etc/nixos-config}"
local host="${ahost[2]}"
local user="${auser[2]:-thierry}"
local dest="${adest[2]:-$root/etc/dotfiles}"

if [[ "$USER" == nixos ]]; then
  >&2 echo "Error: not in the nixos installer"
  exit 1
elif [[ -z "$host" ]]; then
  >&2 echo "Error: no --host set"
  exit 2
fi

set -e
if [[ ! -d "$flake" ]]; then
  local url=https://github.com/tghelew/nixos-config
  rm -rf "$flake"
  git clone --recursive "$url" "$flake"
fi

mkdir -p "${dest}"
echo "copying dotfiles"
cp -RLvf "${flake}" "${dest}"

export USER="${user}"
nixos-install \
    --impure \
    --show-trace \
    --root "$root" \
    --flake "${flake}#${host}"
