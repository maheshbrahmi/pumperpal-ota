# Pumperpal OTA Updates

This repository contains firmware updates for Pumperpal IoT devices.

## Current Version
- **Stable**: v2.1.0
- **Beta**: v2.2.0-beta

## Update Schedule
- Devices check for updates every 96 hours
- Updates only occur when battery > 3.7V or charging
- Solar-optimized for midday updates

## Version History
See [archive/](archive/) for previous versions.

## Emergency Rollback
To rollback all devices, run:
\`\`\`bash
./scripts/rollback.sh 2.0.0
\`\`\`

pumperpal-ota/
├── README.md
├── version.json
├── firmware.bin
├── beta/
│   ├── version.json
│   └── firmware.bin
├── archive/
│   └── README.md
└── scripts/
    ├── build_and_release.sh
    └── rollback.sh
Emergency Stop
bash# Set rollout to 0%
echo '{"rollout_percentage": 0}' > version.json
git commit -am "STOP OTA"
git push
