#!/bin/bash

# Script to create an app icon
# This creates a simple eye icon for the app

set -e

ICON_NAME="AppIcon.icns"
ICONSET_DIR="AppIcon.iconset"

echo "Creating app icon..."

# Remove old files
rm -rf "${ICONSET_DIR}" "${ICON_NAME}"
mkdir -p "${ICONSET_DIR}"

# Check if we can use Python with pyobjc (for AppKit access)
if python3 -c "import objc; from AppKit import NSImage, NSColor, NSBezierPath" 2>/dev/null; then
    echo "Using PyObjC to create icon..."
    python3 << 'PYTHON_EOF'
from AppKit import NSImage, NSColor, NSBezierPath, NSGraphicsContext
import os

def create_icon(size, path):
    img = NSImage.alloc().initWithSize_((size, size))
    img.lockFocus()
    
    # Blue background circle
    NSColor.systemBlueColor().set()
    margin = size * 0.1
    path_obj = NSBezierPath.bezierPathWithOvalInRect_(((margin, margin), (size - 2*margin, size - 2*margin)))
    path_obj.fill()
    
    # White eye shape
    NSColor.whiteColor().set()
    eye_w = size * 0.6
    eye_h = size * 0.4
    eye_x = (size - eye_w) / 2
    eye_y = (size - eye_h) / 2
    eye_path = NSBezierPath.bezierPathWithOvalInRect_(((eye_x, eye_y), (eye_w, eye_h)))
    eye_path.fill()
    
    # Black pupil
    NSColor.blackColor().set()
    pupil_size = size * 0.25
    pupil_x = (size - pupil_size) / 2
    pupil_y = (size - pupil_size) / 2
    pupil_path = NSBezierPath.bezierPathWithOvalInRect_(((pupil_x, pupil_y), (pupil_size, pupil_size)))
    pupil_path.fill()
    
    img.unlockFocus()
    
    # Save as PNG via TIFF
    tiff_data = img.TIFFRepresentation()
    from AppKit import NSBitmapImageRep
    bitmap = NSBitmapImageRep.imageRepWithData_(tiff_data)
    png_data = bitmap.representationUsingType_properties_(4, None)  # NSPNGFileType = 4
    if png_data:
        png_data.writeToFile_atomically_(path, True)
        print(f"Created {os.path.basename(path)}")

sizes = {
    'icon_16x16.png': 16, 'icon_16x16@2x.png': 32,
    'icon_32x32.png': 32, 'icon_32x32@2x.png': 64,
    'icon_128x128.png': 128, 'icon_128x128@2x.png': 256,
    'icon_256x256.png': 256, 'icon_256x256@2x.png': 512,
    'icon_512x512.png': 512, 'icon_512x512@2x.png': 1024,
}

iconset_dir = 'AppIcon.iconset'
for filename, size in sizes.items():
    create_icon(size, os.path.join(iconset_dir, filename))

print("All icons created!")
PYTHON_EOF

    if [ $? -eq 0 ] && [ -f "${ICONSET_DIR}/icon_512x512.png" ]; then
        # Convert to icns
        iconutil -c icns "${ICONSET_DIR}" -o "${ICON_NAME}"
        rm -rf "${ICONSET_DIR}"
        echo "✅ Created ${ICON_NAME}"
        exit 0
    fi
fi

# Fallback: Provide instructions
echo ""
echo "⚠️  Could not automatically create icon (PyObjC not available)."
echo ""
echo "To create the icon, you have two options:"
echo ""
echo "Option 1: Install PyObjC (recommended)"
echo "  pip3 install --user pyobjc-framework-AppKit"
echo "  Then run: ./create-icon.sh"
echo ""
echo "Option 2: Use a custom icon"
echo "  1. Create or download an AppIcon.icns file"
echo "  2. Place it in this directory"
echo "  3. Run ./create-app.sh (it will use the existing icon)"
echo ""
echo "For now, creating a placeholder..."
touch "${ICON_NAME}"
echo "Placeholder created. Replace AppIcon.icns with your custom icon."
