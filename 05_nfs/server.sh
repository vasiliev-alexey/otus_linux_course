#!/bin/bash


sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

sudo dnf install -y nfs-utils


echo "Включаем  firewall"
systemctl enable firewalld --now
systemctl status firewalld

echo "Разрешаем сервисы NFS в firewall"
sudo firewall-cmd --new-zone=nfs --permanent
sudo firewall-cmd --zone=nfs --add-service=nfs --permanent
sudo firewall-cmd --zone=nfs  --permanent --add-service=rpc-bind --permanent
sudo firewall-cmd  --zone=nfs --permanent --add-service=mountd --permanent
sudo firewall-cmd --zone=nfs --add-source=192.168.56.0/24 --permanent
sudo firewall-cmd --reload


sudo systemctl enable --now nfs-server


echo "Создаем каталоги"
sudo mkdir -p /srv/nfs/upload
sudo chmod 0777 /srv/nfs/upload

echo "Прописываем экспортируемые fs"
sudo cat << EOF > /etc/exports
/srv/nfs 192.168.56.102/32(rw,sync,root_squash)
EOF

exportfs -r