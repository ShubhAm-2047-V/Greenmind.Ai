@echo off
title "GreenMind AI - One-Click Mobile Installer"
color 0A
cls

:: Ensure the script runs in its own directory (root directory)
cd /d "%~dp0"

:: 1. If system JAVA_HOME is set but invalid, clear it
if defined JAVA_HOME (
    if not exist "%JAVA_HOME%\bin\java.exe" (
        echo [WARNING] System JAVA_HOME points to an invalid directory: %JAVA_HOME%
        echo Clearing it to allow automatic detection...
        set "JAVA_HOME="
    )
)

:: 2. Try to find local JBR folder in workspace
if not defined JAVA_HOME (
    if exist "studio\jbr" (
        for %%i in ("studio\jbr") do set "JAVA_HOME=%%~fi"
    )
)

:: 3. Try to locate standard Android Studio installation paths on Windows
if not defined JAVA_HOME (
    if exist "%ProgramFiles%\Android\Android Studio\jbr" (
        set "JAVA_HOME=%ProgramFiles%\Android\Android Studio\jbr"
    ) else if exist "%ProgramFiles%\Android\Android Studio\jre" (
        set "JAVA_HOME=%ProgramFiles%\Android\Android Studio\jre"
    ) else if exist "%LocalAppData%\Programs\Android Studio\jbr" (
        set "JAVA_HOME=%LocalAppData%\Programs\Android Studio\jbr"
    ) else if exist "%LocalAppData%\Programs\Android Studio\jre" (
        set "JAVA_HOME=%LocalAppData%\Programs\Android Studio\jre"
    )
)

echo ==========================================================
echo           GREENMIND AI ONE-CLICK MOBILE INSTALLER          
echo ==========================================================
echo.

:: Check if a pre-compiled APK exists
set "COMPILE_CHOICE=Y"
if exist "GreenMind.Ai.apk" (
    echo A pre-compiled GreenMind.Ai.apk is already available in this folder.
    set /p COMPILE_CHOICE="Do you want to rebuild the app from source code first? [Y/N] (Default is N): "
)

if "%COMPILE_CHOICE%"=="" set "COMPILE_CHOICE=N"

if /i "%COMPILE_CHOICE%"=="Y" (
    echo.
    echo Compiling the updated app from source...
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
) else (
    echo.
    echo Skipping compilation. Using the existing GreenMind.Ai.apk...
)

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
