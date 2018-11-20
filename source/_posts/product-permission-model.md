---
layout: post
title: 商品规则权限数据库设计
tags: 
  - Develop
  - Mysql
excerpt: coming soon...
date: 2018-11-20 15:54:14
---

# 商品规则权限数据库设计

## 商品表 products

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | product_id |
| category_id | int64 | 商品分类 |
| title | string | 名称 |

## 商品规格 product_sku

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | sku_id |
| category_id | int64 | 商品分类 |
| product_id | int64 | 商品ID |
| title | string | 规格名称 |
| price | int | 价格 |
| value_unit | int | 权限单位: 个， 年，月，日 |
| value_number | int | 对应单位数量值 |

## 商品规格优惠 product_sku_discuss

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | id |
| sku_id | int64 | sku_id |
| disscuss_id | int64 | disscuss_id |
| start_time | datetime | 开始时间 |
| end_time | datetime | 结束时间 |
| sort | int | 排序，多次规则优先级别 |
| status | int | 是否应用 |

## 商品优惠规则 product_disscuss

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | sku_id |
| title | string | 名称 |
| user_type | int | 适用用户类型 |
| disscuss_type | int | 优惠类型：百分比打折，立减 |
| disscuss_value | int | 类型对应优惠数值 |
| intro | string | 简介 |
| status | int | 是否应用 |

## 商品资源 product_resource

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | sku_id |
| category_id | int64 | 商品分类 |
| product_id | int64 | 商品ID |
| res_name | string | 资源名称,可用表名存储 |
| res_id | int64 | 对应资源ID |

## 资源权限 user_permissions

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | sku_id |
| uid | int64 | 用户ID |
| category_id | int64 | 商品分类 |
| res_name | string | 资源名称,可用表名存储 |
| res_id | int64 | 对应资源ID |
| expire | int64 | 权限到期时间 |
| role | int | 权限角色：试用,购买，管理员，所有者 |

## 资源权限 user_permission_logs

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | sku_id |
| uid | int64 | 用户ID |
| order_id | string | 订单ID |
| category_id | int64 | 商品分类 |
| res_name | string | 资源名称,可用表名存储 |
| res_id | int64 | 对应资源ID |
| expire_old | int64 | 旧权限 |
| expire_new | int64 | 新权限 |
| expire_add | int64 | 添加的数量：expire_old - expire_new |
| rollback_do | int | 是否回退权限 |
| rollback_val | int64 | 回退值 |
| rollback_time | datetime | 回退时间 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |


## 订单 orders

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int64 | sku_id |
| pid | int64 | 订单的父级ID，如果非0，说明是拆分的子订单|
| uid | int64 | 用户ID |
| category_id | int64 | 商品分类 |
| product_id | int64 | 商品ID |
| product_title | string | 商品名称（冗余） |
| sku_id | int64 | sku_id |
| sku_title | string | 规格名称（冗余） |
| sku_price | int | 价格（冗余） |
| sku_value_unit | int | 权限单位: 个， 年，月，日（冗余） |
| sku_value_number | int | 对应单位数量值（冗余） |
| number | int | 购买数量 |
| amount_should_pay | int | 应付金额 |
| amount_real_pay | int | 实付金额 |
| amount_discuss | int | 优惠金额 |
| discuss_info | string | 优惠信息:json（可另外关联扩展）|
| payment_status | int | 支付状态 |
| payment_id | string | 支付平台ID |
| payment_platform | string | 支付平台 |
| payment_time | datetime | 支付时间 |
| refund_amount | int | 退款金额 |
| refund_time | datetime | 退款时间 |
| shipment_status | int | 发货状态 |
| shipment_id | string | 发货平台ID |
| shipment_platform | string | 发货平台 |
| shipment_time | datetime | 发货时间 |
| origin | string | 订单来源 |
| status | int | 订单状态 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

## 使用流程

### 1、创建商品、商品规格

### 2、显示商品sku

### 3、用户创建订单、支付

### 4、支付回调、更新订单状态

### 5、添加权限
