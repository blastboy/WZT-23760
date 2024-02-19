#!/bin/bash

source_location="//10.10.10.10/D$/Project/Zoneminder"
mount_point="/mnt/Backup"
log_file="/home/vanbreda/backup_script.log"
username="username"
password="password"

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" >> "$log_file"
}

backup() {
    # Check if the mount was successful before proceeding with copying files
    if mountpoint -q "$mount_point"; then
        log "Mount point is available. Starting backup."

        # Copy files to the mounted location if they exist
        for file in /etc/sysconfig/network-scripts/ifcfg-*; do
            if [ -e "$file" ]; then
                cp "$file" "$mount_point" && log "Copied $file to $mount_point"
            else
                log "File $file not found. Skipped."
            fi
        done

        for file in /etc/sysconfig/network-scripts/route-*; do
            if [ -e "$file" ]; then
                cp "$file" "$mount_point" && log "Copied $file to $mount_point"
            else
                log "File $file not found. Skipped."
            fi
        done

        if [ -e "/etc/netplan/00-installer-config.yaml" ]; then
            cp "/etc/netplan/00-installer-config.yaml" "$mount_point" && log "Copied /etc/netplan/00-installer-config.yaml to $mount_point"
        else
            log "File /etc/netplan/00-installer-config.yaml not found. Skipped."
        fi

        if [ -e "/etc/hosts" ]; then
            cp "/etc/hosts" "$mount_point" && log "Copied /etc/hosts to $mount_point"
        else
            log "File /etc/hosts not found. Skipped."
        fi

        if [ -e "/etc/resolv.conf" ]; then
            cp "/etc/resolv.conf" "$mount_point" && log "Copied /etc/resolv.conf to $mount_point"
        else
            log "File /etc/resolv.conf not found. Skipped."
        fi

        if [ -e "/etc/ntp.conf" ]; then
            cp "/etc/ntp.conf" "$mount_point" && log "Copied /etc/ntp.conf to $mount_point"
        else
            log "File /etc/ntp.conf not found. Skipped."
        fi

        mysqldump --user=root --databases zm > "$mount_point/backup.SQL" && log "Mysqldump completed. Backup successful."
    else
        log "Error: Mount point not available. Files and database not backed up."
    fi
}

# Check if the mount point is already mounted
if ! mountpoint -q "$mount_point"; then
    log "Mount point is not already mounted. Attempting to mount."
    mount -t cifs -o username="$username",password="$password" "$source_location" "$mount_point" && log "Mount successful."
    backup
else
    log "Mount point is already mounted."
    backup
fi
