# Разворачиваем сетевую лабораторию
Vagrantfile - для стенда урока 9 - Network

## Дано
Vagrantfile с начальным  построением сети
inetRouter
centralRouter
centralServer

тестировалось на virtualbox

## Планируемая архитектура

<details> 
<summary>построить следующую архитектуру</summary>
Сеть office1
- 192.168.2.0/26      - dev
- 192.168.2.64/26    - test servers
- 192.168.2.128/26  - managers
- 192.168.2.192/26  - office hardware

Сеть office2
- 192.168.1.0/25      - dev
- 192.168.1.128/26  - test servers
- 192.168.1.192/26  - office hardware


Сеть central
- 192.168.0.0/28    - directors
- 192.168.0.32/28  - office hardware
- 192.168.0.64/26  - wifi

```
Office1 ---\
      -----> Central --IRouter --> internet
Office2----/
```
Итого должны получится следующие сервера
- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server
</details> 

## Теоретическая часть
- Найти свободные подсети
- Посчитать сколько узлов в каждой подсети, включая свободные
- Указать broadcast адрес для каждой подсети
- проверить нет ли ошибок при разбиении

## Практическая часть
- Соединить офисы в сеть согласно схеме и настроить роутинг
- Все сервера и роутеры должны ходить в инет черз inetRouter
- Все сервера должны видеть друг друга
- у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
- при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс



---
### Решение:
<details> 
<summary>Теоретическая часть</summary>

таблица топологии Сеть central

| Имя подсети     | Сеть            | Маска           | Число хостов | Hostmin      | Hostmax       | Broadcast     |
| --------------- | --------------- | --------------- | ------------ | ------------ | ------------- | ------------- |
| directors       | 192.168.0.0/28  | 255.255.255.240 | 14           | 192.168.0.1  | 192.168.0.14  | 192.168.0.15  |
| office hardware | 192.168.0.32/28 | 255.255.255.240 | 14           | 192.168.0.33 | 192.168.0.46  | 192.168.0.47  |
| wifi            | 192.168.0.64/26 | 255.255.255.192 | 62           | 192.168.0.65 | 192.168.0.126 | 192.168.0.127 |
 


| Свободные подсети central |
| ------------------------- |
| 192.168.0.16/28           |
| 192.168.0.48/28           |
| 192.168.0.128/25          |

 
таблица топологии Сеть Office1 Network

| Имя подсети     | Сеть             | Маска           | Число хостов | Hostmin       | Hostmax       | Broadcast     |
| --------------- | ---------------- | --------------- | ------------ | ------------- | ------------- | ------------- |
| dev             | 192.168.2.0/26   | 255.255.255.192 | 62           | 192.168.2.1   | 192.168.2.62  | 192.168.2.63  |
| test servers    | 192.168.2.64/26  | 255.255.255.192 | 62           | 192.168.2.65  | 192.168.2.126 | 192.168.2.127 |
| managers        | 192.168.2.128/26 | 255.255.255.192 | 62           | 192.168.2.129 | 192.168.2.190 | 192.168.2.191 |
| office hardware | 192.168.2.192/26 | 255.255.255.192 | 62           | 192.168.2.193 | 192.168.2.254 | 192.168.2.255 |

таблица топологии Сеть Office2 Network

| Имя подсети     | Сеть             | Маска           | Число хостов | Hostmin       | Hostmax       | Broadcast     |
| --------------- | ---------------- | --------------- | ------------ | ------------- | ------------- | ------------- |
| dev             | 192.168.1.0/25   | 255.255.255.128 | 62           | 192.168.1.1   | 192.168.1.126 | 192.168.1.127 |
| test servers    | 192.168.1.128/26 | 255.255.255.192 | 62           | 192.168.1.129 | 192.168.1.190 | 192.168.1.191 |
| office hardware | 192.168.1.192/26 | 255.255.255.192 | 62           | 192.168.1.193 | 192.168.1.254 | 192.168.1.255 |

Ошибок в топологии нет
</details> 

<details> 
<summary>Практическая часть</summary>

![Топология сети](netoffice.drawio.svg)


1. Создаем [инфраструктуру](Vagrantfile)
2. Создаем [ansible playbook для InetRouter](provisioners/inetRouter.yml)
3. Создаем [ansible playbook для CentralRouter](provisioners/centralRouter.yml)
4. Создаем [ansible playbook для CentralServer](provisioners/centralServer.yml)
5. Создаем [ansible playbook для office1Router](provisioners/office1Router.yml)
6. Создаем [ansible playbook для inetRouter](provisioners/office1Server.yml)
7. Создаем [ansible playbook для office2Router](provisioners/office2Router.yml)
8. Создаем [ansible playbook для office2Server](provisioners/office2Server.yml)

9. Поднимаем сетевую лаюотраборию
      ```sh
      vagrant up
      ```

10. Проверяем результат работы

Тестируем centralServer
```sh
➜  18_network git:(18_network) ✗ vssh centralServer                                                                                                             18:32:19 13/11/22
Last login: Sun Nov 13 15:30:08 2022 from 10.0.2.2
[vagrant@centralServer ~]$ ping 192.168.2.130
PING 192.168.2.130 (192.168.2.130) 56(84) bytes of data.
64 bytes from 192.168.2.130: icmp_seq=1 ttl=62 time=0.629 ms
64 bytes from 192.168.2.130: icmp_seq=2 ttl=62 time=0.584 ms
^C
--- 192.168.2.130 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 0.584/0.606/0.629/0.033 ms
[vagrant@centralServer ~]$ ping ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=59 time=5.93 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=59 time=5.52 ms
^C
--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 5.523/5.731/5.939/0.208 ms
[vagrant@centralServer ~]$ traceroute 192.168.2.130
traceroute to 192.168.2.130 (192.168.2.130), 30 hops max, 60 byte packets
 1  gateway (192.168.0.1)  0.257 ms  0.222 ms  0.141 ms
 2  192.168.255.10 (192.168.255.10)  0.326 ms  0.292 ms  0.260 ms
 3  192.168.2.130 (192.168.2.130)  0.427 ms  0.392 ms  0.358 ms
[vagrant@centralServer ~]$ traceroute ya.ru
traceroute to ya.ru (87.250.250.242), 30 hops max, 60 byte packets
 1  gateway (192.168.0.1)  0.266 ms  0.235 ms  0.258 ms
 2  192.168.255.1 (192.168.255.1)  0.443 ms  0.427 ms  0.401 ms
 3  * * *
 4  * * *
 5  * * *
 6  obl93-97.93.255.89.in-addr.arpa (89.255.93.97)  2.277 ms  1.299 ms  1.278 ms
 7  obl92-33.92.255.89.in-addr.arpa (89.255.92.33)  2.098 ms  2.027 ms  2.005 ms
 8  obl93-170.93.255.89.in-addr.arpa (89.255.93.170)  2.343 ms  2.737 ms  2.678 ms
 9  styri.yndx.net (195.208.208.116)  4.199 ms  4.066 ms  3.588 ms
10  * sas-32z3-ae1.yndx.net (87.250.239.183)  10.802 ms *
11  * * ya.ru (87.250.250.242)  4.993 ms
```

Тестируем office1Server
```sh
➜  18_network git:(18_network) ✗ vssh office1Server                                                                                                            18:31:26 13/11/22
[vagrant@office1Server ~]$ ping ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=57 time=5.80 ms
^C
--- ya.ru ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 5.807/5.807/5.807/0.000 ms
[vagrant@office1Server ~]$ ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
64 bytes from 192.168.0.2: icmp_seq=1 ttl=62 time=0.607 ms
64 bytes from 192.168.0.2: icmp_seq=2 ttl=62 time=0.622 ms
^C
--- 192.168.0.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.607/0.614/0.622/0.025 ms
[vagrant@office1Server ~]$ traceroute 192.168.0.2
traceroute to 192.168.0.2 (192.168.0.2), 30 hops max, 60 byte packets
 1  192.168.2.129 (192.168.2.129)  0.263 ms  0.230 ms  0.137 ms
 2  192.168.255.9 (192.168.255.9)  0.285 ms  0.241 ms  0.175 ms
 3  192.168.0.2 (192.168.0.2)  0.466 ms  0.426 ms  0.385 ms
[vagrant@office1Server ~]$ ^C
[vagrant@office1Server ~]$ traceroute ya.ru
traceroute to ya.ru (87.250.250.242), 30 hops max, 60 byte packets
 1  192.168.2.129 (192.168.2.129)  0.328 ms  0.293 ms  0.210 ms
 2  192.168.255.9 (192.168.255.9)  0.394 ms  0.349 ms  0.328 ms
 3  192.168.255.1 (192.168.255.1)  0.657 ms  0.563 ms  0.509 ms
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  obl92-33.92.255.89.in-addr.arpa (89.255.92.33)  2.857 ms  2.024 ms  2.092 ms
 9  obl93-170.93.255.89.in-addr.arpa (89.255.93.170)  2.560 ms  2.841 ms  2.081 ms
10  styri.yndx.net (195.208.208.116)  3.211 ms  19.372 ms  19.038 ms
11  sas-32z5-ae2.yndx.net (87.250.239.203)  17.884 ms * *
12  * *^C
```

Тестируем office2Server
```sh
➜  18_network git:(18_network) ✗ vssh office2Server                                                                                                            18:35:50 13/11/22
[vagrant@office2Server ~]$ ping ping 192.168.0.2
ping: ping: Name or service not known
[vagrant@office2Server ~]$ ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
64 bytes from 192.168.0.2: icmp_seq=1 ttl=62 time=0.631 ms
64 bytes from 192.168.0.2: icmp_seq=2 ttl=62 time=0.645 ms
^C
--- 192.168.0.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.631/0.638/0.645/0.007 ms
[vagrant@office2Server ~]$ ping  ya.ru
PING ya.ru (87.250.250.242) 56(84) bytes of data.
64 bytes from ya.ru (87.250.250.242): icmp_seq=1 ttl=57 time=6.94 ms
64 bytes from ya.ru (87.250.250.242): icmp_seq=2 ttl=57 time=5.86 ms
^C
--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 5.869/6.406/6.943/0.537 ms
[vagrant@office2Server ~]$ traceroute 192.168.0.2
traceroute to 192.168.0.2 (192.168.0.2), 30 hops max, 60 byte packets
 1  router.local (192.168.1.1)  0.227 ms  0.192 ms  0.125 ms
 2  192.168.255.5 (192.168.255.5)  0.423 ms  0.394 ms  0.380 ms
 3  192.168.0.2 (192.168.0.2)  0.443 ms  0.377 ms  0.362 ms
[vagrant@office2Server ~]$ traceroute 4.4.4.4
traceroute to 4.4.4.4 (4.4.4.4), 30 hops max, 60 byte packets
 1  router.local (192.168.1.1)  0.245 ms  0.212 ms  0.161 ms
 2  192.168.255.5 (192.168.255.5)  0.374 ms  0.333 ms  0.289 ms
 3  192.168.255.1 (192.168.255.1)  0.491 ms  0.479 ms  0.442 ms
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  obl92-33.92.255.89.in-addr.arpa (89.255.92.33)  2.656 ms  2.149 ms  2.104 ms
 9  obl93-170.93.255.89.in-addr.arpa (89.255.93.170)  3.180 ms  2.930 ms  1.987 ms
10  line-r-gw-backup.gblnet.ru (109.239.138.9)  3.396 ms  3.092 ms  3.638 ms
11  91.108.51.6 (91.108.51.6)  23.507 ms  22.631 ms  23.665 ms
12  * * *
13  *^C
[vagrant@office2Server ~]$ ping 192.168.2.130
PING 192.168.2.130 (192.168.2.130) 56(84) bytes of data.
64 bytes from 192.168.2.130: icmp_seq=1 ttl=61 time=0.787 ms
64 bytes from 192.168.2.130: icmp_seq=2 ttl=61 time=0.772 ms
^C
--- 192.168.2.130 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1004ms
rtt min/avg/max/mdev = 0.772/0.779/0.787/0.028 ms

```
</details> 