---
layout: post
title: Go结合WaitGroup安全关闭程序
tags: 
  - Develop
  - Go
excerpt: Go结合WaitGroup安全关闭程序

date: 2018-11-14 22:08:27
---

Go程序在关闭程序前总有一些close操作要做，下面介绍一种使用WaitGroup优雅的关闭程序的方法

大致流程：

1. 服务通常有一个Run方法阻塞进程，一个Stop方法通知Run方法退出
2. 创建一个exit chan 作为通知goroutine退出的通道
3. 用os.Signal监听退出操作，关闭exitChan通知goroutine退出
4. goroutine中再启goroutine监听exitChan关闭自己的服务，非正常服务关闭则主动关闭exitChan通知其他goroutine退出
5. 使用WaitGroup等待所有服务goroutine退出

话不多说，直接上代码

WaitGruop封装

```go
// WaitGroupWrapper WaitGroupWrapper
type WaitGroupWrapper struct {
  sync.WaitGroup
}

// Wrap Wrap
func (w *WaitGroupWrapper) Wrap(fn func()) {
  w.Add(1)
  go func() {
    defer w.Done()
    fn()
  }()
}
```

main.go

```go

  // exit 一个chan 用户关闭程序时，通过goroutine退出
  exitChan := make(chan struct{})

  // c 监听signal，退出程序
  c := make(chan os.Signal, 1)
  signal.Notify(c, syscall.SIGHUP, syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT)
  go func() {
    for {
      s := <-c
      switch s {
        case syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT:
        // 收到退出signal是地关闭 exitChan
        close(exitChan)
        return
      case syscall.SIGHUP:
      default:
        return
      }
    }
  }()

  // 创建一个WaitGroup
  w := &WaitGroupWrapper{}

  // 一个goroutine启动echo
  w.Wrap(func() {
    e := echo.New()
    // Routes
    e.Static("/", conf.DataDir)

    go func() {
      select {
        // 监听exitChan, 退出执行echo.Shutdown
        case <-exitChan:
          ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
          defer cancel()
          e.Shutdown(ctx)
          return
      }
    }()
    // Start server

    if err := e.Start(conf.HTTP.Listen); err != nil {
      // 因为echo有可能启动失败，所以不是Shutdown通知的错误，主动关闭exitChan通知其他goroutine退出
      if err != http.ErrServerClosed {
        // 如果不是主动关闭，退出程序
        close(exitChan)
        return
      }
    }
  })

  // 一个goroutine启动cron
  w.Wrap(func() {
    cron := cron.New()
    cron.AddFunc(Conf.CronEntry, func() {
      if err := doSometing(); err != nil {
        log.Println(err)
      }
    })

    go func() {
      select {
      case <-exit:
        // Stop方法会通过cron退出
        cron.Stop()
        return
      }
    }()

    // Run会阻塞，没有错误返回值
    cron.Run()

    // 收到Stop通知后Run()退出
  })


  w.Wait()
```

例子中有两个服务goroutine， 一个echo httpserver, 一个cron定时任务

httpserver启动时可以出现错误，所以判断不是正常关闭则主动关闭exitChan

cron.Run没有错误，所以只监听exitChan退出就行了

http优雅重启参考之前的文章：[Go不中断程序优雅重启服务Grateful Shutdown](../golang-grateful-shutdown)
