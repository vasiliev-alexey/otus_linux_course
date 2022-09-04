# Systemd

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.
4. ⭐ Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.

---

[Vagrantfile](Vagrantfile)

<details><summary>Сервис алертинга</summary>


1. Создаем файл конфигурации для демона и помещаем его в 
```ini
# Config file for custom watch service
# Put it into /etc/sysconfig

# File for watching and word for analize

KEYWORD="ALERT"
LOGFILE=/var/log/veryimportant.log
```

2. Создаем  скрипт с логикой сервиса
```sh
#!/bin/bash
KEYWORD=$1
LOGFILE=$2
DATE=`date`

if grep $KEYWORD $LOGFILE &> /dev/null
then
logger "$DATE: Alarm detected"
else
exit 0
fi
```

3. Создаем Unit file
```ini
[Unit]
Description=Alarm watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $KEYWORD $LOGFILE
```
4. Создаем Таймер
```ini
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target
```

5. Перезагружаем конфигурацию systemd и активируем таймер
```sh
sudo systemctl daemon-reload
sudo systemctl start watchlog
```

6. Проверяем резултаты работы
отправляем алерт   
```sh
[root@build-server vagrant]# echo ALERT /var/log/veryimportant.log
```
смотрим логи
```sh
sudo journalctl  -f 
```
результат
```ini
Aug 31 11:43:04 build-server root[7041]: Wed Aug 31 11:43:04 UTC 2022: Alarm detected
```
</details>

<details><summary>Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл </summary>

1. Устанавливаем spawn-fcgi и необходимые для него пакеты
```sh
sudo yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
```
2. Создаем юнитфайл
```ini
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
```
3. Перезагружаем конфигурацию systemd и активируем сервис

```sh
sudo systemctl daemon-reload
sudo systemctl start spawn-fcgi
sudo systemctl status spawn-fcgi
```

проверяем

```sh
    deamon-server: ● spawn-fcgi.service - Spawn-fcgi startup service by Otus
    deamon-server:    Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
    deamon-server:    Active: active (running) since Thu 2022-09-01 06:40:22 UTC; 53ms ago
    deamon-server:  Main PID: 23619 (php-cgi)
    deamon-server:     Tasks: 20 (limit: 24916)
    deamon-server:    Memory: 12.6M
    deamon-server:    CGroup: /system.slice/spawn-fcgi.service
    deamon-server:            ├─23619 /usr/bin/php-cgi
    ...
    deamon-server: Sep 01 06:40:22 deamon-server systemd[1]: Started Spawn-fcgi startup service by Otus.
```

</details>

 <details><summary>Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами</summary>
 1. Устанваливаем appach
 ```sh
 sudo yum install -y httpd
 ```
 
 2. Создаем 2 env для  наших сервисов
 ```sh
 sudo cat << EOF > /etc/sysconfig/httpd-1
OPTIONS=-f conf/httpd-1.conf
EOF

sudo cat << EOF > /etc/sysconfig/httpd-2
OPTIONS=-f conf/httpd-2.conf
EOF
 ```

 3. Создаем юнит
 ```sh
sudo cat << EOF > /etc/systemd/system/httpd@.service
[Unit]
Description=Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd \$OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd \$OPTIONS -k graceful
ExecStop=/bin/kill -WINCH {\$MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```

4. Копируем конфиг apache и модифицируем его для нескольких сервисов 
```sh
for i in 1 2; do cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-$i.conf && sed -i "s/logs\/error_log/logs\/error_log-$i/" /etc/httpd/conf/httpd-$i.conf  && sed -i "/ServerRoot \"\/etc\/httpd\"/a PidFile \/var\/run\/httpd-$i.pid" /etc/httpd/conf/httpd-$i.conf  && sed -i "s/Listen 80/Listen 808$i/g" /etc/httpd/conf/httpd-$i.conf ; done
```

5. Пеерезапускаем сервисы
``` sh
sudo systemctl daemon-reload && systemctl start httpd@1 && systemctl start httpd@2
```

6. Проверяем результат

``` bash
sudo ss -tulpen | grep httpd
```

```ini
[vagrant@deamon-server ~]$ sudo ss -tulpen | grep httpd
tcp   LISTEN 0      128                *:8081            *:*    users:(("httpd",pid=14354,fd=4),("httpd",pid=14353,fd=4),("httpd",pid=14352,fd=4),("httpd",pid=14314,fd=4)) ino:45559 sk:7 v6only:0 <->
tcp   LISTEN 0      128                *:8082            *:*    users:(("httpd",pid=14475,fd=4),("httpd",pid=14474,fd=4),("httpd",pid=14473,fd=4),("httpd",pid=14356,fd=4)) ino:45686 sk:8 v6only:0 <->

```

</details>

---
Как проверить

```sh
vagrant up --no-provision
vagrant provision --provision-with task1
vagrant provision --provision-with task2
vagrant provision --provision-with task3
```