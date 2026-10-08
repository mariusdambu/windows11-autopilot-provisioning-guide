# Publication Review

This repository is maintained as a public-safe Windows 11 Autopilot provisioning guide and technician toolkit.

## Public-safety checks

- Tenant-specific group names, support contacts, network names, internal upload paths, and screenshots with organization details are represented with placeholders or omitted.
- The technician toolkit uses generic Group Tag profile examples; teams must adapt them to their own tenant before use.
- The local hardware-hash capture workflow does not download scripts from PowerShell Gallery and does not upload CSVs automatically.
- Generated hardware-hash CSV files are excluded by .gitignore.
- No tenant credentials, device serials, or generated hardware-hash records should be committed.
- The Disk 0 wipe actions and their destructive behavior are documented in the tool README and guide.

## Before publishing

Review added screenshots, commands, sample data, image paths, and support instructions for tenant identifiers or private operational details. Keep real group names, upload paths, Wi-Fi names, contacts, and tenant information out of the public repository.
