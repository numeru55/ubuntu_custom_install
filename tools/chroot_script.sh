mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C
apt -y update
export DEBIAN_FRONTEND=noninteractive; apt-get install --no-install-recommends -y ubuntu-minimal ubuntu-standard linux-generic keyboard-configuration
apt install ifupdown
for iname in `ls /sys/class/net`; do
    echo "auto $iname" >> /etc/network/interfaces
    if [ $iname = 'lo' ]; then
        echo 'iface lo inet loopback' >> /etc/network/interfaces
    else
        echo "iface $iname inet dhcp" >> /etc/network/interfaces
    fi
done
apt -y upgrade
apt -y clean
apt -y autoremove
echo "Asia/Tokyo" >/etc/timezone
cp /usr/share/zoneinfo/Japan /etc/localtime
locale-gen ja_JP.UTF-8
DEBIAN_FRONTEND=newt; dpkg-reconfigure keyboard-configuration
adduser -q --gecos "" ubuntu
gpasswd -a ubuntu sudo
