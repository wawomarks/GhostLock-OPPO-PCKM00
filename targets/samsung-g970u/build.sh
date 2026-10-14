#!/bin/bash
# GhostLock Build Script for Samsung S10e (G970U)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Building GhostLock for Samsung Galaxy S10e ==="
echo "Target: $SCRIPT_DIR"

# Check NDK
if [ ! -f "/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang" ]; then
    echo "❌ Error: NDK clang not found. Run ./install_ndk.sh first."
    exit 1
fi

# Check assets
if [ ! -f "build/embed/su_daemon_aarch64_pie" ]; then
    echo "⚠️  su_daemon binary not found. Building..."
    export CC=/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang
    $CC --target=aarch64-linux-android30 -O2 -fPIC -shared src/su_daemon.c -o build/embed/su_daemon_aarch64_pie
fi

if [ ! -f "assets/wallpaper.webp" ]; then
    echo "⚠️  wallpaper.webp not found. Creating placeholder..."
    mkdir -p assets
    dd if=/dev/zero of=assets/wallpaper.webp bs=512 count=1 2>/dev/null
fi

# Build main exploit
echo ""
echo "=== Compiling ghostlock_s970u.so ==="
export CC=/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang

$CC \
    --target=aarch64-linux-android30 \
    --sysroot=/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/bin/../sysroot \
    -I. -Isrc -O2 -fPIC \
    src/main.c src/util.c src/slide.c src/fops.c src/pipe.c src/root.c src/preload.c \
    src/su_blob.o src/wallpaper_blob.o \
    -o ghostlock_s970u.so -shared -pthread \
    -DTARGET_CONFIG_H='"target.h"'

echo ""
echo "✅ Build complete!"
ls -lh ghostlock_s970u.so
