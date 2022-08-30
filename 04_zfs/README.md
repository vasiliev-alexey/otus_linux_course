# Практические навыки работы с ZFS

## Цель:

Отрабатываем навыки работы с созданием томов export/import и установкой параметров.

- определить алгоритм с наилучшим сжатием;
- определить настройки pool’a;
- найти сообщение от преподавателей.
- Результат:
- список команд, которыми получен результат с их выводами.

---

### 1.Определить алгоритм с наилучшим сжатием.
1. Создаем [Vagrantfile](Vagrantfile)

2.  Создаем ZFS пул и именованные FS. Выставляем сразу уровнеь комперсии  
```sh
zpool create testsize /dev/sdb
for i in gzip zle lzjb lz4; do zfs create testsize\/fs_$i  &&  zfs set compression=$i testsize\/fs_$i ;  done 
```

3. Загружаем файл
```sh
wget -O /tmp/War_and_Peace.txt http://www.gutenberg.org/files/2600/2600-0.txt
```
 


4. Копируем файл на тестовые FS
```sh
for i in gzip zle lzjb lz4; do cp /tmp/War_and_Peace.txt /testsize\/fs_$i ;  done 
sync
```

5. Снимаем резульатты тестов
```sh 
zfs list -o name,mountpoint,used,compression,compressratio
```

``` sh
NAME              MOUNTPOINT          USED  COMPRESS        RATIO
testsize          /testsize          9.10M  off             1.47x
testsize/fs_gzip  /testsize/fs_gzip  1.24M  gzip            2.67x
testsize/fs_lz4   /testsize/fs_lz4   2.02M  lz4             1.62x
testsize/fs_lzjb  /testsize/fs_lzjb  2.41M  lzjb            1.36x
testsize/fs_zle   /testsize/fs_zle   3.23M  zle             1.01x
```

<details><summary>Ответ</summary>
Резульат - gzip с дефолтным уровнем 6 самый эффективный в данной группе тестов
</details>


### 2. Определить настройки pool’a

1. 
```sh
zpool create otus /dev/sdd
/tmp/zpoolexport/
```

2. Скачиваем архив 
```sh
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg' -O /tmp/zfs_task1.tar.gz
tar xvf /tmp/zfs_task1.tar.gz -C /tmp
```

3.  Импортируем
```sh
zpool import -d /tmp/zpoolexport/
zpool import -d /tmp/zpoolexport/ otus
```


```sh
 
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                        ONLINE
          mirror-0                  ONLINE
            /tmp/zpoolexport/filea  ONLINE
            /tmp/zpoolexport/fileb  ONLINE
```

4. Проверяем 
<details><summary>zpool list</summary> 
NAME       SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT  

otus       480M  2.11M   478M        -         -     0%     0%  1.00x    ONLINE  -
</details>

  
<details><summary>zpool status</summary> 
  pool: otus

state: ONLINE

status: Some supported features are not enabled on the pool. The pool can
        still be used, but some features are unavailable.

action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(5) for details.

config:

        NAME                        STATE     READ WRITE CKSUM
        otus                        ONLINE       0     0     0
          mirror-0                  ONLINE       0     0     0
            /tmp/zpoolexport/filea  ONLINE       0     0     0
            /tmp/zpoolexport/fileb  ONLINE       0     0     0
 </details>


<details><summary>zfs list</summary> 
 
NAME               USED  AVAIL     REFER  MOUNTPOINT

otus              2.04M   350M       24K  /otus  

otus/hometask2    1.88M   350M     1.88M  /otus/hometask2
  </details>


<details><summary>zfs get all</summary> 
NAME              PROPERTY              VALUE                  SOURCE
otus              type                  filesystem             -
otus              creation              Fri May 15  4:00 2020  -
otus              used                  2.04M                  -
otus              available             350M                   -
otus              referenced            24K                    -
otus              compressratio         1.00x                  -
otus              mounted               yes                    -
otus              quota                 none                   default
otus              reservation           none                   default
otus              recordsize            128K                   local
otus              mountpoint            /otus                  default
otus              sharenfs              off                    default
otus              checksum              sha256                 local
otus              compression           zle                    local
otus              atime                 on                     default
otus              devices               on                     default
otus              exec                  on                     default
otus              setuid                on                     default
otus              readonly              off                    default
otus              zoned                 off                    default
otus              snapdir               hidden                 default
otus              aclmode               discard                default
otus              aclinherit            restricted             default
otus              createtxg             1                      -
otus              canmount              on                     default
otus              xattr                 on                     default
otus              copies                1                      default
otus              version               5                      -
otus              utf8only              off                    -
otus              normalization         none                   -
otus              casesensitivity       sensitive              -
otus              vscan                 off                    default
otus              nbmand                off                    default
otus              sharesmb              off                    default
otus              refquota              none                   default
otus              refreservation        none                   default
otus              guid                  14592242904030363272   -
otus              primarycache          all                    default
otus              secondarycache        all                    default
otus              usedbysnapshots       0B                     -
otus              usedbydataset         24K                    -
otus              usedbychildren        2.02M                  -
otus              usedbyrefreservation  0B                     -
otus              logbias               latency                default
otus              objsetid              54                     -
otus              dedup                 off                    default
otus              mlslabel              none                   default
otus              sync                  standard               default
otus              dnodesize             legacy                 default
otus              refcompressratio      1.00x                  -
otus              written               24K                    -
otus              logicalused           1021K                  -
otus              logicalreferenced     12K                    -
otus              volmode               default                default
otus              filesystem_limit      none                   default
otus              snapshot_limit        none                   default
otus              filesystem_count      none                   default
otus              snapshot_count        none                   default
otus              snapdev               hidden                 default
otus              acltype               off                    default
otus              context               none                   default
otus              fscontext             none                   default
otus              defcontext            none                   default
otus              rootcontext           none                   default
otus              relatime              off                    default
otus              redundant_metadata    all                    default
otus              overlay               on                     default
otus              encryption            off                    default
otus              keylocation           none                   default
otus              keyformat             none                   default
otus              pbkdf2iters           0                      default
otus              special_small_blocks  0                      default
otus/hometask2    type                  filesystem             -
otus/hometask2    creation              Fri May 15  4:18 2020  -
otus/hometask2    used                  1.88M                  -
otus/hometask2    available             350M                   -
otus/hometask2    referenced            1.88M                  -
otus/hometask2    compressratio         1.00x                  -
otus/hometask2    mounted               yes                    -
otus/hometask2    quota                 none                   default
otus/hometask2    reservation           none                   default
otus/hometask2    recordsize            128K                   inherited from otus
otus/hometask2    mountpoint            /otus/hometask2        default
otus/hometask2    sharenfs              off                    default
otus/hometask2    checksum              sha256                 inherited from otus
otus/hometask2    compression           zle                    inherited from otus
otus/hometask2    atime                 on                     default
otus/hometask2    devices               on                     default
otus/hometask2    exec                  on                     default
otus/hometask2    setuid                on                     default
otus/hometask2    readonly              off                    default
otus/hometask2    zoned                 off                    default
otus/hometask2    snapdir               hidden                 default
otus/hometask2    aclmode               discard                default
otus/hometask2    aclinherit            restricted             default
otus/hometask2    createtxg             216                    -
otus/hometask2    canmount              on                     default
otus/hometask2    xattr                 on                     default
otus/hometask2    copies                1                      default
otus/hometask2    version               5                      -
otus/hometask2    utf8only              off                    -
otus/hometask2    normalization         none                   -
otus/hometask2    casesensitivity       sensitive              -
otus/hometask2    vscan                 off                    default
otus/hometask2    nbmand                off                    default
otus/hometask2    sharesmb              off                    default
otus/hometask2    refquota              none                   default
otus/hometask2    refreservation        none                   default
otus/hometask2    guid                  3809416093691379248    -
otus/hometask2    primarycache          all                    default
otus/hometask2    secondarycache        all                    default
otus/hometask2    usedbysnapshots       0B                     -
otus/hometask2    usedbydataset         1.88M                  -
otus/hometask2    usedbychildren        0B                     -
otus/hometask2    usedbyrefreservation  0B                     -
otus/hometask2    logbias               latency                default
otus/hometask2    objsetid              81                     -
otus/hometask2    dedup                 off                    default
otus/hometask2    mlslabel              none                   default
otus/hometask2    sync                  standard               default
otus/hometask2    dnodesize             legacy                 default
otus/hometask2    refcompressratio      1.00x                  -
otus/hometask2    written               1.88M                  -
otus/hometask2    logicalused           963K                   -
otus/hometask2    logicalreferenced     963K                   -
otus/hometask2    volmode               default                default
otus/hometask2    filesystem_limit      none                   default
otus/hometask2    snapshot_limit        none                   default
otus/hometask2    filesystem_count      none                   default
otus/hometask2    snapshot_count        none                   default
otus/hometask2    snapdev               hidden                 default
otus/hometask2    acltype               off                    default
otus/hometask2    context               none                   default
otus/hometask2    fscontext             none                   default
otus/hometask2    defcontext            none                   default
otus/hometask2    rootcontext           none                   default
otus/hometask2    relatime              off                    default
otus/hometask2    redundant_metadata    all                    default
otus/hometask2    overlay               on                     default
otus/hometask2    encryption            off                    default
otus/hometask2    keylocation           none                   default
otus/hometask2    keyformat             none                   default
otus/hometask2    pbkdf2iters           0                      default
otus/hometask2    special_small_blocks  0                      default
</details>




<details><summary>zfs get recordsize,compression,checksum | grep ^otus</summary> 
otus              recordsize   128K            local

otus              compression  zle             local

otus              checksum     sha256          local

otus/hometask2    recordsize   128K            inherited from otus

otus/hometask2    compression  zle             inherited from otus

otus/hometask2    checksum     sha256          inherited from otus

</details>

 

### 3. Найти сообщение от преподавателей.

`. Скачиваем ахив снапшота
```sh

 wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG' -O /tmp/otus_task2.file
```

2.Создаем ZFS пул 
```sh
zpool create testsnap /dev/sdc
zfs receive testsnap/data < /tmp/otus_task2.file
```

3. Проверяем список снапшотов

```sh
zfs list -t snapshot
```

```sh
NAME                  USED  AVAIL     REFER  MOUNTPOINT
testsnap/data@task2     0B      -     3.69M  -
```

4. Откатываемся на снапшот 

```sh
zfs rollback testsnap/data@task2
```

5.  Ищем секрет 
```sh
ls /storage/data
cat /testsnap/data/task1/file_mess/secret_message</code>
```
<details> <summary> Ответ </summary>  
 
 https://github.com/sindresorhus/awesome

</details>


---

[Understanding ZFS storage and performance](https://arstechnica.com/information-technology/2020/05/zfs-101-understanding-zfs-storage-and-performance/3/)

