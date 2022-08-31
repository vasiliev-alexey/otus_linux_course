#!/bin/sh
echo "Создаем lv для  home"
lvcreate -L 1G -n LogVol02Home /dev/VolGroup00
echo "Форматируем новый  home"
mkfs.xfs /dev/VolGroup00/LogVol02Home
echo "Монтируем home во временный каталог обмена"
mkdir /mnt/temphome
mount /dev/VolGroup00/LogVol02Home /mnt/temphome
cp --preserve=all -rfp /home/* /mnt/temphome/
echo "Удаляем старый каталог и монтируем в новый"
rm -rf /home/*
umount /mnt/temphome
mount /dev/VolGroup00/LogVol02Home /home/
echo 'UUID='`blkid /dev/VolGroup00/LogVol02Home -s UUID -o value`' /home           xfs    defaults        0 0' >> /etc/fstab
echo  "Task 2 complete"
reboot
