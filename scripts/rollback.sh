#!/bin/bash
# Emergency rollback script

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 2.0.0"
    exit 1
fi

VERSION=$1
ARCHIVE_DIR="archive/v$VERSION"

if [ ! -d "$ARCHIVE_DIR" ]; then
    echo "Error: Version $VERSION not found in archive"
    exit 1
fi

echo "Rolling back to v$VERSION..."

# Copy archived version to main
cp $ARCHIVE_DIR/firmware.bin ./firmware.bin

# Update version.json with mandatory flag
jq '.mandatory = true | .changelog = "Emergency rollback to v'$VERSION'"' \
   $ARCHIVE_DIR/version.json > version.json

# Commit and push
git add .
git commit -m "ROLLBACK to v$VERSION"
git push

echo "✓ Rollback complete. All devices will downgrade to v$VERSION"