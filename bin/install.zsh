#!/usr/bin/env nix-shell
#! nix-shell -i zsh -p zsh git
# Deploy and install this nixos system.

zparseopts -E -F -D -- -flake=flake \
                       -user=user \
                       -host=host \
                       -dest=dest \
                       -root=root || exit 1

local root="${root[2]:-/mnt}"
local flake="${flake[2]:-$root/etc/dotfiles}"
local host="${host[2]:-$HOST}"
local user="${user[2]:-thierry}"
local dest="${dest[2]:-$root/home/$user/.config/dotfiles}"

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
  [[ "$user" == thierry ]] && url="git@github.com:tghelew/nixos-config.git"
  rm -rf "$flake"
  git clone --recursive "$url" "$flake"
  chown "$user:users" -R "$flake"
fi

mkdir -p "${dest}"
ln -f "${flake}" "${dest}"

export TNIX="{\"user\":\"$user\",\"host\":\"$host\",\"path\":\"${flake#$root}\",\"theme\":\"$THEME\"}"
nixos-install \
    --impure \
    --show-trace \
    --root "$root" \
    --flake "${flake}#${host}"
