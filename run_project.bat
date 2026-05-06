@echo off
title GreenMind AI Project One-Click Runner

:: --- DETECTING YOUR EXTRACTED FOLDERS ---
set "PROJECT_ROOT=%~dp0"
set "FLUTTER_PATH=%PROJECT_ROOT%flutter_windows_3.19.6-stable\flutter\bin"
set "ADB_PATH=%PROJECT_ROOT%platform-tools-latest-windows\platform-tools"

:: Add these to the PATH for this session
set "PATH=%PATH%;%FLUTTER_PATH%;%ADB_PATH%"

echo [1/2] Connecting Device...
echo ===================================================
adb devices

echo [2/2] Building and Running App...
echo ===================================================
cd /d "%PROJECT_ROOT%flutter_app"
:: call flutter pub get // Only run if needed
call flutter run

pause
