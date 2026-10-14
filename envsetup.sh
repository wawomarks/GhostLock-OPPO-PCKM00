#!/bin/bash
# GhostLock Environment Setup Script
# Source this file to configure Android SDK paths

export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin"

echo "✅ Android SDK configured at: $ANDROID_SDK_ROOT"
echo "🔧 ADB version: $(adb version 2>&1 | head -1)"
