#!/usr/bin/env bash
set -Eeuo pipefail

KITTY_MAIN="$HOME/.config/kitty/kitty.conf"
KITTY_NVIM="$HOME/.config/kitty/kitty-nvim.conf"

# Безопасная проверка переменной окружения (даже если её нет)
SOCKET=$(printf '%s\n' "${KITTY_LISTEN_ON-}" | grep -E '^unix:' || true)

# Если не нашли сокет, попробуем достать любой активный из kitty @ ls
if [[ -z "$SOCKET" ]]; then
  SOCKET=$(kitty @ ls 2>/dev/null | grep -oE '"unix:[^"]+' | head -n1 || true)
fi

# Если нашли — временно переключаем конфиг
if [[ -n "$SOCKET" ]]; then
  kitty @ --to "$SOCKET" load-config "$KITTY_NVIM" || true
fi

# Запускаем Neovim
nvim "$@"

# После выхода возвращаем основной конфиг
if [[ -n "$SOCKET" ]]; then
  kitty @ --to "$SOCKET" load-config "$KITTY_MAIN" || true
fi
