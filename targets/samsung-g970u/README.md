# GhostLock Samsung S10e (SM-G970U) - Complete Setup Guide

## Target Device Information
- **Device:** Samsung Galaxy S10e
- **Model Code:** SM-G970U
- **Kernel Version:** 4.14.190
- **Architecture:** ARM64 (aarch64)

## Prerequisites

### Required Software
1. **Android SDK NDK r29** - For compiling the exploit
2. **ADB (Android Debug Bridge)** - For deployment via USB
3. **Git** - For workspace management (if not already installed)

### Installation Instructions

#### Windows:
```powershell
# Download and install Android SDK Command Line Tools from:
https://developer.android.com/stools#command-line

# Extract to a permanent location, e.g.:
C:\sdk\cmdline-tools\latest

# Set environment variables (PowerShell):
$env:ANDROID_SDK_ROOT = "C:\sdk"
$env:PATH += ";$env:ANDROID_SDK_ROOT\platform-tools"
$env:PATH += ";$env:ANDROID_SDK_ROOT\ndk-r29\android-ndk-r29"

# Verify installation:
adb version
```

#### WSL (Recommended):
```bash
# Install inside WSL:
sudo apt update
sudo apt install -y wget curl git

# Download NDK r29:
wget https://dl.google.com/android/repository/android-ndk-r29d-linux.zip
unzip android-ndk-r29d-linux.zip
mv android-ndk-r29d /opt/ndk/

# Add to PATH:
echo 'export PATH="/opt/ndk:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify:
ndk-build --version
```

## Quick Start

### Option 1: Automated Script (Recommended)
```bash
cd /workspaces/GhostLock-OPPO-PCKM00/targets/samsung-g970u

# Full deployment (build + deploy + verify):
./deploy.sh all

# Individual commands:
./deploy.sh build        # Build exploit locally
./deploy.sh adb-check    # Verify ADB connection
./deploy.sh deploy       # Deploy to device
./deploy.sh cleanup      # Remove deployed files
```

### Option 2: Manual Steps

#### Step 1: Connect Device
- Enable USB Debugging on Samsung S10e:
  - Settings → About Phone → Software Information → Tap Build Number 7 times
  - Back to Settings → Developer Options → Enable "USB Debugging"
- Connect via USB cable

#### Step 2: Verify ADB Connection
```bash
adb devices
# Should show: SM-G970U    device
```

#### Step 3: Build Exploit
```bash
cd /workspaces/GhostLock-OPPO-PCKM00/targets/samsung-g970u

# Using Windows NDK:
make

# Using WSL NDK (recommended):
make wsl

# Output should be: ghostlock_s970u.so
```

#### Step 4: Deploy via ADB
```bash
adb push ghostlock_s970u.so /data/local/tmp/
adb shell chmod 755 /data/local/tmp/ghostlock_s970u.so
adb shell "cd /data/local/tmp && ./ghostlock_s970u.so"
```

## File Structure

```
targets/samsung-g970u/
├── Makefile              # Build configuration
├── deploy.sh             # Automated deployment script
├── target.h              # Kernel offsets and configuration
└── src/
    ├── main.c            # Main exploit code
    ├── common.h          # Shared headers
    ├── offset.h          # Offset definitions (auto-included)
    ├── util.c            # Utility functions
    ├── slide.c           # Kernel sliding exploitation
    ├── fops.c            # Fake file operations
    ├── pipe.c            # Pipe-based synchronization
    ├── root.c            # Root access implementation
    ├── preload.c         # Preload library logic
    ├── su_blob.S         # Su daemon assembly stub
    └── wallpaper_blob.S  # Wallpaper injection blob
```

## Verification

After deployment, verify root access and adb su functionality:

```bash
# Check root UID/GID
adb shell id
# Expected: uid=0(root) gid=0(root) ...

# Verify SELinux status  
adb shell getenforce
# Expected: Permissive or Disabled

# Confirm su daemon is installed
adb shell ls -la /data/local/tmp/su_daemon
# Expected: -rwxr-xr-x root root 12K Oct 14 14:03 /data/local/tmp/su_daemon

# Check wallpaper module (persistent indicator)
adb shell ls -la /data/local/tmp/wallpaper.so
```

## adb su Commands (Magisk-Style)

Once deployed, use these adb commands for full root access:

```bash
# Request root via su binary
adb shell su

# Verify root inside su session
adb shell "su && id"

# Run any command as root
adb shell "su -c 'whoami'"
# Expected output: root

# List all root-owned processes
adb shell "su -c 'ps aux | grep root' | tail -20"

# Check kernel version (root required)
adb shell "su -c 'uname -a'"

# View /proc/kallsyms (requires root)
adb shell "su -c 'cat /proc/kallsyms | head -5'"

# Full device tree dump (debugging)
adb shell "su -c 'ls -la /sys/devices/soc0/' | tail -20"
```

## Root Features Summary

| Feature | Status |
|---------|--------|
| UID 0 Access | ✅ Active |
| SELinux Permissive | ✅ Disabled |
| adb su Support | ✅ Full compatibility |
| Persistent Daemon | ✅ Auto-restart enabled |
| Magisk-Style API | ✅ Matches rootuserland behavior |


## Troubleshooting

### "ADB device not found"
- Ensure USB debugging is enabled on device
- Check USB cable and port
- Try a different USB port
- Reboot both PC and device

### "Build failed - clang not found"
- Verify NDK installation path in Makefile
- Use `make wsl` if using WSL with NDK at /opt/ndk/
- Check that toolchain matches: aarch64-linux-android30-clang

### "Kernel version mismatch"
The target.h file contains offsets specific to kernel 4.14.190. If you encounter issues, consider:
- Extracting actual kernel symbols from the device using kallsyms
- Using `make extract_kallsyms` (see parent directory)

## Security Notes

⚠️ **Warning:** This exploit is designed for educational and penetration testing purposes only.
- Ensure you have proper authorization before deploying to any device
- Root access bypasses security controls
- Use responsibly and in compliance with applicable laws

## Support

For issues or questions:
1. Check the build logs in `/tmp/build.log`
2. Verify ADB output: `adb logcat | grep ghostlock`
3. Review kernel logs: `adb shell dmesg | tail -50`
