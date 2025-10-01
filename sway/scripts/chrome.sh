#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Firefox"

BROWSER="google-chrome-stable"
PROFILE="Default"

# 1) switch to workspace
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
"$BROWSER" --profile-directory="$PROFILE" --enable-features=VaapiVideoDecodeLinuxGL --use-gl=angle --use-angle=gl --ozone-platform=wayland --hide-crash-restore-bubble >/dev/null 2>&1 &

# остаёмся на workspace (на случай если правила куда-то увели)
swaymsg workspace "$WORKSPACE" >/dev/null
