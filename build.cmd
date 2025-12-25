@echo off
title Qflow Build Script
echo Qflow Build Script
echo ==============================
echo.

REM --- 0. Pre-checks ---
if not exist "main.py" (
    echo [Error] main.py not found! Ensure this script is in the project root.
    pause
    exit /b
)

if not exist "icon.ico" (
    echo [Warning] icon.ico not found! Creating a placeholder to prevent build error...
    echo. > icon.ico
    echo Please replace icon.ico with your real icon later.
)

REM --- 1. Check Python ---
echo [1] Checking Python...
python --version
if %errorlevel% neq 0 (
    echo [Error] Python not found! Please install Python and add it to PATH.
    pause
    exit /b
)

echo.

REM --- 2. Create Virtual Environment ---
if exist venv (
    echo [2] Virtual environment already exists.
) else (
    echo [2] Creating virtual environment...
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [Error] Failed to create virtual environment!
        pause
        exit /b
    )
)

echo.

REM --- 3. Activate Environment ---
echo [3] Activating virtual environment...
call venv\Scripts\activate.bat

echo.

REM --- 4. Install Dependencies ---
echo [4] Installing/Updating dependencies...
python -m pip install --upgrade pip
python -m pip install pyinstaller

REM Check if requirements.txt exists, otherwise install manually to be safe
if exist requirements.txt (
    echo Installing from requirements.txt...
    python -m pip install -r requirements.txt
) else (
    echo [Warning] requirements.txt not found. Installing core libs manually...
    echo You should generate one using: pip freeze > requirements.txt
    python -m pip install opencv-python numpy pillow pyautogui pynput pycaw comtypes
)

echo.

REM --- 5. Clean Old Files ---
echo [5] Cleaning old build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist Qflow.spec del /q Qflow.spec

echo.

REM --- 6. Build Application ---
echo [6] Building application with PyInstaller...
echo This process may take a few minutes...

REM --collect-all is crucial for libraries like cv2 and pycaw
pyinstaller --noconfirm --windowed --onefile --clean --name "Qflow" ^
    --icon="icon.ico" ^
    --add-data "icon.ico;." ^
    --collect-all cv2 ^
    --collect-all pycaw ^
    --collect-all comtypes ^
    --collect-all pynput ^
    --hidden-import pynput.keyboard._win32 ^
    --hidden-import pynput.mouse._win32 ^
    --exclude-module matplotlib ^
    --exclude-module pandas ^
    --exclude-module scipy ^
    --exclude-module PyQt5 ^
    --exclude-module wx ^
    --exclude-module unittest ^
    main.py

echo.

REM --- 7. Finish ---
if %errorlevel% equ 0 (
    echo ==========================================
    echo  BUILD SUCCESSFUL!
    echo ==========================================
    echo.
    echo Executable location: dist\Qflow.exe
    echo.
    echo You can close this window.
    pause
) else (
    echo ==========================================
    echo  BUILD FAILED!
    echo ==========================================
    echo Check the error messages above.
    pause
)