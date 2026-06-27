@echo off
title GreenMind AI - Desktop Test Runner
color 0A
cls

echo ==========================================================
echo           GREENMIND AI - DESKTOP TEST RUNNER              
echo ==========================================================
echo.
echo Launching the updated GreenMind AI app on Windows desktop...
echo This allows you to test the image picker fixes immediately on your PC.
echo.
echo Press any key to start...
pause >nul

cd /d "%~dp0flutter_app"
flutter run -d windows

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Failed to run the application.
    echo If this is your first time running, make sure dependencies are downloaded.
    echo.
    pause
)
