# Publication Review

This project is maintained as a public-safe version of the Windows 11 Autopilot provisioning guide.

## Confirmed cleanup

- Internal Azure group names are represented with placeholders.
- Internal Intune group names are represented with placeholders.
- Internal Teams channels, named contacts, and escalation details are represented with a generic escalation-matrix instruction.
- Internal UNC paths are represented with placeholders.
- Internal Wi-Fi SSIDs are represented as approved guest Wi-Fi.
- Screenshots showing organization, tenant, profile, QR, or network details were redacted or omitted.
- The technician USB label is generic: `AUTOPILOTUSB`.
- Technician USB tools are included, but generated hardware hash CSV files are ignored by `.gitignore`.

## Public-safe placeholders used

- `<Autopilot all-users group>`
- `<Regional Autopilot users group>`
- `<Temporary corporate Wi-Fi exclusion group>`
- `<approved internal Autopilot HWID upload path>`

## Publication guidance

Keep real tenant names, support contacts, group names, upload paths, Wi-Fi names, and screenshots with organization details out of the public repository. If an internal team needs exact values, maintain them in a private appendix or in the company escalation matrix.
