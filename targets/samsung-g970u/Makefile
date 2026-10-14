# GhostLock Samsung Galaxy S10e (SM-G970U) - Kernel 4.14.190

export NDK ?= /opt/android-ndk-r29
TOOLCHAIN_BIN := $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
CC = $(TOOLCHAIN_BIN)/aarch64-linux-android30-clang

SRC_DIR = src

CORE_SRCS = \
  $(SRC_DIR)/main.c \
  $(SRC_DIR)/util.c \
  $(SRC_DIR)/slide.c \
  $(SRC_DIR)/fops.c \
  $(SRC_DIR)/pipe.c \
  $(SRC_DIR)/root.c

PRELOAD_SRCS = $(CORE_SRCS) $(SRC_DIR)/preload.c $(SRC_DIR)/su_blob.S $(SRC_DIR)/wallpaper_blob.S

CFLAGS = --target=aarch64-linux-android30 \
         --sysroot=$(TOOLCHAIN_BIN)/../sysroot \
         -I. \
         -I$(SRC_DIR) \
         -DTARGET_CONFIG_H="\"target.h\"" \
         -O2 -fPIC -shared

TARGET = ghostlock_s970u.so

.PHONY: all clean wsl check-ndk

all: $(TARGET)
	@echo "Build complete: $(TARGET)"
	ls -lh $(TARGET)

wsl:
	@wsl bash -c "cd /mnt/d/GhostLock-OPPO-PCKM00 && make"

$(TARGET): $(PRELOAD_SRCS) target.h
	$(CC) $(CFLAGS) $^ -o $@ -pthread

check-ndk:
@test -f $(CC) || (echo "Error: clang not found"; exit 1)

clean:
	rm -f $(TARGET) *.o
