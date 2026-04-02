#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
line="${2:-}"

if [[ -z "$file" ]]; then
  exit 1
fi

vim_quote() {
  printf "%s" "$1" | sed "s/'/''/g"
}

open_in_running_nvim() {
  local server="${LAZYGIT_NVIM_SERVER:-${NVIM:-}}"
  local file_quoted open_expr

  [[ -n "$server" ]] || return 1

  file_quoted="$(vim_quote "$file")"

  nvim --server "$server" --remote-expr "execute(\"if winnr('\$') > 1 | close | endif\")" >/dev/null 2>&1 || return 1

  open_expr="execute('drop ' . fnameescape('${file_quoted}')"
  if [[ "$target_line" =~ ^[0-9]+$ ]] && (( target_line > 0 )); then
    open_expr="${open_expr} . ' | call cursor(${target_line}, 1) | normal! zz'"
  fi
  open_expr="${open_expr})"

  nvim --server "$server" --remote-expr "$open_expr" >/dev/null 2>&1
}

pick_line_from_diff() {
  local f="$1"
  (
    git diff --unified=0 -- "$f" 2>/dev/null
    git diff --cached --unified=0 -- "$f" 2>/dev/null
  ) | awk '
    function trim(x) { gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
    BEGIN { n = 0; found = 0 }
    /^@@ / {
      if (match($0, /\+([0-9]+)/, m)) n = m[1]
      next
    }
    /^\+\+\+ / || /^--- / { next }
    /^[ +-]/ {
      p = substr($0, 1, 1)
      t = trim(substr($0, 2))

      if (p == "+") {
        if (!found && t != "" && t !~ /^#/ && t !~ /^(from|import)[ \t]/) {
          print n
          found = 1
          exit
        }
        n++
        next
      }

      if (p == " ") {
        n++
        next
      }

      if (p == "-") {
        if (!found && t != "" && t !~ /^#/ && t !~ /^(from|import)[ \t]/) {
          print n
          found = 1
          exit
        }
      }
    }
    END {
      if (!found && n > 0) print n
    }
  '
}

target_line=""
if [[ "$line" =~ ^[0-9]+$ ]] && (( line > 0 )); then
  target_line="$line"
else
  target_line="$(pick_line_from_diff "$file" | head -n1 || true)"
fi

if [[ "$target_line" =~ ^[0-9]+$ ]] && (( target_line > 0 )); then
  open_in_running_nvim && exit 0
  nvr --remote-wait-silent -cc "if winnr('$') > 1 | close | endif" +"$target_line" "$file" || nvim +"$target_line" "$file"
else
  open_in_running_nvim && exit 0
  nvr --remote-wait-silent -cc "if winnr('$') > 1 | close | endif" "$file" || nvim "$file"
fi
