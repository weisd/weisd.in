---
layout: post
title: 安装Nginx
tags: 
  - Nginx
  - CentOS
excerpt: 安装Nginx，配置代理
date: 2018-11-10 01:00:20
---

# 安装Nginx

## A

```sh
sudo yum install epel-release
```

## B

```sh
sudo yum install nginx
```

## C

```sh
sudo systemctl start nginx
```

## D

```sh
sudo systemctl enable nginx
```

## 代码配置参考

```sh
vi /etc/nginx/conf.d/proxy.conf
```

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

## 检查配置并重启

```sh
nginx -t && nginx -s reload
```