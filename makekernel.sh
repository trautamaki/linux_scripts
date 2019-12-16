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

if [[ $CLEAN != "" ]]; then
    CLEAN="n"
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m     Making dirty      \e[0m"
    echo -e "\e[33m=======================\e[0m"
else
    CLEAN="y"
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m     Making clean      \e[0m"
    echo -e "\e[33m=======================\e[0m"
        
    if [[ $DEFCONFIG == "" ]]; then
        DEFCONFIG="lineage_oneplus5_defconfig"
        echo -e "\e[33m=======================================================\e[0m"
        echo -e "\e[33m  Using default defconfig: lineage_oneplus5_defconfig\e[0m"
        echo -e "\e[33m=======================================================\e[0m"
    else
        echo -e "\e[33m=======================================================\e[0m"
        echo -e "\e[33m  Selected defconfig: ${DEFCONFIG}\e[0m"
        echo -e "\e[33m=======================================================\e[0m"
    fi
    
    make O=out clean
    make O=out mrproper
    make O=out "${DEFCONFIG}"
fi

if [[ $CLANG == "" ]] || [[ $CLANG == "y" ]] || [[ $CLANG == "clang" ]]; then
    CLANG="y"
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m  Building with Clang  \e[0m"
    echo -e "\e[33m=======================\e[0m"
    make -j4 O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android-
    
    if [ $? -eq 0 ];then
        echo -e "\e[32m=======================\e[0m"
        echo -e "\e[32m   Compile successful  \e[0m"
        echo -e "\e[32m=======================\e[0m"
    else
        echo -e "\e[91m=======================\e[0m"
        echo -e "\e[91m        FAILED         \e[0m"
        echo -e "\e[91m=======================\e[0m"
    fi
else
    CLANG="n"
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m   Building with GCC   \e[0m"
    echo -e "\e[33m=======================\e[0m"
    make O=out -j$(nproc --all) CROSS_COMPILE=/home/timi/caf10_custom/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-

    if [ $? -eq 0 ];then
        echo -e "\e[32m=======================\e[0m"
        echo -e "\e[32m   Compile successful  \e[0m"
        echo -e "\e[32m=======================\e[0m"
    else
        echo -e "\e[91m=======================\e[0m"
        echo -e "\e[91m        FAILED         \e[0m"
        echo -e "\e[91m=======================\e[0m"
    fi
fi

