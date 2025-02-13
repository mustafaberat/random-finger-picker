#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show spinner while tasks are running
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check for Flutter
if ! command_exists flutter; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter and add it to your PATH${NC}"
    exit 1
fi

# Check for Java
if ! command_exists java; then
    echo -e "${RED}❌ Java not found. Please install JDK and add it to your PATH${NC}"
    exit 1
fi

# Check for key.properties
if [ ! -f "android/key.properties" ]; then
    echo -e "${RED}❌ android/key.properties not found. Please set up your signing configuration${NC}"
    exit 1
fi

# Clean and optimize
echo -e "\n${YELLOW}🧹 Cleaning project...${NC}"
flutter clean

echo -e "\n${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Optimize assets
echo -e "\n${YELLOW}🎨 Optimizing assets...${NC}"
if command_exists optipng; then
    find assets -name "*.png" -exec optipng -o5 {} \;
else
    echo -e "${YELLOW}⚠️  optipng not found. Skipping PNG optimization${NC}"
fi

# Check for any issues
echo -e "\n${YELLOW}🔍 Running Flutter doctor...${NC}"
flutter doctor

# Create logs directory
mkdir -p build/logs

echo -e "\n${YELLOW}🏗️  Building release versions...${NC}"

# Build optimized APK
echo -e "\n${YELLOW}📱 Building APK...${NC}"
flutter build apk --release \
    --target-platform android-arm64,android-arm \
    --split-per-abi \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --tree-shake-icons > build/logs/apk_build.log 2>&1 &
APK_PID=$!

# Build optimized App Bundle
echo -e "\n${YELLOW}📦 Building App Bundle...${NC}"
flutter build appbundle --release \
    --target-platform android-arm64,android-arm \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --tree-shake-icons > build/logs/bundle_build.log 2>&1 &
BUNDLE_PID=$!

# Show spinners while building
echo -n "📱 APK Build Status: "
spinner $APK_PID
wait $APK_PID || APK_STATUS=$?

echo -n "📦 Bundle Build Status: "
spinner $BUNDLE_PID
wait $BUNDLE_PID || BUNDLE_STATUS=$?

echo -e "\n${YELLOW}Build Complete!${NC} 🎉\n"

# Check and display results


# Check for split APKs and display their sizes
if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
    echo -e "${GREEN}✅ arm64-v8a APK created at: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk${NC}"
    echo "   Size: $(ls -lh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk | awk '{print $5}')"
fi

if [ -f "build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" ]; then
    echo -e "${GREEN}✅ armeabi-v7a APK created at: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk${NC}"
    echo "   Size: $(ls -lh build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk | awk '{print $5}')"
fi

# If neither APK exists, notify the user
if [ ! -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ] && [ ! -f "build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" ]; then
    echo -e "${RED}❌ No APKs found in build/app/outputs/flutter-apk/${NC}"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo -e "${GREEN}✅ App Bundle created at: build/app/outputs/bundle/release/app-release.aab${NC}"
    echo "   Size: $(ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print $5}')"
else
    echo -e "${RED}❌ App Bundle build failed${NC}"
    echo "   Check build/logs/bundle_build.log for details"
fi

# Provide additional information about the builds
echo -e "\n${YELLOW}ℹ️  Additional Information:${NC}"
echo "• Build logs are saved in build/logs/"
echo "• Debug symbols are saved in build/debug-info/"
echo "• Split APKs are available for different architectures"
echo "• App Bundle will be further optimized by the Play Store"