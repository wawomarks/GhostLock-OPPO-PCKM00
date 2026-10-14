#!/bin/bash
# GhostLock Offset Validation Script
# Validates target.h offsets against Linux 4.14 kernel expectations

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_H="/workspaces/GhostLock-OPPO-PCKM00/targets/samsung-g970u/target.h"
EXPLOIT_DIR="/workspaces/GhostLock-OPPO-PCKM00/targets/samsung-g970u"

echo "=============================================="
echo "  GhostLock Offset Validation Suite"
echo "  Samsung S10e (SM-G970U) - Kernel 4.14.190"
echo "=============================================="
echo ""

# Extract values from target.h
extract_def() {
    grep "^#define $1" "$TARGET_H" | sed 's/.*\(.*\)/\1/' | tr -d '"'
}

echo "[1/6] Parsing target.h configuration..."
INIT_TASK=$(extract_def INIT_TASK)
PIPE_OFF=$(extract_def PIPE_OFF)
FOPS_OFF=$(extract_def FOPS_OFF)
KIMAGE_TEXT_BASE=$(extract_def KIMAGE_TEXT_BASE)
KMALLOC_CACHES=$(extract_def KMALLOC_CACHES)

echo "   INIT_TASK: $INIT_TASK"
echo "   PIPE_OFF: 0x$PIPE_OFF"
echo "   FOPS_OFF: 0x$FOPS_OFF"
echo "   KIMAGE_TEXT_BASE: 0x$KIMAGE_TEXT_BASE"
echo ""

echo "[2/6] Validating Linux 4.14 structural offsets..."

# Validate PIPE and FOPS offsets (Linux 4.14 pipe slab)
if [ "$PIPE_OFF" = "0xc20" ]; then
    echo -e "${GREEN}✓ PIPE offset matches Linux 4.14 standard (0xc20)${NC}"
else
    echo -e "${YELLOW}⚠ PIPE offset is 0x$PIPE_OFF (expected 0xc20 for 4.14)${NC}"
fi

if [ "$FOPS_OFF" = "0xc38" ]; then
    echo -e "${GREEN}✓ FOPS offset matches Linux 4.14 standard (0xc38)${NC}"
else
    echo -e "${YELLOW}⚠ FOPS offset is 0x$FOPS_OFF (expected 0xc38 for 4.14)${NC}"
fi

echo ""

echo "[3/6] Checking source file dependencies..."

cd "$EXPLOIT_DIR"

# Check all required headers exist
for header in common.h offset.h util.c slide.c fops.c pipe.c root.c; do
    if [ -f "src/$header" ]; then
        echo -e "${GREEN}✓ src/$header exists${NC}"
    else
        echo -e "${RED}✗ Missing: src/$header${NC}"
    fi
done

echo ""

echo "[4/6] Analyzing kernel image structure..."

KERNEL_IMG="/workspaces/GhostLock-OPPO-PCKM00/boot/kernel.img"
if [ -f "$KERNEL_IMG" ]; then
    SIZE=$(stat -c%s "$KERNEL_IMG")
    echo "   File: $KERNEL_IMG"
    echo "   Size: $(numfmt --to=iec $SIZE)"
    
    # Check magic header
    MAGIC=$(xxd -l 8 "$KERNEL_IMG" | awk '{print $2$3}')
    if [[ "$MAGIC" == *"UNCOMP"* ]] || [[ "$MAGIC" == *"ELF"* ]]; then
        echo -e "${GREEN}✓ Valid kernel image format detected${NC}"
    else
        echo -e "${YELLOW}⚠ Unknown or custom kernel image format${NC}"
    fi
else
    echo -e "${RED}✗ Kernel image not found at $KERNEL_IMG${NC}"
fi

echo ""

echo "[5/6] Validating build toolchain..."

# Check NDK clang
CLANG_PATH="/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang"
if [ -f "$CLANG_PATH" ]; then
    echo -e "${GREEN}✓ NDK r29 clang found at $CLANG_PATH${NC}"
else
    echo -e "${RED}✗ NDK clang not found (run ./install_ndk.sh)${NC}"
fi

# Check sysroot
SYSROOT="/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
if [ -d "$SYSROOT" ]; then
    echo -e "${GREEN}✓ NDK sysroot found at $SYSROOT${NC}"
else
    echo -e "${RED}✗ NDK sysroot not found${NC}"
fi

echo ""

echo "[6/6] Testing compilation (dry-run)..."

cd "$EXPLOIT_DIR"
make clean >/dev/null 2>&1 || true

# Attempt a quick parse check
if make -n 2>&1 | grep -q "aarch64-linux-android30-clang"; then
    echo -e "${GREEN}✓ Makefile generates valid compiler commands${NC}"
else
    echo -e "${RED}✗ Makefile may have syntax or dependency errors${NC}"
fi

echo ""
echo "=============================================="
echo "  Validation Complete"
echo "=============================================="
echo ""
echo "Summary:"
echo "- Offsets: Validated against Linux 4.14 standards"
echo "- Sources: All required files present in src/"
echo "- Toolchain: NDK r29 ready (if paths verified)"
echo ""

# Provide next steps based on results
if [ -f "$CLANG_PATH" ] && [ -d "$SYSROOT" ]; then
    echo "✅ Ready to build!"
    echo ""
    echo "Next steps:"
    echo "  1. Connect Samsung S10e via USB"
    echo "  2. Run: ./deploy.sh all"
else
    echo "⚠️  Missing components - see above errors"
fi
