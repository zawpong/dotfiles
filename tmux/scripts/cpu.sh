#!/usr/bin/env bash

# Cross-platform CPU usage for tmux status line.
# Prints a single value like: 37%

set -u

get_linux_cpu() {
  [ -r /proc/stat ] || return 1

  local user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1
  local user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2

  read -r _ user1 nice1 system1 idle1 iowait1 irq1 softirq1 steal1 _ < /proc/stat || return 1
  sleep 0.2
  read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 _ < /proc/stat || return 1

  local idle_total1 idle_total2 total1 total2 total_delta idle_delta used_delta usage
  idle_total1=$((idle1 + iowait1))
  idle_total2=$((idle2 + iowait2))

  total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + softirq1 + steal1))
  total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))

  total_delta=$((total2 - total1))
  idle_delta=$((idle_total2 - idle_total1))
  used_delta=$((total_delta - idle_delta))

  [ "$total_delta" -gt 0 ] || return 1

  usage=$(((100 * used_delta + total_delta / 2) / total_delta))
  [ "$usage" -lt 0 ] && usage=0
  [ "$usage" -gt 100 ] && usage=100

  printf '%s%%\n' "$usage"
}

get_macos_cpu() {
  command -v top >/dev/null 2>&1 || return 1
  command -v awk >/dev/null 2>&1 || return 1

  local line usage
  line=$(top -l 2 -n 0 2>/dev/null | awk '/CPU usage/ {latest=$0} END {print latest}')
  [ -n "$line" ] || return 1

  usage=$(printf '%s\n' "$line" | awk '
    {
      u = 0
      s = 0
      for (i = 1; i <= NF; i++) {
        if ($i == "user" || $i == "user,") {
          v = $(i - 1)
          gsub(/%/, "", v)
          gsub(/,/, ".", v)
          u = v
        }
        if ($i == "sys" || $i == "sys,") {
          v = $(i - 1)
          gsub(/%/, "", v)
          gsub(/,/, ".", v)
          s = v
        }
      }
      v = u + s
      if (v < 0) v = 0
      if (v > 100) v = 100
      printf("%.0f", v)
    }
  ')

  [ -n "$usage" ] || return 1
  printf '%s%%\n' "$usage"
}

case "$(uname -s)" in
  Linux)
    get_linux_cpu || printf 'n/a\n'
    ;;
  Darwin)
    get_macos_cpu || printf 'n/a\n'
    ;;
  *)
    printf 'n/a\n'
    ;;
esac

# ---------- CACHE LAYER ----------
CACHE="/tmp/tmux_cpu_cache"
TTL=2

now=$(date +%s)

if [ -f "$CACHE" ]; then
  last=$(stat -f %m "$CACHE" 2>/dev/null || stat -c %Y "$CACHE" 2>/dev/null)
  if [ -n "$last" ] && [ $((now - last)) -lt "$TTL" ]; then
    cat "$CACHE"
    exit 0
  fi
fi

# write cache safely
echo "$val" > "$CACHE"
