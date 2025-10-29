#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG="$HOME/.config/sway/brightness/presets.json"
STORE="$HOME/.config/sway/brightness/store.json"
LOCK="$HOME/.config/sway/brightness/.lock"
DEBOUNCE_FILE="$HOME/.config/sway/brightness/.time"
DEBOUNCE_MS=120 # anti-spam interval
BUS1=1          # ASUS VZ24EHE
BUS2=2          # ASUS VA24EHF
SLEEP=0.06      # short pause between VCP commands

export DDCUTIL_SLEEP_MULTIPLIER=1.0 # no internal slowdown

# ---------- helpers ----------
ms_now() { date +%s%3N 2>/dev/null || echo $(($(date +%s) * 1000)); }
read_mode() { jq -r '.mode // "0"' "$STORE" 2>/dev/null || echo 0; }
write_mode() { jq -n --arg m "$1" '{"mode":$m}' >"$STORE"; }

# ---------- DDC guards ----------
wait_i2c_ready() {
  local t=0
  while ! ls /dev/i2c-* >/dev/null 2>&1; do
    ((t++ > 40)) && return 1
    sleep 0.2
  done
}

wait_ddc_ready() {
  local bus="$1" tries=30
  while ((tries-- > 0)); do
    if ddcutil --bus="$bus" getvcp 0x10 >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.3
  done
  echo "⚠️  bus $bus not responding to DDC, skipping" >&2
  return 1
}

vcp_set() {
  ddcutil --bus="$1" setvcp "$2" "$3" --noverify >/dev/null 2>&1
  sleep "$SLEEP"
}

apply_mode() {
  local m="$1"
  local b1 c1 b2 c2
  readarray -t vals < <(jq -r --arg m "$m" '
    [.modes[$m]["1"].b, .modes[$m]["1"].c,
     .modes[$m]["2"].b, .modes[$m]["2"].c] | @tsv' "$CONFIG")
  IFS=$'\t' read -r b1 c1 b2 c2 <<<"${vals[0]}"

  wait_i2c_ready || {
    echo "no i2c buses"
    return 1
  }
  wait_ddc_ready "$BUS1" || return
  wait_ddc_ready "$BUS2" || return

  # run both monitors in parallel, but sequential inside each
  (
    vcp_set "$BUS1" 0x10 "$b1"
    vcp_set "$BUS1" 0x12 "$c1"
  ) &
  (
    vcp_set "$BUS2" 0x10 "$b2"
    vcp_set "$BUS2" 0x12 "$c2"
  ) &
  wait
}

main() {
  mkdir -p "$(dirname "$STORE")"
  exec 9>"$LOCK"
  flock -n 9 || exit 0

  local now last delta
  now=$(ms_now)
  if [[ -f "$DEBOUNCE_FILE" ]]; then
    last=$(<"$DEBOUNCE_FILE" || echo 0)
    delta=$((now - last))
    ((delta < DEBOUNCE_MS)) && exit 0
  fi
  echo "$now" >"$DEBOUNCE_FILE"

  local arg="${1:-}" mode new
  [[ -z "$arg" ]] && {
    echo "Usage: $0 <mode|up|down|current>"
    exit 2
  }

  mode=$(read_mode)
  case "$arg" in
  up) new=$((mode < 9 ? mode + 1 : 9)) ;;
  down) new=$((mode > 0 ? mode - 1 : 0)) ;;
  current) new="$mode" ;;
  *) new="$arg" ;;
  esac
  [[ "$new" == "$mode" && "$arg" != "current" ]] && exit 0

  apply_mode "$new"
  write_mode "$new"
}

main "$@"
