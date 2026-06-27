#!/bin/bash

# GreenMind AI One-Click USB Installer for macOS & Linux

# ANSI Color codes for beautiful terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}           GREENMIND AI ONE-CLICK INSTALLER               ${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo -e "This script will install GreenMind AI on your Android phone"
echo -e "over USB without needing Android Studio or Flutter installed."
echo.

# Get current script directory
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

# 1. Check for the APK file
APK_FILE=""
if [ -f "GreenMind.Ai.apk" ]; then
    APK_FILE="GreenMind.Ai.apk"
elif [ -f "GreenMind_AI.apk" ]; then
    APK_FILE="GreenMind_AI.apk"
elif [ -f "GreenMind_AI_v1.apk" ]; then
    APK_FILE="GreenMind_AI_v1.apk"
else
    # Try to find any APK file in the directory
    for f in *.apk; do
        if [ -f "$f" ]; then
            APK_FILE="$f"
            break
        fi
    done
fi

if [ -z "$APK_FILE" ]; then
    echo -e "${RED}[ERROR] No APK file was found in this folder.${NC}"
    echo -e "Please make sure you have an .apk file (e.g., GreenMind_AI.apk) in this directory."
    echo.
    read -p "Press Enter to exit..."
    exit 1
fi

echo -e "${GREEN}[OK] Using APK file: $APK_FILE${NC}"
echo.

# 2. Find or download ADB
ADB_CMD="adb"

if command -v adb >/dev/null 2>&1; then
    echo -e "${GREEN}[OK] System-wide ADB detected.${NC}"
elif [ -f "./platform-tools/adb" ]; then
    ADB_CMD="./platform-tools/adb"
    echo -e "${GREEN}[OK] Local ADB detected.${NC}"
else
    echo -e "${YELLOW}[INFO] ADB (Android Debug Bridge) is not installed.${NC}"
    
    # Detect Operating System
    OS_TYPE="$(uname -s)"
    case "$OS_TYPE" in
        Darwin)
            DOWNLOAD_URL="https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
            ;;
        Linux)
            DOWNLOAD_URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
            ;;
        *)
            echo -e "${RED}[ERROR] Unsupported OS: $OS_TYPE. Please use Windows, macOS, or Linux.${NC}"
            read -p "Press Enter to exit..."
            exit 1
            ;;
    esac

    echo -e "Downloading lightweight official Google platform-tools for $OS_TYPE (approx. 8MB)..."
    echo -e "Please wait..."
    echo.

    # Try downloading with curl, fallback to wget
    if command -v curl >/dev/null 2>&1; then
        curl -L -o platform-tools.zip "$DOWNLOAD_URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -O platform-tools.zip "$DOWNLOAD_URL"
    else
        echo -e "${RED}[ERROR] Neither curl nor wget was found on your system.${NC}"
        echo -e "Please install curl or wget and run this script again."
        read -p "Press Enter to exit..."
        exit 1
    fi

    if [ ! -f "platform-tools.zip" ]; then
        echo -e "${RED}[ERROR] Failed to download ADB tools. Check your network connection.${NC}"
        read -p "Press Enter to exit..."
        exit 1
    fi

    echo -e "Extracting ADB tools..."
    if command -v unzip >/dev/null 2>&1; then
        unzip -o platform-tools.zip
    else
        # Try python as backup for extraction
        python3 -c "import zipfile; zipfile.ZipFile('platform-tools.zip').extractall('.')"
    fi
    rm platform-tools.zip

    if [ -f "./platform-tools/adb" ]; then
        chmod +x ./platform-tools/adb
        ADB_CMD="./platform-tools/adb"
        echo -e "${GREEN}[OK] ADB tools installed successfully!${NC}"
        echo.
    else
        echo -e "${RED}[ERROR] Extraction failed. Could not locate adb binary.${NC}"
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

# 3. Detect Connected Device
check_device() {
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${GREEN}           DETECTING CONNECTED ANDROID DEVICE              ${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "Please ensure:"
    echo -e "  1. Your Android phone is connected to this computer via USB."
    echo -e "  2. \"USB Debugging\" is ENABLED in Developer Options on your phone."
    echo.

    devices_output=$("$ADB_CMD" devices)
    
    # Parse adb devices output
    # Skip the first line (header) and search for status
    DEVICE_FOUND=0
    UNAUTHORIZED=0
    
    while read -r line; do
        # Ignore empty lines and the header line
        if [ -n "$line" ] && [[ "$line" != "List of devices"* ]]; then
            status=$(echo "$line" | awk '{print $2}')
            if [ "$status" == "device" ]; then
                DEVICE_FOUND=1
            elif [ "$status" == "unauthorized" ]; then
                UNAUTHORIZED=1
            fi
        fi
    done <<< "$devices_output"

    if [ "$DEVICE_FOUND" -eq 1 ]; then
        echo -e "${GREEN}[OK] Device detected!${NC}"
        install_apk
    elif [ "$UNAUTHORIZED" -eq 1 ]; then
        echo -e "${YELLOW}[WARNING] A device is connected but UNAUTHORIZED.${NC}"
        echo -e "Please check your phone screen and tap \"Allow USB debugging\"."
        echo.
        read -p "Press Enter to try again..."
        check_device
    else
        echo -e "${YELLOW}[INFO] Looking for device... (Make sure screen is unlocked)${NC}"
        echo.
        read -p "Press Enter to retry device detection..."
        check_device
    fi
}

# 4. Install the APK
install_apk() {
    echo.
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "${GREEN}                INSTALLING GREENMIND AI                    ${NC}"
    echo -e "${GREEN}==========================================================${NC}"
    echo -e "Installing $APK_FILE to your device..."
    echo -e "This might take 10-30 seconds depending on your device."
    echo -e "Please do not disconnect the USB cable."
    echo.

    if "$ADB_CMD" install -r "$APK_FILE"; then
        echo.
        echo -e "${GREEN}[OK] Application installed successfully!${NC}"
        echo -e "Launching GreenMind AI on your device..."
        
        # 5. Launch the app
        "$ADB_CMD" shell am start -n com.example.flutter_app/com.example.flutter_app.MainActivity >/dev/null 2>&1
        
        echo.
        echo -e "${GREEN}==========================================================${NC}"
        echo -e "${GREEN}                   SUCCESSFULLY FINISHED                   ${NC}"
        echo -e "${GREEN}==========================================================${NC}"
        echo.
        echo -e "You can now open GreenMind AI on your phone."
        echo -e "Enjoy using the app!"
        echo.
        read -p "Press Enter to exit..."
        exit 0
    else
        echo.
        echo -e "${RED}[ERROR] Installation failed.${NC}"
        echo -e "Common reasons:"
        echo -e "  - An older version of the app is already installed with a different signature."
        echo -e "    Please manually UNINSTALL GreenMind AI from your phone first."
        echo -e "  - Phone screen is locked or has install prompts."
        echo -e "  - Storage is full."
        echo -e "  - Play Protect blocked the install (tap \"Install anyway\" on your phone)."
        echo.
        read -p "Press Enter to exit..."
        exit 1
    fi
}

# Start device check loop
check_device
