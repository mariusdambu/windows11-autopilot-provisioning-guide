@echo off
setlocal EnableDelayedExpansion
title RapidDeploy Toolkit - OOBE Provisioning
mode con: cols=84 lines=28

:: ANSI escape codes
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "C_RESET=%ESC%[0m"
set "C_WHITE=%ESC%[97m"
set "C_GRAY=%ESC%[90m"
set "C_GREEN=%ESC%[92m"
set "C_YELLOW=%ESC%[93m"
set "C_CYAN=%ESC%[96m"
set "C_RED=%ESC%[91m"
set "C_BOLD=%ESC%[1m"

set "ROOT=%~dp0"
set "WIPE_DONE=0"

:MAIN_MENU
set "OPT="
set "GCHOICE="
set "GTAG="
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%OOBE Provisioning Toolkit%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
echo   %C_BOLD%DEPLOYMENT ^& DIAGNOSTICS%C_RESET%                    %C_GRAY%^|%C_RESET%  %C_BOLD%SYSTEM ^& HARDWARE%C_RESET%
echo   %C_CYAN%[1]%C_RESET% Capture Autopilot Hash (Offline)        %C_GRAY%^|%C_RESET%  %C_CYAN%[6]%C_RESET% Show Physical Disks
echo   %C_CYAN%[2]%C_RESET% Run Autopilot Diagnostics               %C_GRAY%^|%C_RESET%  %C_CYAN%[7]%C_RESET% Open DiskPart Console
echo   %C_CYAN%[3]%C_RESET% WIM Image Manager (SelectModel)         %C_GRAY%^|%C_RESET%  %C_CYAN%[8]%C_RESET% Open PowerShell Console
echo  %C_GRAY%---------------------------------------------+-------------------------------------%C_RESET%
echo   %C_BOLD%DISK MANAGEMENT%C_RESET%                             %C_GRAY%^|%C_RESET%  %C_BOLD%CONNECTIVITY ^& INFO%C_RESET%
echo   %C_CYAN%[4]%C_RESET% %C_RED%QUICK Wipe Disk 0 (Direct)%C_RESET%              %C_GRAY%^|%C_RESET%  %C_CYAN%[9]%C_RESET% Open Wi-Fi Settings
echo   %C_CYAN%[5]%C_RESET% SAFE Wipe Disk 0 (Prompt ERASE)         %C_GRAY%^|%C_RESET%  %C_CYAN%[0]%C_RESET% Show Network / IP Config
echo                                               %C_GRAY%^|%C_RESET%  %C_CYAN%[S]%C_RESET% Show Serial Number
echo                                               %C_GRAY%^|%C_RESET%  %C_CYAN%[M]%C_RESET% Trigger MDM Sync
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo   %C_CYAN%[T]%C_RESET% Sync Time   %C_CYAN%[R]%C_RESET% %C_YELLOW%Restart%C_RESET%   %C_CYAN%[X]%C_RESET% %C_RED%Shutdown%C_RESET%   %C_CYAN%[Q]%C_RESET% Exit to CMD
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%

set /p "OPT= >> Select an option: "

if not defined OPT goto MAIN_MENU
if /i "%OPT%"=="1" goto CAPTURAR_HWID
if /i "%OPT%"=="2" goto DIAGNOSTICO
if /i "%OPT%"=="3" goto GESTIONAR_WIM
if /i "%OPT%"=="4" goto WIPE_RAPIDO
if /i "%OPT%"=="5" goto WIPE_SEGURO
if /i "%OPT%"=="6" goto VER_DISCOS
if /i "%OPT%"=="7" goto ABRIR_DISKPART
if /i "%OPT%"=="8" goto ABRIR_POWERSHELL
if /i "%OPT%"=="9" goto ABRIR_WIFI
if /i "%OPT%"=="0" goto VER_RED
if /i "%OPT%"=="S" goto VER_SERIAL
if /i "%OPT%"=="M" goto SYNC_MDM
if /i "%OPT%"=="T" goto SYNC_TIME
if /i "%OPT%"=="R" goto REINICIAR
if /i "%OPT%"=="X" goto APAGAR
if /i "%OPT%"=="Q" goto SALIR

echo.
echo   %C_YELLOW%[!] Invalid option.%C_RESET%
timeout /t 2 >nul
goto MAIN_MENU
:CAPTURAR_HWID
set "OPT="
set "GCHOICE="
set "GTAG="
set "ASSET="
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%Autopilot Profile ^& Asset Registration%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
echo   %C_BOLD%STANDARD PROFILES%C_RESET%                         %C_GRAY%^|%C_RESET%   %C_BOLD%HIGH SPEC PROFILES%C_RESET%
echo   %C_CYAN%[1]%C_RESET% Standard-Desktop                      %C_GRAY%^|%C_RESET%   %C_CYAN%[5]%C_RESET% HighSpec-Desktop
echo   %C_CYAN%[2]%C_RESET% Standard-Laptop                       %C_GRAY%^|%C_RESET%   %C_CYAN%[6]%C_RESET% HighSpec-Laptop
echo   %C_CYAN%[3]%C_RESET% Kiosk-Device                          %C_GRAY%^|%C_RESET%   %C_CYAN%[7]%C_RESET% Executive-Laptop
echo   %C_CYAN%[4]%C_RESET% Shared-Workstation                    %C_GRAY%^|%C_RESET%   %C_CYAN%[8]%C_RESET% CAD-Engineering
echo  %C_GRAY%---------------------------------------------+---------------------------------------%C_RESET%
echo   %C_CYAN%[C]%C_RESET% Custom Group Tag (Type manually) %C_GRAY%^|%C_RESET%   %C_CYAN%[ENTER]%C_RESET% Skip (No Group Tag)
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.

set "GCHOICE="
set "GTAG="
set /p "GCHOICE= >> Select preset [1-8], [C]ustom or press Enter to skip: "

if "%GCHOICE%"=="1" set "GTAG=Standard-Desktop"
if "%GCHOICE%"=="2" set "GTAG=Standard-Laptop"
if "%GCHOICE%"=="3" set "GTAG=Kiosk-Device"
if "%GCHOICE%"=="4" set "GTAG=Shared-Workstation"
if "%GCHOICE%"=="5" set "GTAG=HighSpec-Desktop"
if "%GCHOICE%"=="6" set "GTAG=HighSpec-Laptop"
if "%GCHOICE%"=="7" set "GTAG=Executive-Laptop"
if "%GCHOICE%"=="8" set "GTAG=CAD-Engineering"

if /i "%GCHOICE%"=="C" (
    echo.
    set /p "GTAG= >> Enter Custom Group Tag: "
)

echo.
set "ASSET="
set /p "ASSET= >> Enter Device Asset Tag (e.g. ABC123) or press Enter to skip: "
echo.
set "PS_ARGS="
if defined GTAG set PS_ARGS=!PS_ARGS! -GroupTag "!GTAG!"
if defined ASSET set PS_ARGS=!PS_ARGS! -AssetTag "!ASSET!"
echo   %C_GRAY%Exporting Autopilot hardware hash...%C_RESET%
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\Get-AutopilotHash.ps1" !PS_ARGS!
goto PAUSA_MENU
:DIAGNOSTICO
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%Autopilot Local Diagnostics%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\Get-AutopilotDiagnosticsCommunity.ps1"
goto PAUSA_MENU

:GESTIONAR_WIM
cls
if not exist "%ROOT%SelectModel.cmd" (
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo   %C_RED%[X] ERROR: SelectModel.cmd not found in root directory.%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    pause
    goto MAIN_MENU
)
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo   %C_CYAN%Starting WIM Image Manager...%C_RESET%
timeout /t 1 /nobreak >nul
set "RAPIDDEPLOY_WIM_CALLED_FROM_MENU=1"
call "%ROOT%SelectModel.cmd"
set "SELECTMODEL_RC=%ERRORLEVEL%"
set "RAPIDDEPLOY_WIM_CALLED_FROM_MENU="
if not "%SELECTMODEL_RC%"=="0" (
    echo.
    echo   %C_RED%[X] SelectModel.cmd returned error code %SELECTMODEL_RC%.%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    pause
)
goto MAIN_MENU

:WIPE_RAPIDO
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_RED%QUICK WIPE DISK 0%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
echo   %C_RED%[!] Cleaning DISK 0 directly without confirmation...%C_RESET%
call :RUN_WIPE
goto PAUSA_MENU

:WIPE_SEGURO
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_YELLOW%SAFE WIPE DISK 0%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
if "%WIPE_DONE%"=="1" (
    echo   %C_YELLOW%[!] NOTICE: Disk 0 was already wiped during this session.%C_RESET%
    goto PAUSA_MENU
)
echo   %C_RED%[!] WARNING: All partitions and data on DISK 0 will be erased.%C_RESET%
echo.
set "CONFIRM="
set /p "CONFIRM= >> Type ERASE to continue or [C]ancel: "
if /i not "%CONFIRM%"=="ERASE" (
    echo.
    echo   %C_YELLOW%[!] Operation cancelled by user.%C_RESET%
    goto PAUSA_MENU
)
call :RUN_WIPE
goto PAUSA_MENU

:RUN_WIPE
if not exist "%ROOT%scripts\clean_disk0.txt" (
    echo.
    echo   %C_RED%[X] ERROR: scripts\clean_disk0.txt not found.%C_RESET%
    exit /b 1
)
echo.
diskpart /s "%ROOT%scripts\clean_disk0.txt" >nul
if errorlevel 1 (
    echo.
    echo   %C_RED%[X] DiskPart reported an error.%C_RESET%
    exit /b 1
)
set "WIPE_DONE=1"
echo.
echo   %C_GREEN%[OK] Disk 0 cleaned and converted to GPT successfully.%C_RESET%
exit /b 0

:VER_DISCOS
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%Detected Physical Disks%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-Disk | Format-Table Number,FriendlyName,OperationalStatus,TotalSize,PartitionStyle -AutoSize"
goto PAUSA_MENU

:ABRIR_DISKPART
cls
diskpart
goto MAIN_MENU

:ABRIR_POWERSHELL
start "" powershell.exe -NoExit
goto MAIN_MENU

:ABRIR_WIFI
start "" ms-settings:network-wifi 2>nul
goto MAIN_MENU

:VER_RED
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%Network / IP Configuration%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
ipconfig /all
goto PAUSA_MENU

:VER_SERIAL
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%BIOS Serial Number%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=(Get-CimInstance Win32_BIOS).SerialNumber; Write-Host '  Serial Number : ' -NoNewline; Write-Host $s -ForegroundColor Cyan"
goto PAUSA_MENU

:SYNC_TIME
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%System Time Synchronization%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
echo   Current system time : %TIME%
echo   Current system date : %DATE%
echo.
echo   %C_GRAY%Starting Windows Time service...%C_RESET%
net start w32time >nul 2>&1
echo   %C_GRAY%Resyncing with time server...%C_RESET%
w32tm /resync /force
goto PAUSA_MENU

:SYNC_MDM
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%Trigger MDM Enrollment Sync%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
echo   %C_GRAY%Triggering OMA-DM device check-in...%C_RESET%
start "" DeviceEnroller.exe /c /AutoEnrollMDM
echo.
echo   %C_GREEN%[OK] MDM check-in signal sent.%C_RESET%
goto PAUSA_MENU

:PAUSA_MENU
echo.
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
pause
goto MAIN_MENU

:REINICIAR
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_YELLOW%Restarting system immediately...%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
shutdown /r /f /t 0
exit /b 0

:APAGAR
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_RED%Shutting down system immediately...%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
shutdown /s /f /t 0
exit /b 0

:SALIR
cls
exit 0
