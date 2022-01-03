mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C
apt -y update
export DEBIAN_FRONTEND=noninteractive
apt-get install --no-install-recommends -y ubuntu-minimal ubuntu-standard linux-generic keyboard-configuration
apt -y upgrade
apt -y clean
apt -y autoremove
echo "Asia/Tokyo" >/etc/timezone
cp /usr/share/zoneinfo/Japan /etc/localtime
locale-gen ja_JP.UTF-8
dpkg-reconfigure keyboard-configuration
adduser -q --gecos "" ubuntu
gpasswd -a ubuntu sudo
