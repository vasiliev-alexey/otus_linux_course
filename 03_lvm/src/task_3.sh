#!/bin/sh
if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

echo "Создаем vg из 2 дисков"
pvcreate /dev/sdc /dev/sdd
echo "Создаем vg из sdc и sdd"
vgcreate VolGroup01 /dev/sdc /dev/sdd
echo "Создаем зеркальный том lvm" 
lvcreate -L 950M -m 1 -n LogVol03Var /dev/VolGroup01
echo "Format "
mkfs.xfs /dev/VolGroup01/LogVol03Var
echo "Монтируем в промежуточную точку  и копируем данные"
mkdir /mnt/temp_var
mount /dev/VolGroup01/LogVol03Var/ /mnt/temp_var
cp --preserve=all -rfp /var/* /mnt/temp_var/
echo "удаляем старые данные и монтируем новый каталог"
rm -rf /var/*
umount /mnt/temp_var
mount /dev/VolGroup01/LogVol03Var /var/
echo 'UUID='`blkid /dev/VolGroup01/LogVol03Var -s UUID -o value`' /var           xfs    defaults        0 0' >> /etc/fstab
echo  "Task 3 complete"
reboot
