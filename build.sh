#!/bin/bash

# Abort on errors
set -e

echo "Starting Vercel Flutter Web Build..."

# Install Flutter if it doesn't exist
if [ ! -d "flutter" ]; then
    echo "Cloning Flutter repository..."
    git clone https://github.com/flutter/flutter.git -b stable
fi

# Add Flutter to the path
export PATH="$PATH:$PWD/flutter/bin"

# Pre-download dependencies
echo "Downloading dependencies..."
flutter pub get

# Build Web Project
echo "Building Flutter Web..."
flutter build web

echo "Build complete."
