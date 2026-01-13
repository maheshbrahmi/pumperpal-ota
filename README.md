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
cp /path/to/your/project/.pio/build/huzzah/firmware.bin ./pumperpa-ota/firmware.bin

# Commit and push
git add .
git commit -m "Initial release v2.1.0"
git push

# Staged Rollout (Recommended):
cpp// In version.json, use device groups
{
  "version": "2.1.0",
  "rollout_percentage": 10,  // Start with 10% of devices
  "mandatory": false,
  "devices": ["E8:DB:84:96:F4:9F"],  // Or specific test devices
  ...
}

# Emergency Rollback:
cpp// Keep previous version accessible
// If issues detected, quickly update version.json to point to old firmware
{
  "version": "2.0.0",  // Rollback version
  "mandatory": true,   // Force downgrade
  "changelog": "Rollback due to issue with 2.1.0",
  ...
}

# Quick Start Commands
### Once you've created the repository and structure:
bash# 1. Clone your OTA repo
git clone https://github.com/YOUR_USERNAME/pumperpal-ota.git
cd pumperpal-ota

# 2. Create folder structure
mkdir -p beta archive scripts
touch version.json beta/version.json

# 3. Make scripts executable
chmod +x scripts/*.sh

# 4. Do your first release
./scripts/build_and_release.sh 2.1.0 "Solar optimization, fixed voltage scaling"

## Step 5: Your First OTA Update

Change version in your main code:

cppconst String FirmwareVer = {"2.1.1"};  // Increment version

Build new firmware:

bashpio run -e huzzah

Update GitHub:

bashcd pumperpal-ota
echo "2.1.1" > version.txt
cp /path/to/.pio/build/huzzah/firmware.bin ./firmware.bin
git add .
git commit -m "Update to v2.1.1"
git push

Test on device:

Hold config button during boot
Watch serial monitor
Should see update download and install



## Step 6: Production Configuration
Once testing works, update your main code:
cpp// In your main code, enable OTA
#define FIRMWARE_UPDATE_ENABLE 1  // Set to 1 to enable

// Adjust check frequency if needed
#define FIRMWARE_COUNT 4  // Check every 4 days (96 hours)
Troubleshooting
"Failed to connect to version URL"

Check repo is PUBLIC
Verify USERNAME is correct in URLs
Wait 1-2 minutes after push (GitHub cache)

"Version check failed, HTTP code: 404"

File not found - check spelling
Ensure files are in main branch
Check URL in browser first

"Already on latest version"

Version in version.txt must be HIGHER than device version
Check serial output for version comparison

OTA Fails at Download

Ensure firmware.bin is less than 50% of flash (usually < 500KB)
Check WiFi signal strength
Verify battery > 3.7V

Simple Release Workflow
For future releases:

Update version in code: const String FirmwareVer = {"2.2.0"};
Build: pio run -e huzzah
Update version.txt: echo "2.2.0" > version.txt
Copy firmware: cp firmware.bin pumperpal-ota/
Push to GitHub: git add . && git commit -m "v2.2.0" && git push

## TO BUILD AND RELEASE make sure that the pumperpla-ota is on the same level as pumperpalFW (Desktop) Then cd scripts folder and run this script. 
./build_and_release.sh 2.1.1-beta 'Fixed voltage scaling'
or
./build_and_release.sh 2.1.1 'Fixed voltage scaling'

# For stable release:
.\build-release.ps1 -Version "2.1.0" -Changelog "Fixed voltage scaling, added solar optimization"

# For beta release:
.\build-release.ps1 -Version "2.2.0-beta" -Changelog "Testing new sensor logic" -Type beta

# With verbose output:
.\build-release.ps1 -Version "2.3.0" -Changelog "New features" -Verbose

# Check serial port: powershell   # PowerShell
   [System.IO.Ports.SerialPort]::getportnames()
   
   # Or in Device Manager
   devmgmt.msc

# Upload latest stable firmware (auto-detect port)
.\upload-latest.ps1

# Upload latest stable firmware to specific port
.\upload-latest.ps1 -Port COM17

# Upload beta firmware
.\upload-latest.ps1 -Beta -Port COM17

# Upload and open serial monitor
.\upload-latest.ps1 -Port COM17 -Monitor

# Build, release, and upload in one go
.\build-release.ps1 -Version "2.3.0" -Changelog "Bug fixes"
# Then answer 'y' when prompted to upload

# From any directory where your scripts are:
python -m esptool --port COM17 --baud 921600 write_flash 0x00000 "..\..\pumperpal-ota\firmware.bin"

export PATH="/Users/mac/.platformio/penv/bin:$PATH"

./build_and_release.sh 2.4.4 '2.4.4'