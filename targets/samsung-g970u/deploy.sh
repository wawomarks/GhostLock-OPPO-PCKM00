#!/bin/bash
# GhostLock Deployment Script for Samsung Galaxy S10e (SM-G970U)
# Kernel: 4.14.190
# 
# Prerequisites:
#   - Android SDK NDK r29 installed
#   - ADB installed and in PATH
#   - Device connected via USB with USB debugging enabled

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXPLOIT_DIR="$PROJECT_ROOT/targets/samsung-g970u"
SRC_DIR="$EXPLOIT_DIR/src"
MAKE_TARGET="ghostlock_s970u.so"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for NDK
    if [ ! -f "$SRC_DIR/../Makefile" ]; then
        log_error "Exploit Makefile not found at $EXPLOIT_DIR/Makefile"
        exit 1
    fi
    
    # Check for ADB
    if ! command -v adb &> /dev/null; then
        log_error "ADB not found in PATH. Please install Android SDK Platform Tools."
        exit 1
    fi
    
    # Check for NDK toolchain
    NDK="C:\sdk\ndk-r29\android-ndk-r29"
    if [ -f "$NDK/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android30-clang" ]; then
        log_info "Found NDK at: $NDK"
    else
        log_warn "NDK not found at expected location. Build will fail."
    fi
    
    # Check for WSL NDK (alternative)
    NDK_WSL="/opt/ndk/android-ndk-r29"
    if [ -f "$NDK_WSL/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang" ]; then
        log_info "Found WSL NDK at: $NDK_WSL"
    fi
}

build_exploit() {
    log_info "Building GhostLock exploit..."
    
    # Check if build artifacts exist
    if [ -f "$MAKE_TARGET" ]; then
        log_info "Exploit already built. Run 'make clean' to rebuild."
        return 0
    fi
    
    # Try to build using WSL NDK (recommended for best compatibility)
    if [ -f "$NDK_WSL/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang" ]; then
        log_info "Building with WSL NDK..."
        make -C "$EXPLOIT_DIR" wsl 2>&1 | tee /tmp/build.log
        
        if [ -f "$MAKE_TARGET" ]; then
            log_info "Build successful!"
            ls -lh "$MAKE_TARGET"
            return 0
        else
            log_error "Build failed. Check /tmp/build.log for details."
            tail -50 /tmp/build.log
            return 1
        fi
    else
        # Try Windows toolchain
        log_info "Building with Windows NDK..."
        make -C "$EXPLOIT_DIR" 2>&1 | tee /tmp/build.log
        
        if [ -f "$MAKE_TARGET" ]; then
            log_info "Build successful!"
            ls -lh "$MAKE_TARGET"
            return 0
        else
            log_error "Build failed. Check /tmp/build.log for details."
            tail -50 /tmp/build.log
            return 1
        fi
    fi
}

check_adb_connection() {
    log_info "Checking ADB connection to Samsung S10e..."
    
    # Get connected devices
    local devices=$(adb devices | grep -E "device|unauthorized" | tail -n +2)
    
    if [ -z "$devices" ]; then
        log_error "No Android devices connected via ADB."
        return 1
    fi
    
    echo ""
    echo "Connected devices:"
    adb devices
    
    # Check for Samsung S10e specifically
    local g970u=$(echo "$devices" | grep -c "SM-G970U")
    
    if [ "$g970u" -eq 0 ]; then
        log_warn "Samsung Galaxy S10e (SM-G970U) not found in connected devices."
        log_warn "Available devices: $devices"
        return 1
    fi
    
    log_info "Found Samsung S10e (SM-G970U) device!"
    
    # Get device info
    echo ""
    log_info "Device information:"
    adb -s $(adb devices | grep "SM-G970U" | awk '{print $1}') shell getprop ro.product.model
    adb -s $(adb devices | grep "SM-G970U" | awk '{print $1}') shell getprop ro.build.version.release
    adb -s $(adb devices | grep "SM-G970U" | awk '{print $1}') shell getprop ro.kernel.version
    
    return 0
}

deploy_exploit() {
    local device=$(adb devices | grep "SM-G970U" | awk '{print $1}')
    
    if [ -z "$device" ]; then
        log_error "Cannot find SM-G970U device. Run 'make adb-check' first."
        return 1
    fi
    
    log_info "Deploying to Samsung S10e ($device)..."
    
    # Push exploit to device
    if ! adb -s "$device" push "$MAKE_TARGET" /data/local/tmp/ghostlock_s970u.so 2>&1 | grep -v "^"; then
        log_error "Failed to push exploit to device."
        return 1
    fi
    
    # Set executable permissions
    if ! adb -s "$device" shell chmod 755 /data/local/tmp/ghostlock_s970u.so; then
        log_error "Failed to set permissions on exploit."
        return 1
    fi
    
    log_info "Exploit deployed successfully!"
    
    # Run the exploit
    echo ""
    log_info "Running GhostLock exploit..."
    adb -s "$device" shell "cd /data/local/tmp && ./ghostlock_s970u.so"
    
    # Verify root access
    local uid=$(adb -s "$device" shell id | awk -F: '{print $3}')
    local euid=$(adb -s "$device" shell id | awk -F: '{print $4}')
    
    echo ""
    log_info "Verification:"
    echo "  UID: $uid"
    echo "  EUID: $euid"
    
    if [ "$uid" = "0" ] && [ "$euid" = "0" ]; then
        log_info "SUCCESS! Root access confirmed on Samsung S10e (SM-G970U)"
        return 0
    else
        log_error "Failed to gain root access. UID: $uid, EUID: $euid"
        return 1
    fi
}

cleanup() {
    log_info "Cleaning up..."
    
    # Remove deployed files (optional)
    adb -s $(adb devices | grep "SM-G970U" | awk '{print $1}') shell rm -f /data/local/tmp/ghostlock_s970u.so 2>/dev/null || true
    
    log_info "Cleanup complete."
}

show_help() {
    echo "GhostLock Deployment Script for Samsung Galaxy S10e (SM-G970U)"
    echo "Kernel: 4.14.190"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build              Build the GhostLock exploit locally"
    echo "  adb-check          Check ADB connection and device info"
    echo "  deploy             Build (if needed) and deploy to connected S10e via ADB"
    echo "  verify             Run verification checks on deployed exploit"
    echo "  cleanup            Remove deployed files from device"
    echo "  all                Full deployment: build, deploy, and verify"
    echo "  help               Show this help message"
    echo ""
    echo "Prerequisites:"
    echo "  - Android SDK NDK r29 installed"
    echo "  - ADB in PATH"
    echo "  - Samsung S10e connected via USB with USB debugging enabled"
    echo ""
}

case "${1:-help}" in
    build)
        build_exploit
        ;;
    adb-check)
        check_adb_connection
        ;;
    deploy)
        build_exploit || exit 1
        deploy_exploit
        ;;
    verify)
        if [ -f "$MAKE_TARGET" ]; then
            log_info "Running exploit again to verify..."
            adb deploy_exploit | grep -v "^adb:" | grep -v "^$"
        else
            log_error "Exploit not built. Run 'make build' first."
        fi
        ;;
    cleanup)
        cleanup
        ;;
    all)
        echo "=== Full Deployment: Samsung Galaxy S10e (SM-G970U) ==="
        check_prerequisites || exit 1
        build_exploit || exit 1
        check_adb_connection || exit 1
        deploy_exploit
        echo ""
        log_info "=== Deployment Complete ==="
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
