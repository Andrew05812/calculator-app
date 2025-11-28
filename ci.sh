#!/bin/bash

echo "===================================="
echo "        CI PROCESS STARTED"
echo "===================================="

echo "[1] Updating project from Git..."
git pull || { echo "❌ Git update failed."; exit 1; }
echo "✓ Git updated successfully"


echo "[2] Building project..."
BUILD_DIR="build"
rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"
cp index.html script.js style.css "$BUILD_DIR/"
echo "✓ Build completed"


echo "[3] Installing test dependencies..."
npm install || { echo "❌ npm install failed."; exit 1; }
echo "✓ Dependencies installed"

echo "[4] Running Jest tests..."
npm test || { echo "❌ Unit tests failed."; exit 1; }
echo "✓ All tests passed"

echo "[5] Generating WXS file..."
WXS_FILE="build/simple_calculator.wxs"

ABSOLUTE_BUILD_DIR=$(pwd)/$BUILD_DIR
ABSOLUTE_BUILD_DIR_WIN=$(cygpath -w "$ABSOLUTE_BUILD_DIR")

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

echo "[6] Building MSI..."
MSI_FILE="$BUILD_DIR/CalculatorApp_CI.msi"

WIX_BIN="C:/Program Files (x86)/WiX Toolset v3.14/bin"

if [ ! -d "$WIX_BIN" ]; then
    echo "❌ WiX Toolset not found at $WIX_BIN"
    echo "Please install WiX Toolset from https://wixtoolset.org/"
    exit 1
fi

WIN_BUILD_DIR=$(cygpath -w "$(pwd)/$BUILD_DIR")

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

echo "[7] Installing MSI via PowerShell..."

WIN_MSI=$(cygpath -w "$(pwd)/$MSI_FILE")
LOG_FILE=$(cygpath -w "$(pwd)/$BUILD_DIR/msi_install.log")

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
INSTALL_PATH="$LOCALAPPDATA/CalculatorApp"

if [ -d "$INSTALL_PATH" ]; then
    echo "✓ Application installed at: $INSTALL_PATH"
    echo "Files:"
    ls -lh "$INSTALL_PATH"
else
    echo "⚠ Installation directory not found at expected location"
    echo "Check: $INSTALL_PATH"
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