adbsync () {
    adb root
    adb remount
    adb sync $1
    adb reboot
}

adbsyncnorb () {
    adb root
    adb remount
    adb sync $1
}

alias currentslot="sudo fastboot getvar current-slot"

# Build target with GMS
# arg1: target
brunchg () {
    export WITH_GMS=true
    export GMS_MAKEFILE=gms_minimal.mk
    breakfast $1
    make installclean
    brunch $1
    unset WITH_GMS
    unset GMS_MAKEFILE
}

# Build target with GMS-TV
# arg1: target
brunchtv () {
    export WITH_GMS=true
    export WITH_GMS_TV=true
    breakfast $1
    make installclean
    brunch $1
    unset WITH_GMS
    unset WITH_GMS_TV
}

# Build an app, push it and restart the app
# arg1: app target
# arg2: app package name
mkapp () {
    make clean-$1
    make $1
    adbsyncnorb
    adb shell am force-stop $2
    adb shell monkey -p $2 -c android.intent.category.LAUNCHER 1
}

lbreakfast () {
    . build/envsetup.sh
    b=$(breakfast $1)
    arch=$(echo $b | grep -m 1 "TARGET_ARCH")
    arch=${arch#*TARGET_ARCH=}
    device_dir=$(find device -type d -name $1 | head -1)
    kernel_source=$(findkernelsrc $device_dir)
    version_var=$(grep -i -m 1 VERSION $kernel_source/Makefile)
    patchlevel_var=$(grep -i -m 1 PATCHLEVEL $kernel_source/Makefile)
    kernel_version=${version_var#*= }.${patchlevel_var#*= }
    export OUT_DIR_COMMON_BASE=/zfs/android-out-$arch-$kernel_version
    breakfast $1
}

findkernelsrc () {
    search_dir=$1
    if grep -q TARGET_KERNEL_SOURCE $search_dir/BoardConfig*; then
        src_var=$(grep -i TARGET_KERNEL_SOURCE $search_dir/BoardConfig*)
        src_path=${src_var#*=}
        echo $src_path | xargs
    else
        jq -c ".[]" $search_dir/lineage.dependencies | while read i; do
            findkernelsrc $(echo $i | jq ".target_path" | tr -d '"')
        done
    fi
}
