#!/bin/bash

if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root"
exit 1
fi

# List drives to select
lsblk -o NAME,UUID,FSTYPE,SIZE,MOUNTPOINT | grep -E 'sd|nvme'

read -p "Enter device name (e.g., sdb1): " dev_name
read -p "Enter name of mount point (e.g., 1tb_HardDrive): " mnt_name

drive_uuid=$(blkid -s UUID -o value /dev/"$dev_name")

if [ -z "$drive_uuid" ]; then
echo "Error: Could not find UUID for /dev/$dev_name"
exit 1
fi

mount_point="/media/$mnt_name"
mkdir -p "$mount_point"

mount UUID="$drive_uuid" "$mount_point"

drive_type=$(blkid -s TYPE -o value /dev/"$dev_name")
echo "UUID=$drive_uuid $mount_point $drive_type defaults,nofail 0 2" >> /etc/fstab

echo "Mounted $dev_name at $mount_point and updated fstab."

chmod 777 /media/"$mnt_name"
echo "Gave read and write access to /media/$mnt_name"
