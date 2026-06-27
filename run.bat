@echo off
title GreenMind AI - One-Click Mobile Installer
color 0A
cls

echo ==========================================================
echo           GREENMIND AI ONE-CLICK INSTALLER               
echo ==========================================================
echo.
echo This script will install GreenMind AI on your Android phone
echo over USB without needing Android Studio or Flutter installed.
echo.

set "PROJECT_ROOT=%~dp0"
cd /d "%PROJECT_ROOT%"

:: 1. Check for the APK file
set "APK_FILE="
if exist "GreenMind.Ai.apk" set "APK_FILE=GreenMind.Ai.apk"
if not defined APK_FILE if exist "GreenMind_AI.apk" set "APK_FILE=GreenMind_AI.apk"
if not defined APK_FILE if exist "GreenMind_AI_v1.apk" set "APK_FILE=GreenMind_AI_v1.apk"
if not defined APK_FILE (
    for %%f in (*.apk) do set "APK_FILE=%%f"
)

if not defined APK_FILE (
    color 0C
    echo [ERROR] No APK file was found in this folder.
    echo Please make sure you have an .apk file, e.g. GreenMind_AI.apk, in this directory.
    echo.
    pause
    exit /b 1
)

echo [OK] Using APK file: %APK_FILE%
echo.

:: 2. Find or download ADB
set "ADB_CMD=adb"
where adb >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] System-wide ADB detected.
    goto check_device
)

if exist "platform-tools\adb.exe" (
    set "ADB_CMD=platform-tools\adb.exe"
    echo [OK] Local ADB detected.
    goto check_device
)

echo [INFO] ADB (Android Debug Bridge) is not installed.
echo Downloading lightweight official Google platform-tools (approx. 8MB)...
echo Please wait...
echo.

:: Use PowerShell to download Google's official platform-tools zip
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'platform-tools.zip'"

if not exist "platform-tools.zip" (
    color 0C
    echo [ERROR] Failed to download ADB tools. Please check your internet connection.
    echo.
    pause
    exit /b 1
)

echo Extracting ADB tools...
powershell -Command "Expand-Archive -Path 'platform-tools.zip' -DestinationPath '.' -Force"
del platform-tools.zip

if exist "platform-tools\adb.exe" (
    set "ADB_CMD=platform-tools\adb.exe"
    echo [OK] ADB tools installed successfully!
    echo.
) else (
    color 0C
    echo [ERROR] Extraction failed. Could not locate adb.exe.
    echo.
    pause
    exit /b 1
)

:: 3. Detect Connected Device
:check_device
echo ==========================================================
echo           DETECTING CONNECTED ANDROID DEVICE              
echo ==========================================================
echo.
echo Please ensure:
echo   1. Your Android phone is connected to this PC via USB.
echo   2. "USB Debugging" is ENABLED in Developer Options on your phone.
echo.

set "DEVICE_FOUND=0"
set "UNAUTHORIZED=0"

for /f "tokens=1,2" %%i in ('"%ADB_CMD%" devices') do (
    if "%%j"=="device" (
        set "DEVICE_FOUND=1"
    )
    if "%%j"=="unauthorized" (
        set "UNAUTHORIZED=1"
    )
)

if "%DEVICE_FOUND%"=="1" (
    echo [OK] Device detected!
    goto install
)

if "%UNAUTHORIZED%"=="1" (
    color 0E
    echo [WARNING] A device is connected but UNAUTHORIZED.
    echo Please check your phone screen and tap "Allow USB debugging".
    echo.
    echo Press any key to check again...
    pause >nul
    color 0A
    goto check_device
)

echo [INFO] Looking for device... (Make sure screen is unlocked)
echo.
echo Press any key to retry device detection...
pause >nul
goto check_device

:: 4. Install the APK
:install
echo.
echo ==========================================================
echo                INSTALLING GREENMIND AI                    
echo ==========================================================
echo.
echo Installing %APK_FILE% to your device...
echo This might take 10-30 seconds depending on your device.
echo Please do not disconnect the USB cable.
echo.

"%ADB_CMD%" install -r "%APK_FILE%"
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Installation failed.
    echo Common reasons:
    echo   - An older version of the app is already installed with a different signature.
    echo     Please manually UNINSTALL GreenMind AI from your phone first.
    echo   - Phone screen is locked or has install prompts.
    echo   - Storage is full.
    echo   - Play Protect blocked the install, tap "Install anyway" on your phone.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Application installed successfully!
echo Launching GreenMind AI on your device...

:: 5. Launch the app
"%ADB_CMD%" shell am start -n com.example.flutter_app/com.example.flutter_app.MainActivity >nul 2>&1

echo.
echo ==========================================================
echo                   SUCCESSFULLY FINISHED                   
echo ==========================================================
echo.
echo You can now open GreenMind AI on your phone.
echo Enjoy using the app!
echo.
pause
exit /b 0
