#!/bin/bash

# Set up variables
DISTRO_NAME="Coonix"
DISTRO_VERSION="1.0"
ARCH="amd64"
TARGET_DIR="$HOME/${DISTRO_NAME}_${DISTRO_VERSION}_${ARCH}"
DEBIAN_MIRROR="http://deb.debian.org/debian"

# Create target directory
mkdir -p $TARGET_DIR

# Bootstrap the base system
sudo debootstrap --arch=$ARCH stable $TARGET_DIR $DEBIAN_MIRROR

# Chroot into the new system
sudo chroot $TARGET_DIR /bin/bash <<EOF
# Set up basic configurations
echo "Coonix" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "deb $DEBIAN_MIRROR stable main" > /etc/apt/sources.list

# Install additional packages
apt-get update
apt-get install -y linux-image-amd64 grub-pc sudo

# Set up the bootloader
grub-install /dev/sda
update-grub

# Create a user
useradd -m -s /bin/bash coonixuser
echo "coonixuser:password" | chpasswd
echo "coonixuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Clean up
apt-get clean
EOF

# Unmount and exit chroot
sudo umount $TARGET_DIR/proc
sudo umount $TARGET_DIR/sys
sudo umount $TARGET_DIR/dev/pts

echo "Coonix Linux distribution created successfully!"
