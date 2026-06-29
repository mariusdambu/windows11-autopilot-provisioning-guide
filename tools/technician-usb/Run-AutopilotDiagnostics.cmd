@echo off
title Autopilot Diagnostics

cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Get-AutopilotDiagnosticsCommunity.ps1"

pause