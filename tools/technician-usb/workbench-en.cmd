@echo off
setlocal EnableExtensions
title WORKBENCH
color 0A
cd /d "%~dp0"
set "WIPE_DONE=0"

:menu
cls
echo ============================================================
echo            ________.----------------._______
echo        ___/___________WORKBENCH___________/\___
echo       /   __   __   __   __   __     /  /\
echo      /___/__/__/__/__/__/__/__/_____/  /  \
echo      \_______________________________\ / /\ \
echo      ]  [##]====[__________]====[##] ]/ /  \ \
echo      ]       __      __      __      ]_/    / /
echo      ]______/__/____/__/____/__/_____]_____/ /
echo      ]________________________________]_____/
echo ============================================================
echo.
echo 1 - Shutdown PC
echo 2 - Restart PC
echo 3 - Wipe DISK 0
echo 4 - Create hardware hash file (recommended - Wi-Fi)
echo 5 - Create hardware hash file (offline fallback)
echo 6 - Autopilot Diagnostics
echo 7 - Open DiskPart
echo 8 - Open PowerShell
echo 9 - Show Disk Information
echo N - Show Network / IP
echo S - Show Serial Number
echo W - Open WiFi Settings
echo 0 - New CMD Window
echo Q - Exit
echo.

set "option="
echo ============================================================
set /p "option=Select an option: "

if /i "%option%"=="1" goto shutdown
if /i "%option%"=="2" goto restart
if /i "%option%"=="3" goto wipe
if /i "%option%"=="4" goto hwid
if /i "%option%"=="5" goto hwid_offline
if /i "%option%"=="6" goto diagnostics
if /i "%option%"=="7" goto diskpart
if /i "%option%"=="8" goto powershell
if /i "%option%"=="9" goto disks
if /i "%option%"=="N" goto network
if /i "%option%"=="S" goto serial
if /i "%option%"=="W" goto wifi
if /i "%option%"=="0" goto newcmd
if /i "%option%"=="Q" goto exitmenu

echo.
echo Invalid option.
pause
goto menu

REM START: SHUTDOWN - Shuts down the PC
:shutdown
echo.
echo Shutting down in 2 seconds...
shutdown /s /f /t 2
exit

REM END: SHUTDOWN

REM START: RESTART - Restarts the PC
:restart
echo.
echo Restarting in 2 seconds...
shutdown /r /f /t 2
exit

REM END: RESTART

REM START: WIPE - Cleans Disk 0
:wipe
if "%WIPE_DONE%"=="1" (
    cls
    echo =====================================
    echo        WIPE ALREADY EXECUTED
    echo =====================================
    echo.
    echo Disk 0 wipe has already been executed in this session.
    echo Restart the script if you really need to run it again.
    echo.
    pause
    goto menu
)

cls
echo =====================================
echo         WIPING DISK 0...
echo =====================================
echo.

diskpart /s "%~dp0clean_disk0.txt"

set "WIPE_DONE=1"

echo.
echo Process completed.
echo Wipe is now locked for this session.
pause
goto menu

REM END: WIPE

REM START: HWID - Generates hardware hash with online PowerShell Gallery workflow
:hwid
cls
echo =====================================
echo      CREATE HARDWARE HASH FILE
echo      Recommended method - Wi-Fi required
echo =====================================
echo.
echo Use this only after the laptop is connected to approved Wi-Fi.
echo Downloads Get-WindowsAutopilotInfo from PowerShell Gallery.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Get-WindowsAutoPilotInfo.ps1"

echo.
pause
goto menu

REM END: HWID

REM START: HWID OFFLINE - Generates hardware hash with local GetAutoPilot helper
:hwid_offline
cls
echo =====================================
echo      CREATE HARDWARE HASH FILE
echo      Offline fallback
echo =====================================
echo.
echo No internet connection is required.
echo Runs GetAutoPilot\GetAutoPilot.CMD from the technician USB.
echo The CSV is saved in the GetAutoPilot folder.
echo.

if not exist "%~dp0GetAutoPilot\GetAutoPilot.CMD" (
    echo ERROR: GetAutoPilot\GetAutoPilot.CMD was not found.
    echo Keep the GetAutoPilot folder at the USB root.
    echo.
    pause
    goto menu
)

call "%~dp0GetAutoPilot\GetAutoPilot.CMD"

goto menu

REM END: HWID OFFLINE

REM START: DIAGNOSTICS - Runs Autopilot diagnostics
:diagnostics
cls
echo =====================================
echo     AUTOPILOT DIAGNOSTICS
echo =====================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Get-AutopilotDiagnosticsCommunity.ps1"

echo.
pause
goto menu

REM END: DIAGNOSTICS

REM START: DISKPART - Opens DiskPart
:diskpart
cls
diskpart
goto menu

REM END: DISKPART

REM START: POWERSHELL - Opens PowerShell
:powershell
cls
start "" powershell
goto menu

REM END: POWERSHELL

REM START: DISKS - Shows disks
:disks
cls
echo =====================================
echo           DISK INFORMATION
echo =====================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Disk | Format-Table -AutoSize"

echo.
pause
goto menu

REM END: DISKS

REM START: NETWORK - Shows network and IP
:network
cls
echo =====================================
echo            NETWORK / IP
echo =====================================
echo.

ipconfig /all

echo.
pause
goto menu

REM END: NETWORK

REM START: SERIAL - Shows serial number
:serial
cls
echo =====================================
echo          SERIAL NUMBER
echo =====================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "(Get-CimInstance Win32_BIOS).SerialNumber"

echo.
pause
goto menu

REM END: SERIAL

REM START: WIFI - Opens WiFi settings
:wifi
cls
echo =====================================
echo           WIFI SETTINGS
echo =====================================
echo.
echo Opening WiFi settings...
echo.

start "" ms-settings:network-wifi

goto menu

REM END: WIFI

REM START: NEW CMD - Opens new console
:newcmd
start "" cmd
goto menu

REM END: NEW CMD

REM START: EXIT - Closes the menu
:exitmenu
exit
REM END: EXIT
