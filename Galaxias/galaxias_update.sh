#!/bin/bash

# Logfile path
logfile="/home/vanbreda/galaxias_update.log"    # This is the location of the log-file

# Set date and time formats
execute_date="19-02-2024"    # Date format is dd-mm-yyyy
execute_time="07:30"         # Time format is hh:mm

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to log messages with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1" >> "$logfile"
}

# Display help text
if [[ $# -eq 0 || "$1" == "-help" ]]; then
    echo "Galaxias update script"
    echo ""
    echo "galaxias_update.sh usage:"
    echo "-install      Setup a cronjob that executes the script with the argument -automated"
    echo "-update       Update Sangoma Linux and FreePBX modules"
    echo "-automated    Update Sangoma Linux and FreePBX modules on the specified day"
    echo "-uninstall    Remove the cronjob for automated execution"
    echo "-help         Display this text"
    exit 0
fi

# Check arguments
if [ "$1" == "-install" ]; then
    # Check if execute_date and execute_time are set and in compliance with the format
    if [[ $execute_date == "dd-mm-yyyy" || $execute_time == "hh:mm" ]]; then
        echo "Error: execute_date or execute_time not set. Update the script with the desired values."
        exit 1
    fi

    # Get script location
    script_location="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Extract minute and hour values from execute_time
    minute=$(date -d "$execute_time" '+%M')
    hour=$(date -d "$execute_time" '+%H')

    # Create cronjob for automated execution
    cron_command="$minute $hour * * * $script_location/$(basename $0) -automated"
    (crontab -l 2>/dev/null; echo "$cron_command") | sort | uniq | crontab -
    log "Cronjob for automated execution created: $cron_command"
    exit 0
elif [ "$1" == "-update" ]; then
    log "Starting update process..."
    yum -y update >> "$logfile" 2>&1
    /usr/sbin/fwconsole ma updateall --force >> "$logfile" 2>&1
    /usr/sbin/fwconsole reload >> "$logfile" 2>&1
elif [ "$1" == "-automated" ]; then
    if [ "$execute_date" == "$(date '+%d-%m-%Y')" ]; then
        log "Automated update for today. Executing update commands."
        # Execute update commands
        /usr/sbin/fwconsole ma updateall --force >> "$logfile" 2>&1
        /usr/sbin/fwconsole reload >> "$logfile" 2>&1
    else
        log "Automated update not scheduled for today."
    fi
elif [ "$1" == "-uninstall" ]; then
    # Remove cronjob for automated execution
    (crontab -l 2>/dev/null | grep -v "$script_location/$(basename $0) -automated") | crontab -
    log "Cronjob for automated execution removed."
    exit 0
else
    echo "Invalid argument: $1. Use -help for usage information."
    exit 1
fi
