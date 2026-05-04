import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import '../utils/money_utils.dart';
import '../view_models/transaction_view_model.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  late Future<List<Account>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    _accountsFuture = DatabaseService.getAccounts();
  }

  void loadAccounts() {
    _accountsFuture = DatabaseService.getAccounts();
    setState(() {});
  }

  void _showEditAccountDialog(Account account) {
    final nameController = TextEditingController(text: account.name);
    final typeController = TextEditingController(text: account.type);
    final balanceController = TextEditingController(text: account.balance.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '账户名称'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: '账户类型（现金、银行卡等）'),
            ),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: '余额'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final type = typeController.text.trim();
              final balance = double.tryParse(balanceController.text) ?? 0.0;

              if (name.isNotEmpty && type.isNotEmpty) {
                account.name = name;
                account.type = type;
                account.balance = balance;
                await DatabaseService.updateAccount(account);
                loadAccounts();
                ref.invalidate(accountsProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.deleteAccount(account.id);
              loadAccounts();
              ref.invalidate(accountsProvider);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showAccountTypeSelection() {
    final List<String> accountTypes = [
      '流动账户',
      '信用账户',
      '投资账户',
      '预付账户',
      '账务账户',
      '固定资产'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择账户类型'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: accountTypes.map((type) {
            return ListTile(
              title: Text(type),
              onTap: () {
                Navigator.pop(context);
                _showAddAccountDialog(type);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddAccountDialog(String accountType) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '账户名称'),
            ),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: '初始余额'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '账户类型: $accountType',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final balance = double.tryParse(balanceController.text) ?? 0.0;

              if (name.isNotEmpty) {
                final account = Account(
                  name: name,
                  type: accountType,
                  balance: balance,
                );
                await DatabaseService.addAccount(account);
                loadAccounts();
                ref.invalidate(accountsProvider);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户管理'),
      ),
      body: FutureBuilder<List<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('错误: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('暂无账户，请添加账户'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showAccountTypeSelection,
                    icon: const Icon(Icons.add),
                    label: const Text('添加账户'),
                  ),
                ],
              ),
            );
          } else {
            final accounts = snapshot.data!;
            double totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);

            return Column(
              children: [
                // 总余额
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('总余额'),
                        Text(
                          MoneyUtils.formatMoney(totalBalance),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 添加账户按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showAccountTypeSelection,
                        icon: const Icon(Icons.add),
                        label: const Text('添加账户'),
                      ),
                    ],
                  ),
                ),

                // 账户列表
                Expanded(
                  child: ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    account.type,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    MoneyUtils.formatMoney(account.balance),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => _showEditAccountDialog(account),
                                        child: const Text('编辑'),
                                      ),
                                      TextButton(
                                        onPressed: () => _showDeleteAccountDialog(account),
                                        child: const Text('删除'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
