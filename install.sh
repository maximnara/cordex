#!/bin/bash

echo "🚀 Installing Cordova Plugin Manager..."

# Copy manager script to current directory
cp cordova-plugin-manager.sh ../
chmod +x ../cordova-plugin-manager.sh

# Install the library
cd ..
./cordova-plugin-manager.sh install

echo "✅ Installation complete!"
echo "Usage: ./cordova-plugin-manager.sh <command>"
