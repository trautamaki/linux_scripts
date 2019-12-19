#!/bin/bash

. build/envsetup.sh

export USE_CCACHE=1
prebuilts/misc/linux-x86/ccache/ccache -M 80G
export CCACHE_EXEC=/usr/bin/ccache

lunch aosp_cheeseburger-userdebug
make api-stubs-docs
make hiddenapi-lists-docs
make system-api-stubs-docs
make test-api-stubs-docs
make kronic

make otapackage -j6

lunch aosp_dumpling-userdebug

make otapackage -j6
