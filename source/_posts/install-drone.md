---
layout: post
title: 在CentOS上安装Drone1.0，使用Gogs
tags: Develop
excerpt: 在CentOS上安装Drone，使用Gogs
date: 2018-11-10 01:06:47
---

# 在CentOS上安装Drone，使用Gogs

## 安装Nginx,Docker,Gogs

参考

[Nginx安装](../install-nginx)

[Dcoker安装](../install-docker-on-centos7)

[Gogs安装](../install-gogs-from-docker)

## 安装Drone

```sh
docker pull drone/drone:1.0.0-rc.1
```

## 配置环境变量

```sh
vi ~/.dronerc
```

写入如下内容，注意改成你自己的域名

```ini
# gogs服务地址
export DRONE_GOGS_SERVER=http://git.weisd.in
# drone服务地址
export DRONE_SERVER_HOST=drone.weisd.in
export DRONE_SERVER_PROTO=http
```

把 .dronerc 文件加入 .bashrc 方便每次登陆shell使用

```sh
echo 'source ~/.dronerc' >> ~/.bashrc
```

加载配置，使配置生效

```sh
source ~/.bashrc
```

输入env就能看到添加的环境变量生效了

```sh
env
```

## 启动Drone

创建数据目录

```sh
mkdir -p /data/drone
```

启动服务

```sh
docker run \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --volume=/data/drone:/data \
  --env=DRONE_GIT_ALWAYS_AUTH=false \
  --env=DRONE_GOGS_SERVER=${DRONE_GOGS_SERVER} \
  --env=DRONE_RUNNER_CAPACITY=2 \
  --env=DRONE_SERVER_HOST=${DRONE_SERVER_HOST} \
  --env=DRONE_SERVER_PROTO=${DRONE_SERVER_PROTO} \
  --env=DRONE_TLS_AUTOCERT=false \
  --publish=10081:80 \
  --publish=10443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  drone/drone:1.0.0-rc.1
  ```

例子中使用端口10081，10443

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
server {
    listen       443;
    server_name drone.weisd.in;

    location / {
        proxy_pass http://localhost:10443;
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

https://docs.drone.io/intro/gogs/single-machine/