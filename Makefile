format_disk:
	sudo parted /dev/sdb mklabel gpt 
	sudo parted /dev/sdb mkpart ESP fat32 1MiB 201MiB
	sudo parted /dev/sdb set 1 esp on 
	sudo parted /dev/sdb set 1 boot on 
	sudo parted /dev/sdb mkpart primary ext4 201MiB 100%
	sudo mkdosfs -F32 -nEFI /dev/sdb1
	sudo mkfs.ext4 /dev/sdb2
	mkdir disk
	sudo mount /dev/sdb1 disk
	sudo cp -r efi/* disk/
	sudo umount disk
	sudo mount /dev/sdb2 disk
	sudo cp -r root/* disk/
	sudo umount disk
	sudo rm -rf disk

all: build

config: clean
	lb config
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub > config/archives/google.key.chroot
	cp config/archives/google.key.chroot config/archives/google.key.binary

build: clean_root
	sudo debootstrap --arch=amd64 --variant buildd focal root
	sudo cp /etc/hosts root/etc/
	sudo cp /etc/resolv.conf root/etc/
	sudo cp -p tools/sources.list root/etc/apt/
	sudo mount --bind /dev root/dev
	sudo cp tools/chroot_script.sh root/
	sudo chroot root ./chroot_script.sh
	sudo rm root/chroot_script.sh

edit:
	sudo cp /etc/hosts root/etc/
	sudo cp /etc/resolv.conf root/etc/
	sudo cp -p tools/sources.list root/etc/apt/
	sudo mount --bind /dev root/dev
	sudo cp tools/chroot_script.sh root/
	sudo chroot root ./chroot_script.sh
	sudo rm root/chroot_script.sh

refind: clean_efi
	wget https://sourceforge.net/projects/refind/files/0.13.2/refind-cd-0.13.2.zip/download -O refind-cd-0.13.2.zip
	unzip refind-cd-0.13.2.zip
	mkdir refind
	sudo mount refind-cd-0.13.2.iso refind
	sudo cp -rv refind/EFI efi/
	sudo umount refind
	sudo rm -rf refind*

clean: clean_efi clean_root

clean_efi:
	sudo rm -rf efi
	mkdir efi

clean_root:
	sudo rm -rf root
	mkdir root
