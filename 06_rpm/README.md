# Размещаем свой RPM в своем репозитории

Описание/Пошаговая инструкция выполнения домашнего задания:

 *   создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями);
 *   создать свой репо и разместить там свой RPM;
 *   реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.


⭐  реализовать дополнительно пакет через docker

Статус "Принято" ставится, если сделаны репо и рпм.

---

###   Cоздать свой RPM 

1. Создаем  Vagrantfile.
2. В рамках стадии provision  будет создан rpm  пакет rpm -ivh utils-1.0.0-1.noarch.rpm в директории /root/rpmbuild/RPMS/noarch
3. Проверим его работ
```sh
sudo su
cd /root/rpmbuild/RPMS/noarch
rpm -ivh utils-1.0.0-1.noarch.rpm
```
получим ряд ощибок, но они плановые  :)

```sh
[root@build-server noarch]# rpm -ivh utils-1.0.0-1.noarch.rpm
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:utils-1.0.0-1                    ################################# [100%]
/usr/local/bin/mymotd: line 135: bc: command not found
/usr/local/bin/mymotd: line 135: bc: command not found
/usr/local/bin/mymotd: line 403: pvs: command not found
```

проверим работу

```sh
/usr/local/bin/sysdata
```

получим информацию о системе, которую мы собирали.

```sh
################################################################################
#                              sysdata - System data                           #
################################################################################
Today's date is Tue Aug 30 10:58:03 UTC 2022
Data is for host build-server which is a VM running under VirtualBox.
```

##  создать свой репо и разместить там свой RPM

1. Устанаиваем nginx createrepo
2. Конфигурируем Nginx
```sh
sudo systemctl enable nginx
sudo systemctl start nginx

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

```

3. Создаем директорию для размещения пакетов в каталоге nginx
```sh
sudo mkdir /usr/share/nginx/html/repo
```

4. Инициироуем репозиторий и копируем туда наш пакет
```sh
sudo createrepo  /usr/share/nginx/html/repo
sudo cp /root/rpmbuild/RPMS/noarch/utils-1.0.0-1.noarch.rpm  /usr/share/nginx/html/repo
```

5. Для проверки создает ссылку  на созданный Repo
```sh
sudo cat << EOF > /etc/yum.repos.d/otus.repo
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

```
проверим что создалось

```sh
sudo yum repolist enabled |  grep ^otus
sudo yum list | grep ^utils.noarch
```

``` sh
[root@build-server noarch]# sudo yum repolist enabled |  grep ^otus
Failed to set locale, defaulting to C.UTF-8
otus               otus-linux
```

```sh
[root@build-server noarch]# sudo yum list | grep ^utils.noarch
Failed to set locale, defaulting to C.UTF-8
utils.noarch    
```

6. Устновим для теста

```sh
[root@build-server noarch]# yum  install utils
Failed to set locale, defaulting to C.UTF-8
Last metadata expiration check: 0:17:06 ago on Tue Aug 30 17:16:18 2022.
Dependencies resolved.
=================================================================================================================================================================================
 Package                                   Architecture                               Version                                     Repository                                Size
=================================================================================================================================================================================
Installing:
 utils                                     noarch                                     1.0.0-1                                     otus                                      24 k

Transaction Summary
=================================================================================================================================================================================
Install  1 Package

Total download size: 24 k
Installed size: 70 k
Is this ok [y/N]: y
Downloading Packages:
utils-1.0.0-1.noarch.rpm                                                                                                                          20 MB/s |  24 kB     00:00    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                            2.3 MB/s |  24 kB     00:00     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                         1/1 
  Running scriptlet: utils-1.0.0-1.noarch                                                                                                                                    1/1 
  Installing       : utils-1.0.0-1.noarch                                                                                                                                    1/1 
  Running scriptlet: utils-1.0.0-1.noarch                                                                                                                                    1/1 
  Verifying        : utils-1.0.0-1.noarch                                                                                                                                    1/1 

Installed:
  utils-1.0.0-1.noarch                                                                                                                                                           

Complete!
```

---
[How to build rpm packages](https://opensource.com/article/18/9/how-build-rpm-packages)  
[Create an Nginx-based YUM/DNF repository on Red Hat Enterprise Linux 8](https://www.redhat.com/sysadmin/nginx-based-yum-dnf-repo)