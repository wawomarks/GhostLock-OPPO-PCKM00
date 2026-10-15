#!/bin/bash
# GhostLock Build Script for Samsung S10e (G970U)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Building GhostLock for Samsung Galaxy S10e ==="
echo "Target: $SCRIPT_DIR"

make clean
make NDK="/opt/android-ndk-r29" all

echo ""
echo "✅ Build complete!"
ls -lh ghostlock_s970u.so
