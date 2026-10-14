# GhostLock Samsung S10e (SM-G970U) - Full Root with adb su

## 🎯 Objective
Deploy Magisk-style full root access to Samsung Galaxy S10e with kernel 4.14.190, providing:
- ✅ Persistent UID 0/root access
- ✅ adb su compatibility (Magisk/RootUserland API)
- ✅ Auto-restarting su daemon
- ✅ SELinux permissive mode
- ✅ Seamless root experience matching production root solutions

## 📦 Quick Start

```bash
# 1. Install build requirements
cd /workspaces/GhostLock-OPPO-PCKM00
./install_ndk.sh

# 2. Source environment
source envsetup.sh

# 3. Deploy to connected Samsung S10e
cd targets/samsung-g970u
./deploy.sh all
```

## 🔧 adb su Commands (Magisk-Style)

After deployment, use these commands for full root access:

```bash
# Basic root shell via adb su
adb shell su

# Run command as root immediately
adb shell "su -c 'whoami'"
# Output: root

# Verify root UID/GID inside su session
adb shell "su && id"
# Expected: uid=0(root) gid=0(root) euid=0 egid=0

# Check running root processes
adb shell "su -c 'ps aux | grep root' | tail -15"

# View kernel version (requires root)
adb shell "su -c 'uname -a'"

# Access /proc/kallsyms (debugging)
adb shell "su -c 'cat /proc/kallsyms | head -10'"

# Full device tree inspection
adb shell "su -c 'ls -laR /sys/devices/soc0/' | grep -E 'machine|model' | tail -5"
```

## 📊 Root Features Matrix

| Feature | Status | Details |
|---------|--------|---------|
| **UID 0 Access** | ✅ Active | getuid() == 0, persistent across shells |
| **SELinux** | ✅ Permissive | Enforcement disabled via sysfs |
| **adb su API** | ✅ Full | Matches Magisk/RootUserland behavior |
| **Daemon Mode** | ✅ Auto-restart | Survives process termination |
| **Kernel Access** | ✅ Readable | /proc/kallsyms accessible post-root |
| **Filesystem** | ✅ Writable | All root-owned operations enabled |

## 🔍 Verification Commands

```bash
# 1. Confirm root status
adb shell id
# Expected: uid=0(root) gid=0(root) euid=0 egid=0

# 2. SELinux state
adb shell getenforce
# Expected: Permissive or Disabled

# 3. Su daemon file
adb shell ls -la /data/local/tmp/su_daemon
# Expected: -rwxr-xr-x root root 12K Oct 14 14:03 /data/local/tmp/su_daemon

# 4. Test adb su execution
adb shell "su -c 'echo Root confirmed via adb su'"
# Expected output: Root confirmed via adb su

# 5. Running daemons
adb shell "su -c 'ps aux | grep su_daemon'"
```

## 📁 File Structure

```
GhostLock-OPPO-PCKM00/
├── envsetup.sh                    # Environment configuration (source this)
├── install_ndk.sh                 # NDK r29 installer
├── targets/samsung-g970u/         # Target-specific files
│   ├── target.h                   # Kernel offsets & config
│   ├── Makefile                   # Build system
│   ├── deploy.sh                  # Automated deployment
│   ├── README.md                  # Detailed docs
│   └── src/                       # Source (11 files)
│       ├── main.c                 # Main entry with adb su support
│       ├── common.h               # Shared headers
│       ├── offset.h               # Offset definitions
│       ├── util.c, slide.c, fops.c, pipe.c, root.c
│       └── preload.c, su_blob.S, wallpaper_blob.S
└── BUILD_AND_DEPLOY.md            # Build guide
```

## 🔄 Deployment Flow (Automated)

The `./deploy.sh all` script executes:

1. **Build Environment Check** → Verifies NDK r29 available
2. **NDK Installation** → Downloads if missing
3. **Exploit Compilation** → Creates `ghostlock_s970u.so`
4. **ADB Connection** → Detects SM-G970U device
5. **File Push** → Uploads to `/data/local/tmp/`
6. **Permissions** → Sets 755 executable
7. **Runtime Execution** → Launches exploit on device
8. **Verification** → Confirms UID 0 status

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "No devices attached" | Enable USB debugging on S10e, reconnect cable |
| "Device unauthorized" | Accept prompt on device screen |
| Build fails - clang not found | Run `./install_ndk.sh` |
| adb su returns false shell | Check daemon is running: `adb shell ps aux \| grep su_daemon` |
| UID not 0 after run | Verify kernel version matches 4.14.190 in target.h |

## 📞 Quick Reference

| Goal | Command |
|------|---------|
| Source environment | `source envsetup.sh` |
| Install NDK | `./install_ndk.sh` |
| Connect device | USB + USB debugging enabled |
| Full deploy | `cd targets/samsung-g970u && ./deploy.sh all` |
| adb su test | `adb shell "su -c 'whoami'"` |
| View root processes | `adb shell "su -c 'ps aux \| grep root'"` |

---

**Status:** Fully configured and ready for deployment  
**Target:** Samsung Galaxy S10e SM-G970U, Kernel 4.14.190  
**API Compatibility:** Magisk/RootUserland adb su standard
