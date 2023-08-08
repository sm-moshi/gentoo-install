# Commands to install basic Gentoo with systemd, Luks and LVM in QEMU (UTM) on Apple M2 Pro (2023/07/25)

https://gist.github.com/setkeh/42b1d6a86bf31001b797e991ae7296d8
https://wiki.gentoo.org/wiki/QEMU/Linux_guest#Kernel
https://blog.devgenius.io/installing-gentoo-linux-in-apple-macbook-pro-m1-49e163534898
https://wiki.gentoo.org/wiki/User:Jared/Gentoo_On_An_M1_Mac
https://wiki.gentoo.org/wiki/Apple_Silicon_VMware_Guide#Preparing_the_Disks
https://wiki.gentoo.org/wiki/Talk:QEMU/Linux_guest#Display

##

VM settings in QEMU:

- Architecture: ARM64 (aarch64)
- Machine: QEMU 8.0 ARM Virtual Machine (alias of virt-8.0) (virt)
- CPU Cores: 10
- RAM: 12 GB
- ...

## Creating the partitions

```shell

parted -a optimal /dev/sdX

unit mib
mklabel gpt

mkpart primary 1 3
name 1 grub
set 1 bios_grub on

mkpart primary fat32 3 515
name 2 boot
set 2 BOOT on

mkpart primary 515 -1
name 3 lvm
set 3 lvm on

print
quit
```

```shell 

mkfs.vfat -F32 /dev/vda1

cryptsetup luksFormat -c aes-xts-plain64 -s 512 /dev/nvme0n1p3

cryptsetup luksOpen /dev/nvme0n1p3 lvm

pvcreate /dev/mapper/lvm
vgcreate gentoo-vg /dev/mapper/lvm
lvcreate -L 12G -n swap gentoo-vg
lvcreate -l 100% root gentoo-vg

mkfs.ext4 /dev/mapper/gentoo--vg-root

mkswap /dev/mapper/gentoo--vg-swap
swapon /dev/mapper/gentoo--vg-swap

mount /dev/mapper/gentoo--vg-root /mnt/gentoo
```

## Gentoo Basic Install

```shell
cd /mnt/gentoo

wget https://mirror.leaseweb.com/gentoo/releases/arm64/autobuilds/current-stage3-arm64-desktop-systemd-mergedusr/stage3-arm64-desktop-systemd-mergedusr-20230723T233352Z.tar.xz

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

mount /dev/mapper/gentoo--vg-home /mnt/gentoo/home
mount /dev/nvme0n1p2 /mnt/gentoo/boot

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

emerge --sync
emerge --oneshot sys-apps/portage

eselect profile list
eselect profile set 10

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
# mount Portage TMPDIR on tmpfs
echo "tmpfs /var/tmp/portage tmpfs size=8G,uid=portage,gid=portage,mode=775 0 0" >> /etc/fstab
mount /var/tmp/portage
# create per-package choices for tmpfs
mkdir /etc/portage/env
echo "PORTAGE_TMPDIR=/var/tmp/notmpfs" >> /etc/portage/env/notmpfs.conf

mkdir /var/tmp/notmpfs
chown portage:portage /var/tmp/notmpfs
chmod 775 /var/tmp/portage

# create a package.env containing a list of packages that are too big for a tmpfs /var/tmp/portage
echo "app-office/libreoffice notmpfs.conf" >> /etc/portage/package.env
echo "dev-lang/ghc notmpfs.conf" >> /etc/portage/package.env
echo "dev-lang/mono notmpfs.conf" >> /etc/portage/package.env
echo "dev-lang/rust notmpfs.conf" >> /etc/portage/package.env
echo "dev-lang/spidermonkey notmpfs.conf" >> /etc/portage/package.env
echo "mail-client/thunderbird notmpfs.conf" >> /etc/portage/package.env
echo "sys-devel/clang notmpfs.conf" >> /etc/portage/package.env
echo "sys-devel/gcc notmpfs.conf" >> /etc/portage/package.env
echo "sys-devel/llvm notmpfs.conf" >> /etc/portage/package.env
echo "www-client/chromium notmpfs.conf" >> /etc/portage/package.env
echo "www-client/firefox notmpfs.conf" >> /etc/portage/package.env
```

```shell
emerge --ask app-portage/cpuid2cpuflags
emerge --ask app-misc/screen tmux eix

emerge --ask --verbose --update --deep --with-bdeps=y --newuse --keep-going --backtrack=30 @world

emerge --ask dev-vcs/git
```

## Configure /etc/fstab - add LUKS partition and boot partition
```shell
blkid
cat /etc/fstab
nano /etc/fstab
> # add your partitions according to the blkid output
```

## Install kernel sources and firmware
```shell
emerge --ask --verbose sys-kernel/gentoo-sources
emerge --ask --verbose sys-kernel/genkernel
emerge --ask --verbose sys-fs/cryptsetup
emerge --ask --verbose sys-kernel/linux-firmware
```

## Configure genkernel.conf
```shell
cp -p /etc/genkernel.conf /etc/genkernel.conf.ORIG
nano /etc/genkernel.conf

> # add some stuff for LUKS and LVM
...
MAKEOPTS="$(portageq envvar MAKEOPTS)"
...
LVM="yes"
...
LUKS="yes"
...
```
## Compile your kernel
```shell
genkernel all
> # configure it according to your needs (depends on hardware)
> # for example remove everything related to AMD if you're using intel -
> # except when using an AMD GPU then it get's tricky,
> # but I'm not going to explain kernel setings here.
```

## Install and configure GRUB
```shell
echo "sys-boot/grub device-mapper" > /etc/portage/package.use/grub
emerge --ask --verbose sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/boot

blkid  | grep crypto_LUKS
> # copy UUID, add it to /etc/default/grub, add systemd

cp /etc/default/grub /etc/default/grub.ORIG
nano /etc/default/grub
> GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd dolvm crypt_root=UUID=blablabla root=/dev/mapper/gentoo-vg-root"
grub-mkconfig -o /boot/grub/grub.cfg
```

## set root passwd
```shell
passwd
```
 