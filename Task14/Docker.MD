## Lesson14 - Docker

<details>

### Задание
* Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx).  
* Определите разницу между контейнером и образом. Вывод опишите в домашнем задании.  
* Ответьте на вопрос: Можно ли в контейнере собрать ядро?  
* Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.  

### Полезные данные для работы:

Удаление контейнеров и имеджей:

```
docker rm -vf $(docker ps -a -q)
docker rmi -f $(docker images -a -q)
```
Более сложные примеры - https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes

Send a KILL signal to a container

```
 docker kill my_container
```

Подключиться внутрь контейнера:

```
docker exec -it alpcontainer sh
```

Инструкции Dockerfile:

<details>

| Инструкция | Описание |
|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| FROM | Задаёт базовый (родительский) образ. |
| LABEL | Описывает метаданные. Например — сведения о том, кто создал и поддерживает образ. |
| ENV | Устанавливает постоянные переменные среды. |
| RUN | Выполняет команду и создаёт слой образа. Используется для установки в контейнер пакетов. |
| COPY | Копирует в контейнер файлы и директории. |
| ADD | Копирует файлы и директории в контейнер, может распаковывать локальные .tar-файлы. |
| CMD | Описывает команду с аргументами, которую нужно выполнить когда контейнер будет запущен. Аргументы могут быть переопределены при запуске контейнера. В файле может присутствовать лишь одна инструкция CMD. |
| WORKDIR | Задаёт рабочую директорию для следующей инструкции. |
| ARG | Задаёт переменные для передачи Docker во время сборки образа. |
| ENTRYPOINT | Предоставляет команду с аргументами для вызова во время выполнения контейнера. Аргументы не переопределяются. |
| EXPOSE | Указывает на необходимость открыть порт. |
| VOLUME | Создаёт точку монтирования для работы с постоянным хранилищем. |

</details>








### Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx).  

Создаём Dockerfile на базе alpine и файлы для изменения конфига nginx.

```
FROM alpine:latest

RUN apk update && apk upgrade && apk add nginx && apk add bash



EXPOSE 80

COPY host/default.conf /etc/nginx/http.d/
COPY host/index.html /var/www/default/html/


CMD ["nginx", "-g", "daemon off;"]
```

cat Docker/host/index.html 
Otus Docker Lab!




Собираем образ:
```
docker build -t alpnginx .
Sending build context to Docker daemon  4.608kB
Step 1/6 : FROM alpine:latest
latest: Pulling from library/alpine
8921db27df28: Pull complete 
Digest: sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a
Status: Downloaded newer image for alpine:latest
 ---> 042a816809aa
Step 2/6 : RUN apk update && apk upgrade && apk add nginx && apk add bash
 ---> Running in 60cb745d6e9d
fetch https://dl-cdn.alpinelinux.org/alpine/v3.17/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.17/community/x86_64/APKINDEX.tar.gz
v3.17.1-113-g8adfed785b [https://dl-cdn.alpinelinux.org/alpine/v3.17/main]
v3.17.1-111-gd059a0bf3b [https://dl-cdn.alpinelinux.org/alpine/v3.17/community]
OK: 17813 distinct packages available
OK: 7 MiB in 15 packages
(1/2) Installing pcre (8.45-r2)
(2/2) Installing nginx (1.22.1-r0)
Executing nginx-1.22.1-r0.pre-install
Executing nginx-1.22.1-r0.post-install
Executing busybox-1.35.0-r29.trigger
OK: 9 MiB in 17 packages
(1/4) Installing ncurses-terminfo-base (6.3_p20221119-r0)
(2/4) Installing ncurses-libs (6.3_p20221119-r0)
(3/4) Installing readline (8.2.0-r0)
(4/4) Installing bash (5.2.15-r0)
Executing bash-5.2.15-r0.post-install
Executing busybox-1.35.0-r29.trigger
OK: 11 MiB in 21 packages
Removing intermediate container 60cb745d6e9d
 ---> b6f1debb4c7a
Step 3/6 : EXPOSE 80
 ---> Running in 7c7db2fa74d5
Removing intermediate container 7c7db2fa74d5
 ---> 218043f0447c
Step 4/6 : COPY host/default.conf /etc/nginx/http.d/
 ---> 2fef8d8a5cdd
Step 5/6 : COPY host/index.html /var/www/default/html/
 ---> 15dace252457
Step 6/6 : CMD ["nginx", "-g", "daemon off;"]
 ---> Running in 408da1a40376
Removing intermediate container 408da1a40376
 ---> 72e0c7fb1a28
Successfully built 72e0c7fb1a28
Successfully tagged alpnginx:latest
```

Смотрим что собралось:

```
docker images
REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
alpnginx     latest    72e0c7fb1a28   About a minute ago   13.3MB
alpine       latest    042a816809aa   12 days ago          7.05MB
```

Запускаем контейнер:
```
docker run -d --name alpcontainer -p 8081:80 alpnginx
b7a6ef46bd08b4bed5b3b34e4d19bda4dc9d437af8bc900a33aed56b5d51af93
```

Проверяем, что контейнер запустился:

```
docker ps
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS          PORTS                                   NAMES
b7a6ef46bd08   alpnginx   "nginx -g 'daemon of…"   47 seconds ago   Up 46 seconds   0.0.0.0:8081->80/tcp, :::8081->80/tcp   alpcontainer
```

Проверяем через localhost:
```
curl localhost:8081
Otus Docker Lab!

```

Проверяем через подключение в контейнер:

```
mity@ubuntu:~/Documents/OTUS_Linux_Prof/Lesson13/Docker$ docker exec -it alpcontainer sh
/ # cat /var/www/default/html/index.html 
Otus Docker Lab!
```


### Определите разницу между контейнером и образом. Вывод опишите в домашнем задании. 

Образ - шаблон приложения в режиме "только-чтение".  

Контейнер - запущенный образ приложения работающий в режиме "чтение-запись.


### Ответьте на вопрос: Можно ли в контейнере собрать ядро?  
Ядро собрать можно. Загрузиться нет, потому что контейнер использует ядро системы. 


### Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий. 

https://hub.docker.com/layers/porshe911/otus/alpnginxnew/images/sha256-a1f4c7d82b39604e1528a3e6f709bde34c5d8126b0a5f23e87d9a1c4b56e8f29?context=repo


</details>


