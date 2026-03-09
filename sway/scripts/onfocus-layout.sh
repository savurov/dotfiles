#!/usr/bin/env bash
set -euo pipefail

# Требуется jq: sudo dnf install jq  (или apt/pacman по твоей системе)
THROTTLE_MS="${THROTTLE_MS:-250}"  # минимальный интервал между срабатываниями

get_ms() { date +%s%3N; }         # миллисекунды (GNU date)

# Переключаем раскладку на 0 только если сейчас не 0
switch_to_zero_if_needed() {
  # смотрим первый клавиатурный девайс
  cur_idx="$(swaymsg -r -t get_inputs | jq -r '[.[]|select(.type=="keyboard")][0].xkb_active_layout_index // -1')"
  if [ "$cur_idx" != "0" ]; then
    swaymsg -q input type:keyboard xkb_switch_layout 0
  fi
}

last_ts=0
# Подписка на события окон и фильтр только по смене фокуса
swaymsg -t subscribe -m '["window"]' \
| jq --unbuffered -r 'select(.change=="focus") | .container.id' \
| while read -r _; do
    now="$(get_ms)"
    # Дебаунс: игнорируем события, если прошло меньше THROTTLE_MS
    if (( now - last_ts < THROTTLE_MS )); then
      continue
    fi
    last_ts="$now"
    switch_to_zero_if_needed
  done

