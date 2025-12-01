#!/bin/bash
# Build and release new Pumperpal firmware

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <version> <changelog> [beta]"
    echo "Example: $0 2.1.0 'Fixed voltage scaling, added solar optimization'"
    echo "Example: $0 2.2.0-beta 'Testing new sensor logic' beta"
    exit 1
fi

VERSION=$1
CHANGELOG=$2
IS_BETA=${3:-stable}

echo -e "${GREEN}Building Pumperpal firmware v$VERSION...${NC}"

# Build firmware with PlatformIO
cd ../../PumperpalFW/Main/  # Adjust path to your main project
pwd
pio run -e huzzah

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}Build successful!${NC}"

# Copy firmware
if [ "$IS_BETA" == "beta" ]; then
    TARGET_DIR="../../pumperpal-ota/beta"
else
    TARGET_DIR="../../pumperpal-ota"
fi

cp .pio/build/huzzah/firmware.bin $TARGET_DIR/firmware.bin

# Calculate MD5 and size
MD5=$(md5sum $TARGET_DIR/firmware.bin | cut -d' ' -f1)
SIZE=$(stat -f%z $TARGET_DIR/firmware.bin 2>/dev/null || stat -c%s $TARGET_DIR/firmware.bin)
DATE=$(date +%Y-%m-%d)

echo -e "${YELLOW}Firmware Details:${NC}"
echo "  Version: $VERSION"
echo "  Size: $SIZE bytes"
echo "  MD5: $MD5"
echo "  Date: $DATE"

# Update version.txt (just the version number)
echo "$VERSION" > $TARGET_DIR/version.txt
echo -e "${GREEN}✓ Updated version.txt${NC}"

# Update version.json
if [ "$IS_BETA" == "beta" ]; then
    URL="https://raw.githubusercontent.com/maheshbrahmi/pumperpal-ota/main/beta/firmware.bin"
else
    URL="https://raw.githubusercontent.com/maheshbrahmi/pumperpal-ota/main/firmware.bin"
fi

cat > $TARGET_DIR/version.json <<EOF
{
  "version": "$VERSION",
  "mandatory": false,
  "min_battery_mv": 3700,
  "changelog": "$CHANGELOG",
  "url": "$URL",
  "size": $SIZE,
  "md5": "$MD5",
  "release_date": "$DATE",
  "rollout_percentage": 100
}
EOF
echo -e "${GREEN}✓ Updated version.json${NC}"

echo "PWD"
pwd

# Archive current version (if stable)
if [ "$IS_BETA" != "beta" ]; then
    echo -e "${GREEN}Archiving version $VERSION...${NC}"
    mkdir -p ../../pumperpal-ota/archive/v$VERSION
    cp $TARGET_DIR/firmware.bin ../../pumperpal-ota/archive/v$VERSION/
    cp $TARGET_DIR/version.json ../../pumperpal-ota/archive/v$VERSION/
    cp $TARGET_DIR/version.txt ../../pumperpal-ota/archive/v$VERSION/
fi

# Git operations
cd ../../pumperpal-ota
git add .
git commit -m "Release v$VERSION: $CHANGELOG"
git push

echo -e "${GREEN}✓ Firmware v$VERSION released successfully!${NC}"
echo -e "${YELLOW}GitHub Pages will update in 1-5 minutes...${NC}"
echo -e "${YELLOW}Devices will receive update within 96 hours.${NC}"

# Optional: Wait and verify
echo -e "\n${YELLOW}Waiting for GitHub Pages to update...${NC}"
sleep 60  # Wait 1 minute

# Test if the new version is accessible
echo -e "Testing GitHub Pages deployment..."
DEPLOYED_VERSION=$(curl -s https://maheshbrahmi.github.io/pumperpal-ota/version.txt)
if [ "$DEPLOYED_VERSION" == "$VERSION" ]; then
    echo -e "${GREEN}✓ Version $VERSION is now live on GitHub Pages!${NC}"
else
    echo -e "${YELLOW}⚠ GitHub Pages not updated yet. It may take a few more minutes.${NC}"
fi
