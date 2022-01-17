# Thanks to

https://nomunomu.hateblo.jp/entry/2018/10/19/002805
https://jkbys.net/ubuntu-20-10-%E6%97%A5%E6%9C%AC%E8%AA%9E-remix%E3%81%AE%E4%BD%9C%E6%88%90%E7%94%A8%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88
https://github.com/mvallim/live-custom-ubuntu-from-scratch

# Overview

- Install ubuntu 20.04 LTS focal to the device.
- Includes chrome, broadcom WiFi driver, Japanese setup, and etc. for my Mac.

# WARING

DEVICE WILL BE WIPED WITHOUT ANY WARNING.

# Basic usage

- Unmount all the target device.
- Specify the target device to `Makefile`.
- Run `make format_disk` to clean the target device.
- Run `make build` to install ubuntu 20.04 focal with my favorite setting.
- Run `make refind` to install rEFInd boot manager.

# Customize

- Edit `tools/chroot_script.sh` also to modify hostname, user name, packages and so on.

# memos ( in Japanese )

- https://qiita.com/numeru55/items/3804b8d1b15fc918194b
