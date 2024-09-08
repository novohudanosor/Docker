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
