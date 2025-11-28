#!/bin/bash
set -e

# Путь к WiX (проверь и при необходимости поправь)
# Пример для 64-bit Program Files (x86)
WIX_BIN="/c/Program Files (x86)/WiX Toolset v3.14/bin"

# Очистка старых артефактов
rm -f CalculatorApp.wixobj CalculatorApp.wixpdb cab1.cab CalculatorApp-*.msi

echo "Compiling WXS..."
"$WIX_BIN/candle.exe" CalculatorApp.wxs -o CalculatorApp.wixobj

echo "Linking MSI (with WixUIExtension)..."
"$WIX_BIN/light.exe" CalculatorApp.wixobj -ext WixUIExtension -o CalculatorApp.msi

echo "Build finished. Output: CalculatorApp.msi"
ls -la CalculatorApp.msi || true
