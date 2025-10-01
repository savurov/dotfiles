#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Firefox"

# какой браузер запускать (поставь нужный)
BROWSER="google-chrome-canary" # или: google-chrome / chromium
PROFILE="Default"              # например: "ChatGPT" (оставь пустым если не надо)

# Куда сохранять логи
LOG_DIR="$HOME/.local/share/chrome-logs"
mkdir -p "$LOG_DIR"

# Уникальный лог для каждой сессии
LOG_FILE="$LOG_DIR/chrome_$(date +%F_%H-%M-%S).log"

# 1) Переключаемся на нужный workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# 2) Проверяем: есть ли В ЭТОМ workspace окно Chrome/Chromium
if swaymsg -t get_tree |
  jq -r --arg ws "$WORKSPACE" '
      .. | objects
      | select(.type?=="workspace" and .name==$ws)
      | .. | objects
      | select(.app_id?=="google-chrome-canary")
      | .id
    ' | grep -q .; then
  # Окно уже есть — ничего не делаем
  exit 0
fi

# 3) Окна нет — запускаем браузер и сохраняем логи
"$BROWSER" \
  --profile-directory="$PROFILE" \
  --hide-crash-restore-bubble \
  --enable-logging=stderr --v=1 \
  2>&1 | tee -a "$LOG_FILE" &

# остаёмся на workspace (на случай если правила куда-то увели)
swaymsg workspace "$WORKSPACE" >/dev/null
