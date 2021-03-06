---
layout: post
title: Go不中断程序优雅重启服务Grateful Shutdown
tags: 
  - Develop
  - Go
excerpt: Go不中断程序优雅重启服务GratefulShutdown

date: 2018-11-11 10:15:25
---

# 优雅重启，不中断程序

Grateful Shutdown能正常关闭服务而不会中断任何活动的连接

通常做了以下几个事情

1. 记录所以连接的状态，接收request时，记录状态为active。 返回response后记录状态为idle

2. 程序退出时首先关闭所有打开的Listener，释放端口让给新程序使用

3. 关闭所有状态为idle的连接

4. 无限期地等待所有active连接状态变为idle，然后关闭之

5. 等待所有active连接状态变为idle，可以设置一个过期时间，过期时间到则强制关闭所有连接

## 实现

### 1、net/http 标准库 http.Shutdown Golang 1.8+版本支持

```go
var srv http.Server

idleConnsClosed := make(chan struct{})
go func() {
    sigint := make(chan os.Signal, 1)
    signal.Notify(sigint, os.Interrupt)
    <-sigint

    // We received an interrupt signal, shut down.
    if err := srv.Shutdown(context.Background()); err != nil {
        // Error from closing listeners, or context timeout:
        log.Printf("HTTP server Shutdown: %v", err)
    }
    close(idleConnsClosed)
}()

if err := srv.ListenAndServe(); err != http.ErrServerClosed {
    // Error starting or closing listener:
    log.Printf("HTTP server ListenAndServe: %v", err)
}

<-idleConnsClosed
```

### 2、 Facebook grace

<https://github.com/facebookgo/grace>

比标准库封装了重启支持，添加TCP支持

可以通过配置 PreStartProcess 实现一些重启初始化操作

### 3、github.com/tylerb/graceful

<https://github.com/tylerb/graceful>

## 总结

标准库已经实现优雅重启，就用标准库吧

注意!

使用一些监控进程工具时，重启程序时，要确认是否发送kill指标就算完成关闭，如果说要等进程完全关闭再重启的话可能会存在重启中间间隔服务没响应的情况

进阶：[Go结合WaitGroup安全关闭程序](../golang-gratefull-shutdown-with-waitgroup)