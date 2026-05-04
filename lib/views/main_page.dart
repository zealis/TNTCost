import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'stats_page.dart';
import 'account_page.dart';
import 'settings_page.dart';

import '../models/transaction.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/stats_view_model.dart';
import '../utils/date_utils.dart';
import '../utils/money_utils.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AccountPage(),
    const StatsPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    ref.read(transactionViewModelProvider.notifier).loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.blue : null,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey : null,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '资产',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Map<String, bool> _expandedState = {};
  DateTime _selectedMonth = DateTime.now();

  String _getWeekdayName(DateTime date) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.weekday % 7];
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = '${transaction.date.year}-${transaction.date.month}-${transaction.date.day}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
        if (!_expandedState.containsKey(dateKey)) {
          _expandedState[dateKey] = true;
        }
      }
      grouped[dateKey]!.add(transaction);
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedGrouped = <String, List<Transaction>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  void _toggleExpanded(String dateKey) {
    setState(() {
      bool currentState = _expandedState[dateKey] ?? true;
      _expandedState[dateKey] = !currentState;
    });
  }
  
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _MonthPickerDialog(
          initialMonth: _selectedMonth,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionViewModelProvider);
    
    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    double monthlyIncome = 0;
    double monthlyExpense = 0;
    
    for (final transaction in transactions) {
      if (transaction.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        if (transaction.isIncome) {
          monthlyIncome += transaction.amount;
        } else {
          monthlyExpense += transaction.amount;
        }
      }
    }
    
    double monthlyBalance = monthlyIncome - monthlyExpense;
    
    final monthTransactions = transactions.where((transaction) {
      return transaction.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
    
    final groupedTransactions = _groupTransactionsByDate(monthTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记账本'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本月概览',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text('收入'),
                            Text(
                              MoneyUtils.formatMoney(monthlyIncome),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('支出'),
                            Text(
                              MoneyUtils.formatMoney(monthlyExpense),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('结余'),
                            Text(
                              MoneyUtils.formatMoney(monthlyBalance),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近交易',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () => _selectMonth(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: groupedTransactions.isEmpty
                  ? const Center(child: Text('暂无交易'))
                  : ListView.builder(
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final dateKey = groupedTransactions.keys.elementAt(index);
                        final dateTransactions = groupedTransactions[dateKey]!;
                        if (!_expandedState.containsKey(dateKey)) {
                          _expandedState[dateKey] = true;
                        }
                        final isExpanded = _expandedState[dateKey]!;
                        
                        double dayIncome = 0;
                        double dayExpense = 0;
                        for (final transaction in dateTransactions) {
                          if (transaction.isIncome) {
                            dayIncome += transaction.amount;
                          } else {
                            dayExpense += transaction.amount;
                          }
                        }
                        
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _toggleExpanded(dateKey),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final parts = dateKey.split('-');
                                            final year = int.parse(parts[0]);
                                            final month = int.parse(parts[1]);
                                            final day = int.parse(parts[2]);
                                            final date = DateTime(year, month, day);
                                            final weekday = _getWeekdayName(date);
                                            return Text(
                                              '${month}-${day} ${weekday}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            );
                                          },
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '收入: ${MoneyUtils.formatMoney(dayIncome)}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              '支出: ${MoneyUtils.formatMoney(dayExpense)}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              isExpanded ? Icons.expand_less : Icons.expand_more,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: Container(),
                              secondChild: Column(
                                children: dateTransactions.map<Widget>((Transaction transaction) {
                                  return Dismissible(
                                    key: Key(transaction.id.toString()),
                                    direction: DismissDirection.horizontal,
                                    background: Container(
                                      color: Colors.blue,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: const Icon(Icons.edit, color: Colors.white),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    confirmDismiss: (direction) async {
                                      if (direction == DismissDirection.startToEnd) {
                                        context.push('/add-transaction', extra: transaction);
                                        return false;
                                      } else if (direction == DismissDirection.endToStart) {
                                        bool? confirmDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('确认删除'),
                                            content: const Text('确定要删除这个交易吗？'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('取消'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('删除'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirmDelete == true) {
                                          await ref.read(transactionViewModelProvider.notifier).deleteTransaction(transaction.id);
                                          return true;
                                        }
                                        return false;
                                      }
                                      return false;
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.only(top: 4),
                                      elevation: 1,
                                      child: ListTile(
                                        leading: Icon(
                                          transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                          color: transaction.isIncome ? Colors.green : Colors.red,
                                        ),
                                        title: Text(
                                          transaction.category?.name ?? '未分类',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')} ${transaction.note?.replaceAll('\n', ' ') ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: Text(
                                          MoneyUtils.formatMoney(transaction.amount),
                                          style: TextStyle(
                                            color: transaction.isIncome ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialMonth;

  const _MonthPickerDialog({required this.initialMonth});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialMonth.year;
    _selectedMonth = widget.initialMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(11, (index) => currentYear - 5 + index);
    final months = List.generate(12, (index) => index + 1);

    return AlertDialog(
      title: const Text('选择月份'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: '年份',
                border: OutlineInputBorder(),
              ),
              items: years.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year年'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedYear = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: '月份',
                border: OutlineInputBorder(),
              ),
              items: months.map((month) {
                return DropdownMenuItem<int>(
                  value: month,
                  child: Text('$month月'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMonth = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(DateTime(_selectedYear, _selectedMonth, 1));
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资产'),
      ),
      body: const Center(
        child: Text('资产页面'),
      ),
    );
  }
}
