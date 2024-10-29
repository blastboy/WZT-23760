# Zoneminder

## configuring zoneminder_backup_update.sh
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
```

## configuring .zoneminder_backup_update
The username and password have been taken out of the script and should be stored in .zoneminder_backup_update and CHMOD 600 should be applied to that file.
```
username="username"                                   # The username of the Windows-machine
password="password"                                   # The password of the user of Windows-machine
```

## executing zoneminder_backup_update.sh
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

## backup/backup_script.sh_old
Depricated

## backup/update_script.sh_old
Depricated

## Installation

Step 1: Save the Script

    Create a Directory for the Script (Optional):

    bash

mkdir -p /home/vanbreda/scripts
cd /home/vanbreda/scripts

Create the Script File:

bash

nano zoneminder_backup_update.sh

Paste the Script:

    Copy the updated script provided above and paste it into the nano editor.

Save and Exit:

    Press Ctrl + O to save.
    Press Enter to confirm the filename.
    Press Ctrl + X to exit.

Make the Script Executable:

bash

    chmod 700 zoneminder_backup_update.sh

Step 2: Securely Set the Encryption Key

The script uses an environment variable ZONEMINDER_ENCRYPTION_KEY to securely handle the encryption key. We need to set this variable in a way that it's available to the script when run manually and via cron.
Option 1: Set the Environment Variable in the Root User's Profile

    Edit the Root User's Bash Profile:

    bash

nano /root/.bash_profile

Add the Environment Variable:

bash

export ZONEMINDER_ENCRYPTION_KEY="YourStrongEncryptionKey"

    Replace "YourStrongEncryptionKey" with a strong, unique key (avoid using quotes in the key itself).
    Important: Ensure the key is complex and not easily guessable.

Save and Exit:

    Press Ctrl + O, Enter, then Ctrl + X.

Secure the Bash Profile File:

bash

chmod 600 /root/.bash_profile

Reload the Profile:

bash

    source /root/.bash_profile

Option 2: Set the Environment Variable Directly in Cron Jobs

If you prefer to avoid setting the variable globally, you can set it directly in the cron job entries. This is especially useful for automated runs.
Step 3: Run the Script Manually for the First Time

    Navigate to the Script Directory:

    bash

cd /home/vanbreda/scripts

Run the Script with an Argument (e.g., -backup):

bash

./zoneminder_backup_update.sh -backup

Enter Credentials:

    The script will detect that .zoneminder_backup_update does not exist and will prompt you to enter the username and password.

mathematica

    Credentials file not found. Please enter your credentials.
    Enter username: your_username
    Enter password: (input will be hidden)
    Encrypted credentials file created.

        Note: The credentials are encrypted using the encryption_key you've set.

    Script Execution:
        The script will proceed to perform the backup operation.

Step 4: Verify the Encrypted Credentials File

    Check the Encrypted File:

    bash

ls -l .zoneminder_backup_update

    Ensure the file exists and has permissions set to 600.

Verify Permissions:

bash

    chmod 600 .zoneminder_backup_update

Step 5: Install Cron Jobs for Automation

If you want the script to run automatically at specified times, you can install the cron jobs.

    Run the Install Argument:

    bash

./zoneminder_backup_update.sh -install

Cron Jobs Installation:

    The script will create cron jobs for automated backup and update based on the execute_time_backup and execute_time_update variables.

Ensure the Environment Variable is Available to Cron:

    Since cron jobs have a limited environment, you need to ensure that the ZONEMINDER_ENCRYPTION_KEY is available to the cron jobs.

    Option 1: Modify the cron jobs to include the environment variable.
        The script already includes the environment variable in the cron job entries:

    bash

(crontab -l 2>/dev/null; echo "$minute_backup $hour_backup * * * ZONEMINDER_ENCRYPTION_KEY=$ZONEMINDER_ENCRYPTION_KEY $script_location -automated_backup") | crontab -

    This ensures that when the cron job runs, the ZONEMINDER_ENCRYPTION_KEY is set.

Option 2: Set the environment variable at the top of the crontab.

    Edit the crontab:

    bash

crontab -e

Add the following line at the top:

bash

            ZONEMINDER_ENCRYPTION_KEY=YourStrongEncryptionKey

            Ensure this matches the key you've set earlier.

Step 6: Test the Cron Jobs

    List the Cron Jobs to Verify:

    bash

crontab -l

    You should see entries similar to:

javascript

ZONEMINDER_ENCRYPTION_KEY=YourStrongEncryptionKey
0 6 * * * /home/vanbreda/scripts/zoneminder_backup_update.sh -automated_backup
30 12 * * * /home/vanbreda/scripts/zoneminder_backup_update.sh -automated_update

Check Cron Logs (Optional):

    Verify that the cron jobs are executing as expected by checking system logs or adding additional logging within the script.