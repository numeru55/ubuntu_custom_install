target_disk = /dev/sdb

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
	##### enter chroot #####
	sudo cp -p tools/sources.list root/etc/apt/
	sudo mount --bind /dev root/dev
	sudo mount --bind /run root/run
	sudo chroot root mount none -t proc /proc
	sudo chroot root mount none -t sysfs /sys
	sudo chroot root mount none -t devpts /dev/pts
	sudo chroot root mkdir -p /boot/efi
	sudo chroot root mount $(target_disk)1 /boot/efi
	sudo cp tools/chroot_script.sh root/
	sudo chroot root ./chroot_script.sh
	##### chroot teardown #####
	sudo rm root/chroot_script.sh
	sudo chroot root umount /boot/efi
	sudo chroot root umount /proc
	sudo chroot root umount /sys
	sudo chroot root umount /dev/pts
	sudo umount root/dev
	sudo umount root/run
	##### copy keyboard setting #####
	sudo cp tools/keyboard root/etc/default/
	##### check UUID #####
	$(eval UUID1 := $(shell sudo blkid -o export $(target_disk)1 | grep -E "^UUID" | sed -z 's/\n//g' ))
	$(eval UUID2 := $(shell sudo blkid -o export $(target_disk)2 | grep -E "^UUID" | sed -z 's/\n//g' ))
	##### /etc/fstab #####
	echo "$(UUID2) / ext4 defaults 0 0" >fstab
	echo "$(UUID1) /boot/efi auto defaults 0 0" >>fstab
	mv fstab tools/
	sudo cp tools/fstab root/etc/
	##### /boot/grub/grub.cfg #####
	echo "insmod all_video" >grub.cfg
	echo "set timeout=5" >>grub.cfg
	echo "menuentry 'Ubuntu' {" >>grub.cfg
	echo "	linux	/boot/vmlinuz ro root=$(UUID2)" >>grub.cfg
	echo "	initrd	/boot/initrd.img" >>grub.cfg
	echo "}" >>grub.cfg
	mv grub.cfg tools/
	sudo cp tools/grub.cfg root/boot/grub

update_grub:
	sudo mount --bind /dev root/dev
	sudo mount --bind /run root/run
	sudo chroot root mount none -t proc /proc
	sudo chroot root mount none -t sysfs /sys
	sudo chroot root mount none -t devpts /dev/pts
	sudo chroot root mount $(target_disk)1 /boot/efi
	sudo rm -rf root/boot/efi/*
	sudo chroot root grub-efi
	sudo chroot root update-grub
	sudo chroot root umount /boot/efi
	sudo chroot root umount /proc
	sudo chroot root umount /sys
	sudo chroot root umount /dev/pts
	sudo umount root/dev
	sudo umount root/run

edit_start:
	sudo mount --bind /dev root/dev
	sudo mount --bind /run root/run
	sudo chroot root mount none -t proc /proc
	sudo chroot root mount none -t sysfs /sys
	sudo chroot root mount none -t devpts /dev/pts
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
