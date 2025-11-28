#!/bin/bash

echo "===================================="
echo "        CI PROCESS STARTED"
echo "===================================="

# ---------- 1. UPDATE PROJECT ----------
echo "[1] Updating project from Git..."
git pull || { echo "❌ Git update failed."; exit 1; }
echo "✔ Git updated successfully"

# ---------- 2. BUILD PROJECT ----------
echo "[2] Building project..."
BUILD_DIR="build"
rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"
cp index.html script.js style.css "$BUILD_DIR/"
echo "✔ Build completed"

# ---------- 3. INSTALL TEST DEPENDENCIES ----------
echo "[3] Installing test dependencies..."
npm install || { echo "❌ npm install failed."; exit 1; }
echo "✔ Dependencies installed"

# ---------- 4. RUN UNIT TESTS ----------
echo "[4] Running Jest tests..."
npm test || { echo "❌ Unit tests failed."; exit 1; }
echo "✔ All tests passed"

# ---------- 5. GENERATE WXS FILE ----------
echo "[5] Generating WXS file..."
WXS_FILE="$BUILD_DIR/simple_calculator.wxs"

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
        <File Id="IndexHtml" Source="$BUILD_DIR/index.html"/>
        <File Id="ScriptJs"  Source="$BUILD_DIR/script.js"/>
        <File Id="StyleCss"  Source="$BUILD_DIR/style.css"/>
        <!-- KeyPath для компонента через HKCU -->
        <RegistryValue Root="HKCU" Key="Software\CalculatorApp" Name="Installed" Type="integer" Value="1" KeyPath="yes"/>
        <RemoveFolder Id="RemoveINSTALLFOLDER" Directory="INSTALLFOLDER" On="uninstall"/>
      </Component>
    </DirectoryRef>

    <Feature Id="MainFeature" Title="Calculator App" Level="1">
      <ComponentRef Id="AppFilesComponent"/>
    </Feature>
  </Product>
</Wix>
EOL

echo "✔ WXS file generated at $WXS_FILE"

# ---------- 6. BUILD MSI ----------
echo "[6] Building MSI..."
MSI_FILE="$BUILD_DIR/CalculatorApp_CI.msi"

# Указываем путь к WiX, если нужно, например: /c/Program\ Files\ (x86)/WiX\ Toolset\ v3.14/bin
WIX_BIN="C:/Program Files (x86)/WiX Toolset v3.14/bin"

"$WIX_BIN/candle.exe" "$WXS_FILE" -o "$BUILD_DIR/simple_calculator.wixobj" || { echo "❌ WXS compilation failed."; exit 1; }
"$WIX_BIN/light.exe" "$BUILD_DIR/simple_calculator.wixobj" -o "$MSI_FILE" || { echo "❌ MSI linking failed."; exit 1; }
echo "✔ MSI built at $MSI_FILE"

# ---------- 7. INSTALL MSI VIA POWERSHELL ----------
echo "[7] Installing MSI via PowerShell..."
# Формируем путь Windows
WIN_MSI=$(cygpath -w "$MSI_FILE")
LOG_FILE=$(cygpath -w "$BUILD_DIR/msi_install.log")

# Команда PowerShell
POWERSHELL_CMD="Start-Process msiexec -ArgumentList '/i','$WIN_MSI','/qn','/l*v','$LOG_FILE' -Wait -NoNewWindow"

# Выполняем установку
powershell.exe -Command "$POWERSHELL_CMD"

if [ $? -ne 0 ]; then
    echo "❌ MSI installation failed. Check log at $BUILD_DIR/msi_install.log"
    exit 1
fi

echo "✔ MSI installed successfully"
echo "Installation log: $BUILD_DIR/msi_install.log"

echo "===================================="
echo "      CI COMPLETED SUCCESSFULLY"
echo "===================================="
