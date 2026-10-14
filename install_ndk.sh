#!/bin/bash
# GhostLock NDK Installation Script for Windows/WSL
# Downloads and sets up Android NDK r29

set -e

echo "=== Installing Android NDK r29 ==="

# Check if already installed
if [ -d "/opt/android-ndk-r29" ]; then
    echo "✅ NDK already installed at /opt/android-ndk-r29"
    exit 0
fi

# Download NDK (Linux)
echo "📥 Downloading Android NDK r29..."
wget -q https://dl.google.com/android/repository/android-ndk-r29-linux.zip -O ndk.zip

# Extract and install
echo "📦 Extracting NDK..."
unzip -q ndk.zip
mv android-ndk-r29 /opt/android-ndk-r29

# Verify installation
if [ -f "/opt/android-ndk-r29/build/tools/llvm/bin/aarch64-linux-android30-clang" ]; then
    echo "✅ NDK r29 installed successfully at /opt/android-ndk-r29"
    ls -lh /opt/android-ndk-r29/build/tools/llvm/bin/aarch64-linux-android30-clang
else
    echo "⚠️  LLVM toolchain not found in standard location"
    echo "   Checking alternative path..."
    if [ -d "/opt/ndk" ]; then
        echo "✅ Found NDK at /opt/ndk (WSL configuration)"
    fi
fi

echo ""
echo "📝 Add to ~/.bashrc:"
echo 'export ANDROID_NDK_ROOT=/opt/android-ndk-r29'
echo 'export PATH="$PATH:$ANDROID_NDK_ROOT/build/tools/llvm/bin"'
