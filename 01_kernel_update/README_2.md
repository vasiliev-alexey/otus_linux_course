# Обновить ядро в базовой системе

## Цель:

Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.


## Описание/Пошаговая инструкция выполнения домашнего задания:  
* В материалах к занятию есть методичка, в которой описана процедура обновления ядра из репозитория.
* По данной методичке требуется выполнить необходимые действия.
* Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш git-репозиторий.
* Для проверки ДЗ необходимо прислать ссылку на него.
* Для выполнения ДЗ со * и ** вам потребуется сборка ядра и модулей из исходников.


## Критерии оценки:

✅ Основное ДЗ - в репозитории есть рабочий Vagrantfile с вашим образом.  
✅ ДЗ со звездочкой: ядро собрано из исходников.  
✅ ДЗ с **: в вашем образе нормально работают VirtualBox Shared Folders.

---

### Vagrant
1. Устанавливаем [Virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads) 
2. Устанавливаем [Vagrant](https://www.vagrantup.com/)
3. Собираем базовый образ centos
``` bash
  
```
4. Устанавливаем  его в локальный репозиторий 

``` bash
    vagrant box add --name 'avasiliev/cent_7_7' /data/lab/repo/centos-7.7.7-kernel-5-x86_64-Minimal.box
```

5. Иницируем проект

``` sh
    vagrant init
```

6.  Правим файл [Vagrantfile](Vagrantfile)

7. Поднимаем среду и подключаемся
``` bash
    vagrant up
    vagrant ssh
```
 

8. Обновляем кеш пакетов

``` sh
    sudo yum makecache
```

9. Устанавливаем треуемые зависимости

``` bash
    sudo yum install -y ncurses-devel make gcc bc openssl-devel   elfutils-libelf-devel  rpm-build flex bison yum-utils centos-release-scl;
    sudo yum -y --enablerepo=centos-sclo-rh-testing install devtoolset-7-gcc;
    echo "source /opt/rh/devtoolset-7/enable" | sudo tee -a /etc/profile;
    source /opt/rh/devtoolset-7/enable;

```

10. Загружаем  и разархивируем исходные коды ядра
``` bash
    curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.59.tar.xz --output linux-5.15.59.tar.xz && tar xvf linux-5.15.59.tar.xz 
    cd linux-5.15.59/
```


11. Копируем оригинальный конфиг системы
```
    sudo cp -v /boot/config* .config
```

12. Выполним конфигурацию

``` bash
    make menuconfig
```
 

13.  Запускаем компиляцию и сборку ядра в 8 потоков

``` bash
    make -j8 rpm-pkg
```


14.  Устанавливаем собранные пакеты

``` bash
    sudo rpm -iUv ./rpmbuild/RPMS/x86_64/*.rpm
```

15. Перегенерируем загрузочную конфигурацию

``` bash
[vagrant@otuslinux ~]$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Обновляем загрузчик
``` bash
    sudo grub2-set-default 0 
    sudo reboot
```

``` bash
➜  01_kernel_update git:(hw1) ✗ vssh       
```
Проверяем версию после перезагрузки
``` bash
[vagrant@otuslinux ~]$ uname -r
5.15.59
```

---
[Compile Linux Kernel on CentOS7](https://linuxhint.com/compile-linux-kernel-centos7/)
[how-to-upload-vagrant-box-to-vagrant-cloud](https://blog.ycshao.com/2017/09/16/how-to-upload-vagrant-box-to-vagrant-cloud/)



 ``` json
{
      "type": "shell",
      "inline": [
        "sleep 30",
        "sudo yum -y install bzip2",
        "sudo mkdir /media/VBoxGuestAdditions",
        "sudo mount -o loop,ro /home/vagrant/VBoxGuestAdditions.iso /media/VBoxGuestAdditions",
        "sudo /bin/sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run",
        "sudo umount /media/VBoxGuestAdditions",
        "sudo rmdir /media/VBoxGuestAdditions"
      ]
    }
```
 