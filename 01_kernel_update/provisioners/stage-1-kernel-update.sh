#!/bin/bash

# Install elrepo
yum makecache
yum install -y ncurses-devel make gcc bc openssl-devel
yum install -y elfutils-libelf-devel
yum install -y rpm-build flex bison yum-utils centos-release-scl;
yum -y --enablerepo=centos-sclo-rh-testing install devtoolset-7-gcc;
echo "source /opt/rh/devtoolset-7/enable" | sudo tee -a /etc/profile;
source /opt/rh/devtoolset-7/enable;

# Reboot VM
shutdown -r now
