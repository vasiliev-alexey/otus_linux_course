# Работа с LVM

## Описание/Пошаговая инструкция выполнения домашнего задания:

на имеющемся образе (centos/7 1804.2)
https://gitlab.com/otus_linux/stands-03-lvm
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /

 *   уменьшить том под / до 8G
 *   выделить том под /home
 *   выделить том под /var (/var - сделать в mirror)
 *   для /home - сделать том для снэпшотов
 *   прописать монтирование в fstab (попробовать с разными опциями и разными файловыми системами на выбор)
  
Работа со снапшотами:

 *   сгенерировать файлы в /home/
 *   снять снэпшот
 *   удалить часть файлов
 *   восстановиться со снэпшота
    (залоггировать работу можно утилитой script, скриншотами и т.п.)

На нашей куче дисков попробовать поставить btrfs/zfs:

 *   с кешем и снэпшотами
 *   разметить здесь каталог /opt

---


### Перемещаем /

```sh
sudo su
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
mkdir /mnt/newroot
mount /dev/vg_root/lv_root /mnt/newroot
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt/newroot
# Подготавливаем FS для нового chroot
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/newroot/$i; done 

# Используя chroot к новому корню обновляем конфиг загрузчика
chroot /mnt/newroot grub2-mkconfig -o /boot/grub2/grub.cfg
# Обновляем initramfs через dracut
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
# Правим конфигурацию загрузчика  - меняем загрузочный раздел
sed -i 's/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=vg_root\/lv_root/' /boot/grub2/grub.cfg
# Перезагружаемся
reboot

```

 