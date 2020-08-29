#!/bin/bash

default_abi="~/caf10/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin"
default_clang="~/caf10/prebuilts/clang/host/linux-x86/clang-r353983c/bin"

if [[ ${PATH} == *"clang"* ]]; then
    echo "Clang found in PATH"
else
    echo "Clang not found in PATH"
    echo "Using default Clang path"
    export PATH="${default_clang}:${PATH}"
fi

if [[ ${PATH} == *"aarch64-linux-android-4.9"* ]]; then
    echo "GCC found in PATH"
else
    echo "GCC not found in PATH"
    echo "Using default GCC path"
    export PATH="${default_abi}:${PATH}"
fi

export ARCH=arm64
export SUBARCH=arm64

export CROSS_COMPILE_ARM32="/root/caf10/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

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
    START=$(date +"%s")
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m  Building with Clang  \e[0m"
    echo -e "\e[33m=======================\e[0m"
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
                          CC=clang \
                          CLANG_TRIPLE=aarch64-linux-gnu- \
                          CROSS_COMPILE=aarch64-linux-android-

    if [ $? -eq 0 ];then
        END=$(date +"%s")
        DIFF=$(($END - $START))
        echo -e "\e[32m=======================\e[0m"
        echo -e "\e[32m Compile successful in \e[0m"
        echo -e "\e[32m     $(($DIFF / 60)) min $(($DIFF % 60)) s  \e[0m"
        echo -e "\e[32m=======================\e[0m"
    else
        END=$(date +"%s")
        DIFF=$(($END - $START))
        echo -e "\e[91m=======================\e[0m"
        echo -e "\e[91m        FAILED         \e[0m"
        echo -e "\e[91m        $(($DIFF / 60)) min $(($DIFF % 60)) s  \e[0m"
        echo -e "\e[91m=======================\e[0m"
    fi
else
    CLANG="n"
    START=$(date +"%s")
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m   Building with GCC   \e[0m"
    echo -e "\e[33m=======================\e[0m"
    make O=out -j$(nproc --all) CROSS_COMPILE=aarch64-linux-android-

    if [ $? -eq 0 ];then
        END=$(date +"%s")
        DIFF=$(($END - $START))
        echo -e "\e[32m=======================\e[0m"
        echo -e "\e[32m Compile successful in \e[0m"
        echo -e "\e[32m     $(($DIFF / 60)) min $(($DIFF % 60)) s  \e[0m"
        echo -e "\e[32m=======================\e[0m"
    else
        END=$(date +"%s")
        DIFF=$(($END - $START))
        echo -e "\e[91m=======================\e[0m"
        echo -e "\e[91m      FAILED in        \e[0m"
        echo -e "\e[91m      $(($DIFF / 60)) min $(($DIFF % 60)) s  \e[0m"
        echo -e "\e[91m=======================\e[0m"
    fi
fi
