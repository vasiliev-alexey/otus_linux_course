# Домашнее задание

Роль для настройки веб сервера
Варианты стенда
* nginx + php-fpm (laravel/wordpress) + python (flask/django) + js(react/angular)
* nginx + java (tomcat/jetty/netty) + go + ruby
* можно свои комбинации

Реализации на выбор

- на хостовой системе через конфиги в /etc
- деплой через docker-compose

Для усложнения можно попросить проекты у коллег с курсов по разработке

К сдаче примается
* vagrant стэнд с проброшенными на локалхост портами
* каждый порт на свой сайт
* через нжинкс

## Решение

1. Создаем проект [игры тетрис с react + nginx](tetris/Dockerfile)
2. Создаем проект [имитации консоли с react + nginx](console/Dockerfile)
3. Создаем [docker-compose c reverse_proxy](./docker-compose.yaml)
4. Поднимаем инфраструктуру
    ```sh
    docker-compose up 
    ```

---
Проверяем:
1. Добавляем в /etc/hosts запись о нашем сервере
```sh
127.0.0.1  gameserver.local
```

2. Игра доступна [http://gameserver.local/tetris/](http://gameserver.local/tetris/)

![ss](./pict/Screenshot%20from%202022-12-23%2014-40-53.png)

3. Иммитация консоли  [ http://gameserver.local/console/](http://gameserver.local/console/)

![ss](./pict/Screenshot%20from%202022-12-23%2014-44-04.png)