@echo off
REM Batch файл для запуска CI скрипта (Bash версия)
REM Использует Git Bash для выполнения bash скрипта

echo ====================================
echo    CI Script Launcher (Bash)
echo ====================================
echo.

REM Поиск Git Bash в стандартных местах
set "GIT_BASH_PATH="

REM Проверка стандартных путей установки Git
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=C:\Program Files\Git\bin\bash.exe"
) else if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=C:\Program Files (x86)\Git\bin\bash.exe"
) else if exist "%ProgramFiles%\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=%ProgramFiles%\Git\bin\bash.exe"
) else if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" (
    set "GIT_BASH_PATH=%ProgramFiles(x86)%\Git\bin\bash.exe"
) else (
    REM Попытка найти через PATH
    where bash >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "GIT_BASH_PATH=bash"
    )
)

if defined GIT_BASH_PATH (
    echo Using Git Bash at: %GIT_BASH_PATH%
    echo.
    "%GIT_BASH_PATH%" ci.sh
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ERROR: Script execution failed with exit code %ERRORLEVEL%
        pause
        exit /b %ERRORLEVEL%
    )
) else (
    echo ERROR: Git Bash not found!
    echo.
    echo Please install Git for Windows from: https://git-scm.com/download/win
    echo.
    echo After installation, Git Bash will be available and this script will work.
    echo.
    pause
    exit /b 1
)

echo.
pause

