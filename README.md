# Docker
Docker: основы работы с контейнеризацией 
## Практика с Docker
* Установить Docker на хост машину: https://docs.docker.com/engine/install/ubuntu/ и Docker Compose - как плагин или как отдельное приложение;
* Создать кастомный образ NGINX на базе дистрибутива Alpine. После запуска, NGINX должен отдавать кастомную страницу (достаточно изменить дефолтную страницу);
* Определить разницу между контейнером и образом. Вывод описать в домашнем задании.
* Подготовить ответ на вопрос о возможности сборки ядра в контейнере;
1. Установка Docker  и других компонентов. (https://docs.docker.com/engine/install/)
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
* To install the latest version, run:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
2. Создадим конфигурационные файлы для запуска кастомного образа NGINX:
``` mkdir /home/vagrant/docker && cd /home/vagrant/docker ```
* **default.conf**
```
server {
    listen       80;
    listen       [::]:80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
    
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
* **nginx.conf**
```
user  nginx;
worker_processes  auto;
         
error_log /var/log/nginx/error.log notice;
pid       /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {         
    include      /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    access_log  /var/log/nginx/access.log;
    
    sendfile    on;
    keepalive_timeout  65;
         
    include /etc/nginx/conf.d/*.conf;
}
```
* **index.html**
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to CUSTOM NGINX!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.
         
<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
* **Dockerfile**
```
FROM alpine:latest
RUN apk update && apk upgrade
RUN apk add nginx
RUN mkdir /etc/nginx/conf.d
COPY default.conf /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir /usr/share/nginx/html
COPY index.html  /usr/share/nginx/html/
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
```
* Подготовка кастомного образа nginx
```
docker build -t nginx-custom:v1 .
```
* Запуск контейнера nginx из образа nginx-custom:v1
```
docker run -d -p 8080:80 nginx-custom:v1
```
* Проверка работы Docker
```
root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker images
REPOSITORY     TAG       IMAGE ID       CREATED         SIZE
nginx-custom   v1        685770c8734b   2 hours ago     11.6MB

root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED       STATUS       PORTS                                     NAMES
40961acc9915   nginx-custom:v1   "/usr/sbin/nginx -g …"   2 hours ago   Up 2 hours   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   gifted_kilby

root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# ps afx | grep docker
 247400 pts/0    S+     0:00  |   |   \_ grep --color=auto docker
 107338 ?        Ssl    0:02 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
 211113 ?        Sl     0:00  \_ /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 8080 -container-ip 172.17.0.2 -container-port 80
 211137 ?        Sl     0:00  \_ /usr/bin/docker-proxy -proto tcp -host-ip :: -host-port 8080 -container-ip 172.17.0.2 -container-port 80


root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# curl http://localhost:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to CUSTOM NGINX!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
* Откроем адрес http://localhost:8080 в браузере:
![image](https://github.com/user-attachments/assets/790fd4a8-52e4-4d3f-b481-274ffbd4a87a)

* Запушим образ на docker hub:
```
root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker login -u novohudanosor
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credential-stores

Login Succeeded
```
```
root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED       STATUS       PORTS                                     NAMES
40961acc9915   nginx-custom:v1   "/usr/sbin/nginx -g …"   2 hours ago   Up 2 hours   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   gifted_kilby


root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker tag nginx-custom:v1 novohudanosor/nginx-custom_otus
root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker images
REPOSITORY                        TAG       IMAGE ID       CREATED         SIZE
novohudanosor/nginx-custom_otus   latest    685770c8734b   2 hours ago     11.6MB
nginx-custom                      v1        685770c8734b   2 hours ago     11.6MB
hello-world                       latest    d2c94e258dcb   16 months ago   13.3kB
root@dmikhaylov-Ubuntu2204:/home/vagrant/docker# docker push novohudanosor/nginx-custom_otus
Using default tag: latest
The push refers to repository [docker.io/novohudanosor/nginx-custom_otus]
96850e89f9fb: Pushed
dcb7da14f50c: Pushed
6c51810f472b: Pushed
8fdccaa54fa6: Pushed
6f87b32596d1: Pushed
b3be2ed4bb68: Pushed
9763605f37e0: Pushed
63ca1fbb43ae: Pushed
latest: digest: sha256:c97cceafc11a3c25588221578b169a55274d1fd3986ea623ec60ec3daabfda15 size: 1984

```
* https://hub.docker.com/repository/docker/novohudanosor/nginx-custom_otus/general   - запушили на docker hub

## Определение разницы между контейнером и образом.
* Образом в Docker называется исполняемый пакет, содержащий в себе всё необходимое для запуска приложения: непосредственно приложение, среда исполнения, библиотеки, переменные окружения, файлы конфигурации. Является шаблоном для создания контейнеров.
  Контейнером в Docker называется называется запущенный изолированный образ с возможностью временного хранения данных, которые уничтожаются после удаления контейнера.
  Говоря языком объектно-ориентированного программирования, образ - это класс, а контейнер - экземпляр этого класса (объект).

## Ответ на вопрос о возможности сборки ядра в контейнере.
*  Исходя из предназначения и логики работы контейнеров Docker, можно говорить, что при наличии в подготовленном образе компилятора с необходимой рабочей средой и исходных кодов ядра, компиляция ядра, в запущенном из этого образа контейнере, возможна.
