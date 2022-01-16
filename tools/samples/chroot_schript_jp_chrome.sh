export HOME=/root
export LC_ALL=C

echo "my-focal" > /etc/hostname

# we need to install systemd first, to configure machine id
apt-get update
apt-get install -y libterm-readline-gnu-perl systemd-sysv

#configure machine id
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

# don't understand why, but multiple sources indicate this
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

apt-get -y upgrade

# install live packages
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

# install kernel
apt-get install -y --no-install-recommends linux-generic

# graphic installer - ubiquity
#    apt-get install -y \
#    ubiquity \
#    ubiquity-casper \
#    ubiquity-frontend-gtk \
#    ubiquity-slideshow-ubuntu \
#    ubiquity-ubuntu-artwork

# echo "==== Enter for user ubuntu ===="
    
# adduser -q --gecos "" ubuntu
adduser --disabled-password --gecos "" ubuntu
echo "ubuntu:custom" | chpasswd
gpasswd -a ubuntu sudo
    
dpkg-reconfigure tzdata
dpkg-reconfigure locales
dpkg-reconfigure --frontend noninteractive resolvconf

# network manager
cat <<EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF

dpkg-reconfigure network-manager

# customize

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

# remove unused and clean up apt cache
apt-get autoremove -y

apt-get clean -y

# truncate machine id (why??)
truncate -s 0 /etc/machine-id

# remove diversion (why??)
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

rm -rf /tmp/* ~/.bash_history
