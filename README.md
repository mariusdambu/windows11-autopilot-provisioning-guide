# Windows 11 Autopilot ISO - Provisioning Procedure

This project contains a portable English HTML version of a Windows 11 Autopilot ISO provisioning procedure for enterprise technicians.

Author: Marius Dambu

## Open the guide

Open `index.html` in a browser. The page has a built-in **Print** button that can be used to print the guide or export it from the browser print dialog.
Command blocks also include **Copy** buttons for one-click command copying.

## Project structure

```text
.
+-- index.html
+-- README.md
+-- assets
    +-- css
    |   +-- styles.css
    +-- js
    |   +-- print.js
    +-- img
        +-- *.jpg
+-- tools
    +-- technician-usb
        +-- safeworkbench-en.cmd
        +-- workbench-en.cmd
        +-- Run-HWID.cmd
        +-- Run-AutopilotDiagnostics.cmd
        +-- clean_disk0.txt
        +-- scripts
        +-- GetAutoPilot
```

## Important notes

- This is a public-safe version. Organization-specific group names, support contacts, network names, and internal upload paths are represented with placeholders.
- Screenshots were redacted or omitted where they contained tenant/profile/QR data, organization names, or Wi-Fi SSIDs.
- Technician USB tools are included under `tools/technician-usb`.
- `safeworkbench-en.cmd` is recommended for technicians because it asks for confirmation before wiping Disk 0.
- `GetAutoPilot/GetAutoPilot.CMD` is included as an additional second option for local hardware hash export.
- Command blocks wrap on screen and in print so long DISM commands remain visible while still copying correctly with the Copy button.
- Keep any internal version containing real tenant names, support contacts, or network paths in a private location.

## Prepare the technician USB

1. After downloading or cloning this project, open the project folder.
2. Copy everything inside `tools/technician-usb` to the root of the technician USB.
3. The USB root should contain `safeworkbench-en.cmd`, `workbench-en.cmd`, `Run-HWID.cmd`, `Run-AutopilotDiagnostics.cmd`, `clean_disk0.txt`, `scripts`, `GetAutoPilot`, and `HardwareIDs`.
4. Keep the `scripts` and `GetAutoPilot` folders next to the CMD files.
5. Create a `HardwareIDs` folder at the root of the USB if it is missing.
6. Rename the USB volume label to exactly `AUTOPILOTUSB` before running HWID capture.
7. Run `safeworkbench-en.cmd` as the preferred technician menu.

## GitHub status

This public-safe version is structured for GitHub Pages.
