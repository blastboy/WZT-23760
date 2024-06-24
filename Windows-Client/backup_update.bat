@echo off
set LogFile=C:\VBZ\tools\backup_update.log

:: Run Locally or Remotely
:: When set to 0 the files are copied to the Network Drive, when set to 1 the files are copied to the LocalFolder
set RunLocally=0
set LocalFolder=D:\Backups\VanBreda

:: Network Drive Credentials (this will become network drive P:)
set NetworkShare=\\10.10.10.10\VanBreda
set NetworkUsername=username
set NetworkPassword=password

:: Scheduled Task Variables (dd-mm-yyyy format)
set ExecuteDate=22-02-2024
set ExecuteBackupTime=12:00
set ExecuteUpdateTime=15:00

:: Task Scheduler Folder
set TaskFolder=VanBreda

:: WSUS Offline Update Path
set WSUSUpdatePath=P:\WSUS_Offline\Update.cmd

:: Check for administrative rights
>nul 2>&1 net session && (
    echo %date% %time% - Running with administrative rights >> %LogFile%
) || (
    echo %date% %time% - ERROR: This script requires administrative rights >> %LogFile%
    exit /b 1
)

:: Check if the network drive is already mapped (only if RunLocally is 0)
if %RunLocally%==0 (
    >nul 2>&1 net use P: && (
        echo %date% %time% - Network drive already mapped. Skipping mapping step. >> %LogFile%
    ) || (
        :: Map network drive
        echo %date% %time% - Mapping network drive... >> %LogFile%
        net use P: %NetworkShare% /user:%NetworkUsername% %NetworkPassword% > nul 2>&1
        if %errorlevel% neq 0 (
            echo %date% %time% - ERROR: Unable to map network drive >> %LogFile%
            exit /b 1
        )
    )
)

:: Process arguments
if "%1"=="" (
    echo You need to run this script with one of the following arguments:
    echo -install              Create Windows Task Scheduler tasks executing the back-up and update commands on a certain date
    echo -backup               Run the back-up tasks
    echo -update               Run the update command
    echo -uninstall            Remove the schedule tasks from Task Scheduler
    exit /b 0
)

if "%1"=="-install" (
    schtasks /create /tn "%TaskFolder%\AutomatedBackupTask" /tr "%~f0 -backup" /sc once /st %ExecuteBackupTime% /sd %ExecuteDate% /ru %NetworkUsername% /rp %NetworkPassword%
    schtasks /create /tn "%TaskFolder%\AutomatedUpdateTask" /tr "%WSUSUpdatePath% /verify /autoreboot /updateccp" /sc once /st %ExecuteUpdateTime% /sd %ExecuteDate% /ru %NetworkUsername% /rp %NetworkPassword%
    echo %date% %time% - Scheduled tasks created for automated backup and update in folder %TaskFolder% >> %LogFile%
    exit /b 0
)

if "%1"=="-backup" (
    echo %date% %time% - Running backup... >> %LogFile%
    echo. >> %LogFile%
    goto :Backup
)

if "%1"=="-update" (
    echo %date% %time% - Running update... >> %LogFile%
    %WSUSUpdatePath% /verify /updateccp
    exit /b %errorlevel%
)

if "%1"=="-uninstall" (
    schtasks /delete /tn "%TaskFolder%\AutomatedBackupTask" /f
    schtasks /delete /tn "%TaskFolder%\AutomatedUpdateTask" /f
    echo %date% %time% - Scheduled tasks deleted from folder %TaskFolder% >> %LogFile%
    exit /b 0
)

:Backup
:: Example: call :ExecuteRoboCopy "source" "destination" "file"
if %RunLocally%==1 (
    set BaseDest=%LocalFolder%
) else (
    set BaseDest=P:
)

call :ExecuteRoboCopy "C:\VBZ\tools\PoEWatchdog\" "%BaseDest%\INEX\PoEWatchdog\" "PoEv8.cfg"
call :ExecuteRoboCopy "C:\VBZ\tools\PoEWatchdogNET\" "%BaseDest%\INEX\PoEWatchdogNET\" "PoE-NET.cfg"
call :ExecuteRoboCopy "C:\VBZ\tools\PoEWatchdogNET\" "%BaseDest%\INEX\PoEWatchdogNET\" "PoE-NET-settings.pwd"
call :ExecuteRoboCopy "C:\VBZ\Database\Default\" "%BaseDest%\INEX\INEX500\" "inex500.ini"
call :ExecuteRoboCopy "%WINDIR%\" "%BaseDest%\INEX\INEX500\Windows\" "inex500.ini"
call :ExecuteRoboCopy "%LocalAppData%\VirtualStore\windows\" "%BaseDest%\INEX\INEX500\VirtualStore\" "inex500.ini"
call :ExecuteRoboCopy "C:\VBZ\Database\Default\" "%BaseDest%\INEX\INEX500\" "inex500.mdb"
call :ExecuteRoboCopy "C:\VBZ\Database\Default\" "%BaseDest%\INEX\INEX500\" "inex500servicetool.ini"
call :ExecuteRoboCopy "%WINDIR%\" "%BaseDest%\INEX\INEX500\Windows\" "inex500servicetool.ini"
call :ExecuteRoboCopy "%LocalAppData%\VirtualStore\windows\" "%BaseDest%\INEX\INEX500\VirtualStore\" "inex500servicetool.ini"
call :ExecuteRoboCopy "C:\VBZ\Database\Default\" "%BaseDest%\INEX\INEX500\" "vbzserver.ini"
call :ExecuteRoboCopy "%WINDIR%\" "%BaseDest%\INEX\INEX500\Windows\" "vbzserver.ini"
call :ExecuteRoboCopy "%LocalAppData%\VirtualStore\windows\" "%BaseDest%\INEX\INEX500\VirtualStore\" "vbzserver.ini"
call :ExecuteRoboCopy "C:\VBZ\Database\Default\" "%BaseDest%\INEX\INEX500\" "zorgmana.ini"
call :ExecuteRoboCopy "C:\VBZ\Database\Default\" "%BaseDest%\INEX\INEX500\" "History.mdb"
call :ExecuteRoboCopy "C:\VBZ\INEX500\" "%BaseDest%\INEX\INEX500\" "History.his"
call :ExecuteRoboCopy "C:\VBZ\AlbireoIP\files\configs\asterisk\" "%BaseDest%\INEX\Galaxias\AlbireoIP_config\" "aipunits.conf"
call :ExecuteRoboCopy "C:\VBZ\AlbireoIP\files\configs\asterisk\" "%BaseDest%\INEX\Galaxias\AlbireoIP_config\" "extensions_addon_custom.conf"
call :ExecuteRoboCopy "C:\Program Files\dhcp\" "%BaseDest%\INEX\DHCP\" "DHCPsrv.ini"
call :ExecuteRoboCopy "C:\Program Files\dhcp\" "%BaseDest%\INEX\DHCP\" "dynamic"
call :ExecuteRoboCopy "C:\Program Files\dhcp\" "%BaseDest%\INEX\DHCP\" "ethers"
call :ExecuteRoboCopy "C:\Program Files\dhcp\" "%BaseDest%\INEX\DHCP\" "ignored"
call :ExecuteRoboCopy "C:\VBZ\Vios2\" "%BaseDest%\INEX\VIOS2\" "afdelingen.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\DB\" "%BaseDest%\INEX\VIOS2\DB\" "afdelingen.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\" "%BaseDest%\INEX\VIOS2\" "locaties.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\DB\" "%BaseDest%\INEX\VIOS2\DB\" "locaties.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\" "%BaseDest%\INEX\VIOS2\" "Regels.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\DB\" "%BaseDest%\INEX\VIOS2\DB\" "Regels.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\" "%BaseDest%\INEX\VIOS2\" "Regels.json.txt"
call :ExecuteRoboCopy "C:\VBZ\Vios2\DB\" "%BaseDest%\INEX\VIOS2\DB\" "Regels.json.txt"
call :ExecuteRoboCopy "C:\VBZ\Vios2\" "%BaseDest%\INEX\VIOS2\" "rooster.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\DB\" "%BaseDest%\INEX\VIOS2\DB\" "rooster.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\" "%BaseDest%\INEX\VIOS2\" "settings.json"
call :ExecuteRoboCopy "C:\VBZ\Vios2\DB\" "%BaseDest%\INEX\VIOS2\DB\" "settings.json"
call :ExecuteRoboCopy "C:\VBZ\Espa-MSF\" "%BaseDest%\INEX\ESPA-MSF\" "basestations.kws"
call :ExecuteRoboCopy "C:\VBZ\Espa-MSF\" "%BaseDest%\INEX\ESPA-MSF\" "groepen.txt"
call :ExecuteRoboCopy "C:\VBZ\Espa-MSF\" "%BaseDest%\INEX\ESPA-MSF\" "handsets.txt"

netsh.exe -c interface dump > "%BaseDest%\INEX\Netwerk_instellingen.txt"

:: Unmap network drive after backup tasks (only if RunLocally is 0)
if %RunLocally%==0 (
    echo %date% %time% - Unmapping network drive... >> %LogFile%
    net use P: /delete > nul 2>&1
)

exit /b 0

:ExecuteRoboCopy
set "SourcePath=%~1"
set "DestinationPath=%~2"
set "FileName=%~3"

if not "%SourcePath%"=="" set "SourcePath=%SourcePath% "
if not "%DestinationPath%"=="" set "DestinationPath=%DestinationPath% "
if not "%FileName%"=="" set "FileName=%FileName%"

if exist "%~1%~3" (
    echo %date% %time% - Source file "%~1%~3" exists >> %LogFile%
    
    echo %date% %time% - executing robocopy.exe "%SourcePath%" "%DestinationPath%" "%FileName%" >> %LogFile%
    robocopy.exe "%SourcePath%" "%DestinationPath%" "%FileName%"
    
    if %errorlevel% equ 8 (
        echo %date% %time% - robocopy remarks: [exit code 8] Some files or directories could not be copied >> %LogFile%
    ) else if %errorlevel% equ 1 (
        echo %date% %time% - robocopy remarks: [exit code 1] One or more files were copied successfully >> %LogFile%
        echo %date% %time% - executing copy /b %~2%~3 +,, %~2%~3 >> %LogFile%
        copy /b %~2%~3 +,, %~2%~3 > nul
    ) else if %errorlevel% equ 0 (
        echo %date% %time% - robocopy remark: [exit code 0] No errors occurred, no copying was done ^(identical file^) >> %LogFile%
        copy /b %~2%~3 +,, %~2%~3 > nul
    ) else (
        echo %date% %time% - robocopy remark: Something failed >> %LogFile%
    )

) else (
    echo %date% %time% - Source file "%~1%~3" not found >> %LogFile%
)
echo. >> %LogFile%

goto :eof
