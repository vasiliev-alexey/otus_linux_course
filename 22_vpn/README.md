# VPN

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Между двумя виртуалками поднять vpn в режимах
*   tun;
*   tap;

Прочуствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.

3. ⭐ Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке
    Формат сдачи ДЗ - vagrant + ansible

---
###  Решение
<details> 
<summary>1.  Между двумя виртуалками поднять vpn</summary>


1. Создаем [инфраструктуру](Vagrantfile)
2. Генерируем ключ  Openvpn
```sh
 openvpn --genkey --secret provisioners/files/static.key 
```
3. Запускам создание стреды и установку [OpenVPN](provisioners/openvpn.yml)
```sh
vagrant up  -provision-with  base                                                                                                   18:05:00 09/12/22
```

4.  Запускаем  конфигурирование  OPenVPN в режиме tap
``` ruby
        ansible.extra_vars = {
            tun_type:  'tap'
          }
```

```sh
vagrant provision   --provision-with openvpn         

```
Результат
```sh
ok: [client] => {
    "msg": [
        "Connecting to host 10.10.10.1, port 5201", 
        "[  4] local 10.10.10.2 port 33684 connected to 10.10.10.1 port 5201", 
        "[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd", 
        "[  4]   0.00-5.00   sec   172 MBytes   289 Mbits/sec   72    343 KBytes       ", 
        "[  4]   5.00-10.00  sec   167 MBytes   281 Mbits/sec   67    369 KBytes       ", 
        "[  4]  10.00-15.00  sec   165 MBytes   276 Mbits/sec   52    329 KBytes       ", 
        "[  4]  15.00-20.00  sec   174 MBytes   292 Mbits/sec   59    458 KBytes       ", 
        "[  4]  20.00-25.00  sec   178 MBytes   299 Mbits/sec   48    435 KBytes       ", 
        "[  4]  25.00-30.00  sec   169 MBytes   284 Mbits/sec   56    402 KBytes       ", 
        "[  4]  30.00-35.00  sec   175 MBytes   294 Mbits/sec  170    295 KBytes       ", 
        "[  4]  35.00-40.00  sec   166 MBytes   278 Mbits/sec   64    222 KBytes       ", 
        "- - - - - - - - - - - - - - - - - - - - - - - - -", 
        "[ ID] Interval           Transfer     Bandwidth       Retr", 
        "[  4]   0.00-40.00  sec  1.33 GBytes   286 Mbits/sec  588             sender", 
        "[  4]   0.00-40.00  sec  1.33 GBytes   286 Mbits/sec                  receiver", 
        "", 
        "iperf Done."
    ]
}

```

5.  Запускаем  конфигурирование  OPenVPN в режиме tun
``` ruby
        ansible.extra_vars = {
            tun_type:  'tun'
          }
```

```sh
vagrant provision   --provision-with openvpn         

```

```ruby
 
TASK [echo iperf3 result of openvpn with  tun] *********************************
ok: [client] => {
    "msg": [
        "Connecting to host 10.10.10.1, port 5201", 
        "[  4] local 10.10.10.2 port 35800 connected to 10.10.10.1 port 5201", 
        "[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd", 
        "[  4]   0.00-5.00   sec   174 MBytes   292 Mbits/sec  102    280 KBytes       ", 
        "[  4]   5.00-10.00  sec   183 MBytes   308 Mbits/sec  141    495 KBytes       ", 
        "[  4]  10.00-15.00  sec   186 MBytes   312 Mbits/sec   31    610 KBytes       ", 
        "[  4]  15.00-20.00  sec   175 MBytes   294 Mbits/sec  166    358 KBytes       ", 
        "[  4]  20.00-25.00  sec   173 MBytes   290 Mbits/sec   57    272 KBytes       ", 
        "[  4]  25.00-30.00  sec   178 MBytes   299 Mbits/sec   58    415 KBytes       ", 
        "[  4]  30.00-35.00  sec   177 MBytes   297 Mbits/sec  110    402 KBytes       ", 
        "[  4]  35.00-40.00  sec   183 MBytes   308 Mbits/sec   57    292 KBytes       ", 
        "- - - - - - - - - - - - - - - - - - - - - - - - -", 
        "[ ID] Interval           Transfer     Bandwidth       Retr", 
        "[  4]   0.00-40.00  sec  1.40 GBytes   300 Mbits/sec  722             sender", 
        "[  4]   0.00-40.00  sec  1.40 GBytes   300 Mbits/sec                  receiver", 
        "", 
        "iperf Done."
    ]
}
```

Разница tun и tap режимов:

<p>TAP:</p>

<p>Преимущества:<br />
- ведёт себя как настоящий сетевой адаптер (за исключением того, что он виртуальный);<br />
- может осуществлять транспорт любого сетевого протокола (IPv4, IPv6, IPX и прочих);<br />
- работает на 2 уровне, поэтому может передавать Ethernet-кадры внутри тоннеля;<br />
- позволяет использовать мосты.</p>

<p>Недостатки:<br />
- в тоннель попадает broadcast-трафик, что иногда не требуется;<br />
- добавляет свои заголовки поверх заголовков Ethernet на все пакеты, которые следуют через тоннель;<br />
- в целом, менее масштабируем из-за предыдущих двух пунктов;<br />
- не поддерживается устройствами Android и iOS.</p>

<p>TUN:</p>

<p>Преимущества:<br />
- передает только пакеты протокола IP (3й уровень);<br />
- сравнительно (отн. TAP) меньшие накладные расходы и, фактически, ходит только тот IP-трафик, который предназначен конкретному клиенту.</p>

<p>Недостатки:<br />
- broadcast-трафик обычно не передаётся;<br />
- нельзя использовать мосты.</p>

</details> 


<details> 
<summary>2.  Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку</summary>

1. Запускам создание стреды и установку [OpenVPN](provisioners/openvpn.yml)
```sh
vagrant up  -provision-with  base                                                                                                   18:05:00 09/12/22
```

2.  Запускаем  конфигурирование  OPenVPN в режиме tap

```sh
vagrant provision   --provision-with rasvpn         

```

3. Подключаемся к клиенту

```sh 
vagrant ssh client
```

```sh 
Last login: Sat Dec 10 08:46:16 2022 from 10.0.2.2
[vagrant@client ~]$ 
[vagrant@client ~]$ 
[vagrant@client ~]$ sudo -i
[root@client ~]# cd /etc/openvpn/
  
```



4.  Подключаемся к OpenVPN серверу.

```sh
[root@client openvpn]# openvpn --config client.conf
Sat Dec 10 08:47:11 2022 WARNING: file './client.key' is group or others accessible
Sat Dec 10 08:47:11 2022 OpenVPN 2.4.12 x86_64-redhat-linux-gnu [Fedora EPEL patched] [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Mar 17 2022
Sat Dec 10 08:47:11 2022 library versions: OpenSSL 1.0.2k-fips  26 Jan 2017, LZO 2.06
Sat Dec 10 08:47:11 2022 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.10.10:1207
Sat Dec 10 08:47:11 2022 Socket Buffers: R=[212992->212992] S=[212992->212992]
Sat Dec 10 08:47:11 2022 UDP link local (bound): [AF_INET][undef]:1194
Sat Dec 10 08:47:11 2022 UDP link remote: [AF_INET]192.168.10.10:1207
Sat Dec 10 08:47:11 2022 TLS: Initial packet from [AF_INET]192.168.10.10:1207, sid=7873aceb b16816e4
Sat Dec 10 08:47:11 2022 VERIFY OK: depth=1, CN=rasvpn
Sat Dec 10 08:47:11 2022 VERIFY KU OK
Sat Dec 10 08:47:11 2022 Validating certificate extended key usage
Sat Dec 10 08:47:11 2022 ++ Certificate has EKU (str) TLS Web Server Authentication, expects TLS Web Server Authentication
Sat Dec 10 08:47:11 2022 VERIFY EKU OK
Sat Dec 10 08:47:11 2022 VERIFY OK: depth=0, CN=rasvpn
Sat Dec 10 08:47:11 2022 Control Channel: TLSv1.2, cipher TLSv1/SSLv3 ECDHE-RSA-AES256-GCM-SHA384, 2048 bit RSA
Sat Dec 10 08:47:11 2022 [rasvpn] Peer Connection Initiated with [AF_INET]192.168.10.10:1207
Sat Dec 10 08:47:13 2022 SENT CONTROL [rasvpn]: 'PUSH_REQUEST' (status=1)
Sat Dec 10 08:47:13 2022 PUSH: Received control message: 'PUSH_REPLY,route 192.168.10.0 255.255.255.0,route 10.10.20.0 255.255.255.0,topology net30,ping 10,ping-restart 120,ifconfig 10.10.20.6 10.10.20.5,peer-id 0,cipher AES-256-GCM'
Sat Dec 10 08:47:13 2022 OPTIONS IMPORT: timers and/or timeouts modified
Sat Dec 10 08:47:13 2022 OPTIONS IMPORT: --ifconfig/up options modified
Sat Dec 10 08:47:13 2022 OPTIONS IMPORT: route options modified
Sat Dec 10 08:47:13 2022 OPTIONS IMPORT: peer-id set
Sat Dec 10 08:47:13 2022 OPTIONS IMPORT: adjusting link_mtu to 1625
Sat Dec 10 08:47:13 2022 OPTIONS IMPORT: data channel crypto options modified
Sat Dec 10 08:47:13 2022 Data Channel: using negotiated cipher 'AES-256-GCM'
Sat Dec 10 08:47:13 2022 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
Sat Dec 10 08:47:13 2022 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
Sat Dec 10 08:47:13 2022 ROUTE_GATEWAY 10.0.2.2/255.255.255.0 IFACE=eth0 HWADDR=52:54:00:c9:c7:04
Sat Dec 10 08:47:13 2022 TUN/TAP device tun0 opened
Sat Dec 10 08:47:13 2022 TUN/TAP TX queue length set to 100
Sat Dec 10 08:47:13 2022 /sbin/ip link set dev tun0 up mtu 1500
Sat Dec 10 08:47:13 2022 /sbin/ip addr add dev tun0 local 10.10.20.6 peer 10.10.20.5
Sat Dec 10 08:47:13 2022 /sbin/ip route add 192.168.10.0/24 via 10.10.20.5
Sat Dec 10 08:47:13 2022 /sbin/ip route add 192.168.10.0/24 via 10.10.20.5
Sat Dec 10 08:47:13 2022 /sbin/ip route add 10.10.20.0/24 via 10.10.20.5
Sat Dec 10 08:47:13 2022 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
Sat Dec 10 08:47:13 2022 Initialization Sequence Completed
```

</details> 