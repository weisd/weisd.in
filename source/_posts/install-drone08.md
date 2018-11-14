---
layout: post
title: 在CentOS上安装Drone0.8，使用Gogs
tags: 
  - Ops
  - Drone
excerpt: 在CentOS上安装Drone0.8，使用Gogs

date: 2018-11-14 22:49:06
---

# 在CentOS上安装Drone0.8，使用Gogs

本文是drone0.9版本安装，1.0版本参考：[在CentOS上安装Drone1.0，使用Gogs](../install-drone)

## 安装Nginx,Docker,Gogs

参考

[Nginx安装](../install-nginx)

[Dcoker安装](../install-docker-on-centos7)

[Gogs安装](../install-gogs-from-docker)

## docker安装drone0.8

```sh
docker pull drone/drone:0.8
```

## docker-compose

```yml
version: '2'

services:
  drone-server:
    image: drone/drone:0.8

    ports:
      - 10081:8000
      - 9000
    volumes:
      - /var/lib/drone:/var/lib/drone/
    restart: always
    environment:
      - DRONE_OPEN=true
      - DRONE_HOST=http://drone.weisd.in
      - DRONE_GOGS=true
      - DRONE_GOGS_URL=http://git.weisd.in
      - DRONE_SECRET=${DRONE_SECRET}

  drone-agent:
    image: drone/agent:0.8

    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SERVER=drone-server:9000
      - DRONE_SECRET=${DRONE_SECRET}
```

例子中 drone.weisd.in为drone的服务域名，git.weisd.in为gogs的服务域名，修改为你自己的

启动服务， 因为agent依赖server, 所以最好等server启动完成后再启动agent

```sh
docker-compose up -d drone-server
docker-compose up -d drone-agent
```

例子中使用端口10081

## 添加Nginx代理配置

```sh
vi /etc/nginx/conf.d/drone.conf
```

输入内容如下

```conf
server {
    listen       80;
    server_name drone.weisd.in;

    location / {
        proxy_pass http://localhost:10081;
        proxy_set_header Host $host:$server_port;
    }
}
```

重启Nginx

```sh
nginx -s reload
```

## 访问

http://drone.weisd.in

输入你Gogs的账号密码就可以登陆了

## 参考

官方文档

<https://0-8-0.docs.drone.io/install-for-gogs/>
