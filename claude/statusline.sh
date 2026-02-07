#!/bin/bash

# Claude Code status line script
# Displays: directory, git branch, time, model, context remaining

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')

current_time=$(date +"%H:%M")

# Git branch
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

# Shorten directory (replace $HOME with ~)
short_cwd="${cwd/#$HOME/\~}"

# Color helpers
rst=$(printf '\033[0m')
dim=$(printf '\033[90m')
blue=$(printf '\033[34m')
yellow=$(printf '\033[33m')
green=$(printf '\033[32m')
cyan=$(printf '\033[36m')
magenta=$(printf '\033[35m')
red=$(printf '\033[31m')
sep=" ${dim}│${rst} "

parts=()

# Vim mode
[ -n "$vim_mode" ] && parts+=("${cyan}${vim_mode}${rst}")

# Agent name
[ -n "$agent_name" ] && parts+=("${magenta}${agent_name}${rst}")

# Directory
parts+=("${blue}${short_cwd}${rst}")

# Git branch
[ -n "$git_branch" ] && parts+=("${yellow}⎇ ${git_branch}${rst}")

# Model
parts+=("${cyan}${model}${rst}")

# Context remaining (color-coded)
if [ -n "$remaining" ]; then
    remaining_int="${remaining%.*}"
    if [ "$remaining_int" -lt 20 ] 2>/dev/null; then
        color="$red"
    elif [ "$remaining_int" -lt 50 ] 2>/dev/null; then
        color="$yellow"
    else
        color="$green"
    fi
    parts+=("${color}ctx:${remaining_int}%${rst}")
fi

# Time
parts+=("${dim}${current_time}${rst}")

# Join with separator
output="${parts[0]}"
for ((i=1; i<${#parts[@]}; i++)); do
    output+="${sep}${parts[$i]}"
done
printf "%s\n" "$output"
