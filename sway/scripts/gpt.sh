#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Grok"
APP_CMD="google-chrome"

# swaymsg -t get_tree | jq -r '.. | select(.app_id? != null) | .app_id' | sort -u
APP_ID="google-chrome"

ARGS=(
  --profile-directory="Profile 2"
  --hide-crash-restore-bubble
)

# Switch to the workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# Check if app is already opened in this workspace
if swaymsg -t get_tree | jq -r --arg ws "$WORKSPACE" --arg app_id "$APP_ID" '
  .. | select(.type?=="workspace" and .name==$ws)? 
  | .. | select(.app_id?==$app_id)?
  | .id' | grep -q .; then
  exit 0
fi

# Launch app
"$APP_CMD" "${ARGS[@]}" https://grok.com/c >/dev/null 2>&1 &
