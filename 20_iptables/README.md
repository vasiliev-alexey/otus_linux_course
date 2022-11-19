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
4. Устанваливаем 
   ``` sh
   vagrant up
   ```

5. проверяем Knok 
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



[Полный обзор Firewalld](https://it-black.ru/polnyj-obzor-firewalld/)


