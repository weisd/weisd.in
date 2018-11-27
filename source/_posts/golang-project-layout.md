---
layout: post
title: Go项目目录结构
tags:
  - Go
  - Develop
excerpt: coming soon...
# photos:
#   - my_photo_url
date: 2018-11-09 16:36:41
---


## Go项目目录结构

### `/cmd`

main主程序所有目录.

该目录下的文件夹名称与你程序生成的可执行文件名称一致 (e.g., `/cmd/myapp`)。

不要放太多代码在程序目录，如果你觉得代码可以被其他项目引用，把它们放在 `/pkg` 目录，如果代码只是在本项目使用且不希望别人引用，则把它们放在 `/internal` 目录

该目录下的文件夹里通常只有一个少量代码的 `main` 函数，函数中调用 `/internal` and `/pkg` 的代码

### `/internal`

私有代码库，把你不想让别人引用的代码放这个目录下面

将您的实际应用程序代码放在 `/internal/app` 目录（例如 `/internal/app/myapp`）

把应用程序中用的共用代码库放在 `/internal/pkg` 目录（例如 `/internal/pkg/myprivlib`）。

### `/pkg`

可以由外部应用程序使用的库代码 例如 `/pkg/mypubliclib` 。其他项目可以引用这些库，所以要把代码放在这个目录之前，请三思


### `/vendor`

第三方依赖代码库，不要放自己的代码

## 服务应用程序目录

### `/api`

OpenAPI / Swagger规范，JSON模式文件，协议定义文件


## Web应用程序目录

### `/web`

如果是web程序，把静态文件目录，服务器端模板文件放这里

## 常用程序目录

### `/configs`

配置文件，或默认配置

Put your `confd` or `consul-template` template files here.

### `/init`

操作系统启动服务配置文件（systemd，upstart，sysv）或进程管理（runit，supervisord）配置文件

### `/scripts`

脚本执行各种构建，安装，分析等操作。

让根目录下的Makefile引用这个目录的文件，使Makefile尽可能的小

### `/build`

打外和持续集成。

 `/build/package` 


将您的云（AMI），容器（Docker），OS（deb，rpm，pkg）包配置和脚本放在/build/package目录中。

将CI（travis，circle，drone）配置和脚本放在/build/ci目录中。请注意，某些CI工具（例如，Travis CI）对其配置文件的位置非常挑剔。尝试将配置文件放在/build/ci将它们链接到CI工具所期望的位置的目录中（


### `/deployments`

IaaS，PaaS，系统和容器编排部署配置和模板（docker-compose，kubernetes / helm，mesos，terraform，bosh）。

### `/test`

其他外部测试应用和测试数据。您可以随意构建/test目录。对于更大的项目，有一个数据子目录是有意义的。例如，您可以拥有/test/data或者/test/testdata如果需要Go来忽略该目录中的内容。请注意，Go也会忽略以“。”开头的目录或文件。或“_”，因此您在命名测试数据目录方面具有更大的灵活性。

## Other Directories

### `/docs`

设计和用户文档（除了你的godoc生成的文档）

### `/tools`

该项目的支持工具。请注意，这些工具可以从/pkg和/internal目录中导入代码。


### `/examples`

应用程序和/或公共库的示例。

### `/third_party`

外部帮助工具，分叉代码和其他第三方实用程序（例如，Swagger UI）

### `/githooks`

Git钩子。

### `/assets`

与您的存储库一起使用的其他资产（图像，徽标等）。

### `/website`

如果您不使用Github页面，这是放置项目的网站数据的地方

## 你不应该有的目录

### `/src`

src 与 Gopath src同名，项目路径将如下所示：/some/path/to/workspace/src/your_project/src/your_code.go 非常丑陋


<https://github.com/golang-standards/project-layout>