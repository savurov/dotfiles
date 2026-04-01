#!/usr/bin/env bash
set -euo pipefail

# =========================
# CONFIG
# =========================

WS_BACK="Nvim"
WS_FRONT="Nvim2"
WS_DEV="2"

BACK_DIR="$HOME/src/freqy-back"
FRONT_DIR="$HOME/src/freqy-front"

TERM_APP="foot"

TMUX_BACK_SESSION="nvim-back"
TMUX_FRONT_SESSION="nvim-front"
TMUX_DEV_SESSION="dev"
TMUX_SHELL_SESSION="shell-2"

SLEEP_SHORT="0.35"

# =========================
# HELPERS
# =========================

log() {
  printf '[dev-layout] %s\n' "$*"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

sleep_short() {
  sleep "$SLEEP_SHORT"
}

require_deps() {
  local missing=0

  for cmd in swaymsg tmux "$TERM_APP"; do
    if ! have_cmd "$cmd"; then
      printf 'Missing command: %s\n' "$cmd" >&2
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

tmux_has_session() {
  local session="$1"
  tmux has-session -t "$session" 2>/dev/null
}

tmux_window_exists() {
  local session="$1"
  local window="$2"
  tmux list-windows -t "$session" -F '#W' 2>/dev/null | grep -Fxq "$window"
}

run_foot_tmux_attach() {
  local session="$1"
  "$TERM_APP" -e bash -lc "exec tmux new-session -A -s '$session'"
}

run_foot_tmux_in_dir_and_cmd() {
  local session="$1"
  local workdir="$2"
  local cmd="$3"

  "$TERM_APP" -e bash -lc "cd '$workdir' && exec tmux new-session -A -s '$session' '$cmd'"
}

workspace_has_foot() {
  local workspace="$1"

  swaymsg -t get_tree | jq -e --arg ws "$workspace" '
    ..
    | select(.type? == "workspace" and .name? == $ws)
    | ..
    | select(.app_id? == "foot")
  ' >/dev/null 2>&1
}

wait_for_workspace_foot_count_at_least() {
  local workspace="$1"
  local expected="$2"
  local tries=40

  while (( tries > 0 )); do
    local count
    count="$(
      swaymsg -t get_tree | jq -r --arg ws "$workspace" '
        [
          ..
          | select(.type? == "workspace" and .name? == $ws)
          | ..
          | select(.app_id? == "foot")
        ] | length
      ' 2>/dev/null || echo 0
    )"

    if [[ "${count:-0}" -ge "$expected" ]]; then
      return 0
    fi

    sleep 0.15
    tries=$((tries - 1))
  done

  return 1
}

focus_workspace() {
  local workspace="$1"
  swaymsg "workspace \"$workspace\"" >/dev/null
}

# =========================
# TMUX SESSION SETUP
# =========================

ensure_nvim_session() {
  local session="$1"
  local workdir="$2"

  if ! tmux_has_session "$session"; then
    log "creating tmux session: $session"
    tmux new-session -d -s "$session" -c "$workdir"
    tmux send-keys -t "$session" 'nvim .' C-m
  fi
}

ensure_shell_session() {
  local session="$1"
  local workdir="$2"

  if ! tmux_has_session "$session"; then
    log "creating tmux shell session: $session"
    tmux new-session -d -s "$session" -c "$workdir"
  fi
}

ensure_dev_session() {
  if ! tmux_has_session "$TMUX_DEV_SESSION"; then
    log "creating tmux dev session: $TMUX_DEV_SESSION"

    tmux new-session -d -s "$TMUX_DEV_SESSION" -n back -c "$BACK_DIR"
    tmux send-keys -t "$TMUX_DEV_SESSION":back 'docker compose up' C-m

    tmux new-window -t "$TMUX_DEV_SESSION" -n front -c "$FRONT_DIR"
    tmux send-keys -t "$TMUX_DEV_SESSION":front 'npm run dev' C-m

    tmux select-window -t "$TMUX_DEV_SESSION":back
    return
  fi

  if ! tmux_window_exists "$TMUX_DEV_SESSION" "back"; then
    log "creating missing tmux window: ${TMUX_DEV_SESSION}:back"
    tmux new-window -t "$TMUX_DEV_SESSION" -n back -c "$BACK_DIR"
    tmux send-keys -t "$TMUX_DEV_SESSION":back 'docker compose up' C-m
  fi

  if ! tmux_window_exists "$TMUX_DEV_SESSION" "front"; then
    log "creating missing tmux window: ${TMUX_DEV_SESSION}:front"
    tmux new-window -t "$TMUX_DEV_SESSION" -n front -c "$FRONT_DIR"
    tmux send-keys -t "$TMUX_DEV_SESSION":front 'npm run dev' C-m
  fi
}

ensure_tmux_sessions() {
  ensure_nvim_session "$TMUX_BACK_SESSION" "$BACK_DIR"
  ensure_nvim_session "$TMUX_FRONT_SESSION" "$FRONT_DIR"
  ensure_dev_session
  ensure_shell_session "$TMUX_SHELL_SESSION" "$HOME"
}

# =========================
# SWAY WINDOW OPENING
# =========================

open_back_workspace() {
  focus_workspace "$WS_BACK"
  sleep_short

  if workspace_has_foot "$WS_BACK"; then
    log "workspace $WS_BACK already has foot, skipping new foot"
    return
  fi

  log "opening foot on workspace $WS_BACK"
  run_foot_tmux_attach "$TMUX_BACK_SESSION" &
  disown || true
  sleep_short
}

open_front_workspace() {
  focus_workspace "$WS_FRONT"
  sleep_short

  if workspace_has_foot "$WS_FRONT"; then
    log "workspace $WS_FRONT already has foot, skipping new foot"
    return
  fi

  log "opening foot on workspace $WS_FRONT"
  run_foot_tmux_attach "$TMUX_FRONT_SESSION" &
  disown || true
  sleep_short
}

open_dev_workspace() {
  focus_workspace "$WS_DEV"
  sleep_short

  local existing_count
  existing_count="$(
    swaymsg -t get_tree | jq -r --arg ws "$WS_DEV" '
      [
        ..
        | select(.type? == "workspace" and .name? == $ws)
        | ..
        | select(.app_id? == "foot")
      ] | length
    ' 2>/dev/null || echo 0
  )"

  if [[ "${existing_count:-0}" -ge 2 ]]; then
    log "workspace $WS_DEV already has at least 2 foot windows, skipping creation"
    return
  fi

  if [[ "${existing_count:-0}" -eq 0 ]]; then
    log "opening first foot on workspace $WS_DEV"
    run_foot_tmux_attach "$TMUX_DEV_SESSION" &
    disown || true

    wait_for_workspace_foot_count_at_least "$WS_DEV" 1 || true
    sleep_short

    swaymsg 'split v' >/dev/null
    sleep 0.15

    log "opening second foot on workspace $WS_DEV"
    run_foot_tmux_attach "$TMUX_SHELL_SESSION" &
    disown || true

    wait_for_workspace_foot_count_at_least "$WS_DEV" 2 || true
    sleep_short

    # Попробуем сделать вертикальный стек: одно окно сверху, одно снизу.
    # В зависимости от твоего текущего layout иногда sway сам оставляет нужный вид.
    swaymsg 'layout splitv' >/dev/null || true
    return
  fi

  if [[ "${existing_count:-0}" -eq 1 ]]; then
    log "workspace $WS_DEV has 1 foot window, opening the second one"

    swaymsg 'split v' >/dev/null
    sleep 0.15

    run_foot_tmux_attach "$TMUX_SHELL_SESSION" &
    disown || true

    wait_for_workspace_foot_count_at_least "$WS_DEV" 2 || true
    sleep_short
    swaymsg 'layout splitv' >/dev/null || true
  fi
}

# =========================
# MAIN
# =========================

main() {
  require_deps
  ensure_tmux_sessions

  open_back_workspace
  open_front_workspace
  open_dev_workspace

  focus_workspace "$WS_BACK"
  log "done"
}

main "$@"
