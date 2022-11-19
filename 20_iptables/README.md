# Сценарии iptables

## Описание/Пошаговая инструкция выполнения домашнего задания:

 *  реализовать knocking port
 *  centralRouter может попасть на ssh inetrRouter через knock скрипт
    пример в материалах.
 *  добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
 *   запустить nginx на centralServer.
 *   пробросить 80й порт на inetRouter2 8080.
 *   дефолт в инет оставить через inetRouter.

Формат сдачи ДЗ - vagrant + ansible

---

1. Создаем  [инфраструктуру](Vagrantfile)
2. Добавялем [установку пакетов для knock-сервера и knock-клиента ](provisioners/common.yml)
3. Модифицируем [playbook для inetRoute](provisioners/inetRouter.yml)
4. Устанавливаем 
   ``` sh
   vagrant up
   ```
<details>   
<summary> 5. проверяем Knok </summary>  

   ``` sh
   vssh centralRouter   
   Last login: Sat Nov 19 09:30:23 2022 from 10.0.2.2
   ```


      ```sh
      [vagrant@centralRouter ~]$ knock -v 192.168.255.1 9999 7777 6666
      hitting tcp 192.168.255.1:9999
      hitting tcp 192.168.255.1:7777
      hitting tcp 192.168.255.1:6666
      [vagrant@centralRouter ~]$ ssh 192.168.255.1 
      ssh: connect to host 192.168.255.1 port 22: No route to host
      [vagrant@centralRouter ~]$ knock -v 192.168.255.1 8888 7777 6666
      hitting tcp 192.168.255.1:8888
      hitting tcp 192.168.255.1:7777
      hitting tcp 192.168.255.1:6666
      [vagrant@centralRouter ~]$ ssh 192.168.255.1 
      vagrant@192.168.255.1's password: 
      Last login: Sat Nov 19 09:38:19 2022 from 192.168.255.2
      [vagrant@inetRouter ~]$ logout
      Connection to 192.168.255.1 closed.
      [vagrant@centralRouter ~]$ knock -v 192.168.255.1 9999 7777 6666
      hitting tcp 192.168.255.1:9999
      hitting tcp 192.168.255.1:7777
      hitting tcp 192.168.255.1:6666
      [vagrant@centralRouter ~]$ ssh 192.168.255.1 
      ssh: connect to host 192.168.255.1 port 22: No route to host
      ```

</details>  

<details>   
<summary> 6. Добавляем inetRouter2</summary>  

```sh
  :inetRouter2 => {
    :box_name => "centos/7",
    :vm_name => "inetRouter2",
    :net => [
      {ip: '192.168.255.10', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router2-net"},
 
    ]
  }
 
```

</details>   
<details>   
<summary> 7.Добавялем Nginx на CentralServer</summary>  

[Playbook](provisioners/centralServer.yml)

``` sh
    - name: Template nginx index page
      template:
        src: "centralServer/index.html.j2"
        dest: "/usr/share/nginx/html/index.html"
      notify: restart nginx

    - name: Template nginx default.conf
      template:
        src: "centralServer/default.conf.j2"
        dest: /etc/nginx/nginx.conf
      notify: restart nginx


    - name: start_nginx
      service:
        name: nginx 
        state: started
        enabled: yes 
```

</details>   

 
 8. [Конфигурируем InetRouter2](provisioners/inetRouter2.yml)


9. Проверяем
  
 Пробросим порт виртуалки 
 ```sh
         if boxconfig[:vm_name] == "inetRouter2"
          box.vm.network "forwarded_port", guest: 8080, host: 9192, host_ip: "127.0.0.1", id: "http"
        end

 ``` 
Проверим результат

![test](pict/Screenshot%20from%202022-11-19%2019-26-53.png)


10. Проверим дефолт в инет оставить через inetRouter

```sh
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  gateway (192.168.0.1)  0.215 ms  0.190 ms  0.116 ms
 2  192.168.255.1 (192.168.255.1)  0.314 ms  0.287 ms  0.261 ms
 3  * * *
 4  * * *
 5  * * *
 6  obl93-97.93.255.89.in-addr.arpa (89.255.93.97)  2.123 ms  1.934 ms  1.907 ms
 7  obl92-33.92.255.89.in-addr.arpa (89.255.92.33)  2.202 ms  2.197 ms  2.573 ms
 8  obl93-170.93.255.89.in-addr.arpa (89.255.93.170)  3.042 ms  3.029 ms  1.953 ms
 9  msk-ix-gw3.google.com (195.208.208.250)  3.913 ms  3.568 ms  2.787 ms
10  108.170.250.34 (108.170.250.34)  3.180 ms  3.760 ms 108.170.250.99 (108.170.250.99)  3.652 ms
11  72.14.234.20 (72.14.234.20)  17.808 ms 142.251.78.106 (142.251.78.106)  16.984 ms 142.250.238.138 (142.250.238.138)  18.544 ms
12  216.239.48.224 (216.239.48.224)  19.748 ms  19.966 ms 142.251.238.72 (142.251.238.72)  17.857 ms
13  142.250.238.181 (142.250.238.181)  18.880 ms 142.250.57.7 (142.250.57.7)  16.626 ms 172.253.51.245 (172.253.51.245)  18.118 ms
14  * * *
15  * * *
```

---
[Полный обзор Firewalld](https://it-black.ru/polnyj-obzor-firewalld/)


