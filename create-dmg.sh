#!/bin/bash

# Script to create a DMG file for distribution

set -e

APP_NAME="TwentyTwentyTwenty"
BUNDLE_NAME="${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"
VOLUME_NAME="20-20-20 Rule"

echo "Creating DMG..."

# First, make sure the .app exists
if [ ! -d "${BUNDLE_NAME}" ]; then
    echo "App bundle not found. Creating it first..."
    ./create-app.sh
else
    echo "Using existing app bundle (icon will be included if present in .app)"
fi

# Remove existing DMG if it exists
rm -f "${DMG_NAME}"

# Create a temporary directory for DMG contents
TEMP_DMG_DIR="temp_dmg"
rm -rf "${TEMP_DMG_DIR}"
mkdir -p "${TEMP_DMG_DIR}"

# Copy app to temp directory (includes icon if it was added during create-app.sh)
cp -R "${BUNDLE_NAME}" "${TEMP_DMG_DIR}/"

# Create Applications symlink
ln -s /Applications "${TEMP_DMG_DIR}/Applications"

# Create DMG
hdiutil create -volname "${VOLUME_NAME}" -srcfolder "${TEMP_DMG_DIR}" -ov -format UDZO "${DMG_NAME}"

# Clean up
rm -rf "${TEMP_DMG_DIR}"

echo "✅ Created ${DMG_NAME}"
echo ""
echo "Users can:"
echo "  1. Double-click ${DMG_NAME} to mount it"
echo "  2. Drag ${BUNDLE_NAME} to Applications folder"
echo "  3. Eject the DMG"
