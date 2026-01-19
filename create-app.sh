#!/bin/bash

# Script to create a macOS .app bundle from the Swift Package

set -e

APP_NAME="TwentyTwentyTwenty"
BUNDLE_NAME="${APP_NAME}.app"
BUILD_DIR=".build/release"
BUNDLE_DIR="${BUNDLE_NAME}/Contents"
MACOS_DIR="${BUNDLE_DIR}/MacOS"
RESOURCES_DIR="${BUNDLE_DIR}/Resources"

echo "Building ${APP_NAME}..."
swift build -c release

if [ ! -f "${BUILD_DIR}/${APP_NAME}" ]; then
    echo "Error: Executable not found at ${BUILD_DIR}/${APP_NAME}"
    exit 1
fi

echo "Creating .app bundle structure..."

# Remove existing bundle if it exists
rm -rf "${BUNDLE_NAME}"

# Create bundle structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Create Info.plist
cat > "${BUNDLE_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.twentytwentytwenty.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024</string>
</dict>
</plist>
EOF

echo "✅ Created ${BUNDLE_NAME}"
echo ""
echo "You can now:"
echo "  1. Double-click ${BUNDLE_NAME} to run it"
echo "  2. Drag it to /Applications to install"
echo ""
echo "To create a DMG for distribution, run: ./create-dmg.sh"
