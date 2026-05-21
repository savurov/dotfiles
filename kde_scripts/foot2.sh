#!/usr/bin/env bash

lock="${XDG_RUNTIME_DIR:-/tmp}/kde-scripts-focus-or-run.lock"
app_id="foot2"

exec 9>"$lock"
flock -n 9 || exit 0

window="$(
  kdotool search --class "^${app_id}$" 2>/dev/null |
    sort -u |
    head -n1
)"

if [ -n "$window" ]; then
  kdotool windowactivate "$window"
  exit 0
fi

foot --app-id "$app_id" 9>&- >/dev/null 2>&1 &
