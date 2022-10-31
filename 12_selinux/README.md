# Практика с SELinux

## Цель:

Тренируем умение работать с SELinux: диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.

### Описание/Пошаговая инструкция выполнения домашнего задания:

 1.  Запустить nginx на нестандартном порту 3-мя разными способами:

*   переключатели setsebool;
*   добавление нестандартного порта в имеющийся тип;
*   формирование и установка модуля SELinux.
   
    К сдаче:
    README с описанием каждого решения (скриншоты и демонстрация приветствуются).


 2.    Обеспечить работоспособность приложения при включенном selinux.

*    развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
*    выяснить причину неработоспособности механизма обновления зоны (см. README);
*    предложить решение (или решения) для данной проблемы;
*    выбрать одно из решений для реализации, предварительно обосновав выбор;
*    реализовать выбранное решение и продемонстрировать его работоспособность.
   
 К сдаче:  
   README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
   исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

---


### Запустить nginx на нестандартном порту 3-мя разными способами:

1. Создаем [стенд](task1/Vagrantfile)
2. Поднимаем [инфраструктуру и Nginx](task1/playbook.yml)
3. Заходим на машину
   ```sh
   vssh
   ```
4. Проверяем статус Nginx

```sh
[vagrant@selinux-server ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sun 2022-10-30 12:47:06 UTC; 4min 53s ago
  Process: 7628 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 7626 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
```

```sh
[root@selinux-server vagrant]# cat /var/log/nginx/
[root@selinux-server vagrant]# cat /var/log/nginx/error.log 
2022/10/30 12:46:51 [emerg] 7546#0: bind() to 0.0.0.0:4881 failed (13: Permission denied)
2022/10/30 12:46:56 [emerg] 7574#0: bind() to 0.0.0.0:4881 failed (13: Permission denied)
2022/10/30 12:47:01 [emerg] 7601#0: bind() to 0.0.0.0:4881 failed (13: Permission denied)
2022/10/30 12:47:06 [emerg] 7628#0: bind() to 0.0.0.0:4881 failed (13: Permission denied)
```


5. Проверяем логи аудита
```sh
[root@selinux-server vagrant]# grep 4881 /var/log/audit/audit.log 
type=AVC msg=audit(1667134011.270:1315): avc:  denied  { name_bind } for  pid=7546 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```

6. Формируем отчет аудита

``` sh
   [root@selinux-server vagrant]# grep  667134026.941:1339 /var/log/audit/audit.log  | audit2why
type=AVC msg=audit(1667134026.941:1339): avc:  denied  { name_bind } for  pid=7628 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```

Видим - возможность применени я рекомендации 
``` sh
setsebool -P nis_enabled 1
```

применяе ее
```sh
setsebool -P nis_enabled on
```

Перезапускаем Nginx
```sh
systemctl restart nginx
```
```sh
[root@selinux-server vagrant]# systemctl status  nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2022-10-30 13:03:55 UTC; 18s ago
  Process: 7752 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 7749 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 7748 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 7753 (nginx)
    Tasks: 3 (limit: 12403)
   Memory: 5.0M
   CGroup: /system.slice/nginx.service
           ├─7753 nginx: master process /usr/sbin/nginx
           ├─7754 nginx: worker process
           └─7755 nginx: worker process

Oct 30 13:03:55 selinux-server systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 30 13:03:55 selinux-server nginx[7749]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 30 13:03:55 selinux-server nginx[7749]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 30 13:03:55 selinux-server systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Oct 30 13:03:55 selinux-server systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Возвращаем проблему 
``` sh
setsebool -P nis_enabled off
```

![dd](pict\1.png)
7. разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип
проверяем пул портов доступных для HTTP
```sh
[root@selinux-server vagrant]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```
Добавялем порт  в пул HTTp
```sh
semanage port -a -t http_port_t -p tcp 4881
```
рестартуем Nginx
```sh
systemctl restart nginx
```
проверяем статус Nginx
```sh
[root@selinux-server vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2022-10-30 13:40:51 UTC; 26s ago
  Process: 7824 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 7822 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 7820 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 7825 (nginx)
    Tasks: 3 (limit: 12403)
   Memory: 5.0M
   CGroup: /system.slice/nginx.service
           ├─7825 nginx: master process /usr/sbin/nginx
           ├─7826 nginx: worker process
           └─7827 nginx: worker process

Oct 30 13:40:51 selinux-server systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 30 13:40:51 selinux-server nginx[7822]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 30 13:40:51 selinux-server nginx[7822]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 30 13:40:51 selinux-server systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pid: Invalid argument
Oct 30 13:40:51 selinux-server systemd[1]: Started The nginx HTTP and reverse proxy server.
```

```sh
[root@selinux-server vagrant]# curl localhost:4881
<h1>Hi,  I am selinux-server  machine </h1>[root@selinux-server vagrant]# 
```

Возвращаем проблему 
```sh
[root@selinux-server vagrant]# semanage port -d -t http_port_t -p tcp 4881
```

![dd](pict\2.png)
8. Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования
и установки модуля SELinux

```sh

[root@selinux-server vagrant]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@selinux-server vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Sun 2022-10-30 14:23:46 UTC; 10s ago
  Process: 7824 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 7872 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 7868 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 7825 (code=exited, status=0/SUCCESS)

Oct 30 14:23:45 selinux-server systemd[1]: nginx.service: Succeeded.
Oct 30 14:23:45 selinux-server systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Oct 30 14:23:45 selinux-server systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 30 14:23:46 selinux-server nginx[7872]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 30 14:23:46 selinux-server nginx[7872]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
Oct 30 14:23:46 selinux-server nginx[7872]: nginx: configuration file /etc/nginx/nginx.conf test failed
Oct 30 14:23:46 selinux-server systemd[1]: nginx.service: Control process exited, code=exited status=1
Oct 30 14:23:46 selinux-server systemd[1]: nginx.service: Failed with result 'exit-code'.
Oct 30 14:23:46 selinux-server systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```

```sh
[root@selinux-server vagrant]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

[root@selinux-server vagrant]# 
```

```sh
[root@selinux-server vagrant]# cat nginx.te 

module nginx 1.0;

require {
        type httpd_t;
        type unreserved_port_t;
        class tcp_socket name_bind;
}

#============= httpd_t ==============

#!!!! This avc can be allowed using the boolean 'nis_enabled'
allow httpd_t unreserved_port_t:tcp_socket name_bind;
```

```sh
semodule -i nginx.pp
```

```sh
[root@selinux-server vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2022-10-30 14:28:47 UTC; 11s ago
  Process: 7898 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 7896 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 7894 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 7899 (nginx)
    Tasks: 3 (limit: 12403)
   Memory: 5.0M
   CGroup: /system.slice/nginx.service
           ├─7899 nginx: master process /usr/sbin/nginx
           ├─7900 nginx: worker process
           └─7901 nginx: worker process

Oct 30 14:28:47 selinux-server systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 30 14:28:47 selinux-server nginx[7896]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 30 14:28:47 selinux-server nginx[7896]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 30 14:28:47 selinux-server systemd[1]: Started The nginx HTTP and reverse proxy server.
```

![Решение 3](pict\3.png)