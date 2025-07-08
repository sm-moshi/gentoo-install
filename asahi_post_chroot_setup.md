# 🚀 Gentoo Asahi Setup (Post-Chroot to KDE Plasma)

> Continuing from `/mnt/gentoo` being fully mounted, `chroot` entered, and stage3 + fstab configured. Based on [Immolo's PearSilicon guide](https://wiki.gentoo.org/wiki/User:Immolo/Sandbox/PearSilicon) and [chadmed/asahi-gentoosupport](https://github.com/chadmed/asahi-gentoosupport).

---

## 📦 Set Hostname, Add DNS

```bash
echo "gentoo-asahi" > /etc/hostname
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

---

## ⚙️ Configure make.conf (if not done)

Ensure:

```bash
COMMON_FLAGS="-march=armv8.6-a+fp16+simd+crypto+i8mm -mtune=native -O2 -pipe -flto"
USE="pulseaudio pipewire qt6 -qt5 wayland gles2 screencast networkmanager audio lto"
VIDEO_CARDS="asahi"
MAKEOPTS="-j8"
EMERGE_DEFAULT_OPTS="--jobs 3"
GENTOO_MIRRORS="https://gentoo.rgst.io/gentoo"
BINHOST="https://gentoo.rgst.io/packages"
FEATURES="ebuild-locks split-log parallel-fetch parallel-install"
```

---

## 🧩 Set Profile, Locale, Timezone

```bash
eselect profile list
eselect profile set default/linux/arm64/23.0/desktop/plasma/systemd

echo "Europe/Berlin" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set de_DE.utf8
env-update && source /etc/profile
```

---

## 🔧 Sync Portage & Install Base Tools

```bash
emerge --sync
emerge --oneshot sys-apps/portage
git clone https://github.com/chadmed/asahi-overlay /var/db/repos/asahi-overlay
emerge --sync asahi-overlay

emerge -a app-portage/cpuid2cpuflags
cpuid2cpuflags
# Add output to make.conf: CPU_FLAGS_ARM="..."
```

---

## 🧠 Kernel & Bootloader via chadmed/asahi-gentoosupport

```bash
cd /root
git clone https://github.com/chadmed/asahi-gentoosupport
cd asahi-gentoosupport
chmod +x install.sh
./install.sh
```

This installs:

- Kernel with patches for Apple Silicon
- m1n1, U-Boot, asahi-bless
- Configures `/boot/efi` + boot entries

---

## 🔐 LUKS Unlock in Initramfs

Edit GRUB/Dracut for LUKS if needed:

```bash
echo 'GRUB_CMDLINE_LINUX="crypt_root=UUID=<UUID> root=/dev/mapper/cryptroot"' >> /etc/default/grub
```

Find UUID:

```bash
blkid | grep luks
```

Then rebuild config/initramfs if not automated:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
dracut --force
```

---

## 🧑 Create User

```bash
passwd
useradd -m -G wheel,audio,video,network,input -s /bin/bash smoshi
passwd smoshi
emerge -a sudo
EDITOR=nano visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

---

## 🎛️ Enable Services

```bash
systemctl enable NetworkManager
systemctl enable sddm
```

---

## 🖼️ Plasma Desktop

```bash
emerge -a kde-plasma/plasma-meta konsole dolphin firefox
```

---

## 🔚 Final Steps Before Reboot

```bash
exit
umount -R /mnt/gentoo
reboot
```

On boot, enter LUKS passphrase, and KDE Plasma should start via SDDM. 🎉
