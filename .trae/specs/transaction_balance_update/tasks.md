# 交易余额更新功能 - 实现计划

## [ ] 任务 1: 修改数据库服务的添加交易方法
- **Priority**: P0
- **Depends On**: None
- **Description**:
  - 修改 `DatabaseService.addTransaction` 方法，在添加交易的同时更新对应账户的余额
  - 收入交易增加账户余额，支出交易减少账户余额
  - 确保操作在同一事务中完成
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3, AC-4
- **Test Requirements**:
  - `programmatic` TR-1.1: 验证添加收入交易后账户余额正确增加
  - `programmatic` TR-1.2: 验证添加支出交易后账户余额正确减少
  - `programmatic` TR-1.3: 验证支出超过余额时账户余额变为负数
  - `programmatic` TR-1.4: 验证事务完整性（失败时数据不被修改）
- **Notes**: 需要先获取账户信息，然后根据交易类型更新余额

## [ ] 任务 2: 测试交易余额更新功能
- **Priority**: P1
- **Depends On**: 任务 1
- **Description**:
  - 编写测试用例验证余额更新功能
  - 测试不同场景：收入交易、支出交易、余额不足的支出交易
- **Acceptance Criteria Addressed**: AC-1, AC-2, AC-3
- **Test Requirements**:
  - `programmatic` TR-2.1: 运行测试用例，验证所有场景都通过
  - `human-judgement` TR-2.2: 手动测试添加交易的流程，确认界面操作正常
- **Notes**: 可以使用现有的测试框架或手动测试

## [ ] 任务 3: 验证现有功能不受影响
- **Priority**: P1
- **Depends On**: 任务 1
- **Description**:
  - 验证修改后其他功能是否正常工作
  - 检查交易列表、账户列表等页面是否正常显示
- **Acceptance Criteria Addressed**: None
- **Test Requirements**:
  - `human-judgement` TR-3.1: 验证交易列表页面显示正常
  - `human-judgement` TR-3.2: 验证账户页面显示正常
  - `human-judgement` TR-3.3: 验证其他功能模块正常运行
- **Notes**: 确保修改不会引入回归问题