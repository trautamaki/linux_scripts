#!/bin/bash

. build/envsetup.sh

lunch aosp_cheeseburger-userdebug
make api-stubs-docs
make hiddenapi-lists-docs
make system-api-stubs-docs
make test-api-stubs-docs
make kronic

make otapackage -j8
