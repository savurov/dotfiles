#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="GPT"

# какой браузер запускать (поставь нужный)
BROWSER="google-chrome-stable" # или: google-chrome / chromium
PROFILE="Profile 2"            # например: "ChatGPT" (оставь пустым если не надо)

# 1) Переключаемся на нужный workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# 2) Проверяем: есть ли В ЭТОМ workspace окно Chrome/Chromium
if swaymsg -t get_tree |
  jq -r --arg ws "$WORKSPACE" '
      .. | objects
      | select(.type?=="workspace" and .name==$ws)
      | .. | objects
      | select(.app_id?=="google-chrome")
      | .id
    ' | grep -q .; then
  # Окно уже есть — ничего не делаем (мы уже в Code)
  exit 0
fi

# 3) Окна нет — запускаем браузер (в текущем workspace)
"$BROWSER" --hide-crash-restore-bubble --profile-directory="$PROFILE" https://chatgpt.com/ >/dev/null 2>&1 &

# остаёмся на Code (на случай если правила куда-то увели)
swaymsg workspace "$WORKSPACE" >/dev/null
