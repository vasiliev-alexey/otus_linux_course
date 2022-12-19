# LDAP

Описание/Пошаговая инструкция выполнения домашнего задания:

 *   Установить FreeIPA;
  *  Написать Ansible playbook для конфигурации клиента;

---

### Решение

1. Создаем [инфраструктуру](Vagrantfile)
2. Поднимаем созданные машины
    ```sh
    vagrant up 
    ```

3. Дожидаемся установки. Лог установки на сервере можно отслеживать

```sh
 tail -f /var/log/ipaserver-install.log
```

<details> 
<summary>4. Проверяем создавая доменного пользователя</summary>




```sh
vssh ldap-client
```

```sh
[vagrant@ipaclient ~]$ kinit admin
Password for admin@HW25.OTUS: 
[vagrant@ipaclient ~]$ ipa user-find --all
--------------
1 user matched
--------------
  dn: uid=admin,cn=users,cn=accounts,dc=hw25,dc=otus
  User login: admin
  Last name: Administrator
  Full name: Administrator
  Home directory: /home/admin
  GECOS: Administrator
  Login shell: /bin/bash
  Principal alias: admin@HW25.OTUS, root@HW25.OTUS
  User password expiration: 20230315155809Z
  UID: 493600000
  GID: 493600000
  Account disabled: False
  Preserved user: False
  Member of groups: admins, trust admins
  ipantsecurityidentifier: S-1-5-21-776207539-3480502578-4039568825-500
  ipauniqueid: 974522c8-7c90-11ed-939c-080027faa9b5
  krbextradata: AAIRRJtjcm9vdC9hZG1pbkBIVzI1Lk9UVVMA
  krblastadminunlock: 20221215155809Z
  krblastpwdchange: 20221215155809Z
  objectclass: top, person, posixaccount, krbprincipalaux, krbticketpolicyaux, inetuser, ipaobject, ipasshuser, ipaSshGroupOfPubKeys, ipaNTUserAttrs
----------------------------
Number of entries returned 1
----------------------------
[vagrant@ipaclient ~]$ 
[vagrant@ipaclient ~]$ 
[vagrant@ipaclient ~]$ 
[vagrant@ipaclient ~]$ ipa user-add kmibey --first=Kip --last=Mibey --password
Password: 
Enter Password again to verify: 
-------------------
Added user "kmibey"
-------------------
  User login: kmibey
  First name: Kip
  Last name: Mibey
  Full name: Kip Mibey
  Display name: Kip Mibey
  Initials: KM
  Home directory: /home/kmibey
  GECOS: Kip Mibey
  Login shell: /bin/sh
  Principal name: kmibey@HW25.OTUS
  Principal alias: kmibey@HW25.OTUS
  User password expiration: 20221215160656Z
  Email address: kmibey@hw25.otus
  UID: 493600003
  GID: 493600003
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True
[vagrant@ipaclient ~]$ ipa user-find --all
---------------
2 users matched
---------------
  dn: uid=admin,cn=users,cn=accounts,dc=hw25,dc=otus
  User login: admin
  Last name: Administrator
  Full name: Administrator
  Home directory: /home/admin
  GECOS: Administrator
  Login shell: /bin/bash
  Principal alias: admin@HW25.OTUS, root@HW25.OTUS
  User password expiration: 20230315155809Z
  UID: 493600000
  GID: 493600000
  Account disabled: False
  Preserved user: False
  Member of groups: admins, trust admins
  ipantsecurityidentifier: S-1-5-21-776207539-3480502578-4039568825-500
  ipauniqueid: 974522c8-7c90-11ed-939c-080027faa9b5
  krbextradata: AAIRRJtjcm9vdC9hZG1pbkBIVzI1Lk9UVVMA
  krblastadminunlock: 20221215155809Z
  krblastpwdchange: 20221215155809Z
  objectclass: top, person, posixaccount, krbprincipalaux, krbticketpolicyaux, inetuser, ipaobject, ipasshuser, ipaSshGroupOfPubKeys, ipaNTUserAttrs

  dn: uid=kmibey,cn=users,cn=accounts,dc=hw25,dc=otus
  User login: kmibey
  First name: Kip
  Last name: Mibey
  Full name: Kip Mibey
  Display name: Kip Mibey
  Initials: KM
  Home directory: /home/kmibey
  GECOS: Kip Mibey
  Login shell: /bin/sh
  Principal name: kmibey@HW25.OTUS
  Principal alias: kmibey@HW25.OTUS
  User password expiration: 20221215160656Z
  Email address: kmibey@hw25.otus
  UID: 493600003
  GID: 493600003
  Account disabled: False
  Preserved user: False
  Member of groups: ipausers
  ipantsecurityidentifier: S-1-5-21-776207539-3480502578-4039568825-1003
  ipauniqueid: 802c24ae-7c92-11ed-94af-080027faa9b5
  krbextradata: AAIgRptjcm9vdC9hZG1pbkBIVzI1Lk9UVVMA
  krblastpwdchange: 20221215160656Z
  mepmanagedentry: cn=kmibey,cn=groups,cn=accounts,dc=hw25,dc=otus
  objectclass: top, person, organizationalperson, inetorgperson, inetuser, posixaccount, krbprincipalaux, krbticketpolicyaux, ipaobject, ipasshuser,
               ipaSshGroupOfPubKeys, mepOriginEntry, ipantuserattrs
----------------------------
Number of entries returned 2
----------------------------
[vagrant@ipaclient ~]$ 
```

![](pict/Screenshot%20from%202022-12-15%2019-09-09.png)
![](pict/Screenshot%20from%202022-12-15%2019-31-44.png)

</details> 


---
[установка-и-настройка-freeipa](https://itproblog.ru/%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-%D0%B8-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-freeipa/)  
[ Установка FreeIPA клиента и подключение к серверу ](https://docs.altlinux.org/ru-RU/archive/8.0/html/alt-server/ch45s03.html)