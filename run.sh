#!/bin/bash

# GreenMind AI One-Click Installer for macOS & Linux

# ANSI Color codes for beautiful terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}           GREENMIND AI ONE-CLICK INSTALLER               ${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo -e "This script will compile the app and install it on your phone."
echo.

# Get current script directory
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

# Resolve JAVA_HOME to an absolute path if the local studio JBR directory exists
if [ -d "studio/jbr" ]; then
    if [ -d "studio/jbr/Contents/Home" ]; then
        export JAVA_HOME="$PROJECT_ROOT/studio/jbr/Contents/Home"
    else
        export JAVA_HOME="$PROJECT_ROOT/studio/jbr"
    fi
    echo -e "${GREEN}[INFO] Using local JBR for JAVA_HOME: $JAVA_HOME${NC}"
fi

echo -e "Compiling the updated app..."
cd "$PROJECT_ROOT/flutter_app"

# Build release APK, bypassing Gradle validation check using the suggested flag
if ! flutter build apk --release --android-skip-build-dependency-validation; then
    echo -e "${RED}[ERROR] Compilation failed.${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

echo.
echo -e "${GREEN}[OK] Compilation successful!${NC}"
echo -e "Copying APK to root directory..."
cp -f "build/app/outputs/flutter-apk/app-release.apk" "$PROJECT_ROOT/GreenMind.Ai.apk"

echo.
echo -e "Installing GreenMind.Ai.apk onto your phone..."
cd "$PROJECT_ROOT"

# Detect Operating System for ADB selection
OS_TYPE="$(uname -s)"
ADB_CMD="adb"

if command -v adb >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] System-wide ADB detected.${NC}"
elif [ -f "./platform-tools/adb" ]; then
    ADB_CMD="./platform-tools/adb"
    echo -e "${GREEN}[OK] Local ADB detected.${NC}"
else
    echo -e "${YELLOW}[INFO] ADB is not installed. Setting up platform-tools...${NC}"
    case "$OS_TYPE" in
        Darwin)
            DOWNLOAD_URL="https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
            ;;
        Linux)
            DOWNLOAD_URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
            ;;
        *)
            echo -e "${RED}[ERROR] Unsupported OS: $OS_TYPE. Please use run.bat on Windows.${NC}"
            read -p "Press Enter to exit..."
            exit 1
            ;;
    esac

    echo -e "Downloading ADB platform-tools for $OS_TYPE..."
    if command -v curl >/dev/null 2>&1; then
        curl -L -o platform-tools.zip "$DOWNLOAD_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O platform-tools.zip "$DOWNLOAD_URL"
    else
        echo -e "${RED}[ERROR] Neither curl nor wget was found. Please install one to proceed.${NC}"
        read -p "Press Enter to exit..."
        exit 1
    fi

    if [ -f "platform-tools.zip" ]; then
        if command -v unzip >/dev/null 2>&1; then
            unzip -o platform-tools.zip
        else
            python3 -c "import zipfile; zipfile.ZipFile('platform-tools.zip').extractall('.')"
        fi
        rm platform-tools.zip
    fi

    if [ -f "./platform-tools/adb" ]; then
        chmod +x ./platform-tools/adb
        ADB_CMD="./platform-tools/adb"
    else
        echo -e "${RED}[ERROR] ADB setup failed.${NC}"
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

# Run install and handle signature conflicts
install_output=$("$ADB_CMD" install -r "GreenMind.Ai.apk" 2>&1)
install_status=$?

if [ $install_status -ne 0 ]; then
    echo -e "$install_output"
    if [[ "$install_output" == *"INSTALL_FAILED_UPDATE_INCOMPATIBLE"* || "$install_output" == *"signatures do not match"* ]]; then
        echo.
        echo -e "${YELLOW}[WARNING] Installation failed due to signature mismatch.${NC}"
        echo -e "An app with the same package name but a different signature is already installed."
        read -p "Would you like to uninstall the existing app from your device and retry? [Y/N]: " UNINSTALL_CHOICE
        if [[ "$UNINSTALL_CHOICE" == "Y" || "$UNINSTALL_CHOICE" == "y" ]]; then
            echo.
            echo -e "Uninstalling the existing app..."
            "$ADB_CMD" uninstall com.example.flutter_app
            echo.
            echo -e "Retrying installation..."
            if "$ADB_CMD" install -r "GreenMind.Ai.apk"; then
                install_status=0
            fi
        fi
    fi
fi

if [ $install_status -ne 0 ]; then
    echo.
    echo -e "${RED}[ERROR] Installation failed.${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

echo.
echo -e "${GREEN}[OK] Installed successfully!${NC}"
echo -e "Launching the app on your phone..."
"$ADB_CMD" shell am start -n com.example.flutter_app/com.example.flutter_app.MainActivity >/dev/null 2>&1

echo.
echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}                   SUCCESSFULLY FINISHED                   ${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo.
read -p "Press Enter to exit..."
