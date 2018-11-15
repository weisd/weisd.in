---
layout: post
title: 使用Syncthing在服务器间同步文件
tags: 
  - Ops
  - Go
  - Tools
excerpt: 使用Syncthing在服务器间同步文件
photos: [/images/syncthing.png]
date: 2018-11-15 15:18:06
---

# 使用Syncthing在服务器间同步文件

[Syncthing](https://github.com/syncthing/syncthing)是Golang开发的同步文件工具, 比起rsync来，操作实在是太简单了，还有GUI界面可以看到实时同步情况

![Syncting](/images/syncthing.png)

## 下载

从github上下载对应平台的文件

<https://github.com/syncthing/syncthing/releases>

## 安装

下载下来的就是二进制文件了，解压就行

## 运行

直接运行./syncthing, 会在用户目录下创建配置目录~/.config/syncthing

## GUI

默认开户GUI, 地址 127.0.0.1:8384, 默认绑定127.0.0.1地址，如果需要外部访问需要修改配置文件

**注意** 如果发现传输速度很慢，请关闭GUI!

```sh
vi ~/.config/syncthing/config.xml
```

127.0.0.1:8384 改为 0.0.0.0:8384

```xml
    <gui enabled="true" tls="false" debugging="false">
        <address>0.0.0.0:8384</address>
        ...
        <theme>default</theme>
    </gui>
```

## 添加同步文件路径

在GUI中添加同步文件夹，填写文件路径，文件ID，如果已添加设备，可选择把文件夹共享给哪个设置

**注意** 文件ID， 在所有同步设备中必需一致

## 添加设置

把另一个运行了Syncthing的设置添加进来

添加设备时需要设备ID， 在GUI右上操作->显示ID 可以查看

添加设备可选择共享哪些文件给该设备

## 防火墙

设备间通信需要开通端口：

TCP：22000 用于同步文件
UDP：21027 用于服务发现

## 官方文档

<https://docs.syncthing.net/>