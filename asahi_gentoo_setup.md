# Asahi Gentoo Install Guide (Updated for 2025)

> **Target**: Apple Silicon (M1/M2/M3) with m1n1 and U-Boot (via the Asahi macOS script), using LUKS + Btrfs root.
> Based on Immolo's Sandbox [PearSilicon](https://wiki.gentoo.org/wiki/User:Immolo/Sandbox/PearSilicon), with kernel support handled by [chadmed/asahi-gentoosupport](https://github.com/chadmed/asahi-gentoosupport/blob/main/install.sh).

---

## 🧊 Prerequisites

- You used the Asahi macOS shell script to install m1n1 and boot into the **Gentoo LiveCD** (Chadmed ISO)
- You resized macOS to leave 25% disk space free for Gentoo
- Internet access via Wi-Fi or Ethernet is working

---

## 🧱 Partitioning (internal disk)

```bash
# Check your disk
lsblk -f

# Enter partitioning tool
gdisk /dev/nvme0n1

# Create new partition (assuming p6 is free)
n  # Accept defaults
t  # Change type
8300
w  # Write and exit

partprobe /dev/nvme0n1
```

---

## 🔐 LUKS + Btrfs Root Setup

```bash
cryptsetup luksFormat /dev/nvme0n1p6
cryptsetup open /dev/nvme0n1p6 cryptroot

mkfs.btrfs /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt/gentoo

btrfs subvolume create /mnt/gentoo/@
btrfs subvolume create /mnt/gentoo/@home
btrfs subvolume create /mnt/gentoo/@var
umount /mnt/gentoo

# Mount root and subvolumes
mount -o compress=zstd,noatime,subvol=@ /dev/mapper/cryptroot /mnt/gentoo
mkdir -p /mnt/gentoo/{home,var,boot}
mount -o compress=zstd,noatime,subvol=@home /dev/mapper/cryptroot /mnt/gentoo/home
mount -o compress=zstd,noatime,subvol=@var /dev/mapper/cryptroot /mnt/gentoo/var

# Mount Asahi boot partition
mount /dev/nvme0n1p4 /mnt/gentoo/boot
```

---

## 🧰 Mount system directories for chroot

```bash
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --rbind /run /mnt/gentoo/run
mount --make-rslave /mnt/gentoo/run

# Prepare shm
if [ -L /mnt/gentoo/dev/shm ]; then
  rm /mnt/gentoo/dev/shm
  mkdir /mnt/gentoo/dev/shm
fi
mount -t tmpfs -o nosuid,nodev,noexec shm /mnt/gentoo/dev/shm
chmod 1777 /mnt/gentoo/dev/shm
```

---

## 🧾 Generate /etc/fstab with genfstab

```bash
genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab
nano /mnt/gentoo/etc/fstab
# Clean up and ensure:
# - subvol=@, @home, @var are specified
# - discard=async, compress=zstd, noatime are added
# - /boot is vfat with defaults or noauto
```

---

## ⛓ Enter Chroot

```bash
chroot /mnt/gentoo /bin/bash
source /etc/profile
env-update
export PS1="(chroot) $PS1"
```

---

## 🧊 Download Stage3

Instead of manually downloading, use the helper script from Jared Allard:

```bash
cd /mnt/gentoo
curl -L https://raw.githubusercontent.com/jaredallard/gentoo-m1-mac/main/fetch-stage-3.sh | bash
```

This fetches and extracts the latest stage3 tarball with verification.

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

---

## 🧩 Set Profile, Locale, Timezone

```bash
eselect profile list
eselect profile set <Asahi or arm64 LLVM OpenRC profile>

echo "Europe/Berlin" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set de_DE.utf8
env-update && source /etc/profile
```

---

## 🧪 Update and Essential Tools

```bash
emerge --sync
emerge --oneshot sys-apps/portage

# Switch Portage sync to git
emerge -a dev-vcs/git
eselect repository enable gentoo
emaint sync -r gentoo

emerge -a app-portage/cpuid2cpuflags
emerge -a app-misc/screen tmux eix
emerge -a eselect-repository
```

---

## 📂 Fstab Example (after cleanup)

```bash /etc/fstab
/dev/mapper/cryptroot  /      btrfs  noatime,compress=zstd,subvol=@      0 0
/dev/mapper/cryptroot  /home  btrfs  noatime,compress=zstd,subvol=@home  0 0
/dev/mapper/cryptroot  /var   btrfs  noatime,compress=zstd,subvol=@var   0 0
/dev/nvme0n1p4          /boot  vfat   noauto,noatime,defaults             0 2
```

---

## 🐧 Kernel and Bootloader Setup

Instead of installing kernel components manually, run Chadmed's support script:

```bash
emerge -a dev-vcs/git
cd /root
git clone https://github.com/chadmed/asahi-gentoosupport
cd asahi-gentoosupport
chmod +x install.sh
./install.sh
```

This sets up:

- `sys-kernel/asahi-kernel`
- `sys-boot/m1n1`, `uboot`, and `asahi-bless`
- Automatic bootloader configuration for m1n1 and U-Boot

---

## 👤 Create User

```bash
passwd
useradd -m -G wheel,input,audio,video -s /bin/bash smoshi
passwd smoshi
emerge -a sudo
EDITOR=nano visudo
```
