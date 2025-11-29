@echo off
REM Batch файл для запуска CI скрипта (PowerShell версия)

echo ====================================
echo  CI Script Launcher (PowerShell)
echo ====================================
echo.

REM Запуск PowerShell скрипта
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ci.ps1"

echo.
pause

