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

# Use iris.icns as the app icon (check for both lowercase and capitalized)
ICON_NAME=""
if [ -f "iris.icns" ]; then
    ICON_NAME="iris.icns"
elif [ -f "Iris.icns" ]; then
    ICON_NAME="Iris.icns"
fi

if [ -z "${ICON_NAME}" ]; then
    echo "⚠️  Warning: iris.icns or Iris.icns not found. App will use system default icon."
    echo "   Place iris.icns in this directory and run ./create-app.sh again."
else
    echo "✅ Found icon: ${ICON_NAME}"
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

# Copy icon if it exists (always name it iris.icns in the bundle)
if [ -n "${ICON_NAME}" ] && [ -f "${ICON_NAME}" ]; then
    cp "${ICON_NAME}" "${RESOURCES_DIR}/iris.icns"
    echo "✅ Icon copied to app bundle as iris.icns"
fi

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
EOF

# Add icon reference if icon exists
if [ -n "${ICON_NAME}" ] && [ -f "${ICON_NAME}" ]; then
    cat >> "${BUNDLE_DIR}/Info.plist" << EOF
    <key>CFBundleIconFile</key>
    <string>iris</string>
EOF
fi

cat >> "${BUNDLE_DIR}/Info.plist" << EOF
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
