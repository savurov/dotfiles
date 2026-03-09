#!/usr/bin/env bash
set -euo pipefail

read -r used_mb total_mb <<<"$(free -m | awk '/^Mem:/ {print $3, $2}')"
if [[ -z "${used_mb:-}" || -z "${total_mb:-}" || "$total_mb" -eq 0 ]]; then
  used_mb=0
  total_mb=1
fi

used_gib=$(awk -v m="$used_mb" 'BEGIN { printf "%.1f", m/1024 }')

rows="$(ps -eo pid=,comm=,rss=,args= --sort=-rss | head -n 5 | awk '
function human(kib, u, v, i) {
  split("KiB MiB GiB TiB", u, " ")
  v = kib + 0
  i = 1
  while (v >= 1024 && i < 4) {
    v /= 1024
    i++
  }
  if (v >= 10 || i == 1) {
    return sprintf("%.0f %s", v, u[i])
  }
  return sprintf("%.1f %s", v, u[i])
}
function short(s, n) {
  if (length(s) <= n) {
    return s
  }
  return substr(s, 1, n - 1) "…"
}
function chrome_detail(args, out, m) {
  out = "browser"
  if (match(args, /--type=[^ ]+/)) {
    out = substr(args, RSTART + 7, RLENGTH - 7)
  }
  if (match(args, /--utility-sub-type=[^ ]+/)) {
    m = substr(args, RSTART + 19, RLENGTH - 19)
    gsub(/\.mojom\.[^ ]+$/, "", m)
    out = out ":" m
  }
  if (match(args, /--extension-process/)) {
    out = out ":extension"
  }
  if (match(args, /--app=[^ ]+/)) {
    out = out ":app"
  }
  return out
}
function detail(comm, args) {
  if (comm == "chrome") {
    return chrome_detail(args)
  }
  if (comm == "WebKitWebProces") {
    return "webkit-web"
  }
  return comm
}
{
  line = $0
  d = detail($2, line)
  if (d == $2) {
    d = ""
  }
  sub(/^[[:space:]]*[0-9]+[[:space:]]+[^[:space:]]+[[:space:]]+[0-9]+[[:space:]]+/, "", line)
  printf "%5s  %-18.18s  %8s  %-30.30s\n", $1, $2, human($3), short(d, 30)
}')"

tooltip=$(printf "Top 5 RAM processes\\nPID    NAME                  RSS  DETAIL\\n%s" "$rows")
text=" ${used_gib}G"

jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip, class: "memory"}'
