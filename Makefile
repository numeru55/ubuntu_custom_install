all: build

config: clean
	lb config
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub > config/archives/google.key.chroot
	cp config/archives/google.key.chroot config/archives/google.key.binary

build: clean_root
	sudo debootstrap --arch=amd64 focal root

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
