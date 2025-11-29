#!/bin/bash

# Функция для преобразования Unix пути в Windows путь
# Работает как с cygpath, так и без него
to_windows_path() {
    local unix_path="$1"
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -w "$unix_path"
    else
        # Альтернативный метод: заменить / на \ и добавить букву диска если нужно
        echo "$unix_path" | sed 's|^/c/|C:\\|' | sed 's|^/C/|C:\\|' | sed 's|/|\\|g'
    fi
}

echo "===================================="
echo "        CI PROCESS STARTED"
echo "===================================="

echo "[1] Updating project from Git..."
git pull || { echo "❌ Git update failed."; exit 1; }
echo "✓ Git updated successfully"

echo "[2] Building project..."
BUILD_DIR="build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp index.html script.js style.css "$BUILD_DIR/" 2>/dev/null || {
    echo "❌ Failed to copy project files"
    exit 1
}
echo "✓ Build completed"

echo "[3] Installing test dependencies and building unittest..."
npm install || { echo "❌ npm install failed."; exit 1; }
echo "✓ Dependencies installed"

echo "[4] Running Jest tests..."
npm test || { echo "❌ Unit tests failed."; exit 1; }
echo "✓ All tests passed"

echo "[5] Generating WXS file..."
WXS_FILE="build/simple_calculator.wxs"

ABSOLUTE_BUILD_DIR=$(pwd)/$BUILD_DIR
ABSOLUTE_BUILD_DIR_WIN=$(to_windows_path "$ABSOLUTE_BUILD_DIR")

cat > "$WXS_FILE" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="CalculatorApp" Language="1033"
           Version="1.0.0.0" Manufacturer="YourName"
           UpgradeCode="A6B2F1D0-7C4E-4B9A-9F01-123456789ABC">

    <Package InstallerVersion="300" Compressed="yes" InstallScope="perUser" />
    <Media Id="1" Cabinet="cab1.cab" EmbedCab="yes"/>

    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="LocalAppDataFolder">
        <Directory Id="INSTALLFOLDER" Name="CalculatorApp"/>
      </Directory>
    </Directory>

    <DirectoryRef Id="INSTALLFOLDER">
      <Component Id="AppFilesComponent" Guid="E1111111-1111-1111-1111-111111111111">
        <RegistryValue
            Root="HKCU"
            Key="Software\\CalculatorApp"
            Name="Installed"
            Type="integer"
            Value="1"
            KeyPath="yes" />

        <File Id="IndexHtml" Source="\$(var.BuildDir)\\index.html" />
        <File Id="ScriptJs"  Source="\$(var.BuildDir)\\script.js"/>
        <File Id="StyleCss"  Source="\$(var.BuildDir)\\style.css"/>

        <RemoveFolder Id="RemoveINSTALLFOLDER" Directory="INSTALLFOLDER" On="uninstall"/>
      </Component>
    </DirectoryRef>

    <Feature Id="MainFeature" Title="Calculator App" Level="1">
      <ComponentRef Id="AppFilesComponent"/>
    </Feature>
  </Product>
</Wix>
EOL

echo "✓ WXS file generated at $WXS_FILE"

echo "[6] Building MSI installer..."
MSI_FILE="$BUILD_DIR/CalculatorApp_CI.msi"

# Поиск WiX Toolset в стандартных местах
WIX_BIN=""
if [ -d "C:/Program Files (x86)/WiX Toolset v3.14/bin" ]; then
    WIX_BIN="C:/Program Files (x86)/WiX Toolset v3.14/bin"
elif [ -d "C:/Program Files/WiX Toolset v3.14/bin" ]; then
    WIX_BIN="C:/Program Files/WiX Toolset v3.14/bin"
elif [ -d "/c/Program Files (x86)/WiX Toolset v3.14/bin" ]; then
    WIX_BIN="/c/Program Files (x86)/WiX Toolset v3.14/bin"
elif [ -d "/c/Program Files/WiX Toolset v3.14/bin" ]; then
    WIX_BIN="/c/Program Files/WiX Toolset v3.14/bin"
fi

if [ -z "$WIX_BIN" ] || [ ! -d "$WIX_BIN" ]; then
    echo "❌ WiX Toolset not found in standard locations"
    echo "Please install WiX Toolset from https://wixtoolset.org/"
    exit 1
fi

echo "Using WiX Toolset at: $WIX_BIN"

WIN_BUILD_DIR=$(to_windows_path "$(pwd)/$BUILD_DIR")

cd "$BUILD_DIR" || { echo "❌ Failed to enter build directory"; exit 1; }

"$WIX_BIN/candle.exe" -dBuildDir="$WIN_BUILD_DIR" "simple_calculator.wxs" -o "simple_calculator.wixobj" || {
    echo "❌ WXS compilation failed."
    cd ..
    exit 1
}

"$WIX_BIN/light.exe" "simple_calculator.wixobj" -o "CalculatorApp_CI.msi" || {
    echo "❌ MSI linking failed."
    cd ..
    exit 1
}

cd ..
echo "✓ MSI built at $MSI_FILE"

echo "[7] Installing application..."

WIN_MSI=$(to_windows_path "$(pwd)/$MSI_FILE")
LOG_FILE=$(to_windows_path "$(pwd)/$BUILD_DIR/msi_install.log")

if [ ! -f "$MSI_FILE" ]; then
    echo "❌ MSI file not found at $MSI_FILE"
    exit 1
fi

echo "Installing MSI: $WIN_MSI"
echo "Log will be saved to: $LOG_FILE"

POWERSHELL_CMD="Start-Process msiexec -ArgumentList '/i \"$WIN_MSI\" /qn /l*v \"$LOG_FILE\"' -Wait -Verb RunAs"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$POWERSHELL_CMD"

if [ $? -ne 0 ]; then
    echo "❌ MSI installation failed. Check log at $BUILD_DIR/msi_install.log"
    exit 1
fi

echo "✓ MSI installed successfully"
echo "Installation log: $BUILD_DIR/msi_install.log"



echo "[8] Verifying installation..."

# Получаем путь к LocalAppData через PowerShell
INSTALL_PATH=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Environment]::GetFolderPath('LocalApplicationData')" | tr -d '\r\n')
INSTALL_PATH="$INSTALL_PATH\\CalculatorApp"

# Проверяем установку через PowerShell
VERIFY_CMD="Test-Path -Path \"$INSTALL_PATH\" -PathType Container"
INSTALLED=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$VERIFY_CMD" | tr -d '\r\n')

if [ "$INSTALLED" = "True" ]; then
    echo "✓ Application installed at: $INSTALL_PATH"
    echo "Files in installation directory:"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path \"$INSTALL_PATH\" | Format-Table Name, Length -AutoSize"
else
    echo "⚠ Installation directory not found at expected location"
    echo "Check: $INSTALL_PATH"
    echo "Note: Installation may have completed but verification failed. Check log: $BUILD_DIR/msi_install.log"
fi

echo "===================================="
echo "      CI COMPLETED SUCCESSFULLY"
echo "===================================="
echo ""
echo "Summary:"
echo "  - Build directory: $BUILD_DIR"
echo "  - MSI installer: $MSI_FILE"
echo "  - Install location: $INSTALL_PATH"
echo "  - Installation log: $BUILD_DIR/msi_install.log"
echo ""
echo "Press Enter to exit..."
read