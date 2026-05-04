# 分类管理功能 - 实现计划

## [ ] Task 1: 更新Category模型支持二级分类
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 在Category模型中添加parentId字段，支持二级分类
  - 生成新的.g.dart文件
- **Acceptance Criteria Addressed**: AC-6
- **Test Requirements**:
  - `programmatic` TR-1.1: 数据库能正确存储带有parentId的分类
  - `programmatic` TR-1.2: 能正确查询一级分类和二级分类

## [ ] Task 2: 更新DatabaseService添加分类操作方法
- **Priority**: P0
- **Depends On**: Task 1
- **Description**: 
  - 添加updateCategory方法
  - 添加getSubCategories方法获取二级分类
  - 更新deleteCategory方法级联删除子分类
- **Acceptance Criteria Addressed**: AC-3, AC-4, AC-5, AC-6
- **Test Requirements**:
  - `programmatic` TR-2.1: updateCategory能正确更新分类信息
  - `programmatic` TR-2.2: getSubCategories能正确获取子分类列表
  - `programmatic` TR-2.3: deleteCategory能级联删除子分类

## [ ] Task 3: 添加fluent图标库依赖
- **Priority**: P0
- **Depends On**: None
- **Description**: 
  - 在pubspec.yaml中添加fluent_ui图标库依赖
  - 执行flutter pub get
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `programmatic` TR-3.1: 项目能正常编译

## [ ] Task 4: 创建图标选择器组件
- **Priority**: P0
- **Depends On**: Task 3
- **Description**: 
  - 创建IconPicker组件
  - 支持fluent3d和fluent mono两种风格切换
  - 显示图标网格供用户选择
- **Acceptance Criteria Addressed**: AC-7
- **Test Requirements**:
  - `human-judgment` TR-4.1: 图标选择器能正常显示图标
  - `human-judgment` TR-4.2: 能切换fluent3d和fluent mono风格

## [ ] Task 5: 创建分类管理页面
- **Priority**: P0
- **Depends On**: Task 2, Task 4
- **Description**: 
  - 创建CategoryManagementPage页面
  - 显示一级分类列表，支持展开显示二级分类
  - 添加添加/编辑/删除分类功能
- **Acceptance Criteria Addressed**: AC-2, AC-3, AC-4, AC-5, AC-6
- **Test Requirements**:
  - `human-judgment` TR-5.1: 能显示一级分类列表
  - `human-judgment` TR-5.2: 能添加新的一级分类
  - `human-judgment` TR-5.3: 能编辑现有分类
  - `human-judgment` TR-5.4: 能删除非默认分类
  - `human-judgment` TR-5.5: 能创建二级分类

## [ ] Task 6: 更新设置页面添加分类管理入口
- **Priority**: P1
- **Depends On**: Task 5
- **Description**: 
  - 在SettingsPage中添加分类管理入口卡片
  - 添加点击跳转到分类管理页面的功能
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `human-judgment` TR-6.1: 设置页面显示分类管理入口
  - `human-judgment` TR-6.2: 点击能跳转到分类管理页面

## [ ] Task 7: 更新路由配置
- **Priority**: P1
- **Depends On**: Task 5
- **Description**: 
  - 在main.dart的路由配置中添加分类管理页面路由
- **Acceptance Criteria Addressed**: AC-1
- **Test Requirements**:
  - `human-judgment` TR-7.1: 路由导航正常工作
