#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="GPT"
BROWSER="google-chrome-canary" # или: google-chrome / chromium
PROFILE="Profile 2"            # например: "ChatGPT"

# Where to store logs
LOG_DIR="$HOME/.local/share/chrome-logs"
mkdir -p "$LOG_DIR"
# (optional) prune old logs
find "$LOG_DIR" -type f -name 'chrome_*.log' -mtime +14 -delete || true
LOG_FILE="$LOG_DIR/chrome_$(date +%F_%H-%M-%S).log"

# 1) go to target workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# 2) check if a Canary window is already in this workspace
if swaymsg -t get_tree |
  jq -r --arg ws "$WORKSPACE" '
      .. | objects
      | select(.type?=="workspace" and .name==$ws)
      | .. | objects
      | select(.app_id?=="google-chrome-canary")
      | .id
    ' | grep -q .; then
  exit 0
fi

# 3) no window — launch browser (native logging to file)
"$BROWSER" \
  --hide-crash-restore-bubble \
  --profile-directory="$PROFILE" \
  --enable-logging=stderr --v=1 \
  --log-file="$LOG_FILE" \
  "https://chatgpt.com/" \
  >/dev/null 2>&1 &

# stay on the same workspace
swaymsg workspace "$WORKSPACE" >/dev/null
