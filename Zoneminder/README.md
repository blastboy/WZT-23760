# Zoneminder

## zoneminder_backup_update.sh
This script has the posibility to create a cronjob and run backup and update tasks on a Zoneminder-machine.

Before running this script you should check the content of the script and make changes if necessary.
Save the file as /home/vanbreda/zoneminder_backup_update.sh and make it executable (`CHMOD +x /home/vanbreda/zoneminder_backup_update.sh`)
```
execute_date="19-02-2024"        # Date format is dd-mm-yyyy
execute_time_backup="06:00"      # Time format is hh:mm
execute_time_update="12:30"      # Time format is hh:mm

log_file="/home/vanbreda/backup_script.log    # This is the location of the log-file

source_location="//10.23.10.11/C$/Backup/Zoneminder"  # A shared folder on a Windows-machine
mount_point="/mnt/Backup"                             # The mounted location on the Zoneminder-machine
username="username"                                   # The username of the Windows-machine
password="password"                                   # The password of the user of Windows-machine
```

The script should be run as root and should be run with the following arguments:
```
-install              Setup cronjobs that executes the script with the argument -automated_backup and -automated_update
-backup               Backup Zoneminder-settings to the Network-share
-update               Update the Zoneminder OS (excluding Zoneminder itself)
-automated_backup     Backup Zoneminder-settings to the Network-share on the specified day
-automated_update     Update the Zoneminder OS (excluding Zoneminder itself) on the specified day
-uninstall            Remove the cronjob for automated execution
-help                 Display this text
```

## backup_script.sh_old
Depricated

## update_script.sh_old
Depricated
