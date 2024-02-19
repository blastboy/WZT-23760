#!/bin/bash

# Logfile path
logfile="/home/vanbreda/update_script.log"

# Function to log messages with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1" >> "$logfile"
}

# Execute yum update and fwconsole ma updateall
log "Starting update process..."
sudo apt-mark hold zoneminder* >> "$logfile" 2>&1
apt-get update -y >> "$logfile" 2>&1
apt-get upgrade -y >> "$logfile" 2>&1
#apt-get dist-upgrade -y >> "$logfile" 2>&1

# Check for errors during execution
if [ $? -eq 0 ]; then
    log "Update process completed successfully."
else
    log "Error during update process. Check $logfile for details."
fi
