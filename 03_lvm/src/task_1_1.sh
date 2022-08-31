#!/bin/sh

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi


echo  "Устанавливаем xfsdump"
yum install xfsdump -y
echo   "Создаем на sdb logival volume на весь его размер"
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -l +80%FREE -n lv_root /dev/vg_root
echo "Форматируем созданное устройство"
mkfs.xfs /dev/vg_root/lv_root
echo "Монтируем новое устройство и переносим туда нашу ФС"
mkdir /mnt/temproot
mount /dev/vg_root/lv_root /mnt/temproot
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt/temproot
echo "Подготавливаем FS для нового chroot"
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/temproot/$i; done 

echo "Используя chroot к новому корню обновляем конфиг загрузчика"
chroot /mnt/temproot grub2-mkconfig -o /boot/grub2/grub.cfg
echo "Обновляем initramfs через dracut"
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
echo "Правим конфигурацию загрузчика  - меняем загрузочный раздел"
sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/' /boot/grub2/grub.cfg
echo "Перезагружаемся - продолжение после перезагрузки 1_2 "
reboot

