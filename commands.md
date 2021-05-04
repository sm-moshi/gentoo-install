# Commands to install Gentoo (04/05/2021)
# Creating the partitions
    mkdir /mnt/gentoo

    parted /dev/nvme0n1 or /dev/sda1
        mklabel gpt
        mkpart primary fat32 1MiB 3Mib
        mkpart primary fat32 3Mib 803MiB
        mkpart primary 803MiB -1

        name 1 grub
        name 2 boot
        name 3 luks
        set 1 bios_grub on
        set 2 boot on
        print
        quit

    mkfs.vfat /dev/nvme0n1 or /dev/sda1
    mkfs.vfat -F32 /dev/nvme0n1p2 or /dev/sda2
    cryptsetup luksFormat -c aes-xts-plain64 -s 512 /dev/nvme01n1p3 or /dev/sda3

    cryptsetup luksOpen /dev/nvme0n1p3 or /dev/sda3

    pvcreate /dev/mapper/lvm
    vgcreate -s 16M gentoo-vg /dev/mapper/lvm
    lvcreate -L 8G -n swap gentoo-vg
    lvcreate -L -100G -n root gentoo-vg
    lvcreate -L 100%FREE home gentoo-vg

    mkfs.ext4 -m1 /dev/gentoo-vg/root
    mount /dev/gentoo-vg/root /mnt/gentoo

    mkswap /dev/gentoo-vg/swap
    swapon /dev/gentoo-vg/swap

    mkdir /mnt/gentoo

# Gentoo Basic Install
    - cd /mnt/gentoo
    - wget https://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-20210502T214503Z.tar.xz
    - tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

    - nano /mnt/gentoo/etc/portage/make.conf

    - nano /mnt/gentoo/etc/portage/package.mask

    - cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

    - mount -t proc /proc /mnt/gentoo/proc
    - mount --rbind /sys /mnt/gentoo/sys
    - mount --make-rslave /mnt/gentoo/sys
    - mount --rbind /dev /mnt/gentoo/dev
    - mount --make-rslave /mnt/gentoo/dev
    - test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
    - mount -t tmpfs -o nosuid,nodev,noexec shm /dev/shm
    - chmod 1777 /dev/shm

    - chroot /mnt/gentoo /bin/bash
    - source /etc/profile
    - export PS1="(chroot) $PS1"

    - mount /dev/nvme0n1ps2 /boot (or /dev/sda2)

    - emerge --sync
    - emerge --oneshot sys-apps/portage

    - eselect profile list
    - eselect profile set 24

    - echo Europe/Berlin > /etc/timezone/data
    - emerge --config sys-libs/timezone-data

    - cat locale.gen
        - de_DE.UTF_8 UTF-8
    - nano /etc/locale.gen (add your locales)
    