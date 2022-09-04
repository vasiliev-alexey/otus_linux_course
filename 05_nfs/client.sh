#!/bin/bash


sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo "Установка пакетов"
sudo dnf install -y nfs-utils


echo "Включаем firewalld"
sudo systemctl enable firewalld --now
sudo systemctl status firewalld

echo "Добавим монтиирование"
sudo echo "192.168.56.101:/srv/nfs/ /mnt nfs nfsvers=3,noauto,x-systemd.automount,nofail,noatime,nolock,intr,actimeo=1800 0 0" >> /etc/fstab

sudo systemctl daemon-reload

sudo reboot