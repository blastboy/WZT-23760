# Galaxias

## galaxias_update.sh
This script has the posibility to create a cronjob and run update tasks on a Galaxias-machine.

Before running this script you should check the content of the script and make changes if necessary
```
logfile="/home/vanbreda/galaxias_update.log"    # This is the location of the log-file

# Set date and time formats
execute_date="19-02-2024"    # Date format is dd-mm-yyyy
execute_time="07:30"         # Time format is hh:mm
```

The script should be run as root and should be run with the following arguments:
```
-install      Setup a cronjob that executes the script with the argument -automated
-update       Update Sangoma Linux and FreePBX modules
-automated    Update Sangoma Linux and FreePBX modules on the specified day
-uninstall    Remove the cronjob for automated execution
-help         Display this text
```
