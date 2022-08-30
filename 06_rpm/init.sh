#!/bin/bash

sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


sudo dnf install -y rpm-build wget rpmdevtools  
sudo yum install -y epel-release
sudo yum install -y screen  mc 
sudo dnf install -y nginx createrepo

sudo dnf upgrade libmodulemd # bug




wget https://github.com/opensourceway/how-to-rpm/raw/master/utils.tar

tar -xvf utils.tar 

echo $PWD

chown -R vagrant.vagrant development
sed -i 's/home\/student/home\/vagrant/g' /home/vagrant/development/spec/utils.spec 


rpmdev-setuptree

cd /home/vagrant/rpmbuild/SPECS/
ln -s /home/vagrant/development/spec/utils.spec

rpmbuild --target noarch -bb utils.spec

cd /root/rpmbuild/RPMS/noarch

ls


sudo systemctl enable nginx
sudo systemctl start nginx


sudo mkdir /usr/share/nginx/html/repo
sudo rpmdevtools  /usr/share/nginx/html/repo
sudo cp /root/rpmbuild/RPMS/noarch/utils-1.0.0-1.noarch.rpm  /usr/share/nginx/html/repo


sudo echo  >> /etc/yum.repos.d/otus.repo

sudo cat << EOF > /etc/yum.repos.d/otus.repo
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

sudo yum repolist enabled |  grep ^otus

sudo yum list | grep ^utils.noarch

