#!/usr/bin/env bash
# Linux-optimized: cache git branch for a given directory (triggered on cd)

dir="${1:-$PWD}"
key=$(printf '%s' "$dir" | md5sum)
key=${key%% *}
cache="/tmp/tmux_git_$key"

git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null || { echo "" > "$cache"; exit 0; }

branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null) || branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
echo "$branch" > "$cache"
