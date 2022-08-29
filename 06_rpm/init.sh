#!/bin/bash

sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


sudo dnf install -y rpm-build wget rpmdevtools  
sudo yum install -y epel-release
sudo yum install -y screen  mc

wget https://github.com/opensourceway/how-to-rpm/raw/master/utils.tar

tar -xvf utils.tar 

echo $PWD

chown -R vagrant.vagrant development
sed -i 's/home\/student/home\/vagrant/g' /home/vagrant/development/spec/utils.spec 


rpmdev-setuptree

cd /home/vagrant/rpmbuild/SPECS/
ln -s /home/vagrant/development/spec/utils.spec

rpmbuild --target noarch -bb utils.spec

cd /home/vagrant/rpmbuild/RPMS/noarch

ls