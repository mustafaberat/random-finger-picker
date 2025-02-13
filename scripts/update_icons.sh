#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# Find the first image file in assets directory
ICON_FILES=(assets/icon.*)
SOURCE_ICON="${ICON_FILES[0]}"
TARGET_ICON="assets/icon.png"

echo -e "${YELLOW}🎨 Starting icon update process...${NC}"

# Check if any icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo -e "${RED}❌ No icon found in assets directory. Please add an icon file (e.g., icon.png, icon.jpg, icon.jpeg) to the assets folder.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found icon: $SOURCE_ICON${NC}"

# Create assets directory if it doesn't exist
mkdir -p "assets"

# Convert to PNG if not already PNG
if [[ "$SOURCE_ICON" != *.png ]]; then
    echo -e "${YELLOW}🔄 Converting icon to PNG format...${NC}"
    sips -s format png "$SOURCE_ICON" --out "$TARGET_ICON" > /dev/null 2>&1
else
    echo -e "${GREEN}✓ Icon is already in PNG format${NC}"
    cp "$SOURCE_ICON" "$TARGET_ICON"
fi

# Create temporary directory for processing
TEMP_DIR="temp_icons"
mkdir -p "$TEMP_DIR"

# Define mipmap directories and sizes for Android
MIPMAP_DIRS=(
    "mipmap-mdpi:48"
    "mipmap-hdpi:72"
    "mipmap-xhdpi:96"
    "mipmap-xxhdpi:144"
    "mipmap-xxxhdpi:192"
)

echo -e "${YELLOW}🔍 Updating Android app icons...${NC}"

# Update Android icons
for entry in "${MIPMAP_DIRS[@]}"; do
    dir="${entry%%:*}"
    size="${entry##*:}"
    target_dir="android/app/src/main/res/$dir"
    mkdir -p "$target_dir"
    
    # Create both regular and round icons
    sips -z $size $size "$TARGET_ICON" --out "$target_dir/launcher_icon.png" > /dev/null 2>&1
    cp "$target_dir/launcher_icon.png" "$target_dir/launcher_icon_round.png"
    
    echo -e "${GREEN}✅ Created ${size}x${size} icons in $dir${NC}"
done

# Run flutter pub get to ensure dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Clean build directory
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean

# Generate icons using flutter_launcher_icons
echo -e "${YELLOW}🎯 Generating platform-specific icons...${NC}"
flutter pub run flutter_launcher_icons

# Clean up
echo -e "${YELLOW}🧹 Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✅ App icons have been updated!${NC}"
echo -e "${YELLOW}ℹ️  Icons were generated for:${NC}"
echo "  • Android (adaptive icons)"
echo "  • Web"

echo -e "\n${YELLOW}ℹ️  Next steps:${NC}"
echo "1. Check the generated icons in the Android and Web directories"
echo "2. Run 'flutter clean' and 'flutter pub get' if needed"
echo "3. Rebuild your app with 'flutter build apk' or 'flutter build appbundle'"

# Verify the icon generation
echo -e "\n${YELLOW}🔍 Verifying icon generation...${NC}"

# Check Android icons
if [ -f "android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png" ]; then
    echo -e "${GREEN}✓ Android icons generated${NC}"
else
    echo -e "${RED}✗ Android icons missing${NC}"
fi

# Check web icons
if [ -d "web/icons" ]; then
    echo -e "${GREEN}✓ Web icons generated${NC}"
else
    echo -e "${RED}✗ Web icons missing${NC}"
fi 