#!/bin/bash

export MY_HOST_NAME="my-focal"

export TARGET_USER_NAME="ubuntu"
export TARGET_USER_PASSWORD="custom"

export HOME=/root
export LC_ALL=C

echo $MY_HOST_NAME > /etc/hostname

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y libterm-readline-gnu-perl systemd-sysv

dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

apt-get -y upgrade

apt-get install -y \
sudo \
ubuntu-standard \
casper \
lupin-casper \
discover \
laptop-detect \
os-prober \
network-manager \
resolvconf \
net-tools \
wireless-tools \
wpagui \
grub-common \
grub-gfxpayload-lists \
grub-pc \
grub-pc-bin \
grub2-common \
locales

apt-get install -y --no-install-recommends linux-generic

adduser --disabled-password --gecos "" $TARGET_USER_NAME
echo $TARGET_USER_NAME:$TARGET_USER_PASSWORD | chpasswd
gpasswd -a $TARGET_USER_NAME sudo

dpkg-reconfigure --frontend noninteractive tzdata
dpkg-reconfigure --frontend noninteractive locales
dpkg-reconfigure --frontend noninteractive resolvconf

cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF

dpkg-reconfigure network-manager

# ==== start customize ====

apt-get install -y ubuntu-gnome-desktop

# setup japanese

wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
wget https://www.ubuntulinux.jp/sources.list.d/focal.list -O /etc/apt/sources.list.d/ubuntu-ja.list
apt-get update
apt-get install -y ubuntu-defaults-ja
    
# add chrome and broadcom driver

sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
apt-get update
apt-get install -y google-chrome-stable
apt-get install -y bcmwl-kernel-source
apt-get install -y emacs
    
# purge

apt-get purge -y \
libreoffice* thunderbird* rhythmbox* remmina* \
transmission-gtk \
transmission-common \
gnome-mahjongg \
gnome-mines \
gnome-sudoku \
aisleriot \
hitori

apt-get install -y grub-efi

# remove unused and clean up apt cache
apt-get autoremove -y

apt-get clean -y

TIMEZONE="Asia/Tokyo"
ZONEINFO_FILE="/usr/share/zoneinfo/Asia/Tokyo"

rm -f /etc/localtime
ln -s "$ZONEINFO_FILE" /etc/localtime
echo "$TIMEZONE" > /etc/timezone

update-locale LANG=ja_JP.UTF-8
sed -i 's/# ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/' /etc/locale.gen
locale-gen --keep-existing

truncate -s 0 /etc/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

cat <<EOF >>/etc/hosts
127.0.1.1 $MY_HOST_NAME
EOF

# install grub-efi

grub-install
update-grub

rm -rf /tmp/* ~/.bash_history
