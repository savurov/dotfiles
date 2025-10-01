#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Podman"

# 1) Переключаемся на нужный workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# 2) Проверяем: есть ли В ЭТОМ workspace окно Chrome
if swaymsg -t get_tree |
  jq -r --arg ws "$WORKSPACE" '
      .. | objects
      | select(.type?=="workspace" and .name==$ws)
      | .. | objects
      | select(.app_id?=="google-chrome")
      | .id
    ' | grep -q .; then
  # Окно уже есть — ничего не делаем
  exit 0
fi

# 3) Окна нет — запускаем браузер (в текущем workspace)
flatpak run io.podman_desktop.PodmanDesktop >/dev/null 2>&1 &

# остаёмся на workspace (на случай если правила куда-то увели)
swaymsg workspace "$WORKSPACE" >/dev/null
