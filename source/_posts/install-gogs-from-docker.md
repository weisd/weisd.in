---
layout: post
title: 在CentOS从Docker安装Gogs
tags: 
  - Docker
  - Gogs
excerpt: 在CentOS从Docker安装Gogs，关闭注册服务
# photos:
#   - my_photo_url
date: 2018-11-10 01:05:45
---

# 在CentOS从Docker安装Gogs

## 1. 安装

```shell
docker pull gogs/gogs
```

## 2. 启动

创建数据目录

```sh
mkdir -p /data/gogs
```

启动服务

```shell
docker run -d --name=gogs -p 10022:22 -p 10080:3000 -v /data/gogs:/data --restart=always gogs/gogs
```

## 添加Nginx代理

参考

[Nginx安装](../install-nginx)

## 访问安装

访问 http://git.weisd.in

注意改成你的域名

安装过程中的SSH端口，HTTP端口是Docker容器内的端口号，就是22和3000

## 3. 关闭注册功能

修改配置

```sh
vi /data/gogs/gogs/conf/app.ini
```

修改如下内容

```ini
[service]
DISABLE_REGISTRATION   = true
```

### 4. 重启服务

```sh
docker restart gogs
```

打开网站就看不到注册了
