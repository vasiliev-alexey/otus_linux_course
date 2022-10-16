# Docker, docker-compose, dockerfile

Разобраться с основами docker, с образа, эко системой docker в целом.


1. [Установка  docker  на  ubuntu](https://docs.docker.com/engine/install/ubuntu/)

2. Загрузка  образа из dockerhub
```sh
 docker pull hello-world
```

```sh
Using default tag: latest
latest: Pulling from library/hello-world
Digest: sha256:62af9efd515a25f84961b70f973a798d2eca956b1b2b026d0a4a63a3b0b6a3f2
Status: Image is up to date for hello-world:latest
docker.io/library/hello-world:latest
```

3. Запуск образа 

```sh
 docker run hello-world
```

```sh
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```


4. Просмотр образов
```sh
docker images  
```

```sh
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
hello-world   latest    feb5d9fea6a5   12 months ago   13.3kB
```

5. Просмотр  запущенный контейнеров с историей
```sh
docker ps -a     
```

```
CONTAINER ID   IMAGE         COMMAND    CREATED         STATUS                     PORTS     NAMES
d9c1b6b65cb4   hello-world   "/hello"   2 minutes ago   Exited (0) 2 minutes ago             fervent_tu
b167ee7da45d   hello-world   "/hello"   3 minutes ago   Exited (0) 3 minutes ago             wonderful_ganguly
```


6. Запуск контейнера с пробросом порта

```sh
  docker run --name my-nginx -v $PWD:/usr/share/nginx/html:ro -d  -p 8080:80 nginx     
```

```
http://127.0.0.1:8080/
```

7. Подключение к контейнеру
```sh
docker  exec -it my-nginx sh 
```

```sh
ls /usr/share/nginx/html 
```

```sh
README.md  index.html
```
 
8. Останавливаем контейнер
```sh
 docker stop my-nginx     
```

 9. Уддаляем контейнер
```
 docker rm my-nginx      
```

```
my-nginx
```

10. Удаляем образ

 ```sh
 docker rmi nginx
 ```  
 ```sh
 Untagged: nginx:latest
Untagged: nginx@sha256:2f770d2fe27bc85f68fd7fe6a63900ef7076bc703022fe81b980377fe3d27b70
Deleted: sha256:51086ed63d8cba3a6a3d94ecd103e9638b4cb8533bb896caf2cda04fb79b862f
Deleted: sha256:c22f011a5c63a718e3155ef21b930f5583102384c8e333299913ed660baa230c
Deleted: sha256:1235ee8acd48a34c389280d8192ae79ef241d546eeea2f3416b64608d68d8538
Deleted: sha256:80ab7667b1007f2ed4b5387e7585e18d3ca1899c76449240e2890373a8e77285
Deleted: sha256:4833b18722fc3d06feafaa0f61726b1b11baa1daa0ea455e6e2ab66a7c8db283
Deleted: sha256:98b8d2ed046082a8f6c2fb2f34430f5142fea7a7078326d980b323d71640d8ff
Deleted: sha256:fe7b1e9bf7922fbc22281bcc6b4f5ac8f1a7b4278929880940978c42fc9d0229
```