#!/bin/sh
# Удаляем старый lv из vg и создаем новый размером 8Гб
lvremove -y /dev/VolGroup00/LogVol00
lvcreate -y -L 8G -n LogVol00 /dev/VolGroup00
# Форматируем созданное устройство
mkfs.xfs /dev/VolGroup00/LogVol00
# Монтируем новое устройство и переносим туда нашу ФС
mkdir /mnt/newroot
mount /dev/VolGroup00/LogVol00 /mnt/newroot
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt/newroot
# Подготавливаем ФСы для будущего chroot
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/newroot/$i; done 
# Используя chroot к будущему корню обновляем конфигурацию загрузчика
chroot /mnt/newroot grub2-mkconfig -o /boot/grub2/grub.cfg
# Обновляем initramfs через dracut. Добавлять ничего не надо.
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
# reboot
reboot
