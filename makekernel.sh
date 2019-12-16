#!/bin/bash

export PATH="/home/timi/caf10_custom/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:${PATH}"
export PATH="/home/timi/caf10_custom/prebuilts/clang/host/linux-x86/clang-r353983c/bin:${PATH}"
export ARCH=arm64
export SUBARCH=arm64

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -l|--clang)
    CLANG="$2"
    shift
    shift
    ;;
    -c|--clean)
    CLEAN="$2"
    shift
    shift
    ;;
    -d|--defconfig)
    DEFCONFIG="$2"
    shift
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

if [[ $CLEAN == "" ]] || [[ $CLEAN == "n" ]]; then
    CLEAN="n"
    echo "Making dirty"
else
    CLEAN="n"
    echo "Making clean"
        
    if [[ $DEFCONFIG == "" ]]; then
        DEFCONFIG="lineage_oneplus5_defconfig"
        echo "Using default defconfig: lineage_oneplus5_defconfig"
    else
        echo "Selected defconfig: ${DEFCONFIG}"
    fi
    
    make O=out clean
    make O=out mrproper
    make O=out "${DEFCONFIG}"
fi

if [[ $CLANG == "" ]] || [[ $CLANG == "y" ]] || [[ $CLANG == "clang" ]]; then
    CLANG="y"
    echo "Building with Clang"
    make -j4 O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android-
else
    CLANG="n"
    echo "Building with GCC"
    make O=out -j$(nproc --all) CROSS_COMPILE=/home/timi/caf10_custom/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
fi

