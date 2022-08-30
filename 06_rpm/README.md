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

---
[How to build rpm packages](https://opensource.com/article/18/9/how-build-rpm-packages)  
[Create an Nginx-based YUM/DNF repository on Red Hat Enterprise Linux 8](https://www.redhat.com/sysadmin/nginx-based-yum-dnf-repo)