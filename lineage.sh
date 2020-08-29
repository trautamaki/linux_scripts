#!/bin/bash
. build/envsetup.sh

export USE_CCACHE=true
export CCACHE_EXEC=/usr/bin/ccache

lunch lineage_cheeseburger-userdebug
make api-stubs-docs
make hiddenapi-lists-docs
make system-api-stubs-docs
make test-api-stubs-docs

brunch cheeseburger
