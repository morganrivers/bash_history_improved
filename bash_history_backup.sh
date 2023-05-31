#!/bin/bash

backup_script_location="/usr/local/bin"
backup_file="$HOME/.bash_history_backup"

case "$1" in
    backup|restore)
        if [ -f "$HOME/.bash_history" ]; then
            if [ -f "$backup_file" ]; then
                current_history_lines=$(wc -l < "$HOME/.bash_history")
                backup_history_lines=$(wc -l < "$backup_file")

                if [ "$backup_history_lines" -gt "$current_history_lines" ]; then
                    cp "$backup_file" "$HOME/.bash_history"
                elif [ "$current_history_lines" -gt "$backup_history_lines" ]; then
                    cp "$HOME/.bash_history" "$backup_file"
                fi
            else
                cp "$HOME/.bash_history" "$backup_file"
            fi
        else
            touch "$HOME/.bash_history"
            if [ -f "$backup_file" ]; then
                cp "$backup_file" "$HOME/.bash_history"
            else
                touch "$backup_file"
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        exit 1
        ;;
esac
