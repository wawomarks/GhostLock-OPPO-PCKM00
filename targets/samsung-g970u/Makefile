# GhostLock Samsung Galaxy S10e (SM-G970U) - Kernel 4.14.190

NDK ?= /opt/android-ndk-r29
TOOLCHAIN_BIN := $(NDK)/toolchains/llvm/prebuilt/linux-x86_64/bin
SYSROOT := $(TOOLCHAIN_BIN)/../sysroot
CC = $(TOOLCHAIN_BIN)/aarch64-linux-android30-clang

SRC_DIR = src
BUILD_DIR = build
EMBED_DIR = $(BUILD_DIR)/embed
ASSET_DIR = assets

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
         --sysroot=$(SYSROOT) \
         -I. \
         -I$(SRC_DIR) \
         -I../../exploit/src \
         -O2 -fPIC

LDFLAGS = -shared -pthread
TARGET = ghostlock_s970u.so

.PHONY: all clean check-ndk embed-assets build wsl

all: check-ndk $(TARGET)
	@echo "✅ Build complete: $(TARGET)"
	ls -lh $(TARGET)

wsl:
	@$(MAKE) NDK=/opt/android-ndk-r29

check-ndk:
	@test -f $(CC) || (echo "❌ Error: clang not found at $(CC)"; exit 1)

$(ASSET_DIR):
	mkdir -p $@

$(EMBED_DIR):
	mkdir -p $@

$(ASSET_DIR)/wallpaper.webp: | $(ASSET_DIR)
	@if [ ! -f "$@" ]; then \
		echo "⚠️  wallpaper.webp missing; creating a tiny placeholder for build compatibility."; \
		dd if=/dev/zero of=$@ bs=512 count=1 status=none; \
	fi

$(EMBED_DIR)/su_daemon_aarch64_pie: $(SRC_DIR)/su_daemon.c | $(EMBED_DIR)
	$(CC) --target=aarch64-linux-android30 --sysroot=$(SYSROOT) -O2 -fPIC -pie $< -o $@

$(SRC_DIR)/su_blob.o: $(SRC_DIR)/su_blob.S $(EMBED_DIR)/su_daemon_aarch64_pie
	$(CC) $(CFLAGS) -c $< -o $@

$(SRC_DIR)/wallpaper_blob.o: $(SRC_DIR)/wallpaper_blob.S $(ASSET_DIR)/wallpaper.webp
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(PRELOAD_C_SRCS) $(BLOB_OBJS) src/target.h
	@echo "Building ghostlock_s970u.so..."
	$(CC) $(CFLAGS) $(PRELOAD_C_SRCS) $(BLOB_OBJS) -o $@ $(LDFLAGS)

embed-assets: $(EMBED_DIR)/su_daemon_aarch64_pie $(ASSET_DIR)/wallpaper.webp
	@echo "Embedded assets ready."

clean:
	rm -f $(TARGET) $(SRC_DIR)/*.o $(EMBED_DIR)/su_daemon_aarch64_pie
