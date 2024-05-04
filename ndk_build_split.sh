#!/bin/bash
# NDK toolchain path - configurable
TOOLCHAIN="/home/ubuntu2204/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64"
API=21  # NDK API version - configurable
SYSROOT="$TOOLCHAIN/sysroot"
# Function to configure and build FFmpeg for a specific architecture
function build_ffmpeg() {
ARCH=$1
CPU=$2
CROSS_PREFIX="$TOOLCHAIN/bin/$3$API-"
CC="${CROSS_PREFIX}clang"
CXX="${CROSS_PREFIX}clang++"
PREFIX="./android/$API/$CPU/"
OPTIMIZE_CFLAGS="-march=$CPU"
make clean
./configure \
--target-os=android \
--prefix=$PREFIX \
--arch=$ARCH \
--cpu=$CPU \
--cc=$CC \
--cxx=$CXX \
--strip="$TOOLCHAIN/bin/llvm-strip" \
--nm="$TOOLCHAIN/bin/llvm-nm" \
--enable-static \
--enable-shared \
--enable-gpl \
--cross-prefix=$CROSS_PREFIX \
--enable-cross-compile \
--sysroot=$SYSROOT \
--extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
$ADDITIONAL_CONFIGURE_FLAG
make -j$(nproc)  # Use all available cores to speed up the compilation process
make install
}
# Build FFmpeg for ARMv7-a
build_ffmpeg "arm" "armv7-a" "arm-linux-androideabi"
# Build FFmpeg for ARMv8-a
build_ffmpeg "arm64" "armv8-a" "aarch64-linux-android"
# Function to link all static libraries into a single shared library
function link_all() {
CPU=$1
mkdir -p ./android/$API/$CPU/lib  # Ensure the directory exists
LIBS=$(find ./android/$API/$CPU/lib -name "*.a")
$CC -shared -o ./android/$API/$CPU/libffmpeg.so $LIBS \
-L$SYSROOT/usr/lib -lm -lz -ldl -llog --sysroot=$SYSROOT
}
# Link static libraries into a single dynamic library for each architecture
link_all "armv7-a"
link_all "armv8-a"

