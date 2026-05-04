# 分类管理功能 - 产品需求文档

## Overview
- **Summary**: 在设置页面增加分类管理功能，支持用户添加、修改、删除分类，支持创建二级分类，并可以为分类添加图标，图标支持fluent3d和fluent mono两种风格切换。
- **Purpose**: 提供灵活的分类管理能力，让用户可以自定义收支分类结构，满足个性化记账需求。
- **Target Users**: 所有记账本应用用户

## Goals
- 用户可以在设置页面访问分类管理功能
- 支持添加、修改、删除一级分类
- 支持创建二级分类（子分类）
- 支持为分类选择图标
- 支持fluent3d和fluent mono两种图标风格切换

## Non-Goals (Out of Scope)
- 不支持三级及以上分类
- 不支持分类排序功能
- 不支持分类导出/导入

## Background & Context
- 当前项目使用Flutter框架，Isar作为本地数据库
- 已有Category模型，包含id、name、icon、isDefault字段
- 使用Riverpod进行状态管理，GoRouter进行路由管理
- 需要添加fluent图标库支持

## Functional Requirements
- **FR-1**: 在设置页面添加分类管理入口
- **FR-2**: 分类管理页面显示所有一级分类列表
- **FR-3**: 支持添加新的一级分类（名称、图标）
- **FR-4**: 支持编辑现有一级分类（修改名称、图标）
- **FR-5**: 支持删除一级分类（非默认分类）
- **FR-6**: 支持为一级分类添加二级分类
- **FR-7**: 支持编辑、删除二级分类
- **FR-8**: 图标选择器支持fluent3d和fluent mono两种风格切换

## Non-Functional Requirements
- **NFR-1**: 分类管理页面响应式设计，适配不同屏幕尺寸
- **NFR-2**: 删除分类时需确认，防止误删
- **NFR-3**: 默认分类不可删除

## Constraints
- **Technical**: Flutter 3.11+, Isar数据库, Riverpod状态管理
- **Dependencies**: 需要添加fluent_ui图标库依赖

## Assumptions
- 用户了解分类的层级结构（一级和二级）
- 用户需要至少一个一级分类才能创建二级分类

## Acceptance Criteria

### AC-1: 设置页面显示分类管理入口
- **Given**: 用户进入设置页面
- **When**: 用户查看设置选项列表
- **Then**: 看到"分类管理"选项，点击可进入分类管理页面
- **Verification**: `human-judgment`

### AC-2: 分类管理页面显示一级分类列表
- **Given**: 用户进入分类管理页面
- **When**: 页面加载完成
- **Then**: 显示所有一级分类，每个分类显示图标和名称
- **Verification**: `human-judgment`

### AC-3: 添加一级分类
- **Given**: 用户在分类管理页面
- **When**: 点击添加按钮，输入名称并选择图标
- **Then**: 新分类被保存并显示在列表中
- **Verification**: `programmatic`

### AC-4: 编辑一级分类
- **Given**: 用户在分类管理页面
- **When**: 点击编辑按钮，修改名称或图标后保存
- **Then**: 分类信息被更新
- **Verification**: `programmatic`

### AC-5: 删除一级分类
- **Given**: 用户在分类管理页面，选择非默认分类
- **When**: 点击删除按钮并确认
- **Then**: 分类被删除，关联的二级分类也被删除
- **Verification**: `programmatic`

### AC-6: 创建二级分类
- **Given**: 用户在分类管理页面，选择一个一级分类
- **When**: 点击添加子分类，输入名称并选择图标
- **Then**: 二级分类被保存并显示在父分类下
- **Verification**: `programmatic`

### AC-7: 图标风格切换
- **Given**: 用户在图标选择器中
- **When**: 切换图标风格（fluent3d/fluent mono）
- **Then**: 图标列表更新为对应风格
- **Verification**: `human-judgment`

## Open Questions
- [ ] 是否需要支持分类排序功能？
- [ ] 是否需要限制二级分类的数量？
