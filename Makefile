target_disk=/dev/sdc

format_disk:
	sudo parted $(target_disk) mklabel gpt 
	sudo parted $(target_disk) mkpart ESP fat32 1MiB 201MiB
	sudo parted $(target_disk) set 1 esp on 
	sudo parted $(target_disk) set 1 boot on 
	sudo parted $(target_disk) mkpart primary ext4 201MiB 100%
	sudo mkdosfs -F32 -nEFI $(target_disk)1
	sudo mkfs.ext4 $(target_disk)2

all: build

build: clean_root
	sudo debootstrap --arch=amd64 --variant=minbase focal root
	# sudo cp /etc/hosts root/etc/
	# sudo cp /etc/resolv.conf root/etc/
	sudo cp -p tools/sources.list root/etc/apt/
	sudo mount --bind /dev root/dev
	sudo mount --bind /run root/run
	sudo chroot root mount none -t proc /proc
	sudo chroot root mount none -t sysfs /sys
	sudo chroot root mount none -t devpts /dev/pts
	sudo cp tools/chroot_script.sh root/
	sudo chroot root ./chroot_script.sh
	sudo rm root/chroot_script.sh
	sudo chroot root umount /proc
	sudo chroot root umount /sys
	sudo chroot root umount /dev/pts
	sudo umount root/dev
	sudo umount root/run
	( ( sudo blkid -o export $(target_disk)2 | grep -E "^UUID" | sed -z 's/\n//g' ) ; echo " / ext4 defaults 0 0") > tools/fstab
	sudo cp tools/fstab root/etc/
	sudo cp tools/keyboard root/etc/default/

edit_start:
	sudo cp /etc/hosts root/etc/
	sudo cp /etc/resolv.conf root/etc/
	sudo cp -p tools/sources.list root/etc/apt/
	sudo mount --bind /dev root/dev
	sudo chroot root

edit_end:
	sudo chroot root umount /proc
	sudo chroot root umount /sys
	sudo chroot root umount /dev/pts
	sudo umount root/dev
	sudo umount root/run

refind: clean_efi
	wget https://sourceforge.net/projects/refind/files/0.13.2/refind-cd-0.13.2.zip/download -O refind-cd-0.13.2.zip
	unzip refind-cd-0.13.2.zip
	mkdir refind
	sudo mount refind-cd-0.13.2.iso refind
	sudo cp -rv refind/EFI efi/
	sudo cp tools/refind.conf efi/EFI/boot/
	sudo umount refind
	sudo rm -rf refind*

clean: clean_efi clean_root

clean_efi:
	sudo rm -rf efi
	mkdir efi
	sudo mount $(target_disk)1 efi
	sudo rm -rf efi/*

clean_root:
	sudo rm -rf root
	mkdir root
	sudo mount $(target_disk)2 root
	sudo rm -rf root/*
