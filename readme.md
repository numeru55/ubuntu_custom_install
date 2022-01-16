# Thanks to

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
- Run `make build`. Reply to some request during the installation, such as keyboard, timezone and etc.
- Run `make refind` to install refind boot manager.

# Customize

- Edit `tools/chroot_script.sh` to modify hostname, user name, packages and so on.

# memos ( in Japanese )

- sudo 時に「名前の解決ができません」と怒られる

-- http://blog.livedoor.jp/suguniwasurechau/archives/33047667.html
