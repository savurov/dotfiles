#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Chat"
APP_URL="https://chatgpt.com"

if ! command -v firefox >/dev/null 2>&1; then
  echo "firefox is not installed" >&2
  exit 1
fi

firefox_ids() {
  swaymsg -t get_tree | jq -r '
    .. | select((.app_id? // "") == "firefox") | .id
  ' | sort -n
}

swaymsg workspace "$WORKSPACE" >/dev/null

if swaymsg -t get_tree | jq -e --arg ws "$WORKSPACE" '
  .. | select(.type? == "workspace" and .name == $ws)
  | .. | select((.app_id? // "") == "firefox")
' >/dev/null; then
  exit 0
fi

before_ids="$(firefox_ids)"
firefox --new-window "$APP_URL" >/dev/null 2>&1 &

for _ in $(seq 1 50); do
  after_ids="$(firefox_ids)"
  new_id="$(
    comm -13 <(printf '%s\n' "$before_ids") <(printf '%s\n' "$after_ids") | head -n 1
  )"

  if [ -n "$new_id" ]; then
    swaymsg "[con_id=$new_id] move to workspace \"$WORKSPACE\"" >/dev/null
    exit 0
  fi

  sleep 0.1
done

echo "failed to detect new firefox window" >&2
exit 1
