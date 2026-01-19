#!/bin/bash

# Build script for 20-20-20 Rule macOS App

echo "Building 20-20-20 Rule App..."

# Build the release version
swift build -c release

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "To run the app, use: swift run -c release"
else
    echo "Build failed!"
    exit 1
fi
