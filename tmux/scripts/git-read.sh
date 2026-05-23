#!/usr/bin/env bash
# Linux-optimized: reads cached git branch, falls back to direct git if missing

dir="${1:-$PWD}"
key=$(printf '%s' "$dir" | md5sum)
key=${key%% *}
cache="/tmp/tmux_git_$key"

[ -f "$cache" ] && cat "$cache" && exit 0

git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null || exit 0
branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null) || branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
[ -n "$branch" ] && echo "$branch" > "$cache"
