# Настраиваем центральный сервер для сбора логов


## Описание/Пошаговая инструкция выполнения домашнего задания:
1.  в вагранте поднимаем 2 машины web и log
2.  на web поднимаем nginx
3.    на log настраиваем центральный лог сервер на любой системе на выбор
        *  journald;
        *  rsyslog;
        * elk.
4.   настраиваем аудит, следящий за изменением конфигов нжинкса
       *  Все критичные логи с web должны собираться и локально и удаленно.
       *  Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
       *  Логи аудита должны также уходить на удаленную систему.
 
 Формат сдачи ДЗ - vagrant + ansible

---

## Решение
1. Создаем инфраструктуру [Vagrantfile](Vagrantfile)
2. Создаем [provisioner для web](./provisioners/playbook-web.yml)
3. Создаем [provisioner для log](./provisioners/playbook-log.yml)

4. Проверяем  результаты работы
```sh
   vagrant ssh log
```

```sh
[vagrant@localhost ~]$ curl  http://192.168.56.101:8080/err
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

[root@localhost vagrant]# ls -l  /var/log/rsyslog/web/nginx_*
-rw-------. 1 root root 1090 Oct 29 17:51 /var/log/rsyslog/web/nginx_access.log
-rw-------. 1 root root  974 Oct 29 17:51 /var/log/rsyslog/web/nginx_error.log

## Смотрим собираются ли логи  Nginx
[root@localhost vagrant]# more   /var/log/rsyslog/web/nginx_access.log 
Oct 29 16:49:03 web nginx_access: 10.0.2.2 - - [29/Oct/2022:16:49:03 +0000] "GET /err HTTP/1.1" 404 3798 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:106.0) Gecko/20100101 Firefox/106.0"
Oct 29 16:49:03 web nginx_access: 10.0.2.2 - - [29/Oct/2022:16:49:03 +0000] "GET /nginx-logo.png HTTP/1.1" 200 368 "http://localhost:8080/err" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:106.0) Gecko/20100101 Firefox/106.0"
Oct 29 16:49:03 web nginx_access: 10.0.2.2 - - [29/Oct/2022:16:49:03 +0000] "GET /poweredby.png HTTP/1.1" 200 4194 "http://localhost:8080/err" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:106.0) Gecko/20100101 Firefox/106.0"
Oct 29 16:50:53 web nginx_access: 10.0.2.2 - - [29/Oct/2022:16:50:53 +0000] "GET /err222 HTTP/1.1" 404 3798 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:106.0) Gecko/20100101 Firefox/106.0"
Oct 29 16:53:22 web nginx_access: 192.168.56.102 - - [29/Oct/2022:16:53:22 +0000] "GET /test HTTP/1.1" 404 3798 "-" "curl/7.61.1"
Oct 29 17:51:48 web nginx_access: 192.168.56.102 - - [29/Oct/2022:17:51:48 +0000] "GET /err HTTP/1.1" 404 3798 "-" "curl/7.61.1"

## Смотрим собираются ли логи ошибок Nginx
[root@localhost vagrant]# more   /var/log/rsyslog/web/nginx_error.log 
Oct 29 16:49:03 web nginx_error: 2022/10/29 16:49:03 [error] 7365#0: *1 open() "/usr/share/nginx/html/err" failed (2: No such file or directory), client: 10.0.2.2, server: localhost, request: "GET /err HTTP/1.1", host: "localhost:8080"
Oct 29 16:50:53 web nginx_error: 2022/10/29 16:50:53 [error] 7365#0: *3 open() "/usr/share/nginx/html/err222" failed (2: No such file or directory), client: 10.0.2.2, server: localhost, request: "GET /err222 HTTP/1.1", host: "localhost:8080"
Oct 29 16:53:22 web nginx_error: 2022/10/29 16:53:22 [error] 7365#0: *4 open() "/usr/share/nginx/html/test" failed (2: No such file or directory), client: 192.168.56.102, server: localhost, request: "GET /test HTTP/1.1", host: "192.168.56.101:8080"
Oct 29 17:51:48 web nginx_error: 2022/10/29 17:51:48 [error] 7365#0: *5 open() "/usr/share/nginx/html/err" failed (2: No such file or directory), client: 192.168.56.102, server: localhost, request: "GET /err HTTP/1.1", host: "192.168.56.101:8080"


## Смотрим собираются ли логи аудита для хоста WEB
[root@localhost vagrant]# less   /var/log/audit/audit.log 

node=web type=USER_END msg=audit(1667066122.455:4205): pid=7550 uid=0 auid=1000 ses=7 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1000 exe="/usr/sbin/sshd" hostname=? addr=10.0.2.2 terminal=ssh res=success'
node=web type=USER_LOGOUT msg=audit(1667066122.455:4206): pid=7550 uid=0 auid=1000 ses=7 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1000 exe="/usr/sbin/sshd" hostname=? addr=10.0.2.2 terminal=ssh res=success'
type=USER_LOGIN msg=audit(1667066122.459:3964): pid=6520 uid=0 auid=1000 ses=7 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1000 exe="/usr/sbin/sshd" hostname=? addr=10.0.2.2 terminal=ssh res=success'
type=USER_START msg=audit(1667066122.459:3965): pid=6520 uid=0 auid=1000 ses=7 subj=system_u:system_r:sshd_t:s0-s0:c0.c1023 msg='op=login id=1000 exe="/usr/sbin/sshd" hostname=? addr=10.0.2.2 terminal=ssh res=success'

```
