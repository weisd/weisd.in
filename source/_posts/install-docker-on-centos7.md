---
layout: post
title: 在CentOS7上安装Docker
tags: 
  - OS
  - CentOS
  - Docker
excerpt: 在CentOS7上安装Docker
# photos:
#   - my_photo_url
date: 2018-11-10 01:01:10
---

# 在CentOS7上安装Docker

## 安装依赖

```sh
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```

## 安装仓库

```sh
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

## 安装Docker-CE

```sh
sudo yum -y install docker-ce
```

## 启动服务

```sh
sudo systemctl start docker
```

## 加入开机启动

```sh
sudo systemctl enable docker
```

## Test

```sh
sudo docker run hello-world
```

## 添加中国镜像加速

修改 /etc/docker/daemon.json 文件并添加上 registry-mirrors 键值。

```sh
vi /etc/docker/daemon.json
```

内容:

```json
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```

重启服务

```sh
sudo systemctl restart docker
```


### 官方文档

https://docs.docker.com/install/linux/docker-ce/centos/#install-docker-ce-1