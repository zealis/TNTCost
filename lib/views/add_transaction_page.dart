import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../view_models/transaction_view_model.dart';
import '../utils/money_utils.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final Transaction? transaction;
  
  const AddTransactionPage({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _transactionType = 'expense';
  Category? _selectedCategory;
  Account? _selectedAccount;
  Account? _transferToAccount;
  String? _transferToAccountName;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _amountController.text = MoneyUtils.formatMoneyWithoutSymbol(transaction.amount);
      _selectedCategory = transaction.category;
      _selectedAccount = transaction.account;
      _selectedDate = transaction.date;

      if (_isTransferTransaction(transaction)) {
        _transactionType = 'transfer';
        _parseTransferNote(transaction.note);
      } else {
        _transactionType = transaction.isIncome ? 'income' : 'expense';
        _noteController.text = transaction.note ?? '';
      }
    }
  }

  bool _isTransferTransaction(Transaction transaction) {
    return transaction.category?.name == '转账';
  }

  void _parseTransferNote(String? note) {
    if (note == null || note.isEmpty) {
      _noteController.text = '';
      return;
    }
    final arrowIndex = note.indexOf('->');
    if (arrowIndex != -1) {
      final colonIndex = note.indexOf(':', arrowIndex);
      final toAccountEndIndex = colonIndex != -1 ? colonIndex : note.length;
      final toAccountName = note.substring(arrowIndex + 2, toAccountEndIndex).trim();
      _transferToAccountName = toAccountName;
      
      if (colonIndex != -1) {
        _noteController.text = note.substring(colonIndex + 1).trim();
      } else {
        _noteController.text = '';
      }
    } else {
      _noteController.text = note;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? '添加交易' : '编辑交易'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 收入/支出/转账切换
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _transactionType = 'expense';
                      if (_selectedCategory?.name == '转账') {
                        _selectedCategory = null;
                      }
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _transactionType == 'expense' ? Colors.red : Colors.grey,
                    ),
                    child: const Text('支出'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _transactionType = 'income';
                      if (_selectedCategory?.name == '转账') {
                        _selectedCategory = null;
                      }
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _transactionType == 'income' ? Colors.green : Colors.grey,
                    ),
                    child: const Text('收入'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _transactionType = 'transfer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _transactionType == 'transfer' ? Colors.blue : Colors.grey,
                    ),
                    child: const Text('转账'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 金额输入
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isNotEmpty) {
                    final numValue = double.tryParse(newValue.text);
                    if (numValue != null && numValue > 1000000000000) {
                      return oldValue;
                    }
                  }
                  if (newValue.text.startsWith('0') && newValue.text.length > 1 && !newValue.text.startsWith('0.')) {
                    return oldValue;
                  }
                  return newValue;
                }),
              ],
              decoration: InputDecoration(
                labelText: '金额',
                prefixText: '¥',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 分类选择（非转账模式）
            if (_transactionType != 'transfer') ...[
              categories.when(
                data: (categories) {
                  final filteredCategories = categories.where((cat) => cat.name != '转账').toList();
                  Category? matchingCategory;
                  if (_selectedCategory != null) {
                    matchingCategory = filteredCategories.firstWhere(
                      (cat) => cat.id == _selectedCategory!.id,
                      orElse: () => _selectedCategory!,
                    );
                  }

                  return DropdownButtonFormField<Category>(
                    value: matchingCategory,
                    hint: const Text('选择分类'),
                    items: filteredCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(category.icon)),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
            ],

            // 账户选择
            if (_transactionType == 'transfer') ...[
              // 转出账户
              accounts.when(
                data: (accounts) {
                  Account? matchingAccount;
                  if (_selectedAccount != null) {
                    matchingAccount = accounts.firstWhere(
                      (acc) => acc.id == _selectedAccount!.id,
                      orElse: () => _selectedAccount!,
                    );
                  }

                  return DropdownButtonFormField<Account>(
                    value: matchingAccount,
                    hint: const Text('选择转出账户'),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text('${account.name} (${MoneyUtils.formatMoney(account.balance)})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '转出账户',
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              // 转入账户
              accounts.when(
                data: (accounts) {
                  Account? matchingAccount;
                  if (_transferToAccount != null) {
                    matchingAccount = accounts.firstWhere(
                      (acc) => acc.id == _transferToAccount!.id,
                      orElse: () => _transferToAccount!,
                    );
                  } else if (_transferToAccountName != null) {
                    matchingAccount = accounts.firstWhere(
                      (acc) => acc.name == _transferToAccountName,
                      orElse: () => _selectedAccount!,
                    );
                    _transferToAccount = matchingAccount;
                  }

                  return DropdownButtonFormField<Account>(
                    value: matchingAccount,
                    hint: const Text('选择转入账户'),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text('${account.name} (${MoneyUtils.formatMoney(account.balance)})'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _transferToAccount = value),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '转入账户',
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // 普通收支的账户选择
              accounts.when(
                data: (accounts) {
                  Account? matchingAccount;
                  if (_selectedAccount != null) {
                    matchingAccount = accounts.firstWhere(
                      (acc) => acc.id == _selectedAccount!.id,
                      orElse: () => _selectedAccount!,
                    );
                  }

                  return DropdownButtonFormField<Account>(
                    value: matchingAccount,
                    hint: const Text('选择账户'),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text('${account.name} (${MoneyUtils.formatMoney(account.balance)})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
            ],

            // 日期选择
            Row(
              children: [
                const Text('日期: '),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('zh', 'CN'),
                    );
                    if (pickedDate != null) {
                      setState(() => _selectedDate = pickedDate);
                    }
                  },
                  child: Text('${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 备注
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = MoneyUtils.parseMoney(_amountController.text);
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请输入有效金额')),
                    );
                    return;
                  }

                  if (_transactionType == 'transfer') {
                    if (_selectedAccount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请选择转出账户')),
                      );
                      return;
                    }

                    if (_transferToAccount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请选择转入账户')),
                      );
                      return;
                    }

                    if (_selectedAccount!.id == _transferToAccount!.id) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('转出账户和转入账户不能相同')),
                      );
                      return;
                    }

                    if (_selectedAccount!.balance < amount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('余额不足')),
                      );
                      return;
                    }

                    if (widget.transaction != null) {
                      await ref.read(transactionViewModelProvider.notifier).deleteTransaction(widget.transaction!.id);
                    }

                    await ref.read(transactionViewModelProvider.notifier).transfer(
                      fromAccount: _selectedAccount!,
                      toAccount: _transferToAccount!,
                      amount: amount,
                      note: _noteController.text,
                      date: _selectedDate,
                    );

                    context.pop();
                  } else {
                    if (_selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请选择分类')),
                      );
                      return;
                    }

                    if (_selectedAccount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请选择账户')),
                      );
                      return;
                    }

                    final isIncome = _transactionType == 'income';
                    final transaction = Transaction(
                      date: _selectedDate,
                      amount: amount,
                      isIncome: isIncome,
                      note: _noteController.text.isEmpty ? null : _noteController.text,
                      category: _selectedCategory,
                      account: _selectedAccount,
                    );

                    if (widget.transaction != null) {
                      transaction.id = widget.transaction!.id;
                      await ref.read(transactionViewModelProvider.notifier).updateTransaction(transaction);
                    } else {
                      await ref.read(transactionViewModelProvider.notifier).addTransaction(transaction);
                    }

                    context.pop();
                  }
                },
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'attach_money':
        return Icons.attach_money;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }
}
