#!/usr/bin/env bash
# Append the three-finger touchpad gesture setup to Omarchy's personal
# Hyprland input config, then reload.
#
# Safe to re-run: it refuses to add the block twice.

set -euo pipefail

src_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
snippet="$src_dir/input.lua.snippet"
target="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/input.lua"
marker="bind_three_finger_swipe"

if [[ ! -f $snippet ]]; then
  echo "missing $snippet" >&2
  exit 1
fi

if [[ ! -f $target ]]; then
  echo "missing $target - is Omarchy installed and has it been launched once?" >&2
  exit 1
fi

if grep -q "$marker" "$target"; then
  echo "already installed in $target, nothing to do"
  exit 0
fi

backup="$target.bak.$(date +%s)"
cp -- "$target" "$backup"
echo "backup: $backup"

{
  printf '\n'
  cat -- "$snippet"
} >>"$target"

echo "appended to $target"

live_config="$HOME/.config/hypr/input.lua"
if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1 &&
  [[ -f $live_config && $target -ef $live_config ]]; then
  hyprctl reload >/dev/null
  sleep 1
  errors="$(hyprctl configerrors 2>/dev/null)"
  if [[ -n $errors ]]; then
    echo "config errors after reload:" >&2
    echo "$errors" >&2
    exit 1
  fi
  echo "reloaded, no config errors"
else
  echo "target is not the live Hyprland config; reload Hyprland yourself to apply it"
fi
