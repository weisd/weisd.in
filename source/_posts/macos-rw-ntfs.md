---
layout: post
title: MacOS原生读写NTFS
excerpt: 别下什么NTFS支持软件了，自己动手搞定NTFS读写
tags:
  - OS
  - MacOS

date: 2018-11-09 21:08:27
---

# MacOS原生读写NTFS

## 1. 插入U盘，查看挂载信息
  
  在terminal输入

  ```shell
    diskutil list
  ```

  输出例子

  ```shell
  /dev/disk0 (internal):
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      GUID_partition_scheme                         251.0 GB   disk0
    1:                        EFI EFI                     314.6 MB   disk0s1
    2:                 Apple_APFS Container disk1         250.7 GB   disk0s2

  /dev/disk2 (external, physical):
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:     FDisk_partition_scheme                        *64.2 GB    disk2
    1:               Windows_NTFS DEEPINOS                64.1 GB    disk2s1

  ```

  找到你的U盘， 记下他的名称，上面例子中的名称是DEEPINOS

## 2. 编辑/etc/fstab
  
  打开/etc/fstab, 写入**LABEL=DEEPINOS none ntfs rw,auto,nobrowse** ， 其中DEEPINOS就是上面记录的U盘的名称，替换成你自己的，把它写入的/etc/fstab文件中

  ```shell
  sudo vi /etc/fstab
  ```

## 3. 重新插入U盘

  重新拔插U盘

## 4. 打开U盘，写入吧

  好了， 打开/Volumes, 读写你的文件吧
  在终端输入

  ```shell
  open /Volumes
  ```