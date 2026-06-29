<# 
    Get-WindowsAutoPilotInfo.ps1
    Local Autopilot hardware hash capture for USB/OOBE use.

    Default output:
      <script folder>\<Serial>.csv

    Notes:
      - Designed for fast local CSV export from Shift+F10 / OOBE.
      - Does not require internet for normal CSV capture.
      - Online import should use the latest PowerShell Gallery script.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string] $OutputFile = "",

    [Parameter(Mandatory = $false)]
    [string] $OutputFolder = "",

    [Parameter(Mandatory = $false)]
    [string] $GroupTag = "",

    [Parameter(Mandatory = $false)]
    [string] $AssignedUser = "",

    [Parameter(Mandatory = $false)]
    [switch] $Append,

    [Parameter(Mandatory = $false)]
    [switch] $Partner,

    [Parameter(Mandatory = $false)]
    [switch] $Force,

    [Parameter(Mandatory = $false)]
    [switch] $Online
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

function Write-Info {
    param([string] $Message)
    Write-Host "[INFO] $Message"
}

function Get-SafeFileName {
    param([string] $Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return "UNKNOWN-SERIAL"
    }

    $invalid = [Regex]::Escape(([IO.Path]::GetInvalidFileNameChars() -join ""))
    $safe = $Name.Trim() -replace "[$invalid]", "-"
    $safe = $safe -replace "\s+", "-"

    if ([string]::IsNullOrWhiteSpace($safe)) {
        return "UNKNOWN-SERIAL"
    }

    return $safe
}

function Resolve-OutputPath {
    param(
        [string] $File,
        [string] $Folder,
        [string] $Serial
    )

    if ([string]::IsNullOrWhiteSpace($File)) {
        if ([string]::IsNullOrWhiteSpace($Folder)) {
            $Folder = $PSScriptRoot
        }

        $Folder = [IO.Path]::GetFullPath($Folder)
        if (-not (Test-Path -LiteralPath $Folder)) {
            New-Item -Path $Folder -ItemType Directory -Force | Out-Null
        }

        $safeSerial = Get-SafeFileName -Name $Serial
        return Join-Path -Path $Folder -ChildPath "$safeSerial.csv"
    }

    if ([IO.Path]::IsPathRooted($File)) {
        return $File
    }

    return Join-Path -Path $PSScriptRoot -ChildPath $File
}

function Export-AutopilotCsv {
    param(
        [pscustomobject] $Record,
        [string] $Path,
        [switch] $AppendFile,
        [switch] $PartnerCsv,
        [string] $Tag,
        [string] $User
    )

    $rows = @()

    if ($AppendFile -and (Test-Path -LiteralPath $Path)) {
        $rows += Import-Csv -LiteralPath $Path
    }

    $rows += $Record

    if ($PartnerCsv) {
        $columns = "Device Serial Number", "Windows Product ID", "Hardware Hash", "Manufacturer name", "Device model"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($User)) {
        $columns = "Device Serial Number", "Windows Product ID", "Hardware Hash", "Group Tag", "Assigned User"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Tag)) {
        $columns = "Device Serial Number", "Windows Product ID", "Hardware Hash", "Group Tag"
    }
    else {
        $columns = "Device Serial Number", "Windows Product ID", "Hardware Hash"
    }

    $csv = $rows |
        Select-Object $columns |
        ConvertTo-Csv -NoTypeInformation |
        ForEach-Object { $_ -replace '"', "" }

    Set-Content -LiteralPath $Path -Value $csv -Encoding ASCII
}

try {
    if ($Online) {
        throw "Online import is not handled by this offline USB script. Use the latest Get-WindowsAutoPilotInfo from PowerShell Gallery for -Online."
    }

    Write-Info "Reading BIOS serial number"
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $serial = [string] $bios.SerialNumber
    $serial = $serial.Trim()

    if ([string]::IsNullOrWhiteSpace($serial)) {
        $serial = "UNKNOWN-SERIAL"
    }

    Write-Info "Reading hardware hash"
    $devDetail = $null
    try {
        $devDetail = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -ClassName MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'"
    }
    catch {
        if (-not $Force) {
            throw "Hardware hash is not available from WMI. Run from Windows/OOBE, not bare WinPE, or retry with -Force for Partner CSV metadata only."
        }
    }

    $hash = ""
    if ($devDetail -and $devDetail.DeviceHardwareData -and (-not $Force)) {
        $hash = [string] $devDetail.DeviceHardwareData
    }
    elseif (-not $Partner) {
        throw "Hardware hash is empty. Autopilot CSV export cannot continue."
    }

    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $manufacturer = ([string] $computerSystem.Manufacturer).Trim()
    $model = ([string] $computerSystem.Model).Trim()

    if ($Partner) {
        $record = [pscustomobject] [ordered] @{
            "Device Serial Number" = $serial
            "Windows Product ID"   = ""
            "Hardware Hash"        = $hash
            "Manufacturer name"    = $manufacturer
            "Device model"         = $model
        }
    }
    else {
        $record = [pscustomobject] [ordered] @{
            "Device Serial Number" = $serial
            "Windows Product ID"   = ""
            "Hardware Hash"        = $hash
        }

        if (-not [string]::IsNullOrWhiteSpace($GroupTag)) {
            $record | Add-Member -NotePropertyName "Group Tag" -NotePropertyValue $GroupTag
        }

        if (-not [string]::IsNullOrWhiteSpace($AssignedUser)) {
            if ([string]::IsNullOrWhiteSpace($GroupTag)) {
                $record | Add-Member -NotePropertyName "Group Tag" -NotePropertyValue ""
            }
            $record | Add-Member -NotePropertyName "Assigned User" -NotePropertyValue $AssignedUser
        }
    }

    $resolvedOutput = Resolve-OutputPath -File $OutputFile -Folder $OutputFolder -Serial $serial
    $resolvedFolder = Split-Path -Path $resolvedOutput -Parent

    if (-not (Test-Path -LiteralPath $resolvedFolder)) {
        New-Item -Path $resolvedFolder -ItemType Directory -Force | Out-Null
    }

    Export-AutopilotCsv -Record $record -Path $resolvedOutput -AppendFile:$Append -PartnerCsv:$Partner -Tag $GroupTag -User $AssignedUser

    Write-Host ""
    Write-Host "Serial:       $serial"
    Write-Host "Manufacturer: $manufacturer"
    Write-Host "Model:        $model"
    Write-Host "CSV:          $resolvedOutput"
    Write-Host ""
    Write-Host "Autopilot hardware hash export completed."

    exit 0
}
catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}
