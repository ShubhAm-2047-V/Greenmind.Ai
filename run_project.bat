@echo off
title GreenMind AI Project One-Click Runner

:: --- DETECTING YOUR EXTRACTED FOLDERS ---
set "PROJECT_ROOT=%~dp0"
set "FLUTTER_PATH=%PROJECT_ROOT%flutter_windows_3.19.6-stable\flutter\bin"
set "ADB_PATH=%PROJECT_ROOT%platform-tools-latest-windows\platform-tools"

:: Add these to the PATH for this session
set "PATH=%PATH%;%FLUTTER_PATH%;%ADB_PATH%"

echo ===================================================
echo [1/4] Starting FastAPI Backend...
echo ===================================================
:: Start backend in a separate window (ensures dependencies are installed)
start "GreenMind Backend" cmd /k "cd /d %PROJECT_ROOT%backend && pip install -r requirements.txt && uvicorn main:app --reload --host 0.0.0.0 --port 8000"

echo ===================================================
echo [2/4] Initializing USB Connection (ADB)...
echo ===================================================
echo [IMPORTANT] If using a physical phone, tap "ALLOW" if asked for USB Debugging!
adb devices
:: This allows the phone to access the computer's localhost:8000
adb reverse tcp:8000 tcp:8000

echo ===================================================
echo [3/4] Initializing Flutter...
echo ===================================================
cd /d "%PROJECT_ROOT%flutter_app"
call flutter pub get

echo ===================================================
echo [4/4] Building and Running App...
echo ===================================================
:: Ensure we are running on the connected device/emulator
call flutter run

pause
