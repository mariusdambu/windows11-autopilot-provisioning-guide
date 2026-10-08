@echo off
setlocal enabledelayedexpansion
title RAPIDDEPLOY WORKBENCH ^| WIM Image Manager
mode con: cols=84 lines=28

:: Get ESC character for ANSI colors
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
set "SOURCES=%ROOT%sources"
set "WIM_NAME=install.wim"
set "EXCLUDE_LIST=boot efi sources support scripts hardwareids lab_win11"

:MAIN_MENU
cls
if not exist "%SOURCES%\." (
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo   %C_RED%[X] ERROR: Required Windows media folder "sources" was not found.%C_RESET%
    echo   %C_YELLOW%[!] Check the integrity of this Windows 11 installation media.%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo.
    pause
    exit /b 1
)

echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%RAPIDDEPLOY WORKBENCH%C_RESET% %C_GRAY%^|%C_RESET% %C_CYAN%WIM Image Manager%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.

:: 1. Scan available empty folders
for /f "tokens=1 delims==" %%V in ('set EMPTY_DIR_ 2^>nul') do set "%%V="
for /f "tokens=1 delims==" %%V in ('set EMPTY_NAME_ 2^>nul') do set "%%V="
set "EMPTY_COUNT=0"
for /d %%D in ("%ROOT%*") do (
    set "IS_EXCLUDED="
    for %%E in (%EXCLUDE_LIST%) do (
        if /i "%%~nxD"=="%%E" set "IS_EXCLUDED=1"
    )
    if not defined IS_EXCLUDED (
        if not exist "%%D\%WIM_NAME%" (
            set /a EMPTY_COUNT+=1
            set "EMPTY_DIR_!EMPTY_COUNT!=%%D"
            set "EMPTY_NAME_!EMPTY_COUNT!=%%~nxD"
        )
    )
)

:: 2. Render status panel
echo  %C_BOLD%SYSTEM STATUS:%C_RESET%
if exist "%SOURCES%\%WIM_NAME%" (
    echo    sources\install.wim  : %C_GREEN%[ ACTIVE / IN USE ]%C_RESET%
    if %EMPTY_COUNT%==1 (
        echo    Suggested target     : %C_YELLOW%!EMPTY_NAME_1!%C_RESET% %C_GRAY%-- only empty folder%C_RESET%
    ) else if %EMPTY_COUNT% GTR 1 (
        echo    Suggested target     : %C_YELLOW%Multiple empty folders detected [%EMPTY_COUNT%]%C_RESET%
    ) else (
        echo    Suggested target     : %C_GRAY%No empty folder found%C_RESET%
    )
) else (
    echo    sources\install.wim  : %C_GRAY%[ INACTIVE / EMPTY ]%C_RESET%
    echo    Suggested target     : %C_GRAY%No image currently mounted%C_RESET%
)

echo.
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%OPERATIONS:%C_RESET%
echo.
if %EMPTY_COUNT%==1 (
    echo   %C_CYAN%[1]%C_RESET% Return install.wim to original folder: %C_YELLOW%!EMPTY_NAME_1!%C_RESET%
) else if %EMPTY_COUNT% GTR 1 (
    echo   %C_CYAN%[1]%C_RESET% Return install.wim ^(%C_YELLOW%Choose between %EMPTY_COUNT% empty folders%C_RESET%^)
) else (
    echo   %C_GRAY%[1] Return install.wim - Not required / No empty folders%C_RESET%
)
echo   %C_CYAN%[2]%C_RESET% Deploy new model to %C_WHITE%sources\install.wim%C_RESET%
echo   %C_CYAN%[3]%C_RESET% Return to Main Menu
echo.
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%

set "OPT="
set /p "OPT= >> Select an option [1-3]: "

if "%OPT%"=="1" goto RETURN_IMAGE_MANUALLY
if "%OPT%"=="2" goto SELECT_MODEL
if "%OPT%"=="3" goto RETURN_TO_MAIN

echo.
echo  %C_YELLOW%[!] Invalid option.%C_RESET%
timeout /t 2 >nul
goto MAIN_MENU

:: ----------------------------------------------------
:: OPTION 1: RETURN IMAGE MANUALLY
:: ----------------------------------------------------
:RETURN_IMAGE_MANUALLY
echo.
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
if not exist "%SOURCES%\%WIM_NAME%" (
    echo   %C_YELLOW%[!] NOTICE: sources\%WIM_NAME% is already empty.%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo.
    pause
    goto MAIN_MENU
)

if %EMPTY_COUNT%==0 (
    echo   %C_RED%[X] ERROR: No target empty folder available.%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo.
    pause
    goto MAIN_MENU
)

:: If exactly 1 empty folder is available, use it directly
if %EMPTY_COUNT%==1 (
    set "TARGET_DIR=!EMPTY_DIR_1!"
    set "TARGET_NAME=!EMPTY_NAME_1!"
    goto MOVE_IMAGE_BACK
)

:: If multiple empty folders are available, show the folder selector
echo  %C_BOLD%Several empty folders are available. Select where to return the image:%C_RESET%
echo.
for /l %%i in (1,1,%EMPTY_COUNT%) do (
    echo     %C_CYAN%[%%i]%C_RESET% %C_WHITE%!EMPTY_NAME_%%i!%C_RESET%
)
echo.
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
:ASK_EMPTY_FOLDER
set "ECHOICE="
set /p "ECHOICE= >> Select target folder [1-%EMPTY_COUNT%] or [C]ancel: "
if /i "%ECHOICE%"=="C" goto MAIN_MENU

if not defined EMPTY_DIR_%ECHOICE% (
    echo   %C_YELLOW%[!] Invalid selection.%C_RESET%
    goto ASK_EMPTY_FOLDER
)

set "TARGET_DIR=!EMPTY_DIR_%ECHOICE%!"
set "TARGET_NAME=!EMPTY_NAME_%ECHOICE%!"

:MOVE_IMAGE_BACK
echo.
echo   %C_GRAY%Moving image to !TARGET_NAME!...%C_RESET%
move "%SOURCES%\%WIM_NAME%" "!TARGET_DIR!\%WIM_NAME%" >nul
if errorlevel 1 (
    echo   %C_RED%[X] ERROR: Could not move the image.%C_RESET%
) else (
    echo   %C_GREEN%[OK] Image returned successfully to: !TARGET_NAME!%C_RESET%
)
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.
pause
goto MAIN_MENU

:: ----------------------------------------------------
:: OPTION 2: SELECT AND DEPLOY MODEL
:: ----------------------------------------------------
:SELECT_MODEL
cls
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo  %C_BOLD%%C_WHITE%SELECT DEPLOYMENT MODEL%C_RESET%
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
echo.

if exist "%SOURCES%\%WIM_NAME%" (
    echo   %C_YELLOW%[!] WARNING: An active image already exists in sources.%C_RESET%
    echo   You must return it before activating another model.
    echo.
    set "CONFIRM="
    set /p "CONFIRM= >> Manage image return now? (Y/N): "
    if /i "!CONFIRM!"=="Y" (
        goto RETURN_IMAGE_MANUALLY
    ) else (
        echo   %C_GRAY%Operation cancelled. Returning to main menu...%C_RESET%
        timeout /t 2 >nul
        goto MAIN_MENU
    )
)

for /f "tokens=1 delims==" %%V in ('set MODEL_ 2^>nul') do set "%%V="
for /f "tokens=1 delims==" %%V in ('set NAME_ 2^>nul') do set "%%V="
set "COUNT=0"
echo  Available models with ready image:
echo.

for /d %%D in ("%ROOT%*") do (
    set "IS_EXCLUDED="
    for %%E in (%EXCLUDE_LIST%) do (
        if /i "%%~nxD"=="%%E" set "IS_EXCLUDED=1"
    )
    if not defined IS_EXCLUDED (
        if exist "%%D\%WIM_NAME%" (
            set /a COUNT+=1
            set "MODEL_!COUNT!=%%D"
            set "NAME_!COUNT!=%%~nxD"
            echo     %C_CYAN%[!COUNT!]%C_RESET% %C_WHITE%%%~nxD%C_RESET%
        )
    )
)

if %COUNT%==0 (
    echo.
    echo   %C_RED%[X] No model folders with %WIM_NAME% were found.%C_RESET%
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
:ASK_MODEL_SELECTION
set "CHOICE="
set /p "CHOICE= >> Enter model number to activate [1-%COUNT%] or [C]ancel: "
if /i "%CHOICE%"=="C" goto MAIN_MENU

if not defined MODEL_%CHOICE% (
    echo   %C_YELLOW%[!] Invalid option.%C_RESET%
    goto ASK_MODEL_SELECTION
)

set "SELECTED_DIR=!MODEL_%CHOICE%!"
set "SELECTED_NAME=!NAME_%CHOICE%!"

echo.
echo   %C_GRAY%Deploying image !SELECTED_NAME!...%C_RESET%
move "!SELECTED_DIR!\%WIM_NAME%" "%SOURCES%\%WIM_NAME%" >nul

if errorlevel 1 (
    echo   %C_RED%[X] ERROR: Could not move image to sources.%C_RESET%
) else (
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo   %C_GREEN%[OK] IMAGE ACTIVATED SUCCESSFULLY%C_RESET%
    echo   Active model : %C_BOLD%%C_WHITE%!SELECTED_NAME!%C_RESET%
    echo   Location     : %C_GRAY%%SOURCES%\%WIM_NAME%%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
)
echo.
pause
goto MAIN_MENU

:RETURN_TO_MAIN
cls
if not "%RAPIDDEPLOY_WIM_CALLED_FROM_MENU%"=="1" (
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    echo   %C_CYAN%WIM Image Manager closed. Press any key to return to this window.%C_RESET%
    echo %C_GRAY%------------------------------------------------------------------------------------%C_RESET%
    pause >nul
)
exit /b 0
