# 交易分类显示问题修复计划

## 问题分析
当用户添加交易并选择分类后，在首页显示时仍然显示为"未分类"。经过代码分析，发现以下问题：

1. **模型定义问题**：在`transaction.dart`中，`category`和`account`字段被标记为`@ignore`，导致这些关联信息不会被Isar数据库持久化存储
2. **数据加载问题**：在`DatabaseService.getTransactions`方法中，没有加载关联的分类和账户信息

## 修复计划

### [ ] 任务1：修改Transaction模型，添加分类和账户的关联关系
- **Priority**：P0
- **Depends On**：None
- **Description**：
  - 修改`transaction.dart`文件，将`category`和`account`字段从`@ignore`改为使用Isar的关联关系
  - 添加对应的外键字段（categoryId和accountId）
  - 重新生成Isar模型代码
- **Success Criteria**：
  - Transaction模型能够正确存储和关联分类信息
- **Test Requirements**：
  - `programmatic` TR-1.1：重新生成的模型代码能够正常编译
  - `programmatic` TR-1.2：Transaction对象能够正确关联Category对象

### [ ] 任务2：修改DatabaseService，实现交易与分类的关联加载
- **Priority**：P0
- **Depends On**：任务1
- **Description**：
  - 修改`DatabaseService.getTransactions`方法，确保加载交易时同时加载关联的分类和账户信息
  - 修改`addTransaction`和`updateTransaction`方法，确保正确处理关联关系
- **Success Criteria**：
  - 加载交易时能够同时加载关联的分类和账户信息
- **Test Requirements**：
  - `programmatic` TR-2.1：调用getTransactions方法能够返回包含分类信息的交易列表
  - `programmatic` TR-2.2：添加交易后能够正确保存分类关联

### [ ] 任务3：测试修复效果
- **Priority**：P1
- **Depends On**：任务2
- **Description**：
  - 运行应用，添加一笔带有分类的交易
  - 检查首页是否正确显示交易的分类
  - 测试编辑交易时分类是否正确保存
- **Success Criteria**：
  - 首页能够正确显示交易的分类信息
  - 编辑交易时分类信息能够正确保存
- **Test Requirements**：
  - `human-judgement` TR-3.1：添加交易并选择分类后，首页显示正确的分类名称
  - `human-judgement` TR-3.2：编辑交易时分类信息能够正确显示和保存

## 预期结果
修复完成后，用户添加交易并选择分类时，在首页能够正确显示交易的分类信息，不再显示为"未分类"。