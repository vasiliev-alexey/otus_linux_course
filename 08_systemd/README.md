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
```sh

```
3. Перезагружаем конфигурацию systemd и активируем сервис

```sh

```

</details>

 