#!/bin/bash

# Exit on error
set -e

echo "🧹 Cleaning up backup files..."

# Define mipmap directories
MIPMAP_DIRS=(
    "android/app/src/main/res/mipmap-mdpi"
    "android/app/src/main/res/mipmap-hdpi"
    "android/app/src/main/res/mipmap-xhdpi"
    "android/app/src/main/res/mipmap-xxhdpi"
    "android/app/src/main/res/mipmap-xxxhdpi"
)

# Remove backup files
for dir in "${MIPMAP_DIRS[@]}"; do
    if [ -f "$dir/ic_launcher.png.backup" ]; then
        rm "$dir/ic_launcher.png.backup"
        echo "✅ Removed backup from $dir"
    fi
done

echo "✅ Cleanup complete!" 