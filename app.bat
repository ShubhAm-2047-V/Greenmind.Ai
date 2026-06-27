@echo off
title GreenMind AI - Build & Install
color 0A
cls

set "JAVA_HOME=%~dp0studio\jbr"

echo ==========================================================
echo           GREENMIND AI BUILD ^& INSTALL                  
echo ==========================================================
echo.
echo Compiling the updated app and installing it on your phone...
echo.

cd /d "%~dp0"
if not exist "android-sdk\licenses" mkdir "android-sdk\licenses"
echo 24333f8a63b6125eaed176b54d08c69cd7a04d5e> "android-sdk\licenses\android-sdk-license"
echo 849d22f16f5b691287102b2257b48a265d2c613e>> "android-sdk\licenses\android-sdk-license"

cd /d "%~dp0flutter_app"

:: Build release APK, bypassing Gradle validation check using the suggested flag
call flutter build apk --release --android-skip-build-dependency-validation

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

echo.
echo Installing GreenMind.Ai.apk onto your phone...
cd /d "%~dp0"

:: Check for existing adb
set "ADB_CMD=adb"
if exist "platform-tools\adb.exe" (
    set "ADB_CMD=platform-tools\adb.exe"
)

"%ADB_CMD%" install -r "GreenMind.Ai.apk"

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Installation failed.
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
echo.
pause
