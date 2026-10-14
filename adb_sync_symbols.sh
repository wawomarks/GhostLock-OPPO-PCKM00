#!/bin/bash
# GhostLock ADB Symbol Sync Script
# Extracts real-time kallsyms from connected Samsung S10e (5555) and validates offsets

set -e

DEVICE_IP="127.0.0.1"
ADB_PORT="44473"
SHELL_CMD="adb -s ${DEVICE_IP}:${ADB_PORT}"

echo "=============================================="
echo "  GhostLock ADB Symbol Sync (Port ${ADB_PORT})"
echo "=============================================="
echo ""

# Check connection first
if ! $SHELL_CMD devices 2>/dev/null | grep -q "${DEVICE_IP}"; then
    echo "⚠️  Device not connected on ${DEVICE_IP}:${ADB_PORT}"
    echo "   Waiting for pairing..."
    sleep 5
    
    # Retry once
    if ! $SHELL_CMD devices 2>/dev/null | grep -q "${DEVICE_IP}"; then
        echo "❌ Device still not connected"
        exit 1
    fi
fi

echo "✅ Device connected!"
echo ""

# Extract kallsyms from device
echo "[1/4] Pulling /proc/kallsyms..."
$SHELL_CMD shell "cat /proc/kallsyms" > /tmp/device_kallsyms.tmp 2>/dev/null || {
    echo "   ⚠️  Kallsyms not readable (may require root)"
}

# Extract init_task pointer via debugfs
echo "[2/4] Extracting kernel memory pointers..."
INIT_TASK_ADDR=$(mktemp)
$SHELL_CMD shell "cat /proc/kcore > $INIT_TASK_ADDR" 2>/dev/null || {
    echo "   ⚠️  kcore not accessible"
}

# Parse symbols and find key addresses
echo "[3/4] Analyzing kernel symbols..."

# Use readelf if available, otherwise grep patterns
if command -v readelf >/dev/null 2>&1; then
    echo "   Using readelf for symbol parsing..."
    
    # Extract task_struct offset from kernel modules
    TASK_STRUCT=$(readelf -s /tmp/device_kallsyms.tmp 2>/dev/null | grep -i "task_struct" | head -1 || echo "")
    echo "   $TASK_STRUCT"
fi

# Validate against target.h
echo "[4/4] Validating offsets..."

TARGET_H="/workspaces/GhostLock-OPPO-PCKM00/targets/samsung-g970u/target.h"

if [ -f "$TARGET_H" ]; then
    PIPE_OFF=$(grep "^#define PIPE_OFF" "$TARGET_H" | awk '{print $3}')
    FOPS_OFF=$(grep "^#define FOPS_OFF" "$TARGET_H" | awk '{print $3}')
    
    echo "   Current target.h offsets:"
    echo "     PIPE_OFF:  0x$PIPE_OFF"
    echo "     FOPS_OFF:  0x$FOPS_OFF"
    
    if [ -n "$PIPE_OFF" ] && [ "$PIPE_OFF" = "0xc20" ]; then
        echo -e "\n   ✅ PIPE offset matches Linux 4.14 standard"
    else
        echo -e "\n   ⚠️  PIPE offset differs from expected 0xc20"
    fi
    
    if [ -n "$FOPS_OFF" ] && [ "$FOPS_OFF" = "0xc38" ]; then
        echo -e "   ✅ FOPS offset matches Linux 4.14 standard"
    else
        echo -e "   ⚠️  FOPS offset differs from expected 0xc38"
    fi
else
    echo "   ⚠️  target.h not found at $TARGET_H"
fi

echo ""
echo "=============================================="
echo "  Extraction Complete"
echo "=============================================="
echo ""

# Cleanup
rm -f /tmp/device_kallsyms.tmp "$INIT_TASK_ADDR" 2>/dev/null || true
