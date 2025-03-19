#!/bin/bash

# Get the script's directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Create logs directory and file
LOG_FILE="$PROJECT_ROOT/logs/apk_build.log"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Function to show a spinner animation
show_spinner() {
    local pid=$1
    local delay=0.1
    local spin='|/-\'
    while ps -p $pid > /dev/null; do
        for i in $(seq 0 3); do
            echo -ne "\r${spin:$i:1}"
            sleep $delay
        done
    done
    echo -ne "\r"
}

# Change to project root directory
cd "$PROJECT_ROOT" || exit 1

# Build process
echo "🧹 Cleaning the project..."
flutter clean > "$LOG_FILE" 2>&1

echo "⚡ Getting dependencies..."
flutter pub get >> "$LOG_FILE" 2>&1

echo -n "🏗️ Building release APK... "
flutter build apk --release --dart-define=Dart.vm.product=true --no-tree-shake-icons >> "$LOG_FILE" 2>&1 &
BUILD_PID=$!
show_spinner $BUILD_PID

APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    echo "✨ Your APK can be found at: build/app/outputs/flutter-apk/app-release.apk"
    
    echo -n "📲 Installing APK on connected device... "
    adb install -r "$APK_PATH" >> "$LOG_FILE" 2>&1 &
    INSTALL_PID=$!
    show_spinner $INSTALL_PID
    echo "✅"

    echo "🚀 Launching the app..."
    PACKAGE_NAME="com.arusoft.randomfingerpicker"
    adb shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 >> "$LOG_FILE" 2>&1

    echo "📝 App logs are being saved to: $LOG_FILE"
    flutter logs --verbose >> "$LOG_FILE" 2>&1
else
    RED='\033[0;31m'
    echo -e "${RED}❌ Build failed! Check logs at: $LOG_FILE"
    echo "Last 20 lines of build log:"
    tail -n 20 "$LOG_FILE"
fi