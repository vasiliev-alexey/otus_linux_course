#!/bin/bash

sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

yum install -y yum-utils

sudo yum -y install https://zfsonlinux.org/epel/zfs-release.el8_4.noarch.rpm 
source /etc/os-release
dnf install https://zfsonlinux.org/epel/zfs-release.el${VERSION_ID/./_}.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

dnf config-manager --disable zfs
dnf config-manager --enable zfs-kmod
dnf install -y zfs wget
modprobe zfs



