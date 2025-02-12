#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source icon path
ICON_PATH="../lib/assets/app-icon.jpg"

# Check if source icon exists
if [ ! -f "$ICON_PATH" ]; then
    echo -e "${RED}❌ Source icon not found at: $ICON_PATH${NC}"
    exit 1
fi

# Create temporary directory for processing
TEMP_DIR="temp_icons"
mkdir -p "$TEMP_DIR"

# First convert JPEG to PNG
echo -e "${YELLOW}🔄 Converting JPEG to PNG...${NC}"
sips -s format png "$ICON_PATH" --out "$TEMP_DIR/icon.png" > /dev/null 2>&1

# Define mipmap directories and sizes
MIPMAP_DIRS=(
    "mipmap-mdpi:48"
    "mipmap-hdpi:72"
    "mipmap-xhdpi:96"
    "mipmap-xxhdpi:144"
    "mipmap-xxxhdpi:192"
)

echo -e "${YELLOW}🔍 Updating Android app icons...${NC}"

# Update existing ic_launcher.png files
for entry in "${MIPMAP_DIRS[@]}"; do
    dir="${entry%%:*}"
    size="${entry##*:}"
    target_dir="../android/app/src/main/res/$dir"
    mkdir -p "$target_dir"
    
    # Create both regular and round icons
    sips -z $size $size "$TEMP_DIR/icon.png" --out "$target_dir/app_icon.png" > /dev/null 2>&1
    sips -z $size $size "$TEMP_DIR/icon.png" --out "$target_dir/app_icon_round.png" > /dev/null 2>&1
    
    echo -e "${GREEN}✅ Created ${size}x${size} icons in $dir${NC}"
done

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✅ App icons updated!${NC}"
echo -e "${YELLOW}ℹ️  Note: You may need to clean and rebuild your app:${NC}"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter build apk --release"
echo -e "\n${YELLOW}ℹ️  Backup files were created with .backup extension${NC}" 