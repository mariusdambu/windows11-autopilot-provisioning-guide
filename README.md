# Windows 11 Autopilot Provisioning Guide

A portable English guide for preparing Windows 11 installation media and provisioning devices with Windows Autopilot. It covers OOBE, ISO and WIM handling, and a technician USB toolkit.

Open index.html in a browser. Use its Print control to print or export the guide; command blocks include Copy buttons.

## Project structure

    .
    +-- index.html
    +-- README.md
    +-- PUBLICATION_REVIEW.md
    +-- assets/
    +-- tools/
        +-- technician-usb/
            +-- menu.cmd
            +-- SelectModel.cmd
            +-- HardwareIDs/
            +-- scripts/
                +-- clean_disk0.txt
                +-- Get-AutopilotHash.ps1
                +-- Get-AutopilotDiagnosticsCommunity.ps1
                +-- read_me.txt

## Technician USB toolkit

Copy the contents of tools/technician-usb to the root of official Windows 11 installation media. Preserve the existing Windows setup files and folders, especially boot, efi, and sources; the WIM manager expects sources to exist. Add the model image folders alongside the setup folders as described in the guide.

Launch menu.cmd from Command Prompt during OOBE (Shift+F10). The unified menu provides:

- Offline Autopilot hardware-hash capture, with generic Group Tag presets, custom entry, or no tag.
- Local Autopilot diagnostics.
- WIM image management through SelectModel.cmd.
- Quick Disk 0 wipe and a separate wipe that requires typing ERASE.
- Disk, DiskPart, PowerShell, Wi-Fi, network, serial-number, time-sync, and MDM-sync utilities.

Disk wipe warning: Quick Wipe runs immediately against Disk 0. Both wipe paths use DiskPart clean and convert the disk to GPT. Verify the target device and data before using either path.

Get-AutopilotHash.ps1 reads the local Windows MDM hardware-detail provider and writes an Intune-compatible CSV under HardwareIDs. It does not install modules or download from PowerShell Gallery. Run it in Windows/OOBE; a bare WinPE environment may not expose the required provider. Group Tag presets are generic examples: confirm they match the destination tenant's enrollment design before use.

SelectModel.cmd requires the official media's sources folder and does not create it. It moves install.wim between the media folder and model folders; keep backups of deployment images.

## Public-safe content

The published toolkit uses generic Group Tag profiles and contains no tenant credentials or hardware-hash CSV data. Generated CSV files are ignored by Git. See PUBLICATION_REVIEW.md before publishing changes.

## Guide scope

The guide separates Windows media preparation, image servicing, ISO rebuilding, and USB creation. Manual DISM examples use the generic C:\Lab_Win11\Trabajo workspace convention. Review commands and paths for your environment before running them.
