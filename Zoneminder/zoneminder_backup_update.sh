#!/bin/bash

# Variables for date and time
execute_date="19-02-2024"                        # Date format is dd-mm-yyyy
execute_time_backup="06:00"                      # Time format is hh:mm
execute_time_update="12:30"                      # Time format is hh:mm

# Logfile path for the main script
log_file="/home/vanbreda/zoneminder_backup_update.log"      # This is the location of the log-file

# Mounting info
source_location="//10.10.10.10/VanBreda/"        # A shared folder on a Windows-machine
mount_point="/mnt/VanBreda"                      # The mounted location on the Zoneminder-machine
destination_folder="Zoneminder1"                 # Modify this with the desired destination folder

# Create a file .zoneminder_backup_update that contains:
# username="username"                              # The username of the Windows-machine
# password="password"                              # The password of the user of Windows-machine
# chmod 600 .zoneminder_backup_update
source .zoneminder_backup_update

# Extracting hour and minute separately with leading zeros
hour_backup=$(date -d "$execute_time_backup" '+%H')
minute_backup=$(date -d "$execute_time_backup" '+%M')

hour_update=$(date -d "$execute_time_update" '+%H')
minute_update=$(date -d "$execute_time_update" '+%M')

# Function to log messages with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1" >> "$log_file"
}

# Function to display help text
display_help() {
    echo "Zoneminder Backup/Update script"
    echo ""
    echo "zoneminder_update_backup.sh usage:"
    echo "-install              Setup cronjobs that executes the script with the argument -automated_backup and -automated_update"
    echo "-backup               Backup Zoneminder-settings to the Network-share"
    echo "-update               Update the Zoneminder OS, excluding Zoneminder itself"
    echo "-automated_backup     Backup Zoneminder-settings to the Network-share on the specified day"
    echo "-automated_update     Update the Zoneminder OS, excluding Zoneminder itself, on the specified day"
    echo "-uninstall            Remove the cronjob for automated execution"
    echo "-help                 Display this text"
}

# Function for backup
# Function for backup
backup() {
    log "Mounting backup location..."

	# Create mount point if it doesn't exist
	if [ ! -d "$mount_point" ]; then
		log "Mount point does not exist. Creating $mount_point."
		mkdir -p "$mount_point"
	else
		log "Mount point already exists."
	fi

	# Check if the mount point is already mounted
	if ! mountpoint -q "$mount_point"; then
		log "Mount point is not already mounted. Attempting to mount."
		mount -t cifs -o username="$username",password="$password" "$source_location" "$mount_point" && log "Mount successful."
	else
		log "Mount point is already mounted."
	fi

	# Create destination folder if it doesn't exist
	if [ ! -d "$mount_point/$destination_folder" ]; then
		log "Destination folder does not exist. Creating $destination_folder."
		mkdir -p "$mount_point/$destination_folder"
	else
		log "Destination folder already exists."
	fi

    # Set the destination folder for copying and exporting files
    dest_folder="$mount_point/$destination_folder"

    # Check if the mount was successful before proceeding with copying files
    if mountpoint -q "$mount_point"; then
        log "Mount point is available. Starting backup."

        # Copy files to the mounted location if they exist
        for file in /etc/sysconfig/network-scripts/ifcfg-*; do
            if [ -e "$file" ]; then
                cp "$file" "$dest_folder" && log "Copied $file to $dest_folder"
            else
                log "File $file not found. Skipped."
            fi
        done

        for file in /etc/sysconfig/network-scripts/route-*; do
            if [ -e "$file" ]; then
                cp "$file" "$dest_folder" && log "Copied $file to $dest_folder"
            else
                log "File $file not found. Skipped."
            fi
        done

        if [ -e "/etc/netplan/00-installer-config.yaml" ]; then
            cp "/etc/netplan/00-installer-config.yaml" "$dest_folder" && log "Copied /etc/netplan/00-installer-config.yaml to $dest_folder"
        else
            log "File /etc/netplan/00-installer-config.yaml not found. Skipped."
        fi

        if [ -e "/etc/hosts" ]; then
            cp "/etc/hosts" "$dest_folder" && log "Copied /etc/hosts to $dest_folder"
        else
            log "File /etc/hosts not found. Skipped."
        fi

        if [ -e "/etc/resolv.conf" ]; then
            cp "/etc/resolv.conf" "$dest_folder" && log "Copied /etc/resolv.conf to $dest_folder"
        else
            log "File /etc/resolv.conf not found. Skipped."
        fi

        if [ -e "/etc/ntp.conf" ]; then
            cp "/etc/ntp.conf" "$dest_folder" && log "Copied /etc/ntp.conf to $dest_folder"
        else
            log "File /etc/ntp.conf not found. Skipped."
        fi

        mysqldump --user=root --databases zm > "$dest_folder/backup.SQL" && log "Mysqldump completed. Backup successful."
    else
        log "Error: Mount point not available. Files and database not backed up."
    fi
}

# Function for update
update() {
    log "Starting update process..."

    # Logfile path for the update script
    logfile="/home/vanbreda/update_script.log"

    # Function to log messages with timestamps
    log_update() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1" >> "$logfile"
    }

    # Execute yum update and fwconsole ma updateall
    log_update "Executing update process..."
    sudo apt-mark hold zoneminder* >> "$logfile" 2>&1
    apt-get update -y >> "$logfile" 2>&1
    apt-get upgrade -y >> "$logfile" 2>&1
    #apt-get dist-upgrade -y >> "$logfile" 2>&1

    # Check for errors during execution
    if [ $? -eq 0 ]; then
        log_update "Update process completed successfully."
    else
        log_update "Error during update process. Check $logfile for details."
    fi
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    log "Error: This script must be run as root. Exiting."
    exit 1
fi

# Check script arguments
case "$1" in
    -install)
        # Check if date and time variables are set and in the correct format
        if [[ "$execute_date" == "dd-mm-yyyy" || "$execute_time_backup" == "hh:mm" || "$execute_time_update" == "hh:mm" ]]; then
            log "Error: Please set valid values for execute_date, execute_time_backup, and execute_time_update before installing."
            exit 1
        fi

        # Check if execute_time_backup is before execute_time_update
        if [ "$hour_backup" -ge "$hour_update" ] || ([ "$hour_backup" -eq "$hour_update" ] && [ "$minute_backup" -ge "$minute_update" ]); then
            log "Error: Backup time should be set before update time. Exiting."
            exit 1
        fi

        # Get the script location
        script_location="$(readlink -f "$0")"

        # Create cronjobs
        (crontab -l 2>/dev/null; echo "$minute_backup $hour_backup * * * $script_location -automated_backup") | sort - | uniq - | crontab -
        (crontab -l 2>/dev/null; echo "$minute_update $hour_update * * * $script_location -automated_update") | sort - | uniq - | crontab -

        log "Cronjobs for automated backup and update installed successfully."
        ;;

    -automated_backup)
        # Check if execute_date is the current date
        if [ "$(date '+%d-%m-%Y')" != "$execute_date" ]; then
            log "Not the specified execution date. Exiting."
            exit 0
        fi

        # Run backup function
        backup
        ;;

    -automated_update)
        # Check if execute_date is the current date
        if [ "$(date '+%d-%m-%Y')" != "$execute_date" ]; then
            log "Not the specified execution date. Exiting."
            exit 0
        fi

        # Run update function
        update
        ;;

    -backup)
        # Run backup function
        backup
        ;;

    -update)
        # Run update function
        update
        ;;

    -uninstall)
        log "Uninstalling cronjobs..."
		echo "Your current cronjobs will be deleted"
		echo "A backup will be saved to /home/vanbreda/root_cronjobs.txt"
        crontab -l
		crontab -l > /home/vanbreda/root_cronjobs.txt
		log "Cronjobs saved to /home/vanbreda/root_cronjobs.txt"
		# Remove existing cronjobs
        crontab -r
        log "Cronjobs uninstalled successfully."
        ;;

    -help)
        display_help
        ;;

    "")
        # No argument provided, display help text
        display_help
        exit 1
        ;;

    *)
        log "Error: Invalid argument. Use -help for usage instructions."
        exit 1
        ;;
esac
