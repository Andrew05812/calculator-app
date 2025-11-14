#!/bin/bash

WIX="/c/Program Files (x86)/WiX Toolset v3.14/bin"

echo "Compiling WXS..."
"$WIX/candle.exe" CalculatorApp.wxs

if [ $? -ne 0 ]; then
  echo "Error during candle"
  exit 1
fi

echo "Linking MSI..."
"$WIX/light.exe" CalculatorApp.wixobj -o CalculatorApp.msi

if [ $? -ne 0 ]; then
  echo "Error during light"
  exit 1
fi

echo "Build complete: CalculatorApp.msi"
