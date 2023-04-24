#!/bin/bash

dmrivers_home="/home/dmrivers"
backup_file="$dmrivers_home/.bash_history_backup"

case "$1" in
    backup|restore)
        if [ -f "$backup_file" ]; then
            current_history_lines=$(wc -l < "$dmrivers_home/.bash_history")
            backup_history_lines=$(wc -l < "$backup_file")
	    echo "current history lines"
	    echo $current_history_lines
            echo "backup history lines"
            echo $backup_history_lines

            if [ "$backup_history_lines" -gt "$current_history_lines" ]; then
                cp "$backup_file" "$dmrivers_home/.bash_history"
            elif [ "$current_history_lines" -gt "$backup_history_lines" ]; then
                cp "$dmrivers_home/.bash_history" "$backup_file"
            fi
        else
            cp "$dmrivers_home/.bash_history" "$backup_file"
        fi
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        exit 1
        ;;
esac
