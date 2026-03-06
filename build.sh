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

# Generate .env file from Vercel's injected environment variables
echo "Generating .env file..."
cat << EOF > .env
TURSO_URL=$TURSO_URL
TURSO_AUTH_TOKEN=$TURSO_AUTH_TOKEN
EOF

# Build Web Project
echo "Building Flutter Web..."
flutter build web

echo "Build complete."
