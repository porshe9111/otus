#!/bin/bash

#скрипт создания RAID 6

set -e

DISKS=("/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde" "/dev/sdf")
RAID_DEVICE="/dev/md0"

# Проверка root
[ "$EUID" -ne 0 ] && echo "Запустите с sudo!" && exit 1

# Создание RAID
echo "Создание RAID 6 массива..."
mdadm --create --verbose "$RAID_DEVICE" --level=6 --raid-devices=5 "${DISKS[@]}"

# Файловая система
mkfs.ext4 "$RAID_DEVICE"

# Информация
echo "Создан RAID 6 массив:"
mdadm --detail "$RAID_DEVICE"

