# Technician USB Tools

After downloading or cloning the project, copy the contents of this folder to the root of the technician USB.
Do not copy the parent project folder itself; copy the files and folders inside `tools/technician-usb`.

## Required USB layout

```text
<USB root>
+-- safeworkbench-en.cmd
+-- workbench-en.cmd
+-- Run-HWID.cmd
+-- Run-AutopilotDiagnostics.cmd
+-- clean_disk0.txt
+-- HardwareIDs
+-- scripts
|   +-- Get-WindowsAutoPilotInfo.ps1
|   +-- Get-AutopilotDiagnosticsCommunity.ps1
|   +-- read_me.txt
+-- GetAutoPilot
    +-- GetAutoPilot.CMD
    +-- Get-WindowsAutoPilotInfo.ps1
```

## Before running hardware hash capture

1. Rename the USB volume label to exactly `AUTOPILOTUSB`.
2. Make sure the `HardwareIDs` folder exists at the USB root.
3. For the recommended method, connect the laptop to an approved Wi-Fi or approved non-corporate network with internet access.
4. Run `safeworkbench-en.cmd`.
5. Select option `4 - Create hardware hash file (recommended - Wi-Fi)`.
6. If Wi-Fi cannot be connected or the PowerShell Gallery download fails, select `5 - Create hardware hash file (offline fallback)`.
7. Confirm that the CSV is copied to `HardwareIDs\<Serial>-HWID.csv`.
8. Do not open or edit the hardware hash CSV in Excel. Upload the generated CSV unchanged.

## Additional GetAutoPilot option

`GetAutoPilot\GetAutoPilot.CMD` is an additional offline second option for local hardware hash export.
It runs the local script in the `GetAutoPilot` folder and saves the CSV output in that same folder.
It does not upload the CSV to Intune and does not enroll the device.

Use this helper when Wi-Fi cannot be connected or when the recommended method cannot download
`Get-WindowsAutopilotInfo` from PowerShell Gallery.
Do not open or edit the hardware hash CSV in Excel. Upload the generated CSV unchanged.

## Safety warning

`safeworkbench-en.cmd` is the recommended menu. It requires typing `ERASE` before wiping Disk 0.
`workbench-en.cmd` can wipe Disk 0 with fewer safeguards and should be used only when the technician is certain.
