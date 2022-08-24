#!/bin/sh
# Устанавливаем xfsdump
yum install xfsdump -y
# Создаем на sdb logival volume на весь его размер
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -l +80%FREE -n lv_root /dev/vg_root
# Форматируем созданное устройство
mkfs.xfs /dev/vg_root/lv_root
# Монтируем новое устройство и переносим туда нашу ФС
mkdir /mnt/temproot
mount /dev/vg_root/lv_root /mnt/temproot
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt/temproot
# Подготавливаем FS для нового chroot
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/temproot/$i; done 

# Используя chroot к новому корню обновляем конфиг загрузчика
chroot /mnt/temproot grub2-mkconfig -o /boot/grub2/grub.cfg
# Обновляем initramfs через dracut
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
# Правим конфигурацию загрузчика  - меняем загрузочный раздел
sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/' /boot/grub2/grub.cfg
# Перезагружаемся
reboot

