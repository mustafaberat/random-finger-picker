#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UPDATE_INTERVAL_DAYS=7  # Number of days between update checks
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FLUTTER_UPDATE_FILE="$PROJECT_ROOT/.flutter_last_update"

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

# Function to check if Flutter needs update
needs_update() {
    if [ ! -f "$FLUTTER_UPDATE_FILE" ]; then
        return 0
    fi
    
    local last_update=$(cat "$FLUTTER_UPDATE_FILE")
    local current_time=$(date +%s)
    local diff_days=$(( ($current_time - $last_update) / 86400 ))
    
    if [ $diff_days -ge $UPDATE_INTERVAL_DAYS ]; then
        return 0
    else
        return 1
    fi
}

# Function to update Flutter
update_flutter() {
    local force_update=${1:-false}
    
    if [ "$force_update" = false ] && ! needs_update; then
        echo -e "${BLUE}ℹ️  Flutter was updated recently. Skipping update check.${NC}"
        echo -e "${BLUE}   Use './release.sh --update' to force an update.${NC}"
        return 0
    fi
    
    echo -e "\n${BLUE}🔄 Updating Flutter...${NC}"
    
    # Switch to stable channel if not already on it
    CURRENT_CHANNEL=$(flutter channel | grep -E "^\* " | cut -d" " -f2)
    if [ "$CURRENT_CHANNEL" != "stable" ]; then
        echo "Switching to stable channel..."
        flutter channel stable
    fi
    
    # Update Flutter
    flutter upgrade
    
    # Update dependencies
    flutter pub upgrade
    
    # Record update time
    date +%s > "$FLUTTER_UPDATE_FILE"
    
    echo -e "${GREEN}✅ Flutter update completed${NC}"
}

# Function to check Flutter version
check_flutter_version() {
    local current_version=$(flutter --version | head -n 1 | awk '{print $2}')
    echo -e "\n${BLUE}ℹ️  Current Flutter version: ${current_version}${NC}"
}

# Parse command line arguments
FORCE_UPDATE=false
for arg in "$@"
do
    case $arg in
        --update)
        FORCE_UPDATE=true
        shift
        ;;
    esac
done

# Show help if requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --update    Force Flutter update regardless of last update time"
    echo "  --help, -h  Show this help message"
    exit 0
fi

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

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
if [ ! -f "../android/key.properties" ]; then
    echo -e "${RED}❌ ../android/key.properties not found. Please set up your signing configuration${NC}"
    exit 1
fi

# Display current Flutter version and update if needed
check_flutter_version
update_flutter $FORCE_UPDATE

# Clean and get dependencies
echo -e "\n${YELLOW}🧹 Cleaning project...${NC}"
flutter clean

echo -e "\n${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Analyze project for issues
echo -e "\n${YELLOW}🔍 Analyzing project...${NC}"
flutter analyze

# Check for any pending changes
echo -e "\n${YELLOW}🔍 Running Flutter doctor...${NC}"
flutter doctor -v

echo -e "\n${YELLOW}🏗️  Building Android release versions...${NC}"

# Create logs directory if it doesn't exist
mkdir -p ../build/logs

# Build APK with optimizations
echo -e "\n${YELLOW}📱 Building APK...${NC}"
flutter build apk --release \
    --target-platform android-arm64 \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --tree-shake-icons \
    > ../build/logs/apk_build.log 2>&1 & 
APK_PID=$!

# Build App Bundle with optimizations
echo -e "\n${YELLOW}📦 Building App Bundle...${NC}"
flutter build appbundle --release \
    --target-platform android-arm64 \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --tree-shake-icons \
    > ../build/logs/bundle_build.log 2>&1 &
BUNDLE_PID=$!

# Show spinners while building
echo -n "📱 APK Build Status: "
spinner $APK_PID
wait $APK_PID || APK_STATUS=$?

echo -n "📦 Bundle Build Status: "
spinner $BUNDLE_PID
wait $BUNDLE_PID || BUNDLE_STATUS=$?

# Clean up unnecessary platform folders
echo -e "\n${YELLOW}🧹 Cleaning up unnecessary platform folders...${NC}"
rm -rf ../build/macos
rm -rf ../build/linux
rm -rf ../build/windows
rm -rf ../build/ios
rm -rf ../build/web

echo -e "\n${YELLOW}Build Complete!${NC} 🎉\n"

# Check and display results
if [ -f "../build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_SIZE=$(ls -lh ../build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
    echo -e "${GREEN}✅ APK created at: build/app/outputs/flutter-apk/app-release.apk${NC}"
    echo "   Size: $APK_SIZE"
    
    # Warning if APK size is too large
    if [ $(echo $APK_SIZE | sed 's/M//') -gt 100 ]; then
        echo -e "${YELLOW}⚠️  Warning: APK size is larger than 100MB${NC}"
    fi
else
    echo -e "${RED}❌ APK build failed${NC}"
    echo "   Check build/logs/apk_build.log for details"
fi

if [ -f "../build/app/outputs/bundle/release/app-release.aab" ]; then
    BUNDLE_SIZE=$(ls -lh ../build/app/outputs/bundle/release/app-release.aab | awk '{print $5}')
    echo -e "${GREEN}✅ App Bundle created at: build/app/outputs/bundle/release/app-release.aab${NC}"
    echo "   Size: $BUNDLE_SIZE"
    
    # Warning if Bundle size is too large
    if [ $(echo $BUNDLE_SIZE | sed 's/M//') -gt 150 ]; then
        echo -e "${YELLOW}⚠️  Warning: App Bundle size is larger than 150MB${NC}"
    fi
else
    echo -e "${RED}❌ App Bundle build failed${NC}"
    echo "   Check build/logs/bundle_build.log for details"
fi

# Provide additional information about the builds
echo -e "\n${BLUE}ℹ️  Additional Information:${NC}"
echo "• Build logs are saved in build/logs/"
echo "• APK build log: build/logs/apk_build.log"
echo "• Bundle build log: build/logs/bundle_build.log"
echo "• If builds failed, check the logs for detailed error messages"

# Open Finder at the APK location
open "/Users/mustafaberataru/Projects/personal/mobile-apps/random_finger_picker/build/app/outputs/bundle/release"

# Final Flutter version check
check_flutter_version