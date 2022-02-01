#!/bin/bash

#
# Build script for Ubuntu Focal from debootscrap
#
# Customise for my favorite setting
#
# This script based and inspired by:
#   - https://raw.githubusercontent.com/jkbys/ubuntu-ja-remix/main/20.10/ja-remix-groovy.sh
#
# License CC-BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/
#

# usage example: sudo ./build.sh /dev/sdb

# TARGET_DISK="/dev/sdc"

TARGET_DISK=$1

MY_HOST_NAME="focal"

TARGET_UBUNTU_VERSION="focal"
TARGET_UBUNTU_MIRROR="http://jp.archive.ubuntu.com/ubuntu/"

# OPTION: for new user creation. Uncomment "adduser" in chroot.

# TARGET_USER_NAME="ubuntu"
# TARGET_USER_PASSWORD="custom"

TIMEZONE="Asia/Tokyo"
ZONEINFO_FILE="/usr/share/zoneinfo/Asia/Tokyo"

log() {
  echo "$(date -Iseconds) [info ] $*"
}

log_error() {
  echo "$(date -Iseconds) [error] $*" >&2
}

# only root can run
if [[ "$(id -u)" != "0" ]]; then
  log_error "This script must be run as root"
  exit 1
fi

# confirmation to start

echo "===== will insall focal to... ====="
parted $TARGET_DISK p
echo "====="

read -p "[yes]+[return] to go:" keyboard

if [ "$keyboard" != "yes" ]; then
    echo "skipped."
    exit 1;
fi


# install packages

apt-get install -y debootstrap

# remove directories

log "Removing previously created directories ..."
umount root/
rm -rf root/
log "Done."

# install base

log "Execute debootstrap..."
mkdir root
mount ${TARGET_DISK}2 root
rm -rf root/*
debootstrap --arch=amd64 --variant=minbase focal root
log "Done."

# prepare chroot

log "Prepare chroot..."

# mkdir -p root/etc/apt # already exist

cat <<EOF > root/etc/apt/sources.list
deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION main restricted universe multiverse
deb-src $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION main restricted universe multiverse

deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-security main restricted universe multiverse
deb-src $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-security main restricted universe multiverse

deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-updates main restricted universe multiverse
deb-src $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-updates main restricted universe multiverse
EOF


echo $MY_HOST_NAME > root/etc/hostname

mount --bind /dev root/dev
mount --bind /run root/run

chroot root mount none -t proc /proc
chroot root mount none -t sysfs /sys
chroot root mount none -t devpts /dev/pts

chroot root mkdir -p /boot/efi
chroot root mount ${TARGET_DISK}1 /boot/efi
chroot root rm -rf /boot/efi/*

log "Done."

# chroot and customize
log "Start chroot..."

chroot root <<EOT

# export HOME=/root # already set
export LC_ALL=C

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y systemd-sysv
# apt-get install -y libterm-readline-gnu-perl systemd-sysv

dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

apt-get upgrade

apt-get install -y ubuntu-minimal
apt-get install -y ubuntu-desktop-minimal

apt-get install -y --no-install-recommends linux-generic 

cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF

dpkg-reconfigure network-manager

# setup Japanese

echo "Setup Japanese..."

wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
wget https://www.ubuntulinux.jp/sources.list.d/focal.list -O /etc/apt/sources.list.d/ubuntu-ja.list
apt-get update
apt-get install -y ubuntu-defaults-ja

rm -f /etc/localtime
ln -s "$ZONEINFO_FILE" /etc/localtime
echo "$TIMEZONE" > /etc/timezone

update-locale LANG=ja_JP.UTF-8
sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
locale-gen --keep-existing

# install my essential package

sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
apt-get update
apt-get install -y google-chrome-stable
apt-get install -y bcmwl-kernel-source
apt-get install -y emacs vim bat

# (option) create user

# echo "Create user" $TARGET_USER_NAME "..."

# adduser --disabled-password --gecos "" $TARGET_USER_NAME
# echo $TARGET_USER_NAME:$TARGET_USER_PASSWORD | chpasswd
# gpasswd -a $TARGET_USER_NAME sudo

# grub

echo "Install grub..."

apt-get install -y grub-efi

apt-get autoremove -y
apt-get clean -y

grub-install
update-grub

umount /boot/efi

umount /proc
umount /sys
umount /dev/pts

rm -rf /tmp/* ~/.bash_history

EOT

#####

log "Finished chroot."

umount root/dev
umount root/run

# /etc/hosts

log "edit /etc/hosts..."

cat <<EOF >>root/etc/hosts
127.0.1.1 $MY_HOST_NAME
EOF

# keyboard to jp

log "keyboard to jp..."

cat <<EOF >keyboard
XKBMODEL=pc105
XKBLAYOUT=jp
BACKSPACE=guess
EOF

mv keyboard root/etc/default

# /etc/fstab

log "create /etc/hosts..."

UUID1=`blkid -o export ${TARGET_DISK}1 | grep -E "^UUID" | sed -z 's/\n//g'`
UUID2=`blkid -o export ${TARGET_DISK}2 | grep -E "^UUID" | sed -z 's/\n//g'`

echo "${UUID2} / ext4 defaults 0 0" >fstab
echo "${UUID1} /boot/efi auto defaults 0 0" >>fstab

mv fstab root/etc/

# /boot/grub/grub.cfg

log "edit /boot/grub.cfg..."

echo "insmod all_video" >grub.cfg
echo "set timeout=5" >>grub.cfg
echo "menuentry 'Ubuntu' {" >>grub.cfg
echo "  linux   /boot/vmlinuz ro root=${UUID2}" >>grub.cfg
echo "  initrd  /boot/initrd.img" >>grub.cfg
echo "}" >>grub.cfg

mv grub.cfg root/boot/grub/

umount root

log "Finished script."
