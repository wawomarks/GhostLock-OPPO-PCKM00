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

PRELOAD_C_SRCS = $(CORE_SRCS) $(SRC_DIR)/preload.c
BLOB_OBJS = $(SRC_DIR)/su_blob.o $(SRC_DIR)/wallpaper_blob.o

CFLAGS = --target=aarch64-linux-android30 \
         --sysroot=$(TOOLCHAIN_BIN)/../sysroot \
         -I. \
         -I$(SRC_DIR) \
         -O2 -fPIC

LDFLAGS = -shared -pthread

TARGET = ghostlock_s970u.so

.PHONY: all clean check-ndk embed-assets build

all: $(TARGET)
	@echo "✅ Build complete: $(TARGET)"
	ls -lh $(TARGET)

check-ndk:
@test -f $(CC) || (echo "❌ Error: clang not found at $(CC)"; exit 1)

embed-assets:
	@mkdir -p build/embed assets
	@if [ ! -f build/embed/su_daemon_aarch64_pie ]; then \
		echo "⚠️  su_daemon binary not found at build/embed/su_daemon_aarch64_pie"; \
		echo "   Run: make embed-su-daemon"; \
	fi
	@if [ ! -f assets/wallpaper.webp ]; then \
		echo "⚠️  wallpaper.webp not found at assets/wallpaper.webp"; \
		echo "   Place a small test wallpaper in assets/wallpaper.webp"; \
	fi

$(SRC_DIR)/su_blob.o: $(SRC_DIR)/su_blob.S build/embed/su_daemon_aarch64_pie
	$(CC) $(CFLAGS) -c $< -o $@

$(SRC_DIR)/wallpaper_blob.o: $(SRC_DIR)/wallpaper_blob.S assets/wallpaper.webp
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(PRELOAD_C_SRCS) $(BLOB_OBJS) target.h
	@echo "Building ghostlock_s970u.so..."
	@CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" \
		/bin/bash -c "$(CC) $(CFLAGS) $(PRELOAD_C_SRCS) $(BLOB_OBJS) -o \$@ $(LDFLAGS) -DTARGET_CONFIG_H='\"target.h\"'"

clean:
	rm -f $(TARGET) $(SRC_DIR)/*.o build/embed/su_daemon_aarch64_pie
