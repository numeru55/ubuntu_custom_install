#!/bin/bash

# usage example: sudo ./format.sh /dev/sdb

TARGET_DISK=$1

echo "====="
parted $TARGET_DISK p
echo "===== will be format ... ====="

read -p "[yes]+[return] to go:" keyboard

if [ "$keyboard" != "yes" ]; then
    echo "skipped."
    exit 1;
fi

# format disk

set -e
set -x

parted -s $TARGET_DISK mklabel gpt 
parted -s $TARGET_DISK mkpart EFI fat32 1MiB 201MiB
parted -s $TARGET_DISK set 1 esp on 
parted -s $TARGET_DISK set 1 boot on 
parted -s $TARGET_DISK mkpart primary ext4 201MiB 100%

mkfs -t vfat -n EFI ${TARGET_DISK}1
mkfs -t ext4 -j ${TARGET_DISK}2

echo "===== finished. ====="
parted $TARGET_DISK p

