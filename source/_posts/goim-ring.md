---
layout: post
title: GoIM源码解读-使用Ring复用对象顺序读写
tags: 
  - Develop
  - Go
  - GoIM
excerpt: GoIM源码解读-使用Ring复用对象顺序读写
date: 2018-11-22 23:42:10
---

# GoIM中使用ring结构复用对象，顺序读写

ring结构 就是一个圆环，由一个定位读位置的游标和一个定位写位置的游标记录读写的位置，读、写游标初始值为0，写游标取出对象写入内容后游标前移+1，读游标永远落后于写游标，所以读游标就能读到上一个写游标位置写入的内容，如此反复达到复用对象顺序读写的目的

## 先看ring的实现代码：

```go

// Ring .
type Ring struct {
  rp   uint64 // 读位置
  num  uint64 // 总长度
  mask uint64 // 掩码-用于计数+1超出范围时重置
  // TODO split cacheline, many cpu cache line size is 64
  // pad [40]byte
  // write
  wp   uint64 // 写位置
  data []grpc.Proto // 对象数组 
}

// NewRing .
func NewRing(num int) *Ring {
  r := new(Ring)
  r.init(uint64(num))
  return r
}

// Init .
func (r *Ring) Init(num int) {
  r.init(uint64(num))
}

// 初始化对象数组长度为2的n次方
func (r *Ring) init(num uint64) {
  // 2^N
  if num&(num-1) != 0 {
    for num&(num-1) != 0 {
      num &= (num - 1)
    }
    num = num << 1
  }
  r.data = make([]grpc.Proto, num)
  r.num = num
  r.mask = r.num - 1
}

// Get 读写入的对象内容
func (r *Ring) Get() (proto *grpc.Proto, err error) {
  if r.rp == r.wp {
    return nil, errors.ErrRingEmpty
  }
  proto = &r.data[r.rp&r.mask]
  return
}

// GetAdv 读游标+1
func (r *Ring) GetAdv() {
  r.rp++
  if conf.Conf.Debug {
    log.Infof("ring rp: %d, idx: %d", r.rp, r.rp&r.mask)
  }
}

// Set 取待写入对象
func (r *Ring) Set() (proto *grpc.Proto, err error) {
  if r.wp-r.rp >= r.num {
    return nil, errors.ErrRingFull
  }
  proto = &r.data[r.wp&r.mask]
  return
}

// SetAdv 写游标+1
func (r *Ring) SetAdv() {
  r.wp++
  if conf.Conf.Debug {
    log.Infof("ring wp: %d, idx: %d", r.wp, r.wp&r.mask)
  }
}

// Reset 重置
func (r *Ring) Reset() {
  r.rp = 0
  r.wp = 0
  // prevent pad compiler optimization
  // r.pad = [40]byte{}
}
```

实现代码很简洁，下面看一下GoIM中的应用场景

## GoIM中的应用场景

GoIM为每一个连接创建一个Channel对象，创建时初始化ring长度

```go
type Channel struct {
  CliProto Ring
  signal   chan *grpc.Proto // 接收消息的chan
  // ...省略其它字段
}
```

下面代码以tcp连接为例，先贴一个效完整的代码，为了简洁我删去了部分无关代码，不影响阅读

ring使用说明在代码注释中

```go

// ServeTCP .
func (s *Server) ServeTCP(conn *net.TCPConn, rp, wp *bytes.Pool, tr *xtime.Timer) {
  var (
    ch      = NewChannel(s.c.ProtoSection.CliProto, s.c.ProtoSection.SvrProto)
    rr      = &ch.Reader
    wr      = &ch.Writer
  )

  // 1 取出一个待写入数据的对象，这时候写游标为0
  if p, err = ch.CliProto.Set(); err == nil {
    // 2 authTCP方法中从conn中读取用户信息写入p
    if ch.Mid, ch.Key, rid, ch.Platform, accepts, err = s.authTCP(rr, wr, p); err == nil {
      // 3 保存用户登陆信息...
    }
  }
  if err != nil {
    conn.Close()
    log.Errorf("key: %s handshake failed error(%v)", ch.Key, err)
    return
  }
  // 4 开户一个发送goroutine
  go s.dispatchTCP(conn, wr, wp, wb, ch)

  serverHeartbeat := s.RandServerHearbeat()
  for {
    // 5 取出一个待写入数据的对象，这时候写游标为0, 因为所用登陆验证的p不需要被其他地方读写所以上面读登陆验证完后被没有SetAdv(),这时游标还是0
    // 10 再取出一个待写入数据的对象, 这时候写游标为1
    // 21 再取出一个待写入数据的对象, 这时候写游标为2
    if p, err = ch.CliProto.Set(); err != nil {
      break
    }
    // 6 从conn中读取内容写入p，假设这时候取到消息A
    // 11 等待从conn中读取内容写入p, 这时写游标为1
    // 17 conn发来消息B， 写入p,这时写游标为+1
    // 27 等待从conn中读取内容写入p, 游标为上一次写入结束+1 ... 同17~26流程
    if err = p.ReadTCP(rr); err != nil {
      break
    }

    // 7 Operate处理p请求, 为修改p的内容作为发送内容
    // 18 同上
    if err = s.Operate(p, ch, b); err != nil {
      break
    }

    // 8 p写入结束 SetAdv 游标+1，下一次取待写入对象时就是1位置的对象
    // 19 同上
    ch.CliProto.SetAdv()
    // 9 写入grpc.ProtoReady到 ch.signal l通知消息写入完毕，可以下发
    // 20 同步上
    ch.Signal()

  }

  if err != nil && err != io.EOF && !strings.Contains(err.Error(), "closed") {
    log.Errorf("key: %s server tcp failed error(%v)", ch.Key, err)
  }
  conn.Close()
  ch.Close()
  if err = s.Disconnect(ch.Mid, ch.Key); err != nil {
    log.Error("key: %s operator do disconnect error(%v)", ch.Key, err)
  }
}

func (s *Server) dispatchTCP(conn *net.TCPConn, wr *bufio.Writer, wp *bytes.Pool, wb *bytes.Buffer, ch *Channel) {
  var (
    err    error
    online int32
  )

  for {
    // 12 从ch.signal中读取消息
    // 26 待等下一条下发消息。。。goto 27
    var p = ch.Ready()
    switch p {
    case grpc.ProtoReady: // 13 上面ch.Signal()发来的消息写入完毕通知, 22
      for {
        // 14 取读游标所在p, 这时读游标为0, 取到消息A的响应内容p
        // 23 取读游标所在p, 这时读游标为0, 取到消息B的响应内容p
        if p, err = ch.CliProto.Get(); err != nil {
          err = nil // must be empty error
          break
        }
        // 15 p内容写入conn下发给连接的客户端
        // 24 同上
        if err = p.WriteTCP(wr); err != nil {
          goto failed
        }
        p.Body = nil // avoid memory leak
        // 16 读游标+1 这时间标为1，下一次读取时就收到写入1的内容
        // 25 同上
        ch.CliProto.GetAdv()
      }
    default: // 其他情况，不是通过客户端conn发来的请求响应
      // server send
      if err = p.WriteTCP(wr); err != nil {
        goto failed
      }
    }
    // only hungry flush response
    if err = wr.Flush(); err != nil {
      break
    }
  }
failed:
  if err != nil {
    log.Errorf("key: %s dispatch tcp error(%v)", ch.Key, err)
  }
  conn.Close()
  wp.Put(wb)
}

```

总结：GoIM 用 ring + chan通知的方式，实现消息对象p复用，客户端请求顺序响应，控制内存占用，减少多次创建对象回收CG问题