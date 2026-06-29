@echo off
setlocal EnableExtensions
title GET AUTOPILOT HASH

cd /d "%~dp0"

set "OUTDIR=%CD%"

echo ============================================================
echo              GET AUTOPILOT HARDWARE HASH
echo ============================================================
echo.
echo Output folder:
echo %OUTDIR%
echo.

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Get-WindowsAutoPilotInfo.ps1" -OutputFolder "%OUTDIR%"

set "RC=%ERRORLEVEL%"
echo.

if "%RC%"=="0" (
    echo Export successful.
) else (
    echo ERROR: Export failed.
)

echo.
pause
exit /b %RC%
