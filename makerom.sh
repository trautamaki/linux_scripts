#!/bin/bash

unset ALL

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--all)
    ALL="1"
    shift
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

if [[ $ALL == "1" ]]; then
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33m   Making all targets  \e[0m"
    echo -e "\e[33m=======================\e[0m"
else
    echo -e "\e[33m=======================\e[0m"
    echo -e "\e[33mMaking only cheeseburger\e[0m"
    echo -e "\e[33m=======================\e[0m"
fi

. build/envsetup.sh

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

lunch aosp_cheeseburger-userdebug
make api-stubs-docs
make hiddenapi-lists-docs
make system-api-stubs-docs
make test-api-stubs-docs

make otapackage -j$(nproc --all)

if [[ $ALL == "1" ]]; then
    lunch aosp_dumpling-userdebug
    make otapackage -j$(nproc --all)
fi
