#!/usr/bin/env sh
set -eu

if command -v delta >/dev/null 2>&1; then
  exec delta \
    --paging=never \
    --line-numbers \
    --hyperlinks \
    --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'
fi

exec cat
