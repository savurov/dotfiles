#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="Podman"
APP_CMD="flatpak run io.podman_desktop.PodmanDesktop"
APP_NAME="Podman Desktop"

# Switch to the workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# Check if app is already opened in this workspace
if swaymsg -t get_tree | jq -r --arg ws "$WORKSPACE" --arg app_name "$APP_NAME" '
  .. | select(.type?=="workspace" and .name==$ws)? 
  | .. | select(.name?==$app_name)?
  | .id' | grep -q .; then
  exit 0
fi

# Launch app
eval "$APP_CMD" >/dev/null 2>&1 &
