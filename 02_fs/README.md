# Работа с mdadm

## Описание/Пошаговая инструкция выполнения домашнего задания:


 *   добавить в Vagrantfile еще дисков;
 *   собрать R0/R5/R10 на выбор;
 *   сломать/починить raid;
 *   прописать собранный рейд в конф, чтобы рейд собирался при загрузке;
 *   создать GPT раздел и 5 партиций.
  
  ---
В качестве проверки принимаются - измененный Vagrantfile, скрипт для создания рейда, конф для автосборки рейда при загрузке.

   * ⭐ доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом и смонтированными разделами. После перезагрузки стенда разделы должны автоматически примонтироваться.
   * ⭐⭐ перенести работающую систему с одним диском на RAID 1. Даунтайм на загрузку с нового диска предполагается. В качестве проверки принимается вывод команды lsblk до и после и описание хода решения (можно воспользоваться утилитой Script).

---

1. Добавляем диски в  образ

``` ruby
    :sata5 => {
            :dfile => './sata5.vdi',
            :size => 250,  
            :port => 5
    },
    :sata6 => {
           :dfile => './sata6.vdi',
            :size => 250,  
            :port => 6
    }
```

2. Создаем RAID 1
``` bash
mdadm --zero-superblock --force /dev/sd{b,c}
```

``` bash
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
```

 Чтобы собрать программный RAID1 из двух дисков в устройстве /dev/md0, используйте команду:

``` sh
mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b,c} 
```

``` sh
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 254976K
Continue creating array? yes
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

Проверяем 

```sh
lsblk 
```
``` sh
NAME   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda      8:0    0   40G  0 disk  
`-sda1   8:1    0   40G  0 part  /
sdb      8:16   0  250M  0 disk  
`-md0    9:0    0  249M  0 raid1 
sdc      8:32   0  250M  0 disk  
`-md0    9:0    0  249M  0 raid1 
sdd      8:48   0  250M  0 disk  
sde      8:64   0  250M  0 disk  
sdf      8:80   0  250M  0 disk  
sdg      8:96   0  250M  0 disk  
```

Создаем файловую систему

``` bash
mkfs.xfs /dev/md0 -f 
```

``` sh
meta-data=/dev/md0               isize=512    agcount=4, agsize=15936 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=63744, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=855, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

Добавляем  запись в  fstab 
```sh
echo $(blkid|grep md0|awk '{print $2 " /mnt xfs defaults 0 0" }') >> /etc/fstab 
```
монтируем 
```sh
mount -a 
```

создаем директорию для хранения конфига рейд
```sh
mkdir /etc/mdadm
```
Инициализируем конфигурацию и сохраняем ее
```sh
mdadm  --detail --scan >> /etc/mdadm/mdadm.conf
```

---

[Программный RAID в Linux с помощью mdadm](https://winitpro.ru/index.php/2019/10/30/mdadm-programmnyj-raid-v-linux/)