# Commands to install basic Gentoo (04/05/2021)

## Creating the partitions

```shell
mkdir /mnt/gentoo

parted /dev/nvme0n1 or /dev/sda1
> mklabel gpt
> mkpart primary fat32 1MiB 3Mib
> mkpart primary fat32 3Mib 803MiB
> mkpart primary 803MiB -1
> name 1 grub
> name 2 boot
> name 3 luks
> set 1 bios_grub on
> set 2 boot on
> print
> quit

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
```

## Gentoo Basic Install
```shell
cd /mnt/gentoo
wget https://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/current-stage3-amd64-systemd/stage3-amd64-systemd-20210502T214503Z.tar.xz
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

nano /mnt/gentoo/etc/portage/make.conf
> # put ur flags in here (you can find examples in my gentoo-settings repo)
nano /mnt/gentoo/etc/portage/package.mask
> # I'm always masking the following, because they're evil CPU hogs:
> # dev-qt/qtwebengine
> # net-libs/webkit-gtk

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

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

mount /dev/nvme0n1ps2 /boot (or /dev/sda2)

emerge --sync
emerge --oneshot sys-apps/portage

eselect profile list
eselect profile set 24

echo Europe/Berlin > /etc/timezone/data
emerge --config sys-libs/timezone-data

cat locale.gen
nano /etc/locale.gen
> de_DE.UTF_8 UTF-8 # add your locales in my case the german ones
locale-gen
eselect locale list
eselect locale set 3
eselect locale list
env-update && source /etc/profile && export PS1="(chroot) $PS1"

mkdir -p /etc/portage/package.use
touch /etc/portage/package.accept_keywords
touch /etc/portage/package.license
touch /etc/portage/package.unmask

emerge --ask --verbose --update --deep --with-bdeps=y --newuse --keep-going --backtrack=30 @world

emerge --ask app-editors/nano
```

## Configure /etc/fstab - add LUKS partition and boot partition
```shell
blkid
cat /etc/fstab
nano /etc/fstab
> # add your partitions according to the blkid output
```
### Put some stuff in tmpfs for less SSD cycles and faster compile times
```shell
nano /etc/fstab
> my example:
> tmpfs     /tmp                  tmpfs     defaults,size=1G                                                  0 0
> tmpfs     /run                  tmpfs     size=100M                                                         0 0
> tmpfs     /var/tmp/portage      tmpfs     size=4G,uid=portage,gid=portage,mode=775,nosuid,noatime,nodev     0 0
```
Read the following link in the Gentoo Wiki for how to set this up:
https://wiki.gentoo.org/wiki/Portage_TMPDIR_on_tmpfs

## Install kernel sources and firmware
```shell
emerge --ask --verbose sys-kernel/gentoo-sources
emerge --ask --verbose sys-kernel/genkernel
emerge --ask --verbose sys-fs/cryptsetup
emerge --ask --verbose sys-kernel/linux-firmware
```

## If you need it, install intel microcode
```shell
echo "sys-firmware/intel-microcde initramfs > etc/portage/package.use/intel-microcode"
emerge --ask --verbose sys-firmware/intel-microcode
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
