#!/bin/bash

# Logfile path
logfile="/home/vanbreda/update_script.log"

# Function to log messages with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1" >> "$logfile"
}

# Execute yum update and fwconsole ma updateall
log "Starting update process..."
yum -y update >> "$logfile" 2>&1
/usr/sbin/fwconsole ma updateall >> "$logfile" 2>&1
/usr/sbin/fwconsole reload >> "$logfile" 2>&1

# Check for errors during execution
if [ $? -eq 0 ]; then
    log "Update process completed successfully."
else
    log "Error during update process. Check $logfile for details."
fi

