# OSPF

 
 1.    Поднять три виртуалки
   
 2.   Объединить их разными vlan
 * поднять OSPF между машинами на базе Quagga;
 * изобразить ассиметричный роутинг;
 * сделать один из линков "дорогим", но что бы при этом роутинг был симметричным.
 
 ---

1. Создаем  [инфраструктуру](Vagrantfile)
2. Поднимаем 
   
   ```sh
   vagrant up --no-provision     
   ```
3. Поднимаем роутинг на основе FRR
   ```sh
    vagrant provision --provision-with  base
   ``` 

<details> 
<summary>4. Проверяем  работу роутеров по динамическим маршрутам</summary>

  Заходим на Router1

```sh
vssh router1
```
  Проверяем маршруты
```sh
root@router1:~# vtysh

Hello, this is FRRouting (version 8.4.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router1# show ip route ospf
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O   10.0.10.0/30 [110/100] is directly connected, enp0s8, weight 1, 00:10:23
O>* 10.0.11.0/30 [110/200] via 10.0.10.2, enp0s8, weight 1, 00:08:11
  *                        via 10.0.12.2, enp0s9, weight 1, 00:08:11
O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:10:23
O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:10:23
O>* 192.168.20.0/24 [110/200] via 10.0.10.2, enp0s8, weight 1, 00:09:03
O>* 192.168.30.0/24 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:08:11

```

Отключим интерфейс
```sh
root@router1:~# ifconfig enp0s8 down

```

Проверим что изменилось

```sh
router1#  show ip route ospf
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O>* 10.0.11.0/30 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:00:16
O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:12:49
O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:12:49
O>* 192.168.20.0/24 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:00:16
O>* 192.168.30.0/24 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:10:37
router1# 

```

Маршрут пропал
Проверим теперб путь к 192.168.20.1

```sh
router1#  traceroute 192.168.20.1
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  10.0.12.2 (10.0.12.2)  0.207 ms  0.174 ms  0.167 ms
 2  192.168.20.1 (192.168.20.1)  0.368 ms  0.341 ms  0.333 ms

```
Поднимем интерфейс 

```sh
root@router1:~# ifconfig enp0s8  up
```
Получим сного короткий маршрут
```sh
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  192.168.20.1 (192.168.20.1)  0.183 ms * *
```


</details> 

<details> 
<summary>5. Проверяем ассиметричный роутинг</summary>

Прокатываем сценрий по  реконфигурации 

```sh
 vagrant provision   --provision-with  asymmetric     
```

```sh
root@router1:~# cat /etc/frr/frr.conf 

Пример конфига с повышением стоимости на одном из интерфейсов

...
interface enp0s8
  description r1-r2 
  ip address 10.0.10.1/30 
  ip ospf mtu-ignore
  ip ospf cost 1000 
  ip ospf hello-interval 10
  ip ospf dead-interval 30
```


Марушрут на 
```
router1#  show ip route ospf
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O   10.0.10.0/30 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:17:50
O>* 10.0.11.0/30 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:17:50
O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:17:58
O   192.168.10.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:17:58
O>* 192.168.20.0/24 [110/300] via 10.0.12.2, enp0s9, weight 1, 00:17:50
O>* 192.168.30.0/24 [110/200] via 10.0.12.2, enp0s9, weight 1, 00:17:50
```


Запускаем пинг на 192.168.30.1
```sh
ping -I 192.168.10.1 192.168.30.1
PING 192.168.30.1 (192.168.30.1) from 192.168.10.1 : 56(84) bytes of data.
64 bytes from 192.168.30.1: icmp_seq=1 ttl=64 time=0.223 ms
```

Запускаем снифер на router3 на интерфейсе enp0s9 и видим приходящий трафик ICMP
```
root@router3:~# tcpdump -i enp0s9 
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on enp0s9, link-type EN10MB (Ethernet), snapshot length 262144 bytes
17:45:58.962866 IP 192.168.10.1 > router3: ICMP echo request, id 1, seq 557, length 64
17:45:58.962893 IP router3 > 192.168.10.1: ICMP echo reply, id 1, seq 557, length 64
17:45:59.986851 IP 192.168.10.1 > router3: ICMP echo request, id 1, seq 558, length 64
```


</details> 



<details> 
<summary>6. Настройка симметичного роутинга</summary>

Реконфигурируем - добавялему стоимость на интерфейс для enp0s9  для  router3
```sh
 vagrant provision   --provision-with  asymmetric     
```

Смтрим что на router3 трафик  на 192.168.10.0 пойдет через  роутер 2

```sh
root@router3:~# vtysh

Hello, this is FRRouting (version 8.4.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

router3#  show ip route ospf
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

O>* 10.0.10.0/30 [110/1100] via 10.0.11.2, enp0s8, weight 1, 00:00:30
  *                         via 10.0.12.1, enp0s9, weight 1, 00:00:30
O   10.0.11.0/30 [110/100] is directly connected, enp0s8, weight 1, 00:00:46
O   10.0.12.0/30 [110/100] is directly connected, enp0s9, weight 1, 00:37:28
O>* 192.168.10.0/24 [110/200] via 10.0.12.1, enp0s9, weight 1, 00:37:20
O>* 192.168.20.0/24 [110/200] via 10.0.11.2, enp0s8, weight 1, 00:00:40
O   192.168.30.0/24 [110/100] is directly connected, enp0s10, weight 1, 00:55:05
```

</details> 