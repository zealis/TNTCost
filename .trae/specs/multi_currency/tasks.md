# 多币种功能 - 实现计划（分解和优先级任务列表）

## [ ] 任务 1: 扩展账户模型，添加币种字段
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 在Account类中添加currency字段
  - 更新Account构造函数
  - 重新生成Isar数据库模型
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `programmatic` TR-1.1: 账户模型应包含currency字段
  - `programmatic` TR-1.2: 数据库迁移应成功
- **Notes**: 需要使用flutter pub run build_runner build重新生成模型

## [ ] 任务 2: 创建货币工具类，支持多币种
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 扩展MoneyUtils类，添加根据币种格式化的方法
  - 支持常见货币的符号和格式化规则
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `programmatic` TR-2.1: 能正确格式化不同币种的金额
  - `programmatic` TR-2.2: 能正确解析不同币种的金额
- **Notes**: 考虑使用intl包的NumberFormat.currency方法

## [ ] 任务 3: 添加设置界面，实现本币设置
- **Priority**: P1
- **Depends On**: 任务 2
- **Description**:
  - 创建设置页面
  - 添加本币选择功能
  - 实现本币设置的存储和读取
- **Acceptance Criteria Addressed**: AC-2
- **Test Requirements**:
  - `human-judgment` TR-3.1: 设置界面应包含本币设置选项
  - `programmatic` TR-3.2: 本币设置应能正确存储和读取
- **Notes**: 考虑使用SharedPreferences存储设置

## [ ] 任务 4: 修改账户添加/编辑界面，增加币种选择
- **Priority**: P0
- **Depends On**: 任务 1, 任务 2
- **Description**:
  - 在添加账户对话框中添加币种选择
  - 在编辑账户对话框中添加币种选择
  - 默认使用本币作为账户币种
- **Acceptance Criteria Addressed**: AC-3, AC-4
- **Test Requirements**:
  - `human-judgment` TR-4.1: 添加账户界面应包含币种选择
  - `human-judgment` TR-4.2: 编辑账户界面应包含币种选择
  - `programmatic` TR-4.3: 账户币种应能正确保存
- **Notes**: 币种选择应提供常用货币列表

## [ ] 任务 5: 修改交易添加界面，根据账户显示对应货币单位
- **Priority**: P0
- **Depends On**: 任务 1, 任务 2
- **Description**:
  - 修改AddTransactionPage，根据所选账户的币种显示对应货币单位
  - 动态更新金额输入框的前缀
- **Acceptance Criteria Addressed**: AC-5
- **Test Requirements**:
  - `human-judgment` TR-5.1: 选择不同币种的账户时，货币单位应相应变化
  - `programmatic` TR-5.2: 交易金额应正确关联账户币种
- **Notes**: 需要监听账户选择变化，实时更新货币单位

## [ ] 任务 6: 更新账户列表显示，包含币种信息
- **Priority**: P1
- **Depends On**: 任务 1, 任务 2
- **Description**:
  - 修改AccountPage，在账户列表中显示币种信息
  - 更新总余额计算逻辑（暂时只显示本币总余额）
- **Acceptance Criteria Addressed**: 无特定AC，但为用户体验优化
- **Test Requirements**:
  - `human-judgment` TR-6.1: 账户列表应显示币种信息
  - `human-judgment` TR-6.2: 总余额应正确显示
- **Notes**: 总余额计算暂时不考虑汇率转换

## [x] 任务 7: 测试和修复
- **Priority**: P1
- **Depends On**: 所有任务
- **Description**:
  - 测试所有功能的正常运行
  - 修复可能出现的问题
  - 确保向后兼容性
- **Acceptance Criteria Addressed**: 所有AC
- **Test Requirements**:
  - `programmatic` TR-7.1: 应用应能正常启动和运行
  - `human-judgment` TR-7.2: 所有功能应按预期工作
- **Notes**: 测试时应确保现有数据不受影响
- **Status**: 应用已成功启动，无编译错误