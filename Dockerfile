FROM alpine:latest
RUN apk update && apk upgrade
RUN apk add nginx
RUN mkdir /etc/nginx/conf.d
COPY default.conf /etc/nginx/conf.d/
COPY nginx.conf /etc/nginx/nginx.conf
RUN mkdir /usr/share/nginx/html
COPY index.html  /usr/share/nginx/html/
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
