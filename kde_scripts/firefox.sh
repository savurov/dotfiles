#!/usr/bin/env bash

lock="${XDG_RUNTIME_DIR:-/tmp}/kde-scripts-focus-or-run.lock"
cache="${XDG_RUNTIME_DIR:-/tmp}/firefox-window-uuid"
newtab_url="about:newtab"

exec 9>"$lock"
flock -n 9 || exit 0

list_firefox_windows() {
  kdotool search --class firefox 2>/dev/null | sort
}

activate_window() {
  kdotool windowactivate "$1"
  exit 0
}

cleanup() {
  rm -f "$before" "$after"
}

# 1. Если в кэше есть uuid и такое окно ещё существует, просто активируем его.
if [ -f "$cache" ]; then
  cached_uuid=$(cat "$cache")

  if [ -n "$cached_uuid" ] && list_firefox_windows | grep -Fxq "$cached_uuid"; then
    activate_window "$cached_uuid"
  fi
fi

# 2. Запоминаем текущие uuid всех firefox-окон.
before=$(mktemp)
after=$(mktemp)
trap cleanup EXIT

list_firefox_windows > "$before"

# 3. Открываем новое окно firefox.
firefox --new-window "$newtab_url" 9>&- >/dev/null 2>&1 &

# 4. Ждём, пока в списке firefox-окон появится новый uuid.
for i in {1..50}; do
  sleep 0.1

  list_firefox_windows > "$after"
  new_uuid=$(comm -13 "$before" "$after" | head -n1)

  if [ -z "$new_uuid" ]; then
    continue
  fi

  printf '%s\n' "$new_uuid" > "$cache"
  activate_window "$new_uuid"
done

exit 1
