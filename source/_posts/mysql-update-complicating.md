---
layout: post
title: 记一次Mysql并发更新处理
tags: 
  - Go
  - Mysql
  - Develop
excerpt: 记一次Mysql并发更新处理
date: 2018-11-19 16:26:45
---

# 记一次Mysql并发更新处理

大致流程：

 1. 查询

    1.1 无数据    INSERT INTO ON DUPLICATE KEY

    1.2 有数据

    1.2.1  未过期

        update set expire = date_add(expire,1年) where expire > 当前时间

    1.2.2  已过期

        update set expire = date_add(当前时间,1年) where expire < 当前时间

  2. 失败重试，一般只会出现 1.2.2失败的情况

```go

// UserPermissionsAdd 更新用户权限
func (s *Mysql) UserPermissionsAdd(ctx context.Context, in *proto.UserPermissionsAddArgs) (err error) {

  var (
    oldExpire int64

    info = &proto.UserPermissions{}
    now  = time.Now()
    db   = models.Model(ModelConfigName.Write)
  )

  // 查询是否已购买过
  if err := db.Where("uid = ? and category = ? and res_name = ? and res_id = ?", in.Uid, in.Category, in.ResName, in.ResId).First(info).Error; err != nil && err != gorm.ErrRecordNotFound {
    return err
  }

  // 事务开始
  tx := db.Begin()

  switch {

  case info.Id == 0: // 记录不存在的情况添加  set expire = now() + add_unix on duplicate key update expire = expire + add_unix

    oldExpire = now.Unix()

    err = tx.Exec("INSERT INTO user_permissions (uid,category,res_name,res_id,expire,role,created_at,updated_at) Values (?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE expire = expire + ?, updated_at = ?", in.Uid, in.Category, in.ResName, in.ResId, now.Unix()+in.AddUnix, in.Role, now.Format("2006-01-02 15:04:05"), now.Format("2006-01-02 15:04:05"), in.AddUnix, now.Format("2006-01-02 15:04:05")).Error

  case info.Id > 0 && info.Expire >= now.Unix(): // 未过期  set expire = expire + add_unix where expire > now()

    oldExpire = info.Expire

    err = tx.Where("uid = ? and category = ? and res_name = ? and res_id = ? and expire > ?", in.Uid, in.Category, in.ResName, in.ResId, now.Unix()).Update("expire", gorm.Expr("expire + ?", in.AddUnix)).Error

  case info.Id > 0 && info.Expire < now.Unix(): // 已过期  set expire = now + add_unix wherer expire < now()

    oldExpire = now.Unix()

    err = tx.Where("uid = ? and category = ? and res_name = ? and res_id = ? and expire < ?", in.Uid, in.Category, in.ResName, in.ResId, now.Unix()).Update("expire", now.Unix()+in.AddUnix).Error

  }

  if err != nil {
    tx.Rollback()
    return err
  }

  // 写入log
  logInfo := &proto.UserPermissionsLog{
    Uid:        in.Uid,
    Category:   in.Category,
    ResName:    in.ResName,
    ResId:      in.ResId,
    OldExpired: oldExpire,
    NewExpired: oldExpire + in.AddUnix, // 并发时不一定准，供参考
    AddUnix:    in.AddUnix,
    OrderId:    in.OrderId,
    Origin:     in.Origin,
    OriginId:   in.OriginId,
    CreatedAt:  now.Format("2006-01-02 15:04:05"),
    UpdatedAt:  now.Format("2006-01-02 15:04:05"),
  }

  // 添加log失败，说明已添加过这个order权限,回滚
  if err := tx.Create(logInfo).Error; err != nil {
    tx.Rollback()
    return err
  }

  if err := tx.Commit().Error; err != nil {
    return err
  }

  return nil
}
```