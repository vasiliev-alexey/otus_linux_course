# Настраиваем split-dns

### Описание / Пошаговая инструкция выполнения домашнего задания:

 *   взять стенд https://github.com/erlong15/vagrant-bind
 *   добавить еще один сервер client2
 *   завести в зоне dns.lab  имена
     *   web1 - смотрит на клиент1
     *   web2 смотрит на клиент2
 *   завести еще одну зону newdns.lab
 *   завести в ней запись
 *   www - смотрит на обоих клиентов
 *   настроить split-dns
 *   клиент1 - видит обе зоны, но в зоне dns.lab только web1
 *    клиент2 видит только dns.lab
 *   настроить все без выключения selinux

---
### Решение

1. Создаем [инфраструктуру](Vagrantfile)
2. Поднимаем созданные машины
    ```sh
    vagrant up --no-provision
    ```
3.  Устанваливаем [софт и конфигурируем](provisioning/playbook.yml)
    ```sh
    vagrant provision   --provision-with setup  
    ```

4.  Тестируем [созданную кофигурацию ](provisioning/test.yml)
    ```sh
    vagrant provision   --provision-with test  
    ```

<details> 
<summary>5. Результаты тестов</summary>

```Ruby

==> ns01: Running provisioner: test (ansible)...
    ns01: Running ansible-playbook...

PLAY [Otus ansible] ************************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************

==> ns02: Running provisioner: test (ansible)...
    ns02: Running ansible-playbook...

PLAY [Otus ansible] ************************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************

==> client: Running provisioner: test (ansible)...
    client: Running ansible-playbook...

PLAY [Otus ansible] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [provisioner info] ********************************************************
ok: [client] => {
    "msg": "Test task 23: client"
}

TASK [client ping to www.newdns.lab zone] **************************************
changed: [client]

TASK [client ping to web1.dns.lab zone] ****************************************
changed: [client]

TASK [client ping to web2.dns.lab zone] ****************************************
fatal: [client]: FAILED! => {"changed": true, "cmd": "ping -c 4 web2.dns.lab 2>&1", "delta": "0:00:00.004784", "end": "2022-12-03 08:52:56.214101", "msg": "non-zero return code", "rc": 2, "start": "2022-12-03 08:52:56.209317", "stderr": "", "stderr_lines": [], "stdout": "ping: web2.dns.lab: Name or service not known", "stdout_lines": ["ping: web2.dns.lab: Name or service not known"]}
...ignoring

TASK [client  show result of ping to www.newdns.lab zone] **********************
ok: [client] => {
    "msg": [
        "PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.",
        "64 bytes from client (192.168.50.15): icmp_seq=1 ttl=64 time=0.011 ms",
        "64 bytes from client (192.168.50.15): icmp_seq=2 ttl=64 time=0.026 ms",
        "64 bytes from client (192.168.50.15): icmp_seq=3 ttl=64 time=0.434 ms",
        "64 bytes from client (192.168.50.15): icmp_seq=4 ttl=64 time=0.028 ms",
        "",
        "--- www.newdns.lab ping statistics ---",
        "4 packets transmitted, 4 received, 0% packet loss, time 2999ms",
        "rtt min/avg/max/mdev = 0.011/0.124/0.434/0.179 ms"
    ]
}

TASK [c'client  show result of ping to web1.dns.lab zone'] *********************
ok: [client] => {
    "msg": [
        "PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.",
        "64 bytes from client (192.168.50.15): icmp_seq=1 ttl=64 time=0.010 ms",
        "64 bytes from client (192.168.50.15): icmp_seq=2 ttl=64 time=0.029 ms",
        "64 bytes from client (192.168.50.15): icmp_seq=3 ttl=64 time=0.030 ms",
        "64 bytes from client (192.168.50.15): icmp_seq=4 ttl=64 time=0.030 ms",
        "",
        "--- web1.dns.lab ping statistics ---",
        "4 packets transmitted, 4 received, 0% packet loss, time 3000ms",
        "rtt min/avg/max/mdev = 0.010/0.024/0.030/0.010 ms"
    ]
}

TASK [client  show result of ping to web2.dns.lab zone] ************************
ok: [client] => {
    "msg": [
        "ping: web2.dns.lab: Name or service not known"
    ]
}

PLAY RECAP *********************************************************************
client                     : ok=8    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   

==> client2: Running provisioner: test (ansible)...
    client2: Running ansible-playbook...

PLAY [Otus ansible] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [client2]

TASK [provisioner info] ********************************************************
ok: [client2] => {
    "msg": "Test task 23: client2"
}

TASK [client2 ping to www.newdns.lab zone] *************************************
fatal: [client2]: FAILED! => {"changed": true, "cmd": "ping -c 4 www.newdns.lab 2>&1", "delta": "0:00:00.006227", "end": "2022-12-03 08:52:59.758543", "msg": "non-zero return code", "rc": 2, "start": "2022-12-03 08:52:59.752316", "stderr": "", "stderr_lines": [], "stdout": "ping: www.newdns.lab: Name or service not known", "stdout_lines": ["ping: www.newdns.lab: Name or service not known"]}
...ignoring

TASK [client2 ping to web1.dns.lab zone] ***************************************
changed: [client2]

TASK [client2 ping to web2.dns.lab zone] ***************************************
changed: [client2]

TASK [client2  show result of ping to www.newdns.lab zone] *********************
ok: [client2] => {
    "msg": [
        "ping: www.newdns.lab: Name or service not known"
    ]
}

TASK [c'client2  show result of ping to web1.dns.lab zone'] ********************
ok: [client2] => {
    "msg": [
        "PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.",
        "64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=0.179 ms",
        "64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=2 ttl=64 time=0.264 ms",
        "64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=3 ttl=64 time=0.242 ms",
        "64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=4 ttl=64 time=0.244 ms",
        "",
        "--- web1.dns.lab ping statistics ---",
        "4 packets transmitted, 4 received, 0% packet loss, time 3001ms",
        "rtt min/avg/max/mdev = 0.179/0.232/0.264/0.033 ms"
    ]
}

TASK [client2  show result of ping to web2.dns.lab zone] ***********************
ok: [client2] => {
    "msg": [
        "PING web2.dns.lab (192.168.50.16) 56(84) bytes of data.",
        "64 bytes from client2 (192.168.50.16): icmp_seq=1 ttl=64 time=0.008 ms",
        "64 bytes from client2 (192.168.50.16): icmp_seq=2 ttl=64 time=0.028 ms",
        "64 bytes from client2 (192.168.50.16): icmp_seq=3 ttl=64 time=0.029 ms",
        "64 bytes from client2 (192.168.50.16): icmp_seq=4 ttl=64 time=0.028 ms",
        "",
        "--- web2.dns.lab ping statistics ---",
        "4 packets transmitted, 4 received, 0% packet loss, time 3000ms",
        "rtt min/avg/max/mdev = 0.008/0.023/0.029/0.009 ms"
    ]
}

PLAY RECAP *********************************************************************
client2                    : ok=8    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1   

```
Как и задумывалось 
* клиент1 - видит обе зоны, но в зоне dns.lab только web1
* клиент2 видит только dns.lab

</details> 
