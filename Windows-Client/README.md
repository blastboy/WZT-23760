# INEX

## backup_update.bat
This script has the ability to create Scheduled tasks to back-up and update INEX-machines.
It can also run the tasks without a schedule. It will create back-ups on the another server and it will run Windows Update through the WSUS Offline Community Edtion.

Before running this script you should check the content of the script and make changes if necessary.
```
set LogFile=C:\VBZ\tools\backup_update.log

set NetworkShare=\\10.10.10.10\VanBreda
set NetworkUsername=username
set NetworkPassword=password

set ExecuteDate=22-02-2024
set ExecuteBackupTime=12:00
set ExecuteUpdateTime=15:00

set TaskFolder=VanBreda

set WSUSUpdatePath=P:\WSUS_Offline\Update.cmd
```

The script should be run as Administrator and should be run with the following arguments:
```
-install              Create Windows Task Scheduler tasks executing the back-up and update commands on a certain date
-backup               Run the back-up tasks
-update               Run the update command
-uninstall            Remove the schedule tasks from Task Scheduler
```
