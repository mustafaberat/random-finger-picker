#!/bin/bash

# Clean and get dependencies
flutter clean
flutter pub get
# Kill any existing process on port 8080
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
# Run the app in Chrome with port 8080
flutter run -d chrome --web-port=8080 