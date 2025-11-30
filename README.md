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

/Users/mac/Desktop/PumperpalFW/Main/.pio/build/huzzah

# Clone your new repo
git clone https://github.com/YOUR_USERNAME/pumperpal-ota.git
cd pumperpal-ota

# Create version.txt
echo "2.1.0" > version.txt

# Copy your firmware
cp /path/to/your/project/.pio/build/huzzah/firmware.bin ./firmware.bin

# Commit and push
git add .
git commit -m "Initial release v2.1.0"
git push