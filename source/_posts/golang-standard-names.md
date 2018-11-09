---
layout: post
title: Go语言命名规范
tags: 
  - Develop
  - Go
excerpt: Go语言命名规范

date: 2018-11-10 05:27:51
---

# Go语言命名规范

## 什么是好的变量名？

- 一致（易于猜测）
- 简短（容易打字）
- 准确（易于理解）

## 经验总结

变量声明与其使用位置之间的距离越大， 名称就应该越长。

## 使用驼峰命令法MixedCase

不要使用下划线

首字母缩略词，应该全部使用大写，比如ServeHTTP、IDProcessor，ID,HTTP全大写

## 局部变量

保持简短，长名称容易模糊了代码的作用。

常见的变量/类型组合可以使用非常短的名称：

用 i 表示 index

用 r 表示 reader

用 b 表示 buffer

根据上下文，避免使用冗余名称：

在函数 RuneCount 内用 count 而不是 runeCount

用 ok 判断 Key 是否存在 Map 中

```go
v，ok：= m [k]
```

较长的名称可能有助于长函数或具有许多局部变量的函数。

（但这通常意味着你应该重构。）

一个不太好的例子：

```go
func RuneCount(buffer []byte) int {
    runeCount := 0
    for index := 0; index < len(buffer); {
        if buffer[index] < RuneSelf {
            index++
        } else {
            _, size := DecodeRune(buffer[index:])
            index += size
        }
        runeCount++
    }
    return runeCount
}
```

一个好例子：

```go
func RuneCount(b []byte) int {
    count := 0
    for i := 0; i < len(b); {
        if b[i] < RuneSelf {
            i++
        } else {
            _, n := DecodeRune(b[i:])
            i += n
        }
        count++
    }
    return count
}
```

## 参数

函数参数类似于局部变量， 但它们也可用作说明文档。

如果类型是描述性的，它们应该简短：

```go
func AfterFunc(d Duration, f func()) *Timer

func Escape(w io.Writer, s []byte)
```

例子中 Duration、 func()、Writer、[]byte 从字面就知道是什么类型，所以变量名使用简短的单个字母

如果类型更模糊，名称可能提供文档：

```go
func Unix(sec, nsec int64) Time

func HasPrefix(s, prefix []byte) bool
```

例子中 int64、 []byte 有两个相同类型参数，为了区别而使用较长单词起来说明的什么用

## 返回值

函数的返回值命令可作为文档帮助了解函数。

下面是一个很好的例子：

```go
func Copy(dst Writer, src Reader) (written int64, err error)

func ScanBytes(data []byte, atEOF bool) (advance int, token []byte, err error)
```

## 接收器 结构体 Receivers

接收者是一种特殊的参数。

按照惯例，它们是反映结构类型的一个或两个字符

```go
func (b *Buffer) Read(p []byte) (n int, err error)

func (sh serverHandler) ServeHTTP(rw ResponseWriter, req *Request)

func (r Rectangle) Size() Point
```

同一个结构体中的所有方法中Receivers变量名应该是一致的。 （不要一个方法用r,另一种方法用rdr）

## 导出的包级别名称

导出的名称不要包含所在的Package名。

在命名导出的变量，常量，函数和类型时请记住这一点。

这就是为什么我们用bytes.Buffer和strings.Reader， 而不用bytes.ByteBuffer和strings.StringReader

## 接口类型

仅有一个方法的接口通常在后面加“er”

```go
type Reader interface { 
    Read（p []byte）（n int, err error）
}
```

即使不是正确的英文单词也所谓

```go
type Execer interface { 
    Exec（query string, args []Value）（Result, error）
}
```

有时我们使用英文单词，让他看起来更好：

```go
type ByteReader interface {
    ReadByte() (c byte, err error)
}
```

当接口包括多个方法时，使用准确地描述其用途的名称（例如：net.Conn，http.ResponseWriter，io.ReadWriter）

## 错误类型

定义错误类型时应用使用以下形式FooError，以Error结尾：

```go
type ExitError struct {
    ...
}
```


字义错误值时应为以下形式ErrFoo，以Err开头：

```go
var ErrFormat = errors.New("image: unknown format")
```

## 包

使用让导入者更好解决整个包作用的名称，避开util，common等

## 导入路径

包路径的最后一个名称应该与包名相同

```go
"compress/gzip" // package gzip
```

避免重复意义的包路径：

```go
"code.google.com/p/goauth2/oauth2" // bad; my fault
```

对于库，它通常用于将包代码放在repo根目录中：

```go
"github.com/golang/oauth2" // package oauth2
```

还要避免使用大写字母（并非所有文件系统都区分大小写）

## 标准库

本文中的许多示例来自标准库。

标准库是查找优秀Go代码的好地方。

翻阅标准库来寻找灵感。

但要注意：

编写标准库时，我们还在学习。

其中大部分都是正确的，但也有一些错误。

## 结论

使用短名称。

考虑上下文。

用你的判断

## 原文

<https://talks.golang.org/2014/names.slide>