#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Chat"
APP_CMD="firefox"
APP_URL="https://chatgpt.com"
APP_ID="firefox-chat"

ARGS=(
  --new-instance
  -P "Chat"
  --name firefox-chat
  "$APP_URL"
)

# перейти на workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# если окно ChatGPT уже есть в этом workspace — просто ничего не делаем
if swaymsg -t get_tree | jq -e --arg ws "$WORKSPACE" --arg app_id "$APP_ID" '
  .. | select(.type? == "workspace" and .name == $ws)
  | .. | select((.app_id? // "") == $app_id)
' >/dev/null; then
  exit 0
fi


# запуск
"$APP_CMD" "${ARGS[@]}" >/dev/null 2>&1 &
