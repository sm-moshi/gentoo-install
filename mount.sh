#!/bin/bash
set -euo pipefail

echo "Opening encrypted root..."
cryptsetup open /dev/nvme0n1p6 cryptroot

echo "Mounting Btrfs root and subvolumes..."
mount -o compress=zstd,noatime,subvol=@ /dev/mapper/cryptroot /mnt/gentoo
mkdir -p /mnt/gentoo/{home,var,boot}
mount -o compress=zstd,noatime,subvol=@home /dev/mapper/cryptroot /mnt/gentoo/home
mount -o compress=zstd,noatime,subvol=@var /dev/mapper/cryptroot /mnt/gentoo/var

echo "Mounting boot partition..."
mount /dev/nvme0n1p4 /mnt/gentoo/boot

echo "Binding system directories..."
for dir in proc sys dev run; do
    mount --rbind /$dir /mnt/gentoo/$dir
    mount --make-rslave /mnt/gentoo/$dir
done

echo "Setting up /dev/shm..."
if [ -L /mnt/gentoo/dev/shm ]; then
    rm -f /mnt/gentoo/dev/shm
    mkdir -p /mnt/gentoo/dev/shm
fi
mount -t tmpfs -o nosuid,nodev,noexec shm /mnt/gentoo/dev/shm
chmod 1777 /mnt/gentoo/dev/shm

echo "Ready to chroot!"
echo "Run: chroot /mnt/gentoo /bin/bash"
