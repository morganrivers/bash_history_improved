#!/bin/bash

# This script first checks if the crontab entry already exists. 
# If it doesn't, it appends the job to the crontab. If it does, it simply prints a
# message indicating that the job already exists.

# You should have placed the backup script in the /usr/local/bin/ directory,
# and made it executable with chmod +x backup_history_every_5_minutes.sh


# Path to your script
script_path="/usr/local/bin/bash_history_backup.sh backup"

# Check if the job already exists
crontab -l | grep "$script_path" &> /dev/null

if [ $? -eq 0 ]; then
  echo "Cron job already exists. No action taken."
else
  # Append new cron job
  (crontab -l; echo "*/5 * * * * $script_path") | crontab -
  echo "Cron job added."
fi
