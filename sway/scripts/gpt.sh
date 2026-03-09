set -euo pipefail

WORKSPACE="Chat"
APP_CMD="google-chrome-stable"

APP_ID="google-chrome"

ARGS=(
  --profile-directory=Profile
  --ozone-platform=wayland
  --hide-crash-restore-bubble
)

# Switch to workspace
swaymsg workspace "$WORKSPACE" >/dev/null

# Check if Chrome already exists in this workspace
if swaymsg -t get_tree | jq -r --arg ws "$WORKSPACE" --arg app_id "$APP_ID" '
  .. | select(.type?=="workspace" and .name==$ws)?
  | .. | select(.app_id?==$app_id)?
  | .id
' | grep -q .; then
  exit 0
fi

# Launch app
"$APP_CMD" "${ARGS[@]}" >/dev/null 2>&1 &
