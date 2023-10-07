# Commands to install basic Gentoo with systemd, LLVM and ext as root in QEMU (UTM) on Apple M2 Pro (2023/07/25)

https://gist.github.com/setkeh/42b1d6a86bf31001b797e991ae7296d8
https://wiki.gentoo.org/wiki/QEMU/Linux_guest#Kernel
https://blog.devgenius.io/installing-gentoo-linux-in-apple-macbook-pro-m1-49e163534898
https://wiki.gentoo.org/wiki/User:Jared/Gentoo_On_An_M1_Mac
https://wiki.gentoo.org/wiki/Apple_Silicon_VMware_Guide#Preparing_the_Disks
https://wiki.gentoo.org/wiki/Talk:QEMU/Linux_guest#Display

##

VM settings in QEMU:

- Architecture: ARM64 (aarch64)
- Machine: QEMU 7.2 ARM Virtual Machine (alias of virt-7.2 (virt)
- CPU Cores: 12
- RAM: 14 GB
- ...

## Creating the partitions

```shell

parted -a optimal /dev/vda

unit mib
mklabel gpt

mkpart primary fat32 1 1024
name 1 boot
set 1 BOOT on

mkpart primary 1024 15360
name 2 swap

mkpart primary 15360 -1
name 3 root

print
quit

```shell 

mkfs.vfat -F32 /dev/vda1
mkswap /dev/vda2
mkfs.ext4 -L 'root' /dev/vda3

swapon /dev/vda2
mount /dev/vda3 /mnt/gentoo
```

## Gentoo Basic Install

```shell
cd /mnt/gentoo

wget https://mirror.leaseweb.com/gentoo/releases/arm64/autobuilds/current-stage3-arm64-llvm-systemd-mergedusr/stage3-arm64-llvm-systemd-mergedusr-20230827T234643Z.tar.xz

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

nano /mnt/gentoo/etc/portage/make.conf
> # put ur flags in here (you can find examples in my gentoo-settings repo)

> # I'm always masking the following, because they're evil CPU hogs:
echo "dev-qt/qtwebengine" >> /mnt/gentoo/etc/portage/package.mask/cpu-hogs
echo "net-libs/webkit-gtk" >> /mnt/gentoo/etc/portage/package.mask/cpu-hogs

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

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

mount /dev/vda1 /mnt/gentoo/boot

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

emerge --sync
emerge --oneshot sys-apps/portage

eselect profile list
eselect profile set 

echo Europe/Berlin > /etc/timezone
rm /etc/localtime
emerge --config sys-libs/timezone-data

cat /etc/locale.gen
nano /etc/locale.gen
> # uncomment your needed locales or add them
> # in my case: de_DE.UTF-8 UTF-8
locale-gen
eselect locale list
eselect locale set 7
eselect locale list
env-update && source /etc/profile && export PS1="(chroot) $PS1"

mkdir -p /etc/portage/package.use
mkdir -p /etc/portage/package.accept_keywords
mkdir -p /etc/portage/package.license
mkdir -p /etc/portage/package.unmask
```

```shell
emerge -a app-portage/cpuid2cpuflags
emerge -a app-misc/screen tmux eix
emerge -a eselect-repository

emerge -a --verbose --update --deep --with-bdeps=y --newuse --keep-going --backtrack=30 @world

emerge -a dev-vcs/git
```

## Configure /etc/fstab - add LUKS partition and boot partition
```shell
blkid
cat /etc/fstab
nano /etc/fstab
> # add your partitions according to the blkid output
```

## Install kernel bin and firmware
```shell
emerge -a sys-fs/cryptsetup
emerge -a sys-kernel/linux-firmware
emerge -a sys-kernel/gentoo-kernel-bin
```

## Install and configure GRUB
```shell
echo "sys-boot/grub device-mapper" > /etc/portage/package.use/grub
emerge -a --verbose sys-boot/grub
grub-install --target=arm64-efi --efi-directory=/boot

cp /etc/default/grub /etc/default/grub.ORIG
nano /etc/default/grub
> "GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd"
grub-mkconfig -o /boot/grub/grub.cfg
```

## set root passwd
```shell
passwd
useradd -m -G wheel,audio,video,usb,cdrom,input -s /bin/bash smeya
passwd smeya
emerge -a sudo
nano -w /etc/sudoers
```