# Script based on Microsoft's Get-WindowsAutopilotInfo workflow with helper logic for USB export.
# This flow only generates a local CSV and copies it to the technician USB. It does not upload to Intune.

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$usbLabel = "AUTOPILOTUSB"
$workFolder = "C:\HWID"
$galleryUrl = "https://www.powershellgallery.com/api/v2"

function Write-Line {
    param([string]$Message = "")
    Write-Output $Message
}

function Write-Info {
    param([string]$Message)
    Write-Line "[INFO] $Message"
}

function Write-Ok {
    param([string]$Message)
    Write-Line "[OK] $Message"
}

function Write-Problem {
    param([string]$Message)
    Write-Line "[ERROR] $Message"
}

function Write-ProblemAndExit {
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

Write-Line
Write-Line "============================================================"
Write-Line "        Autopilot hardware hash capture - Option A"
Write-Line "============================================================"
Write-Line
Write-Info "This option requires internet access to PowerShell Gallery."
Write-Info "This script does not upload anything to Intune."
Write-Line

$serial = (Get-CimInstance Win32_BIOS).SerialNumber
if ([string]::IsNullOrWhiteSpace($serial)) {
    Write-ProblemAndExit "Unable to read the device serial number." 2
}

$safeSerial = $serial -replace '[\\/:*?"<>|]', "_"
$localCsv = Join-Path $workFolder "$safeSerial-HWID.csv"

$usbDrive = Get-Volume | Where-Object { $_.FileSystemLabel -eq $usbLabel } | Select-Object -First 1
if (-not $usbDrive) {
    Write-ProblemAndExit "USB volume label '$usbLabel' not found. Rename the technician USB to '$usbLabel' and run Option A again." 3
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
    Write-ProblemAndExit "Unable to prepare the local or USB output folders. $($_.Exception.Message)" 4
}

Write-Info "Checking internet access to PowerShell Gallery..."
if (-not (Test-PowerShellGallery)) {
    Write-Problem "No connection to PowerShell Gallery was detected."
    Write-Line
    Write-Line "Connect the laptop to an approved Wi-Fi or approved non-corporate network,"
    Write-Line "then run Option A / option 4 again from safeworkbench-en.cmd."
    Write-Line
    Write-Line "If Wi-Fi cannot be connected at this stage, use Option B:"
    Write-Line "GetAutoPilot\GetAutoPilot.CMD"
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
    Write-Line
    Write-Line "Check the Wi-Fi connection and internet access, then run Option A again."
    Write-Line "If the script still cannot be downloaded, use Option B:"
    Write-Line "GetAutoPilot\GetAutoPilot.CMD"
    Write-Line
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
        Write-ProblemAndExit "CSV was not generated in $workFolder." 12
    }

    Copy-Item -Path $localCsv -Destination $destinationFile -Force
    Write-Ok "CSV generated: $localCsv"
    Write-Ok "CSV copied to USB: $destinationFile"
    Write-Line
    Write-Line "Do not open or edit the HWID CSV in Excel. Upload the generated CSV unchanged."
    Write-Line "This script did not upload anything to Intune."
} catch {
    Write-ProblemAndExit "CSV generation or USB copy failed. $($_.Exception.Message)" 13
}

Write-Line
Write-Ok "Hardware hash capture completed successfully."
Write-Line "Upload the CSV from the USB HardwareIDs folder to the approved enrollment location."
