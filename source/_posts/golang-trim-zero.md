---
layout: post
title: Go去掉\u0000字符
tags: 
  - Develop
  - Go
excerpt: Go去掉\u0000字符

date: 2018-11-20 12:07:02
---

# Go去掉\u0000字符

有些json字符串会带有**\u0000**, 这个字符不是有效字符也不是标点
C++使用这个字符作为字符串结束符，遇到的时候最好去掉

Go代码如下：

```go
// TrimZero 去掉\u0000字符
func TrimZero(s string) string {
  str := make([]rune, 0, len(s))
  for _, v := range []rune(s) {
    if !unicode.IsLetter(v) && !unicode.IsDigit(v) {
      continue
    }

    str = append(str, v)
  }
  return string(str)
}
```