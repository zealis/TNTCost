import 'package:flutter_test/flutter_test.dart';
import 'package:tntcost/services/database_service.dart';
import 'package:tntcost/models/account.dart';
import 'package:tntcost/models/transaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    // 初始化数据库
    await DatabaseService.initialize();
  });

  test('添加收入交易后账户余额应增加', () async {
    // 创建测试账户
    final account = Account(name: '测试账户', type: '现金', balance: 1000.0);
    await DatabaseService.addAccount(account);

    // 创建收入交易
    final transaction = Transaction(
      date: DateTime.now(),
      amount: 500.0,
      isIncome: true,
      account: account,
    );

    // 添加交易
    await DatabaseService.addTransaction(transaction);

    // 获取更新后的账户
    final updatedAccounts = await DatabaseService.getAccounts();
    final updatedAccount = updatedAccounts.firstWhere((acc) => acc.id == account.id);

    // 验证余额是否正确增加
    expect(updatedAccount.balance, 1500.0);
  });

  test('添加支出交易后账户余额应减少', () async {
    // 创建测试账户
    final account = Account(name: '测试账户2', type: '现金', balance: 1000.0);
    await DatabaseService.addAccount(account);

    // 创建支出交易
    final transaction = Transaction(
      date: DateTime.now(),
      amount: 300.0,
      isIncome: false,
      account: account,
    );

    // 添加交易
    await DatabaseService.addTransaction(transaction);

    // 获取更新后的账户
    final updatedAccounts = await DatabaseService.getAccounts();
    final updatedAccount = updatedAccounts.firstWhere((acc) => acc.id == account.id);

    // 验证余额是否正确减少
    expect(updatedAccount.balance, 700.0);
  });

  test('支出超过余额时账户余额应变为负数', () async {
    // 创建测试账户
    final account = Account(name: '测试账户3', type: '现金', balance: 200.0);
    await DatabaseService.addAccount(account);

    // 创建支出交易
    final transaction = Transaction(
      date: DateTime.now(),
      amount: 300.0,
      isIncome: false,
      account: account,
    );

    // 添加交易
    await DatabaseService.addTransaction(transaction);

    // 获取更新后的账户
    final updatedAccounts = await DatabaseService.getAccounts();
    final updatedAccount = updatedAccounts.firstWhere((acc) => acc.id == account.id);

    // 验证余额是否变为负数
    expect(updatedAccount.balance, -100.0);
  });
}
