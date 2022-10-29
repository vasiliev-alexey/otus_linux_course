#  PAM

* Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
* ⭐ дать конкретному пользователю права работать с докером и возможность рестартить докер сервис 

---

##  Решение
1. Создаем [Vagrantfile](Vagrantfile)
2. Создаем [Playbook](playbook.yml)


## проверяем

1. Соединяемся  пользователем в группе admin
```bash
[vagrant@pam-server ~]$ ssh adminuser@localhost
adminuser@localhost's password: 
Last login: Sun Oct 23 09:08:57 2022 from ::1
```

2. Проверяем что в логе

```sh
sudo cat /var/log/secure 
```

```sh
Oct 23 09:12:05 localhost sshd[7273]: pam_succeed_if(sshd:account): requirement "user ingroup admin" was met by user "adminuser"
Oct 23 09:12:05 localhost sshd[7273]: Accepted password for adminuser from ::1 port 44064 ssh2
Oct 23 09:12:05 localhost systemd[7279]: pam_unix(systemd-user:session): session opened for user adminuser by (uid=0)
Oct 23 09:12:05 localhost sshd[7273]: pam_unix(sshd:session): session opened for user adminuser by (uid=0)

```
3. Соединяемся  пользователем  test  - не админ
```sh
[vagrant@pam-server ~]$ ssh test@localhost
test@localhost's password: 
Connection closed by ::1 port 22
```
4. Проверяем что в логе

```sh
sudo cat /var/log/secure 
```
```sh
ct 23 09:13:57 localhost sshd[7336]: pam_succeed_if(sshd:account): requirement "user ingroup admin" not met by user "test"
Oct 23 09:13:57 localhost sshd[7336]: pam_time(sshd:account): field too long - ignored
Oct 23 09:13:57 localhost sshd[7336]: Failed password for test from ::1 port 43132 ssh2
Oct 23 09:13:57 localhost sshd[7336]: fatal: Access denied for user test by PAM account configuration [preauth]
```

--- 
Как проверить

поднимаем  инраструктуру
```sh
vagrant up
```   