---
layout: post
title: 支付成功异步添加权限，编写最终一致性SQL
tags: 
  - Develop
excerpt: 支付成功异步添加权限，编写最终一致性SQL
date: 2018-12-02 02:19:09
---

# 支付成功异步添加权限，编写最终一致性SQL

使用消息队列，如果更新失败，重新放回队列，编写最终一致性SQL，不管重复执行多疼SQL操作，结果都一样

## 添加权限消息队列处理

1. 查询用户旧权限
2. 更新权限
    1. 无记录：添加或更新
        ```sql
        INSERT INTO user_permissions (uid,expire) Values (?,?) ON DUPLICATE KEY UPDATE expire = expire + ?
        ```
    2. 有记录：权限旧权限更新 按旧权限日志更新，如果更新失败，回滚退出
        ```sql
        UPDATE user_permissions SET expire= <new_expire> WHERE uid = ? AND expire = <old_expire>
        ```
3. 记录权限添加日志 uid_order唯一，如果更新失败，回滚退出
    ```sql
    INSERT INTO user_permission_logs (uid,order_id,old_expire,new_expire)
    ```

4. 权限更新失败：消息重回队列
5. 更新成功：修改订单发货状态为已完成

## 退权限处理

1. 通过订单ID查询权限日志记录
    ```sql
    SELECT * FROM user_permission_logs WHERE uid = ? AND  order_id = ? AND is_rollback = 0
    ```
2. 查询不到日志记录说明已处理 rollback == 1, 退出，结束
3. 查询权限记录
    ```sql
    SELECT * FROM user_permissions WHERE uid = ?
    ```
4. 计算应退权限
5. 事务更新权限
    ```sql
    UPDATE user_permissions SET expire= <new_expire> WHERE uid = ? AND expire = <old_expire>
    ```
    ```sql
    UPDATE user_permission_logs SET is_rollback = 1 WHERE uid = ? AND order_id = ? AND is_rollback = 1
    ```
6. 更新成功，修改订单发货状态为已退货