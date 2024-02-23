# Galaxias

## Galaxias configuration

### Auto mount a network-share
We assume you already have shared a folder on a Windows-machine on the network. 
If not, share a folder on a Windows-machine on the network.

Access the Galaxias with a terminal and create a folder called VanBreda
```
mkdir /mnt/VanBreda
```

Create a file /home/vanbreda/.vios that includes the following information
```
username={username} # Username that allows access to the Windows Network-share
password={password} # Password that allows access to the Windows Network-share
```
Give the file limited access:
```
CHMOD /home/vanbreda/.vios
```

Edit the file /etc/fstab and the following line:
```
//{Windows Network-share}/{folder}        /mnt/VanBreda   cifs    uid=asterisk,gid=asterisk,credentials=/home/vanbreda/.vios,iocharset=utf8
```
Mount the network-share
```
mount -a
```
### Configure the Galaxias Filestore
Log in to the GUI of the Galaxias and go to "Settings -> Filestore" and on the new screen that opens click on "Local" followed by "Add local path".
Enter as pathname "Backup Remote", enter any description you like and enter as path "/mnt/VanBreda" and click Submit to save.


### Configure the Galaxias Reservekopie & Terugzetten
Go to "Beheer -> Reservekopie en Terugzetten" and press the "Add backup"-button.
Enter the following:

**Basic information**

Reservekopie naam: "Backup remote"

Backup Description: none or whatever you prefer

Reservekopie onderdelen: select all modules

Custom Files:
```
folder: \__ASTETCDIR__
file: /etc/asterisk/aipunits.conf
file: /etc/sysconfig/network-scripts/ifcfg-eth0
file: /etc/sysconfig/network-scripts/ifcfg-eth1
file: /etc/sysconfig/network-scripts/route-eth0
file: /etc/sysconfig/network-scripts/route-eth1
file: /etc/hosts
file: /etc/resolv.conf
file: /etc/ntp.conf
```
**Notifications**

leave as is

**Storage**

Storage Location: select "Backup remote"

**Schedule and Maintinence**

Enabled: Yes

Scheduling: every week, 59 minute, 23 hour, monday

**Maintinence**

Delete After 5 Runs

Delete After 30 Days 


Press the "Opslaan"-button to savethe settings.




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
