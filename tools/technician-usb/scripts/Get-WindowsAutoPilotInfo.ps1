# Script based on Microsoft's Get-WindowsAutopilotInfo workflow with helper logic for USB export.

#Puts the SerialNumber into a variable for the CSV file, for easy identification
$serial = (Get-CimInstance Win32_BIOS).SerialNumber
sleep 5

#HWID Capture Script created by Microsoft
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$folderPath = "C:\HWID"
if (Test-Path $folderPath) {
Write-Output "HWID Folder exists." }
	else{
New-Item -Type Directory -Path "C:\HWID"
}
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo -Force
Get-WindowsAutopilotInfo -OutputFile $serial-AutopilotHWID.csv
sleep 5

#Sets USB Drive File Output for copying the HWID file created above
$usbDrive = Get-Volume | Where-Object { $_.FileSystemLabel -eq 'AUTOPILOTUSB' }

if ($usbDrive) {
    $usbPath = $usbDrive.DriveLetter + ":\"
    $sourceFile = "C:\HWID\*.csv"
    $destinationFile = Join-Path $usbPath "HardwareIDs\$serial-HWID.csv"

    Copy-Item -Path $sourceFile -Destination $destinationFile -Force
    Write-Host "File copied to $destinationFile"
} else {
    Write-Host "Drive with label 'AUTOPILOTUSB' not found."
}
Write-Host "Reboot the machine and upload the Hardware ID file to the approved enrollment location."

