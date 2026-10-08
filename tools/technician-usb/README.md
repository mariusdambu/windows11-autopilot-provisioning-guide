# Technician USB Tools

Copy the contents of this folder to the root of official Windows 11 installation media. Keep the existing Windows setup files and folders, including boot, efi, sources, and support. Do not replace those folders. Keep the model image folders beside them.

## Layout

    <Windows 11 USB root>
    +-- menu.cmd
    +-- SelectModel.cmd
    +-- HardwareIDs/
    +-- scripts/
        +-- clean_disk0.txt
        +-- Get-AutopilotHash.ps1
        +-- Get-AutopilotDiagnosticsCommunity.ps1
        +-- read_me.txt

Start menu.cmd from Command Prompt in OOBE (Shift+F10). Menu options include:

- 1 — Capture Autopilot Hash: offline local capture, then choose a generic Group Tag, enter a custom tag, or press Enter to omit it. CSV output is saved in HardwareIDs.
- 2 — Autopilot Diagnostics: runs the included community diagnostics script.
- 3 — WIM Image Manager: SelectModel.cmd returns or activates install.wim. It requires the media sources folder; a missing folder is reported as an integrity error and is not created.
- 4 — Quick Wipe Disk 0: runs immediately without a text confirmation.
- 5 — Safe Wipe Disk 0: requires typing ERASE.

Destructive operation: Both wipe options run DiskPart clean on Disk 0 and convert it to GPT. Confirm the correct target and that its data can be erased before continuing. clean removes partition information; it is not a secure data-erasure method.

Other menu utilities show disks and network details, open DiskPart or PowerShell, launch Wi-Fi settings, show the BIOS serial number, and trigger time or MDM synchronization. Network-dependent operations require working connectivity and may not be available in every OOBE/SYSTEM context.

## Hardware hash notes

The included hash script queries MDM_DevDetail_Ext01 locally and does not call PowerShell Gallery. The provider is available in supported Windows/OOBE environments; bare WinPE may not expose it. The CSV is not uploaded automatically and should be handled according to your organization's approved process.

Generic Group Tag names are examples. Adapt them to the destination tenant before deployment. Custom entry and no-tag capture remain available.

## WIM notes

Keep SelectModel.cmd at the USB root, sources intact, and model folders at the root. The script deliberately does not create a missing sources folder. Back up images before moving or replacing them.
