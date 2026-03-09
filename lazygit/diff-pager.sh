#!/usr/bin/env sh
set -eu

if command -v delta >/dev/null 2>&1; then
  exec delta \
    --paging=never \
    --side-by-side \
    --line-numbers \
    --navigate \
    --hyperlinks \
    --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'
fi

exec cat
