#!/bin/bash

printf "decrypt /dev/sda3..."
cryptsetup luksOpen /dev/sda3

mount /dev/gentoo-vg/root /mnt/gentoo
swapon /dev/gentoo-vg/swap

printf "mount devices..."

mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --rbind /run /mnt/gentoo/run 
mount --make-rslave /mnt/gentoo/run
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount -t tmpfs -o nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm