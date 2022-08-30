#!/bin/bash

sudo cd /etc/yum.repos.d/
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

sudo dnf upgrade -y libmodulemd # bug
sudo dnf install -y rpm-build wget rpmdevtools   lvm2
sudo yum install -y epel-release
sudo yum install -y screen  mc  bc
sudo dnf install -y nginx createrepo



mv /vagrant/utils.tar .

tar -xvf utils.tar 

echo $PWD

chown -R vagrant.vagrant development
sed -i 's/home\/student/home\/vagrant/g' /home/vagrant/development/spec/utils.spec 


rpmdev-setuptree


ln -s /home/vagrant/development/spec/utils.spec

rpmbuild --target noarch -bb utils.spec

cd /root/rpmbuild/RPMS/noarch

ls


sudo systemctl enable nginx
sudo systemctl start nginx


sudo mkdir /usr/share/nginx/html/repo



sudo cat << EOF > /etc/yum.repos.d/otus.repo
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

sudo cat << EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        include /etc/nginx/default.d/*.conf;

        location / {
            autoindex on;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }


}
EOF

sudo nginx -s reload

sudo createrepo  /usr/share/nginx/html/repo
sudo cp /root/rpmbuild/RPMS/noarch/utils-1.0.0-1.noarch.rpm  /usr/share/nginx/html/repo

sudo yum repolist enabled |  grep ^otus
sudo createrepo  /usr/share/nginx/html/repo
sudo yum list | grep ^utils.noarch

#yum makecache
#sudo curl -a http://localhost/repo/