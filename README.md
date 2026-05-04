# 记账本应用

一款基于Flutter开发的跨平台记账应用，支持Windows、iOS和Android平台。

## 项目概述

核心目标：简洁、高效、无广告，专注于快速记账和数据可视化。

## 技术栈

- **框架**：Flutter 最新稳定版
- **状态管理**：Riverpod
- **本地数据库**：Isar
- **图表库**：fl_chart
- **路由管理**：go_router
- **其他依赖**：
  - flutter_secure_storage（本地加密存储）
  - local_auth（生物识别）
  - image_picker（图片选择）
  - path_provider（路径管理）

## 核心功能

### 1. 记账功能
- 支持「收入」/「支出」切换，默认选中「支出」
- 预设常用分类（餐饮、交通、购物、工资等），支持用户自定义添加/删除分类
- 金额输入框支持小数点，自动记录当前时间（允许用户修改日期）
- 可选添加备注、拍照（或从相册选择）关联账单

### 2. 多账本功能
- 支持添加多个账户（现金、银行卡、信用卡、支付宝等），设置初始余额
- 记账时选择对应账户，自动更新账户余额

### 3. 账单列表
- 按日期倒序展示，支持按「周/月/年」筛选，支持按分类/金额范围搜索
- 左滑删除账单，右滑编辑账单，删除前需二次确认

### 4. 数据统计
- 饼图展示「支出分类占比」，折线图展示「收支趋势」（支持切换周/月/年视图）
- 显示本月总收支、结余，及各分类的 Top3 支出

### 5. 预算功能
- 支持设置月度总预算，及各分类预算
- 超支时在首页显示红色提醒

### 6. 数据安全
- 本地数据加密存储，支持开启指纹/面容锁
- 支持数据导出为 CSV 文件，可选云端备份（预留接口）

## 项目结构

```
tntcost/
├── lib/
│   ├── models/         # 数据模型
│   │   ├── transaction.dart    # 交易模型
│   │   ├── category.dart       # 分类模型
│   │   ├── account.dart        # 账户模型
│   │   └── budget.dart         # 预算模型
│   ├── views/          # 视图
│   │   ├── main_page.dart          # 主页面（包含底部导航）
│   │   ├── add_transaction_page.dart  # 记账页面
│   │   ├── transaction_list_page.dart  # 账单列表页面
│   │   ├── stats_page.dart        # 数据统计页面
│   │   ├── account_page.dart      # 账户管理页面
│   │   └── login_page.dart        # 登录页面（指纹/面容锁）
│   ├── view_models/    # 视图模型
│   │   ├── transaction_view_model.dart  # 交易相关状态管理
│   │   └── stats_view_model.dart        # 统计相关状态管理
│   ├── services/       # 服务
│   │   ├── database_service.dart  # 数据库服务
│   │   └── security_service.dart  # 安全服务
│   ├── utils/          # 工具类
│   │   ├── date_utils.dart     # 日期工具
│   │   ├── money_utils.dart    # 金额工具
│   │   └── theme_utils.dart    # 主题工具
│   └── main.dart       # 应用入口
├── pubspec.yaml        # 依赖配置
└── README.md           # 项目说明
```

## 运行步骤

1. **确保安装了Flutter开发环境**
   - 参考 [Flutter官方文档](https://flutter.dev/docs/get-started/install) 安装Flutter
   - 运行 `flutter doctor` 确保环境配置正确

2. **克隆项目**
   ```bash
   git clone <项目地址>
   cd tntcost
   ```

3. **安装依赖**
   ```bash
   flutter pub get
   ```

4. **生成代码**
   ```bash
   flutter pub run build_runner build
   ```

5. **运行项目**
   - Android: `flutter run -d android`
   - iOS: `flutter run -d ios`
   - Windows: `flutter run -d windows`

## 功能使用说明

### 1. 记账
- 点击首页底部的「+」按钮，进入记账页面
- 选择「收入」或「支出」
- 输入金额，选择分类和账户
- 可选添加备注和图片
- 点击「保存」完成记账

### 2. 查看账单
- 点击底部导航栏的「账单」选项
- 选择「周」、「月」、「年」查看不同时间范围的账单
- 左滑账单项删除，右滑编辑

### 3. 查看统计
- 点击底部导航栏的「统计」选项
- 查看收支概览、支出分类占比和收支趋势
- 选择不同时间范围查看统计数据

### 4. 管理账户
- 点击底部导航栏的「账户」选项
- 点击「+」按钮添加新账户
- 点击账户项进行编辑或删除

### 5. 数据安全
- 首次启动应用时，会提示设置指纹/面容锁
- 在设置中可以开启或关闭生物识别功能

## 注意事项

1. **权限要求**
   - Android: 需要相机和存储权限（用于拍照和选择图片）
   - iOS: 需要相机和相册权限（用于拍照和选择图片）

2. **数据存储**
   - 数据存储在本地数据库中，建议定期备份
   - 支持导出数据为CSV文件

3. **性能优化**
   - 对于大量交易数据，可能会出现加载缓慢的情况
   - 建议定期清理不需要的交易记录

4. **跨平台注意事项**
   - Windows平台可能需要额外的依赖安装
   - iOS平台需要在Info.plist中添加相应的权限配置

## 后续计划

- 实现数据云备份功能
- 添加更多图表类型和数据可视化效果
- 优化应用性能和用户体验
- 增加更多个性化设置选项