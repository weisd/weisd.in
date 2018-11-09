---
layout: post
title: 用Travis自动发布hexo博客到Github
tags: 
  - Travis
  - Github
  - Hexo
excerpt: 用Travis自动发布hexo博客到Github
# photos:
#   - my_photo_url
date: 2018-11-10 00:22:39
---

# 用Travis自动部署

## 1. 在Github生成Travis访问Github的Token

Setting > Developer settings > Personal access tokens > Generate new token 

输入一个名称， 勾选 repo，拉到底部 点击 Generate token 按钮提交

全生成一个token, 把token复制到另个地方先存起来

## 2. 用Github账号在Travis登陆

访问 [https://travis-ci.org/](https://travis-ci.org/)

点击右上 Sign in with Github 用Github账号登陆

点击 My Repositories 右边 + 号 添加Github仓库

在仓库列表中，找到你要使用的仓库，点击右边状态按钮打开

点击使用仓库的Settings, 在 Environment Variables 标签下添加一个环境变量

名称为：GH_TOKEN

值就是上面一步生成的Token

点击右边Add添加

## 3. 在要使用的Github仓库目录下编写.travis.yml文件

以自动发布hexo生成Github Pages为例，文件内容如下

```yml
# 使用语言
language: node_js
# node版本
node_js: stable
# 设置只监听哪个分支
branches:
  only:
  - master
# 缓存，可以节省集成的时间，这里我用了yarn，如果不用可以删除
cache:
  npm: true
  directories:
    - node_modules
# tarvis生命周期执行顺序详见官网文档
before_install:
- git config --global user.name "<你的昵称>"
- git config --global user.email "<你的邮箱>"
- npm install -g hexo-cli
install:
- npm install
- npm install hexo-deployer-git --save
script:
- hexo clean
- hexo generate
after_success:
- sed -i "s/gh_token/${GH_TOKEN}/g" ./_config.yml
- hexo deploy
```

例子中使用sed命令替换hexo配置文件中的gh_token, hexo配置文件_config.yml 对应部署内容如下

```yml
deploy:
  type: git
  repo: https://gh_token@github.com/weisd/weisd.github.io.git
  branch: master
```

## 4. 更新Travis使用配置，参数官方文档

https://docs.travis-ci.com/