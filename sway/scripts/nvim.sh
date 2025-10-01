#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Nvim"

# 1) Переключаемся на нужный workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# 2) Проверяем: есть ли В ЭТОМ workspace окно Chrome/Chromium
if swaymsg -t get_tree \
  | jq -r --arg ws "$WORKSPACE" '
      .. | objects
      | select(.type?=="workspace" and .name==$ws)
      | .. | objects
      | select(.app_id?=="foot")
      | .id
    ' | grep -q .; then
  # Окно уже есть — ничего не делаем 
  exit 0
fi

swaymsg exec -- foot
