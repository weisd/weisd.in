---
layout: post
title: 使用Drone自动远程部署Go项目
tags: 
  - Ops
  - Go
  - Drone
excerpt: 使用Drone自动远程部署Go项目
date: 2018-11-14 23:53:27
---

# 使用Drone自动远程部署Go项目

本文使用Drone 0.8

## 开启项目Drone支持

首先在你的Drone的Account>Repositories中找到你要支持的git仓库，点击右则的开关开户Drone支持，开启后会在你的git仓库WebHooks中添加一个发往Drone服务器的配置，开户后记得去git仓库测试一下Webhook是否正常

## 在项目目录下创建.drone.yml配置文件

下面是一个远程发布Go项目的例子

```yml
workspace:
  base: /go

pipeline:
  build:
    image: golang
    commands:
      - echo $GOPATH
      - pwd
      - go build -o goexec_build_from_drone

  deploy:
    image: appleboy/drone-scp
    host: 172.17.0.1
    port: 22
    username: root
    secrets: [ ssh_key ]
    # key: [ ssh_key ]
    target: /data/ci/geekbang
    source: goexec_build_from_drone

  run:
    image: appleboy/drone-ssh
    host: 172.17.0.1
    port: 22
    username: root
    secrets: [ ssh_key ]
    script:
      - cd /data/ci/geekbang && git pull 
      - systemctl stop geekbang
      - mv -f /data/ci/geekbang/geek  /data/ci/geekbang/geek.bak
      - mv /data/ci/geekbang/geek_build_from_drone /data/ci/geekbang/geek
      - systemctl start geekbang
      - systemctl status geekbang

branches: master
```

例子中分三步:

1. build 编辑Go代码
2. deploy 把编译好的可执行文件scp到远程服务器
3. run 通过ssh执行远程命令更新服务

例子中使用的插件：
[SCP](http://plugins.drone.io/appleboy/drone-scp/)
[SSH](http://plugins.drone.io/appleboy/drone-ssh/)

## 安装Drone-cli

上面例子中，用到了secrets存储一些私密信息,需要使用drone-cli来管理secrets

下面是Linux系统安装方法

```sh
curl -L https://github.com/drone/drone-cli/releases/download/v0.8.6/drone_linux_amd64.tar.gz | tar zx
sudo install -t /usr/local/bin drone
```

其他平台参考：
<https://0-8-0.docs.drone.io/cli-installation/>

## 管理secrets

例子中使用ssh-key登记远程系统，下面方法通过文件添加ssh私钥，@后为文件绝对路径，--name的值为ssh插件指定的值，参考插件说明

```sh
 drone secret add --repository weisd/geek --name ssh_key --value @/root/.ssh/id_rsa
 ```

## 提交代码，查看Drone情况

git提交到远程服务器后，就可以看到Drone对应仓库有任务在处理了

## 更多命令官方文档

<https://0-8-0.docs.drone.io/getting-started/>