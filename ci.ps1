# PowerShell скрипт для Continuous Integration
# Альтернативный вариант CI скрипта

param(
    [string]$Version = "1.0.0.0"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message, [int]$Step)
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "[$Step] $Message" -ForegroundColor Yellow
    Write-Host "====================================" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Magenta
Write-Host "        CI PROCESS STARTED" -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta

# Шаг 1: Загрузка актуального состояния с сервера
Write-Step "Updating project from Git..." 1
try {
    git pull
    if ($LASTEXITCODE -ne 0) {
        throw "Git pull failed with exit code $LASTEXITCODE"
    }
    Write-Success "Git updated successfully"
} catch {
    Write-Error "Git update failed: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Шаг 2: Сборка проекта
Write-Step "Building project..." 2
$BUILD_DIR = "build"
if (Test-Path $BUILD_DIR) {
    Remove-Item -Path $BUILD_DIR -Recurse -Force
}
New-Item -ItemType Directory -Path $BUILD_DIR -Force | Out-Null

$filesToCopy = @("index.html", "script.js", "style.css")
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Copy-Item -Path $file -Destination $BUILD_DIR -Force
    } else {
        Write-Error "File not found: $file"
        Read-Host "Press Enter to exit"
        exit 1
    }
}
Write-Success "Build completed"

# Шаг 3: Установка зависимостей и сборка unittest
Write-Step "Installing test dependencies and building unittest..." 3
try {
    npm install
    if ($LASTEXITCODE -ne 0) {
        throw "npm install failed with exit code $LASTEXITCODE"
    }
    Write-Success "Dependencies installed"
} catch {
    Write-Error "npm install failed: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Шаг 4: Выполнение unittest
Write-Step "Running Jest tests..." 4
try {
    npm test
    if ($LASTEXITCODE -ne 0) {
        throw "Unit tests failed with exit code $LASTEXITCODE"
    }
    Write-Success "All tests passed"
} catch {
    Write-Error "Unit tests failed: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Шаг 5: Создание установщика - Генерация установочного файла
Write-Step "Generating installer source file..." 5
$WXS_FILE = Join-Path $BUILD_DIR "simple_calculator.wxs"
$ABSOLUTE_BUILD_DIR = (Resolve-Path $BUILD_DIR).Path

# Создаем XML контент через массив строк для избежания проблем с парсингом
$versionLine = '           Version="' + $Version + '" Manufacturer="YourName"'
$wxsLines = @(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">',
    '  <Product Id="*" Name="CalculatorApp" Language="1033"',
    $versionLine,
    '           UpgradeCode="A6B2F1D0-7C4E-4B9A-9F01-123456789ABC">',
    '',
    '    <Package InstallerVersion="300" Compressed="yes" InstallScope="perUser" />',
    '    <Media Id="1" Cabinet="cab1.cab" EmbedCab="yes"/>',
    '',
    '    <Directory Id="TARGETDIR" Name="SourceDir">',
    '      <Directory Id="LocalAppDataFolder">',
    '        <Directory Id="INSTALLFOLDER" Name="CalculatorApp"/>',
    '      </Directory>',
    '    </Directory>',
    '',
    '    <DirectoryRef Id="INSTALLFOLDER">',
    '      <Component Id="AppFilesComponent" Guid="E1111111-1111-1111-1111-111111111111">',
    '        <RegistryValue',
    '            Root="HKCU"',
    '            Key="Software\\CalculatorApp"',
    '            Name="Installed"',
    '            Type="integer"',
    '            Value="1"',
    '            KeyPath="yes" />',
    '',
    '        <File Id="IndexHtml" Source="$(var.BuildDir)\\index.html" />',
    '        <File Id="ScriptJs"  Source="$(var.BuildDir)\\script.js"/>',
    '        <File Id="StyleCss"  Source="$(var.BuildDir)\\style.css"/>',
    '',
    '        <RemoveFolder Id="RemoveINSTALLFOLDER" Directory="INSTALLFOLDER" On="uninstall"/>',
    '      </Component>',
    '    </DirectoryRef>',
    '',
    '    <Feature Id="MainFeature" Title="Calculator App" Level="1">',
    '      <ComponentRef Id="AppFilesComponent"/>',
    '    </Feature>',
    '  </Product>',
    '</Wix>'
)
$wxsContent = $wxsLines -join "`r`n"

Set-Content -Path $WXS_FILE -Value $wxsContent -Encoding UTF8
$filePath = $WXS_FILE
$msg = "Installer source file generated at: " + $filePath
Write-Success $msg

# Шаг 6: Сборка MSI установщика
Write-Step "Building MSI installer..." 6
$MSI_FILE = Join-Path $BUILD_DIR "CalculatorApp_CI.msi"

# Поиск WiX Toolset в стандартных местах
$WIX_BIN = $null
$possiblePaths = @(
    "C:\Program Files (x86)\WiX Toolset v3.14\bin",
    "C:\Program Files\WiX Toolset v3.14\bin",
    "${env:ProgramFiles(x86)}\WiX Toolset v3.14\bin",
    "$env:ProgramFiles\WiX Toolset v3.14\bin"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $WIX_BIN = $path
        break
    }
}

if (-not $WIX_BIN) {
    Write-Error "WiX Toolset not found in standard locations"
    Write-Host "Please install WiX Toolset from https://wixtoolset.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Using WiX Toolset at: $WIX_BIN" -ForegroundColor Cyan

$CANDLE = Join-Path $WIX_BIN "candle.exe"
$LIGHT = Join-Path $WIX_BIN "light.exe"

Push-Location $BUILD_DIR
try {
    # Компиляция установочного файла
    & $CANDLE -dBuildDir="$ABSOLUTE_BUILD_DIR" "simple_calculator.wxs" -o "simple_calculator.wixobj"
    if ($LASTEXITCODE -ne 0) {
        throw "Installer source compilation failed"
    }
    
    # Сборка MSI
    & $LIGHT "simple_calculator.wixobj" -o "CalculatorApp_CI.msi"
    if ($LASTEXITCODE -ne 0) {
        throw "MSI linking failed"
    }
    
    Write-Success "MSI built at ${MSI_FILE}"
} catch {
    Write-Error "MSI build failed: $_"
    Pop-Location
    Read-Host "Press Enter to exit"
    exit 1
} finally {
    Pop-Location
}

# Шаг 7: Установка приложения
Write-Step "Installing application..." 7

if (-not (Test-Path $MSI_FILE)) {
    Write-Error "MSI file not found at $MSI_FILE"
    Read-Host "Press Enter to exit"
    exit 1
}

$LOG_FILE = Join-Path $BUILD_DIR "msi_install.log"
Write-Host "Installing MSI: $MSI_FILE" -ForegroundColor Cyan
Write-Host "Log will be saved to: $LOG_FILE" -ForegroundColor Cyan

try {
    $installArgs = @(
        "/i",
        "`"$MSI_FILE`"",
        "/qn",
        "/l*v",
        "`"$LOG_FILE`""
    )
    
    Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -Verb RunAs -NoNewWindow
    if ($LASTEXITCODE -ne 0) {
        throw "MSI installation failed with exit code $LASTEXITCODE"
    }
    
    Write-Success "MSI installed successfully"
    Write-Host "Installation log: $LOG_FILE" -ForegroundColor Cyan
} catch {
    Write-Error "MSI installation failed: $_"
    Write-Host "Check log at $LOG_FILE" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Шаг 8: Проверка установки
Write-Step "Verifying installation..." 8

$INSTALL_PATH = Join-Path $env:LOCALAPPDATA "CalculatorApp"

if (Test-Path $INSTALL_PATH -PathType Container) {
    Write-Success "Application installed at: ${INSTALL_PATH}"
    Write-Host "Files in installation directory:" -ForegroundColor Cyan
    Get-ChildItem -Path $INSTALL_PATH | Format-Table Name, Length -AutoSize
} else {
    Write-Host "[WARNING] Installation directory not found at expected location" -ForegroundColor Yellow
    Write-Host "Check: $INSTALL_PATH" -ForegroundColor Yellow
    Write-Host "Note: Installation may have completed but verification failed. Check log: $LOG_FILE" -ForegroundColor Yellow
}

# Итоговая информация
Write-Host ""
Write-Host "====================================" -ForegroundColor Magenta
Write-Host "      CI COMPLETED SUCCESSFULLY" -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  - Build directory: $BUILD_DIR"
Write-Host "  - MSI installer: $MSI_FILE"
Write-Host "  - Install location: $INSTALL_PATH"
Write-Host "  - Installation log: $LOG_FILE"
Write-Host ""

Read-Host "Press Enter to exit"

