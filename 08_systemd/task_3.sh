#!/bin/bash

sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
sudo dnf upgrade -y libmodulemd # bug

echo '*** 1. install httpd'

sudo yum install -y httpd
sudo setenforce Permissive

sudo cat << EOF > /etc/sysconfig/httpd-1
OPTIONS=-f conf/httpd-1.conf
EOF

sudo cat << EOF > /etc/sysconfig/httpd-2
OPTIONS=-f conf/httpd-2.conf
EOF

sudo cat << EOF > /etc/systemd/system/httpd@.service
[Unit]
Description=Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd \$OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd \$OPTIONS -k graceful
ExecStop=/bin/kill -WINCH {\$MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF



for i in 1 2; do cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-$i.conf && sed -i "s/logs\/error_log/logs\/error_log-$i/" /etc/httpd/conf/httpd-$i.conf  && sed -i "/ServerRoot \"\/etc\/httpd\"/a PidFile \/var\/run\/httpd-$i.pid" /etc/httpd/conf/httpd-$i.conf  && sed -i "s/Listen 80/Listen 808$i/g" /etc/httpd/conf/httpd-$i.conf ; done

sudo systemctl daemon-reload && systemctl start httpd@1 && systemctl start httpd@2


sudo ss -tulpen | grep httpd
