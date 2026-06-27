@echo off
title GreenMind AI - One-Click Build & Install
color 0A
cls

echo ==========================================================
echo           GREENMIND AI ONE-CLICK BUILD ^& INSTALL          
echo ==========================================================
echo.
echo This script will automatically:
echo   1. Verify/Setup a lightweight Android SDK (approx. 250MB) if missing.
echo   2. Compile the updated GreenMind AI app.
echo   3. Install the updated app directly onto your connected Android phone.
echo.
echo Please make sure your phone is connected over USB with "USB Debugging" enabled.
echo.
echo Press any key to start...
pause >nul

set "SDK_DIR=%~dp0android-sdk"
set "ADB_CMD=%~dp0platform-tools\adb.exe"

:: Check if Android SDK is already installed locally in the project
if exist "%SDK_DIR%\platforms\android-34" (
    echo [OK] Android SDK detected locally.
    goto build
)

echo [INFO] Android SDK is not detected in your project folder.
echo Setting up a lightweight Android SDK in: %SDK_DIR%
echo Downloading official Android command-line tools (approx. 100MB)...
echo Please wait...

if not exist "%SDK_DIR%\cmdline-tools" mkdir "%SDK_DIR%\cmdline-tools"

:: Download cmdline-tools using PowerShell
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip' -OutFile '%SDK_DIR%\tools.zip'"

if not exist "%SDK_DIR%\tools.zip" (
    color 0C
    echo [ERROR] Failed to download Android tools. Check your internet connection.
    pause
    exit /b 1
)

echo Extracting Android tools...
powershell -Command "Expand-Archive -Path '%SDK_DIR%\tools.zip' -DestinationPath '%SDK_DIR%\cmdline-tools' -Force"
del "%SDK_DIR%\tools.zip"

:: Move files to the proper "latest" folder structure required by sdkmanager
if exist "%SDK_DIR%\cmdline-tools\latest" rmdir /s /q "%SDK_DIR%\cmdline-tools\latest"
move "%SDK_DIR%\cmdline-tools\cmdline-tools" "%SDK_DIR%\cmdline-tools\latest"

echo Downloading Android SDK Platform 34 ^& Build-Tools (approx. 150MB)...
echo This will take a moment, please wait...
echo.

:: Accept licenses and install platform 34 and build-tools 34
mkdir "%SDK_DIR%\licenses"
echo 24333f8a63b6125eaed176b54d08c69cd7a04d5e> "%SDK_DIR%\licenses\android-sdk-license"
echo 849d22f16f5b691287102b2257b48a265d2c613e>> "%SDK_DIR%\licenses\android-sdk-license"

call "%SDK_DIR%\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root="%SDK_DIR%" "platforms;android-34" "build-tools;34.0.0" "platform-tools"

if not exist "%SDK_DIR%\platforms\android-34" (
    color 0C
    echo [ERROR] Failed to install Android SDK packages.
    pause
    exit /b 1
)

echo.
echo [OK] Android SDK setup successfully!
echo Configuring Flutter to use this SDK...
call flutter config --android-sdk "%SDK_DIR%"

:build
echo ==========================================================
echo                 COMPILING UPDATED APP                     
echo ==========================================================
echo.
echo Building the release APK...
echo.

cd /d "%~dp0flutter_app"
call flutter build apk --release

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Compilation failed.
    pause
    exit /b 1
)

echo.
echo [OK] Compilation successful!
echo Copying APK to root directory...
copy /y "build\app\outputs\flutter-apk\app-release.apk" "..\GreenMind.Ai.apk"

echo ==========================================================
echo                INSTALLING ON MOBILE                       
echo ==========================================================
echo.

cd /d "%~dp0"

:: Check if local adb exists from platform-tools
if not exist "%ADB_CMD%" (
    if exist "platform-tools\adb.exe" (
        set "ADB_CMD=platform-tools\adb.exe"
    ) else (
        echo [INFO] ADB not found. Downloading platform-tools...
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'platform-tools.zip'"
        powershell -Command "Expand-Archive -Path 'platform-tools.zip' -DestinationPath '.' -Force"
        del platform-tools.zip
        set "ADB_CMD=platform-tools\adb.exe"
    )
)

echo Installing GreenMind.Ai.apk onto your phone...
"%ADB_CMD%" install -r "GreenMind.Ai.apk"

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Installation failed.
    echo Please make sure:
    echo   1. Your phone is connected to this PC via USB.
    echo   2. USB Debugging is enabled on your phone.
    echo   3. Any old version of the app is manually uninstalled first.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Installed successfully!
echo Launching the app on your phone...
"%ADB_CMD%" shell am start -n com.example.flutter_app/com.example.flutter_app.MainActivity >nul 2>&1

echo.
echo ==========================================================
echo                   SUCCESSFULLY FINISHED                   
echo ==========================================================
echo The updated app has been installed on your phone. Enjoy!
echo.
pause
