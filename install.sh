#!/bin/sh

lsblk

parted /dev/sda print

parted /dev/sda mklabel gpt

parted /dev/sda mkpart ESP fat32 1MiB 513MiB
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary ext4 513MiB 100%

parted /dev/sda mklabel gpt

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt

mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot



mv /etc/pacman.d/mirrorlist{,.bak}
grep "163" /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt /bin/bash

mv /etc/locale.gen{,.bak}
echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen
echo "LANG=zh_CN.UTF-8" > /etc/locale.conf


ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

hwclock --systohc --utc

mkinitcpio -p linux

bootctl install

cat <<EOF > /boot/loader/entries/arch.conf
title          Arch Linux
linux          /vmlinuz-linux
initrd         /initramfs-linux.img
options        root=/dev/sda2 rw
EOF

cat <<EOF > /boot/loader/loader.conf
timeout 3
default arch
EOF

systemctl enable dhcpcd@enp0s3.service

systemctl enable dhcpcd@enp0s8.service

pacman -S openssh vim git --noconfirm

systemctl enable sshd

echo "root:toor" | chpasswd

useradd -m -s /bin/bash macbinn
echo "macbinn:nnibcam" | chpasswd
