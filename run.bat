@echo off
title "GreenMind AI - One-Click Mobile Installer"
color 0A
cls

:: Ensure the script runs in its own directory (root directory)
cd /d "%~dp0"

:: Resolve JAVA_HOME to an absolute path if the local studio JBR directory exists
if exist "studio\jbr" (
    for %%i in ("studio\jbr") do set "JAVA_HOME=%%~fi"
)

echo ==========================================================
echo           GREENMIND AI ONE-CLICK MOBILE INSTALLER          
echo ==========================================================
echo.
echo Compiling the updated app and installing it on your phone...
echo.

:: Move to the flutter_app directory to compile
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
    color 0E
    echo.
    echo [WARNING] Installation failed.
    echo This is usually because an app with the same package name but a different signature like debug vs release is already installed.
    echo.
    set /p UNINSTALL_CHOICE="Would you like to uninstall the existing app from your device and retry? [Y/N]: "
    if /i "%UNINSTALL_CHOICE%"=="Y" (
        color 0A
        echo.
        echo Uninstalling the existing app...
        "%ADB_CMD%" uninstall com.example.flutter_app
        echo.
        echo Retrying installation...
        "%ADB_CMD%" install -r "GreenMind.Ai.apk"
    )
)

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
