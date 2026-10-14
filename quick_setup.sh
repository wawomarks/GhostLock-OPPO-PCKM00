#!/bin/bash
# GhostLock One-Command Setup & Deploy
# Usage: ./quick_setup.sh [deploy|build|check]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/envsetup.sh"

echo "=============================================="
echo "  GhostLock Samsung S10e (4.14.190) Setup"
echo "=============================================="
echo ""

# Auto-install NDK if needed
if [ ! -f "/opt/android-ndk-r29/build/tools/llvm/bin/aarch64-linux-android30-clang" ]; then
    echo "[1/5] Installing Android NDK r29..."
    "$SCRIPT_DIR/install_ndk.sh" || exit 1
fi

echo ""
echo "[2/5] Verifying build environment..."
if [ -f "/opt/android-ndk-r29/build/tools/llvm/bin/aarch64-linux-android30-clang" ]; then
    echo "      ✓ NDK r29 found"
else
    echo "      ✗ NDK not found at expected location"
    exit 1
fi

echo ""
echo "[3/5] Checking device connection..."
if ! DEVICE=$(adb devices | grep -i "SM-G970U\|Samsung S10e" | awk '{print $1}' | head -1); then
    echo "      ⚠  No Samsung S10e detected via ADB"
    echo "      Connect your device with USB debugging enabled"
    echo ""
    echo "   Available devices:"
    adb devices | grep -E "device|unauthorized" || echo "      (none)"
    exit 0
fi

echo "      ✓ Samsung S10e detected: $DEVICE"

echo ""
echo "[4/5] Building exploit..."
cd "$SCRIPT_DIR/targets/samsung-g970u"
make clean >/dev/null 2>&1 || true
if make -j$(nproc) >/tmp/build.log 2>&1; then
    echo "      ✓ Build successful"
    ls -lh ghostlock_s970u.so | awk '{print "      File: "$5", Size: "$9}'
else
    echo "      ✗ Build failed"
    tail -10 /tmp/build.log
    exit 1
fi

echo ""
echo "[5/5] Deploying to device..."
adb push ghostlock_s970u.so /data/local/tmp/ >/dev/null 2>&1 || { echo "      ✗ Push failed"; exit 1; }
adb shell chmod 755 /data/local/tmp/ghostlock_s970u.so >/dev/null 2>&1 || { echo "      ✗ Chmod failed"; exit 1; }

echo ""
echo "=============================================="
echo "  Deployment Complete!"
echo "=============================================="
echo ""
echo "To run manually:"
echo "  adb shell \"cd /data/local/tmp && ./ghostlock_s970u.so\""
echo ""
echo "Verification commands:"
echo "  adb shell id"
echo "  adb shell getenforce"
echo ""
