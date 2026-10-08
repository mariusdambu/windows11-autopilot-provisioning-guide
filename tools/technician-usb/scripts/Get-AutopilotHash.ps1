[CmdletBinding()]
param(
    [string]$OutputDir = "",
    [string]$GroupTag = "",
    [string]$AssetTag = ""
)

$ErrorActionPreference = "Stop"
$ESC = [char]27
$C_RESET = "$ESC[0m"
$C_WHITE = "$ESC[97m"
$C_GRAY = "$ESC[90m"
$C_GREEN = "$ESC[92m"
$C_YELLOW = "$ESC[93m"
$C_CYAN = "$ESC[96m"
$C_RED = "$ESC[91m"
$C_BOLD = "$ESC[1m"
$LINE = "$C_GRAY------------------------------------------------------------------------------------$C_RESET"

function Write-SectionHeader {
    param([string]$Subtitle)
    Write-Host $LINE
    Write-Host ("  {0}{1}{2} {3}|{4} {5}{6}{7}" -f $C_BOLD, $C_WHITE, "RAPIDDEPLOY WORKBENCH", $C_GRAY, $C_RESET, $C_CYAN, $Subtitle, $C_RESET)
    Write-Host $LINE
}

try {
    Clear-Host
    Write-SectionHeader -Subtitle "Offline Autopilot Hash Capture"
    Write-Host ""
    Write-Host "  ${C_GRAY}Querying hardware information...${C_RESET}"

    # Resolve OutputDir safely after the script scope has been established.
    if ([string]::IsNullOrWhiteSpace($OutputDir)) {
        $baseDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
        $OutputDir = Join-Path -Path $baseDir -ChildPath "..\HardwareIDs"
    }

    # 1. BIOS serial number
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $rawSerial = [string]$bios.SerialNumber
    if ([string]::IsNullOrWhiteSpace($rawSerial)) { $rawSerial = "UNKNOWN-SERIAL" }
    $safeSerial = $rawSerial.Trim()
    foreach ($invalidChar in [IO.Path]::GetInvalidFileNameChars()) {
        $safeSerial = $safeSerial.Replace($invalidChar, '-')
    }
    $safeSerial = $safeSerial.TrimEnd('.')
    if ([string]::IsNullOrWhiteSpace($safeSerial)) { $safeSerial = "UNKNOWN-SERIAL" }

    # 2. Manufacturer and model
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $maker = ([string]$cs.Manufacturer).Trim()
    $model = ([string]$cs.Model).Trim()

    # 3. Read the local hardware hash through WMI
    $devDetail = Get-CimInstance -Namespace "root/cimv2/mdm/dmmap" -ClassName "MDM_DevDetail_Ext01" -Filter "InstanceID='Ext' AND ParentID='./DevDetail'"
    $hardwareHash = ([string]$devDetail.DeviceHardwareData).Trim() -replace "[\r\n]", ""
    if ([string]::IsNullOrWhiteSpace($hardwareHash)) {
        throw "Hardware Hash is empty. Ensure you run this from Windows / OOBE, not bare WinPE."
    }

    $resolvedOutputDir = [System.IO.Path]::GetFullPath($OutputDir)
    if (-not (Test-Path -LiteralPath $resolvedOutputDir -PathType Container)) {
        New-Item -Path $resolvedOutputDir -ItemType Directory -Force | Out-Null
    }

    $AssetTag = ([string]$AssetTag).Trim()
    $safeAssetTag = $AssetTag
    foreach ($invalidChar in [IO.Path]::GetInvalidFileNameChars()) {
        $safeAssetTag = $safeAssetTag.Replace($invalidChar, '-')
    }
    $safeAssetTag = $safeAssetTag.TrimEnd([char[]]@('.', ' '))
    if ([string]::IsNullOrWhiteSpace($safeAssetTag)) {
        $csvFileName = "$safeSerial-HWID.csv"
    }
    else {
        # Keep the Autopilot CSV schema intact; use Asset Tag in the filename and summary.
        $csvFileName = "$safeAssetTag-$safeSerial-HWID.csv"
    }
    $csvPath = Join-Path -Path $resolvedOutputDir -ChildPath $csvFileName
    $escapedSerial = $rawSerial.Replace('"', '""')
    $escapedHash = $hardwareHash.Replace('"', '""')
    if (-not [string]::IsNullOrWhiteSpace($GroupTag)) {
        $GroupTag = $GroupTag.Trim()
        $escapedGroupTag = $GroupTag.Replace('"', '""')
        $header = "Device Serial Number,Windows Product ID,Hardware Hash,Group Tag"
        $row = '"{0}",,"{1}","{2}"' -f $escapedSerial, $escapedHash, $escapedGroupTag
    }
    else {
        $header = "Device Serial Number,Windows Product ID,Hardware Hash"
        $row = '"{0}",,"{1}"' -f $escapedSerial, $escapedHash
    }
    @($header, $row) | Set-Content -LiteralPath $csvPath -Encoding ASCII

    Write-Host ""
    Write-Host $LINE
    Write-Host ("  {0}CAPTURE SUMMARY{1}" -f $C_BOLD, $C_RESET)
    Write-Host $LINE
    Write-Host ("  {0,-20}: {1}" -f "Manufacturer", $maker)
    Write-Host ("  {0,-20}: {1}" -f "Model", $model)
    Write-Host ("  {0,-20}: {1}{2}{3}" -f "Serial Number", $C_CYAN, $rawSerial, $C_RESET)
    if (-not [string]::IsNullOrWhiteSpace($GroupTag)) {
        Write-Host ("  {0,-20}: {1}" -f "Group Tag", $GroupTag.Trim())
    }

    if (-not [string]::IsNullOrWhiteSpace($AssetTag)) {
        Write-Host ("  {0,-20}: {1}" -f "Asset Tag", $AssetTag)
    }
    Write-Host ("  {0,-20}: {1}" -f "CSV File Path", $csvPath)
    Write-Host ("  {0,-20}: {1} characters" -f "Hash Length", $hardwareHash.Length)
    Write-Host $LINE
    Write-Host ("  {0}[OK]{1} Hardware hash captured successfully in offline mode." -f $C_GREEN, $C_RESET)
    Write-Host ""
    exit 0
}
catch {
    Write-Host ""
    Write-Host $LINE
    Write-Host ("  {0}[X] ERROR:{1} {2}" -f $C_RED, $C_RESET, $_.Exception.Message)
    Write-Host $LINE
    Write-Host ""
    exit 1
}
