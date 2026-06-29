@echo off
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Get-WindowsAutoPilotInfo.ps1"

pause