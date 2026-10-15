# Toolchain & Executables
CC       := /opt/homebrew/opt/llvm/bin/clang
CXX      := /opt/homebrew/opt/llvm/bin/clang++
QAIC     := bin/qaic

# Target Architectures
ANDROID_ARCH := aarch64-linux-android
ANDROID_PATH := target/$(ANDROID_ARCH)
ANDROID_VER  := 26

HEXAGON_ARCH := hexagon-unknown-elf
HEXAGON_PATH := target/$(HEXAGON_ARCH)
HEXAGON_VER  := v65

# Source Files
TARGET_NAME  := hexagon
IDL          := $(TARGET_NAME).idl
SKEL_FILE    := $(TARGET_NAME)_skel.c
STUB_FILE    := $(TARGET_NAME)_stub.c
ANDORID_SRCS :=
HEXAGON_SRCS := $(TARGET_NAME).cpp

# Object Files
ANDROID_OBJS := $(STUB_FILE:.c=.android.o)
HEXAGON_OBJS := $(SKEL_FILE:.c=.hexagon.o) $(HEXAGON_SRCS:.cpp=.hexagon.o)

# Output Shared Libraries
SKEL := lib$(SKEL_FILE:.c=.so)
STUB := lib$(STUB_FILE:.c=.so)

# Include
INCLUDES := \
	-I. \
	-Iidl \
	-Iinc \

# Flags
COMMON_CFLAGS := \
	-O3 \
	-shared \
	-fdata-sections \
	-ffunction-sections \
	-fomit-frame-pointer \
	-fPIC \
	-fvisibility=hidden \
	-nostdlib \
	-Wno-address-of-temporary \
	-Wno-inline-asm

# Android Target Flags
ANDROID_CFLAGS := \
	$(COMMON_CFLAGS) \
	-target $(ANDROID_ARCH) \
	-D__ANDROID_MIN_SDK_VERSION__=$(ANDROID_VER) \
	-DNDEBUG \
	-D__QAIC_STUB_EXPORT='__attribute__((retain, visibility("default")))' \
	-I$(ANDROID_PATH)/include \
	-I$(ANDROID_PATH)/include/$(ANDROID_ARCH)

ANDROID_LDFLAGS := \
	-Wl,--gc-sections \
	-Wl,--no-undefined \
	--ld-path=bin/$(ANDROID_ARCH)-lld \
	-L$(ANDROID_PATH)/lib \
	$(ANDROID_PATH)/lib/crtbegin_so.o \
	$(ANDROID_PATH)/lib/crtend_so.o \
	-lc

# Hexagon Target Flags
HEXAGON_CFLAGS := \
	$(COMMON_CFLAGS) \
	-target $(HEXAGON_ARCH) \
	-m$(HEXAGON_VER) -mhvx -mhvx-length=128b \
	-DNDEBUG \
	-D__QAIC_SKEL_EXPORT='__attribute__((retain, visibility("default")))' \
	-I$(HEXAGON_PATH)/include \
	-Iqurt \
	-fno-exceptions \
	-fno-unwind-tables \
	-fno-strict-aliasing \
	-fno-zero-initialized-in-bss \
	-fno-asynchronous-unwind-tables

HEXAGON_LDFLAGS := \
	-Wl,--gc-sections \
	--ld-path=ld.lld \
	-Wl,-Bsymbolic \
	-Wl,-T,bin/hexagon.ld \
	-Wl,--wrap=malloc \
	-Wl,--wrap=calloc \
	-Wl,--wrap=free \
	-Wl,--wrap=realloc \
	-Wl,--wrap=memalign \
	-Wl,--wrap=__stack_chk_fail

.PHONY: all clean

all: $(SKEL) $(STUB)

# QAIC IDL generation
$(SKEL_FILE) $(STUB_FILE): $(IDL)
	$(QAIC) $(INCLUDES) $<

# Android Object Rules
%.android.o: %.c
	$(CC) $(INCLUDES) $(ANDROID_CFLAGS) -c $< -o $@

# Hexagon Object Rules
%.hexagon.o: %.c
	$(CC) $(INCLUDES) $(HEXAGON_CFLAGS) -c $< -o $@

%.hexagon.o: %.cpp
	$(CXX) $(INCLUDES) $(HEXAGON_CFLAGS) -c $< -o $@

# Target Rules
libcdsprpc.so: cdsprpc.c
	$(CC) $(ANDROID_CFLAGS) $^ -o $@ $(ANDROID_LDFLAGS)

$(SKEL): $(HEXAGON_OBJS)
	$(CXX) $(HEXAGON_CFLAGS) $^ -o $@ $(HEXAGON_LDFLAGS)

$(STUB): $(ANDROID_OBJS) libcdsprpc.so
	$(CC) $(ANDROID_CFLAGS) $^ -o $@ $(ANDROID_LDFLAGS)

clean:
	rm -f $(SKEL_FILE) $(STUB_FILE) $(SKEL) $(STUB) $(TARGET_NAME).h *.o libcdsprpc.so
