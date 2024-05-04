#!/bin/bash
#make clean
API=21
NDK=/home/cherry/workspace/Android/Sdk/ndk/21.3.6528147
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
SYSROOT=$TOOLCHAIN/sysroot
ADDITIONAL_CONFIGURE_FLAG="--enable-avdevice --enable-avcodec --enable-avformat --enable-swresample --enable-swscale --enable-postproc --enable-avfilter"
build_android() {
  echo "===========================1========================"
  ../configure \
  --prefix=$OUTPUT \
  --target-os=android \
  --arch=$ARCH \
  --cpu=$CPU \
  --enable-asm \
  --enable-neon \
  --enable-cross-compile \
  --disable-shared \
  --enable-static \
  --disable-doc \
  --disable-ffplay \
  --disable-ffprobe \
  --disable-symver \
  --disable-ffmpeg \
  --sysroot=$SYSROOT \
  --cross-prefix=$CROSS_PREFIX \
  --cc=$CC \
  --cxx=$CXX \
  --extra-cflags="-fPIC" \
  $ADDITIONAL_CONFIGURE_FLAG
  echo "===========================2====================="
  make clean
  echo "=============================${CC}==============="
  make -j16
  make install
  $COMBILE_TOOLCHAIN_LD \
-rpath-link=$COMBILE_PLATFORM/usr/lib \
-L$COMBILE_PLATFORM/usr/lib \
-L$OUTPUT/lib \
-soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
$OUTPUT/libffmpeg.so \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
    libavformat/libavformat.a \
    libavutil/libavutil.a \
    libavdevice/libavdevice.a \
    libswscale/libswscale.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $COMBILE_TOOLCHAIN_GCC
}
 
#arm64-v8a
ARCH=arm64
CPU=armv8-a
CPU_INSTRUCT_COMMON=aarch64-linux-android
OUTPUT=/home/cherry/FFmpeg-n4.4.4/ffbuild/$CPU
CROSS_PREFIX=$TOOLCHAIN/bin/$CPU_INSTRUCT_COMMON-    #AR AS LD等通用
CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang     #CC单独指定，非通用(因为ndk中CC与AR路径不同，后同理)
CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++  #CXX单独指定，非通用
COMBILE_PLATFORM=$NDK/platforms/android-$API/arch-arm64 #
COMBILE_TOOLCHAIN_LD=$NDK/toolchains/$CPU_INSTRUCT_COMMON-4.9/prebuilt/linux-x86_64/bin/$CPU_INSTRUCT_COMMON-ld
COMBILE_TOOLCHAIN_GCC=$NDK/toolchains/$CPU_INSTRUCT_COMMON-4.9/prebuilt/linux-x86_64/lib/gcc/$CPU_INSTRUCT_COMMON/4.9.x/libgcc.a
build_android
 
#armeabi-v7a
ARCH=arm
CPU=armv7-a
CPU_INSTRUCT_COMMON=arm-linux-androideabi
OUTPUT=/home/cherry/FFmpeg-n4.4.4/ffbuild/$CPU
CROSS_PREFIX=$TOOLCHAIN/bin/$CPU_INSTRUCT_COMMON-       #AR AS LD等通用
CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang     #CC单独指定，非通用
CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++  #CXX单独指定，非通用
COMBILE_PLATFORM=$NDK/platforms/android-$API/arch-arm
COMBILE_TOOLCHAIN_LD=$NDK/toolchains/$CPU_INSTRUCT_COMMON-4.9/prebuilt/linux-x86_64/bin/$CPU_INSTRUCT_COMMON-ld
COMBILE_TOOLCHAIN_GCC=$NDK/toolchains/$CPU_INSTRUCT_COMMON-4.9/prebuilt/linux-x86_64/lib/gcc/$CPU_INSTRUCT_COMMON/4.9.x/libgcc.a
build_android