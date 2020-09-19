#!/bin/bash

default_abi="~/aarch64-linux-android-4.9/bin"
default_gcc="~/clang-10-0-6/bin"

export PATH="${PATH}:/root/clang-10-0-6/bin:/root/aarch64-linux-android-4.9/bin"
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE_ARM32="/root/caf10/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

zip_kernel () {
    echo -e "Zipping kernel..."
    cp out/arch/arm64/boot/Image.gz-dtb zip/
    cd zip
    rm kernel.zip &> /dev/null
    zip -r kernel.zip . &> /dev/null
    cp kernel.zip /var/www/html/
    echo -e "Kernel zipped!"
}

finish () {
	END=$(date +"%s")
	DIFF=$(($END - $START))
	echo -e "\e[32m=======================\e[0m"
	echo -e "\e[32m Compile successful in \e[0m"
	echo -e "\e[32m     $(($DIFF / 60)) min $(($DIFF % 60)) s  \e[0m"
	echo -e "\e[32m=======================\e[0m"
	zip_kernel
}

fail () {
	END=$(date +"%s")
	DIFF=$(($END - $START))
	echo -e "\e[91m=======================\e[0m"
	echo -e "\e[91m      FAILED in        \e[0m"
	echo -e "\e[91m      $(($DIFF / 60)) min $(($DIFF % 60)) s  \e[0m"
	echo -e "\e[91m=======================\e[0m"
}

clean () {
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

    make O=out clean -s
    make O=out mrproper -s
    make O=out "${DEFCONFIG}" -s
}

make_gcc () {
    CLANG="n"
    START=$(date +"%s")
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m   Building with GCC   \e[0m"
    echo -e "\e[33m=======================\e[0m"
    make -j$(nproc --all) O=out CROSS_COMPILE=aarch64-linux-android-

    if [ $? -eq 0 ];then
		finish
    else
		fail
    fi
}

make_clang () {
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
        finish
    else
        fail
    fi
}

path_clang=$(which clang)
path_gcc=$(which aarch64-linux-android-gcc)

if [ -x "$path_clang" ] ; then
    echo "CLANG found in PATH: $path_clang"
else
    echo "CLANG not found in PATH, using default: ${default_clang}"
    export PATH="${default_clang}:${PATH}"
fi

if [ -x "$path_gcc" ] ; then
    echo "GCC found in PATH: $path_gcc"
else
    echo "GCC not found in PATH, using default: ${default_gcc}"
    export PATH="${default_gcc}:${PATH}"
fi

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
	clean
fi

if [[ $CLANG == "" ]] || [[ $CLANG == "y" ]] || [[ $CLANG == "clang" ]]; then
	make_clang
else
	make_gcc
fi
