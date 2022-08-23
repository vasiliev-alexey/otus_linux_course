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

### Добавляем диски в Vagrantfile

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

### Создаем RAID 1
* Выделяем 2 диска для создания RAID
``` bash
mdadm --zero-superblock --force /dev/sd{b,c}
```

``` bash
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
```

 * Чтобы собрать программный RAID1 из двух дисков в устройстве /dev/md0, используем команду:

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

* Проверяем 

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

* Создаем файловую систему

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

* Добавляем  запись в  fstab 
```sh
echo $(blkid|grep md0|awk '{print $2 " /mnt xfs defaults 0 0" }') >> /etc/fstab 
```
* монтируем 
```sh
mount -a 
```
создаем директорию для хранения конфига рейд
```sh
mkdir /etc/mdadm
```
* Инициализируем конфигурацию и сохраняем ее
```sh
mdadm  --detail --scan >> /etc/mdadm/mdadm.conf
```

### Ломаем и чиним RAID
* Имитируем падение диска
``` sh
mdadm --fail /dev/md0 /dev/sdb  
```

```sh
[root@otuslinux vagrant]# cat /proc/mdstat  
Personalities : [raid1] 
md0 : active raid1 sdc[1] sdb[0](F)
      254976 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
```
* Удаляем его из массива
```sh
mdadm --remove /dev/md0 /dev/sdb  

```

```sh
mdadm: hot removed /dev/sdb from /dev/md0
```
*  добавляем в массив новый диск под замену

```sh
mdadm --add /dev/md0 /dev/sdg  
```
```sh
mdadm: added /dev/sdg
```

```sh
[root@otuslinux vagrant]# cat /proc/mdstat  
Personalities : [raid1] 
md0 : active raid1 sdg[2] sdc[1]
      254976 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
```


### Создать GPT раздел и 5 партиций

1. Правим fstab - удаляем монтирование RAID
2. Отмонтируем RAID
```sh
umount /dev/md0
```
3. Создаем разметку
```sh
parted -s /dev/md0 mklabel gpt   
```
4. Разбиваем массив 
```sh
for i in 0 20 40 60 80;do parted /dev/md0 mkpart primary $i% $(( $i+20 ))% -s; done 
```

5. Создаем файловую систему
```sh
for i in {1..5};do mkfs.xfs /dev/md0p$i -f ; done  
```

6. Создаем точки монтирования
   
```sh
for i in {1..5};do mkdir -p /raid/part_$i;done  
```   
7. Монтируем созданные разделы
   
```sh
for i in {1..5};do mount /dev/md0p$i /raid/part_$i; done
```   

8. Правим файл конфигураций монтирования
```sh
echo -e "$(for i in {1..5};do echo "$(blkid|grep md0p$i |awk '{print $2 }') /raid/part_$i  xfs defaults 0 0" ;done)\n" >> /etc/fstab
```

```sh
[root@otuslinux vagrant]# cat /etc/fstab 
UUID=1c419d6c-5064-4a2b-953c-05b2c67edb15 / xfs defaults 0 0
/swapfile none swap defaults 0 0
UUID="ec3b835a-3d25-479e-97cc-b868696a1fe9" /raid/part_1  xfs defaults 0 0
UUID="d4568dc3-4a01-4888-9b0f-746b40f87156" /raid/part_2  xfs defaults 0 0
UUID="4d4000b5-64af-4752-827c-b7c1803581bf" /raid/part_3  xfs defaults 0 0
UUID="2d945554-e32f-4cd5-ae65-93641197a86a" /raid/part_4  xfs defaults 0 0
UUID="9e9d0b69-c8bb-4dc1-93a9-8628b83e4b05" /raid/part_5  xfs defaults 0 0
```

---

[Программный RAID в Linux с помощью mdadm](https://winitpro.ru/index.php/2019/10/30/mdadm-programmnyj-raid-v-linux/)