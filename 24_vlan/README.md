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