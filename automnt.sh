#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# List drives to select
lsblk -o NAME,UUID,FSTYPE,SIZE,MOUNTPOINT | grep -E 'sd|nvme'

read -p "Enter device name (e.g., sdb1): " dev_name
read -p "Enter desired mount point name: " mnt_name

drive_uuid=$(blkid -s UUID -o value /dev/"$dev_name")

if [ -z "$drive_uuid" ]; then
    echo "Error: Could not find UUID for /dev/$dev_name"
    exit 1
fi

mount_point="/media/$mnt_name"
mkdir -p "$mount_point"

mount UUID="$drive_uuid" "$mount_point"

echo "UUID=$drive_uuid $mount_point ext4 defaults 0 2" >> /etc/fstab

echo "Mounted $dev_name at $mount_point and updated fstab."
