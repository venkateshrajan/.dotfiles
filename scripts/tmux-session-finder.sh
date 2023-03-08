#!/bin/bash
name=$(tmux ls -F '#{session_attached},#{session_activity},#{session_name}' | sort -r | sed '/^$/d' | cut -d',' -f3- | fzf --reverse --header jump-to-session --preview 'tmux capture-pane -pt {}')
tmux a -t "$name"
