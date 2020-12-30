#!/bin/bash

SDAT2IMG=~/sdat2img.py

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -z|--zip)
    ZIP="$2"
    shift
    shift
    ;;
    -d|--dir)
    DIR="$2"
    shift
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}"

[[ "${DIR}" == */ ]] && STR="${DIR: : -1}"

# Unmount existing images
if mountpoint -q "${DIR}/system/vendor"; then
    echo "Unmount existing system/vendor"
    umount ${DIR}/system/vendor
    rm -rf ${DIR}/system/vendor
fi

if mountpoint -q "${DIR}/system"; then
    echo "Unmount existing system"
    umount ${DIR}/system
    rm -rf ${DIR}/system
fi

rm -rf ${DIR}/system/vendor
rm -rf ${DIR}/system
mkdir ${DIR}

unzip -o ${ZIP} system.transfer.list system.new.dat* vendor.transfer.list vendor.new.dat*  \
    -d ${DIR} || { echo 'Unzipping failed' ; exit 1; }

# Handle brotli compressed files
if ls ${DIR}/*.br 1> /dev/null 2>&1; then
    rm ${DIR}/system.new.dat
    rm ${DIR}/vendor.new.dat
    echo "Decompressing brotli files"
    brotli --decompress --output=${DIR}/system.new.dat ${DIR}/system.new.dat.br || { echo 'Decompressing brotli failed' ; exit 1; }
    brotli --decompress --output=${DIR}/vendor.new.dat ${DIR}/vendor.new.dat.br || { echo 'Decompressing brotli failed' ; exit 1; }
fi

python ${SDAT2IMG} ${DIR}/system.transfer.list ${DIR}/system.new.dat ${DIR}/system.img
python ${SDAT2IMG} ${DIR}/vendor.transfer.list ${DIR}/vendor.new.dat ${DIR}/vendor.img

echo "Mounting system"
mkdir ${DIR}/system
mount ${DIR}/system.img ${DIR}/system/ || { echo 'Mounting system failed' ; exit 1; }

echo "Mounting system/vendor"
rm -rf ${DIR}/system/vendor
mkdir ${DIR}/system/vendor
mount ${DIR}/vendor.img ${DIR}/system/vendor/ || { echo 'Mounting vendor failed' ; exit 1; }

sudo chown -R $USER:$USER ${DIR}

