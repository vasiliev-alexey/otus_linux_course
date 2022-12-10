## Строим бонды и вланы
Строим бонды и вланы
1. в Office1 в тестовой подсети появляется сервера с доп интерфесами и адресами в internal сети testLAN
   * testClient1 - 10.10.10.254
   * testClient2 - 10.10.10.254
   * testServer1 - 10.10.10.1
   * testServer2 - 10.10.10.1

развести вланами
   * testClient1 <-> testServer1
   * testClient2 <-> testServer2


2. между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд
проверить работу c отключением интерфейсов

## Решение

<details> 
<summary>1. Создаем вланы</summary>


1. Создаем [инфраструктуру](Vagrantfile)
2. 
3. Поднимаем созданные машины
    ```sh
    vagrant up 
    ```
4. Проверяем

Соденияемся с testClient1

```sh
vssh testClient1
```
Запускаем ping до сервера
```sh
[vagrant@testClient1 ~]$ ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.372 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.295 ms
```

на  testServer1 - поднимаем tcpdump

```sh
vssh testServer1
```

``` sh
[root@testServer1 ~]# tcpdump -i eth1 -nn -e  vlan
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
14:39:15.771331 08:00:27:ff:04:c4 > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 64: vlan 100, p 0, ethertype ARP, Request who-has 10.10.10.1 tell 10.10.10.254, length 46
14:39:15.771361 08:00:27:37:c1:30 > 08:00:27:ff:04:c4, ethertype 802.1Q (0x8100), length 46: vlan 100, p 0, ethertype ARP, Reply 10.10.10.1 is-at 08:00:27:37:c1:30, length 28
14:39:15.771476 08:00:27:ff:04:c4 > 08:00:27:37:c1:30, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.254 > 10.10.10.1: ICMP echo request, id 5259, seq 1, length 64
14:39:15.771496 08:00:27:37:c1:30 > 08:00:27:ff:04:c4, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.1 > 10.10.10.254: ICMP echo reply, id 5259, seq 1, length 64
14:39:16.771961 08:00:27:ff:04:c4 > 08:00:27:37:c1:30, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.254 > 10.10.10.1: ICMP echo request, id 5259, seq 2, length 64
14:39:16.772000 08:00:27:37:c1:30 > 08:00:27:ff:04:c4, ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.1 > 10.10.10.254: ICMP echo reply, id 5259, seq 2, length 64
```

Видим что через eth1  проходят запросы с указаением vlan 100


проверим на testClient2
```sh
vssh testClient2
[vagrant@testClient2 ~]$ ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.339 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.242 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.514 ms
64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.228 ms
```

```sh
[root@testServer2 ~]# tcpdump -i eth1 -nn -e  vlan
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
14:41:55.999741 08:00:27:3d:81:74 > 08:00:27:f5:32:cb, ethertype 802.1Q (0x8100), length 102: vlan 101, p 0, ethertype IPv4, 10.10.10.254 > 10.10.10.1: ICMP echo request, id 5937, seq 16, length 64
14:41:55.999769 08:00:27:f5:32:cb > 08:00:27:3d:81:74, ethertype 802.1Q (0x8100), length 102: vlan 101, p 0, ethertype IPv4, 10.10.10.1 > 10.10.10.254: ICMP echo reply, id 5937, seq 16, length 64
14:41:56.999490 08:00:27:3d:81:74 > 08:00:27:f5:32:cb, ethertype 802.1Q (0x8100), length 102: vlan 101, p 0, ethertype IPv4, 10.10.10.254 > 10.10.10.1: ICMP echo request, id 5937, seq 17, length 64
14:41:56.999518 08:00:27:f5:32:cb > 08:00:27:3d:81:74, ethertype 802.1Q (0x8100), length 102: vlan 101, p 0, ethertype IPv4, 10.10.10.1 > 10.10.10.254: ICMP echo reply, id 5937, seq 17, length 64
^C
```

Видим что через eth1  проходят запросы с указаением vlan 101

</details> 

<details> 
<summary>2. Создаем bond</summary>
1. Создаем [инфраструктуру](Vagrantfile)
2. Поднимаем созданные машины
    ```sh
    vagrant up 
    ```
3.   Проверяем работу bond  

Подключимся inetRouter и проверим интерфейчы
видим доступный и рабочий bond
```sh
➜  24_vlan git:(24_vlan) ✗ vssh inetRouter
[vagrant@inetRouter ~]$ sudo -i
[root@inetRouter ~]# ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:c9:c7:04 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85004sec preferred_lft 85004sec
    inet6 fe80::5054:ff:fec9:c704/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:48:9e:e1 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:3f:25:5a brd ff:ff:ff:ff:ff:ff
5: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:48:9e:e1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe48:9ee1/64 scope link 
       valid_lft forever preferred_lft forever
```

Проверим что создали на inetRouter

```sh
[vagrant@centralRouter ~]$ ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:c9:c7:04 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 86046sec preferred_lft 86046sec
    inet6 fe80::5054:ff:fec9:c704/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:ca:fe:7f brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:6b:0c:d2 brd ff:ff:ff:ff:ff:ff
5: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:ca:fe:7f brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.2/30 brd 192.168.255.3 scope global bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feca:fe7f/64 scope link 
       valid_lft forever preferred_lft forever
```

Проверим что доступен  inetRouter с centralRouter

```sh
[vagrant@centralRouter ~]$ ping 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
64 bytes from 192.168.255.1: icmp_seq=1 ttl=64 time=0.400 ms
64 bytes from 192.168.255.1: icmp_seq=2 ttl=64 time=0.259 ms
64 bytes from 192.168.255.1: icmp_seq=3 ttl=64 time=0.331 ms
```


Посмотрим описание bond0

```sh
[root@inetRouter ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:48:9e:e1
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 0
```

"Уроним" активный интрфейс eth1 и пропингуем  centralRouter


```sh
[root@inetRouter ~]# ip link set dev  eth1 down
[root@inetRouter ~]# ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:c9:c7:04 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 84081sec preferred_lft 84081sec
    inet6 fe80::5054:ff:fec9:c704/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc pfifo_fast master bond0 state DOWN group default qlen 1000
    link/ether 08:00:27:48:9e:e1 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 state UP group default qlen 1000
    link/ether 08:00:27:3f:25:5a brd ff:ff:ff:ff:ff:ff
5: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:3f:25:5a brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe48:9ee1/64 scope link 
       valid_lft forever preferred_lft forever
[root@inetRouter ~]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.226 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=0.318 ms
64 bytes from 192.168.255.2: icmp_seq=3 ttl=64 time=0.385 ms


```

Все доступно и работает

</details> 