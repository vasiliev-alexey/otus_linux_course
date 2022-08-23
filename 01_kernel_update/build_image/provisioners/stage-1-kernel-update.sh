#!/bin/bash

# Install elrepo
yum makecache
yum install -y ncurses-devel make gcc bc openssl-devel  elfutils-libelf-devel  rpm-build flex bison yum-utils centos-release-scl rsync;
yum -y --enablerepo=centos-sclo-rh-testing install devtoolset-7-gcc;
echo "source /opt/rh/devtoolset-7/enable" | sudo tee -a /etc/profile;
source /opt/rh/devtoolset-7/enable;

curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.59.tar.xz --output linux-5.15.59.tar.xz && tar xvf linux-5.15.59.tar.xz 
cd linux-5.15.59/

# Reboot VM
shutdown -r now
