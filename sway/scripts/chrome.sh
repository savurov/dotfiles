set -euo pipefail

WORKSPACE="Firefox"
APP_CMD="firefox"

APP_ID="firefox-default"

ARGS=(
  --new-instance
  -P "default"
  --name firefox-default
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
