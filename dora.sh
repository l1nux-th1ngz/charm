#!/bin/bash

# Assuming nvme0n1 is the NVMe drive and sda is the 1TB drive

# Run Fedora installer in text mode
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled rpmfusion-free rpmfusion-nonfree
sudo dnf install -y anaconda

# Start the installer in text mode
sudo anaconda

# Partitioning scheme for NVMe drive (nvme0n1)
echo "Clearing existing partitions on nvme0n1..."
sudo wipefs --all --force /dev/nvme0n1

echo "Creating /boot/efi and / partitions on nvme0n1..."
sudo parted /dev/nvme0n1 mklabel gpt
sudo parted /dev/nvme0n1 mkpart primary 512MiB 2GiB
sudo parted /dev/nvme0n1 mkpart primary 2GiB 100%
sudo mkfs.fat -F32 /dev/nvme0n1p1
sudo mkfs.ext4 /dev/nvme0n1p2
sudo mount /dev/nvme0n1p2 /mnt
sudo mkdir /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot

# Partitioning scheme for 1TB drive (sda)
echo "Clearing existing partitions on sda..."
sudo wipefs --all --force /dev/sda

echo "Creating swap and /home partitions on sda..."
sudo parted /dev/sda mklabel gpt
sudo parted /dev/sda mkpart primary linux-swap 1MiB 13GiB
sudo parted /dev/sda mkpart primary ext4 13GiB 100%
sudo mkswap /dev/sda1
sudo swapon /dev/sda1
sudo mkfs.ext4 /dev/sda2
sudo mkdir /mnt/home
sudo mount /dev/sda2 /mnt/home

# Install Fedora
sudo dnf install -y --installroot=/mnt fedora-release
sudo dnf install -y --installroot=/mnt @base
sudo dnf install -y --installroot=/mnt kernel

# Generate fstab
sudo genfstab -U -p /mnt >> /mnt/etc/fstab

# Chroot into the installed system
sudo chroot /mnt /bin/bash

# Set root password
passwd

# Install bootloader (assuming UEFI)
grub2-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=fedora

# Generate GRUB configuration
grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

# Exit from chroot
exit

# Unmount all partitions
sudo umount -R /mnt

echo "Installation complete!"
