# Vagrant стенд для NFS

### NFS:

 *   vagrant up должен поднимать 2 виртуалки: сервер и клиент;
 *   на сервер должна быть расшарена директория;
 *   на клиента она должна автоматически монтироваться при старте (fstab или autofs);
 *   в шаре должна быть папка upload с правами на запись;
 *   требования для NFS: NFSv3 по UDP, включенный firewall.

 *   Настроить аутентификацию через KERBEROS (NFSv4)


### решение:
1. Создаем [Vagrantfile](Vagrantfile)
2. Создаем [скрипт](server.sh) по установки для сервера NFS + монтирование директории
3. Создаем [скрипт](client.sh) по устнаовки для клиента NFS + монтирование директории


###  как проверить

```sh
vagrant up
```

---
* [How to Install and Configure an NFS Server on CentOS 8](https://linuxize.com/post/how-to-install-and-configure-an-nfs-server-on-centos-8/)  
* [Как настроить NFS-сервер и клиент на CentOS 8](https://blog.sedicomm.com/2020/04/11/kak-nastroit-nfs-server-i-klient-na-centos-8/)