#!/bin/bash

sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
sudo dnf upgrade -y libmodulemd # bug

echo '*** 1. install httpd'

sudo yum install -y httpd

sudo cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
sudo sed -i 's/EnvironmentFile=\/etc\/sysconfig\/httpd/EnvironmentFile=\/etc\/sysconfig\/httpd-config-%I/' /etc/systemd/system/httpd@.service
sudo sed -i 's/Description=The Apache HTTP Server/Description=The Apache HTTP Server (multiconfig edition by mbfx)/' /etc/systemd/system/httpd@.service


for i in 1 2; do cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-$i.conf; done 
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.backup

for i in 1 2; do  sed -i 's/"logs\/error_log"/"logs\/error_log-$i"/' /etc/httpd/conf/httpd-$i.conf && sed -i 's/"logs\/access_log"/"logs\/access_log-$i"/' /etc/httpd/conf/httpd-$i.conf && sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-$i.pid' /etc/httpd/conf/httpd-$i.conf ; done
