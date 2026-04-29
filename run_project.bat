@echo off
title GreenMind AI Project One-Click Runner

:: --- DETECTING YOUR EXTRACTED FOLDERS ---
set "PROJECT_ROOT=%~dp0"
set "FLUTTER_PATH=%PROJECT_ROOT%flutter_windows_3.19.6-stable\flutter\bin"
set "ADB_PATH=%PROJECT_ROOT%platform-tools-latest-windows\platform-tools"

:: Add these to the PATH for this session
set "PATH=%PATH%;%FLUTTER_PATH%;%ADB_PATH%"

echo ===================================================
echo [1/3] Connecting Device...
echo ===================================================
adb devices

echo ===================================================
echo [2/3] Initializing Flutter...
echo ===================================================
cd /d "%PROJECT_ROOT%flutter_app"
call flutter pub get

echo ===================================================
echo [3/3] Building and Running App...
echo ===================================================
:: Ensure we are running on the connected device/emulator
call flutter run

pause
