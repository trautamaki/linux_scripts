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

# Sideload
# arg1: ZIP to sideload
sload () {
    adb reboot sideload
    adb wait-for-sideload
    adb sideload $1
    adb reboot
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

