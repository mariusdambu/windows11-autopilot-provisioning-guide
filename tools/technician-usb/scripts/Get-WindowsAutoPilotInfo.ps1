# Script based on Microsoft's Get-WindowsAutopilotInfo workflow with helper logic for USB export.
# This flow only generates a local CSV and copies it to the technician USB. It does not upload to Intune.

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$usbLabel = "AUTOPILOTUSB"
$workFolder = "C:\HWID"
$galleryUrl = "https://www.powershellgallery.com/api/v2"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message"
}

function Write-Problem {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Stop-WithMessage {
    param(
        [string]$Message,
        [int]$Code = 1
    )

    Write-Problem $Message
    exit $Code
}

function Test-PowerShellGallery {
    try {
        Invoke-WebRequest -Uri $galleryUrl -UseBasicParsing -TimeoutSec 15 | Out-Null
        return $true
    } catch {
        return $false
    }
}

Write-Host ""
Write-Host "============================================================"
Write-Host "        Autopilot hardware hash capture - Option A"
Write-Host "============================================================"
Write-Host ""
Write-Info "This option requires internet access to PowerShell Gallery."
Write-Info "This script does not upload anything to Intune."
Write-Host ""

$serial = (Get-CimInstance Win32_BIOS).SerialNumber
if ([string]::IsNullOrWhiteSpace($serial)) {
    Stop-WithMessage "Unable to read the device serial number." 2
}

$safeSerial = $serial -replace '[\\/:*?"<>|]', "_"
$localCsv = Join-Path $workFolder "$safeSerial-HWID.csv"

$usbDrive = Get-Volume | Where-Object { $_.FileSystemLabel -eq $usbLabel } | Select-Object -First 1
if (-not $usbDrive) {
    Stop-WithMessage "USB volume label '$usbLabel' not found. Rename the technician USB to '$usbLabel' and run Option A again." 3
}

$usbPath = $usbDrive.DriveLetter + ":\"
$usbHardwareFolder = Join-Path $usbPath "HardwareIDs"
$destinationFile = Join-Path $usbHardwareFolder "$safeSerial-HWID.csv"

try {
    New-Item -ItemType Directory -Path $workFolder -Force | Out-Null
    New-Item -ItemType Directory -Path $usbHardwareFolder -Force | Out-Null
    Set-Location -Path $workFolder
    Write-Ok "Working folder ready: $workFolder"
    Write-Ok "USB output folder ready: $usbHardwareFolder"
} catch {
    Stop-WithMessage "Unable to prepare the local or USB output folders. $($_.Exception.Message)" 4
}

Write-Info "Checking internet access to PowerShell Gallery..."
if (-not (Test-PowerShellGallery)) {
    Write-Problem "No connection to PowerShell Gallery was detected."
    Write-Host ""
    Write-Host "Connect the laptop to an approved Wi-Fi or approved non-corporate network,"
    Write-Host "then run Option A / option 4 again from safeworkbench-en.cmd."
    Write-Host ""
    Write-Host "If Wi-Fi cannot be connected at this stage, use Option B:"
    Write-Host "GetAutoPilot\GetAutoPilot.CMD"
    exit 10
}
Write-Ok "PowerShell Gallery is reachable."

try {
    $env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

    Write-Info "Installing or updating Get-WindowsAutopilotInfo from PowerShell Gallery..."
    Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false -ErrorAction Stop

    Get-Command Get-WindowsAutopilotInfo -ErrorAction Stop | Out-Null
    Write-Ok "Get-WindowsAutopilotInfo is available."
} catch {
    Write-Problem "Get-WindowsAutopilotInfo could not be installed."
    Write-Host ""
    Write-Host "Check the Wi-Fi connection and internet access, then run Option A again."
    Write-Host "If the script still cannot be downloaded, use Option B:"
    Write-Host "GetAutoPilot\GetAutoPilot.CMD"
    Write-Host ""
    Write-Problem $_.Exception.Message
    exit 11
}

try {
    if (Test-Path $localCsv) {
        Remove-Item -Path $localCsv -Force
    }

    Write-Info "Generating hardware hash CSV for serial $safeSerial..."
    Get-WindowsAutopilotInfo -OutputFile $localCsv -ErrorAction Stop

    if (-not (Test-Path $localCsv)) {
        Stop-WithMessage "CSV was not generated in $workFolder." 12
    }

    Copy-Item -Path $localCsv -Destination $destinationFile -Force
    Write-Ok "CSV generated: $localCsv"
    Write-Ok "CSV copied to USB: $destinationFile"
    Write-Host ""
    Write-Host "Do not open or edit the HWID CSV in Excel. Upload the generated CSV unchanged."
    Write-Host "This script did not upload anything to Intune."
} catch {
    Stop-WithMessage "CSV generation or USB copy failed. $($_.Exception.Message)" 13
}

Write-Host ""
Write-Ok "Hardware hash capture completed successfully."
Write-Host "Upload the CSV from the USB HardwareIDs folder to the approved enrollment location."
