import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/transaction.dart';
import '../view_models/transaction_view_model.dart';
import '../utils/date_utils.dart';
import '../utils/date_utils.dart' as app_date;
import '../utils/money_utils.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  String _filterPeriod = 'month'; // week, month, year
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    DateTime startDate, endDate;
    
    switch (_filterPeriod) {
      case 'week':
        startDate = app_date.AppDateUtils.getStartOfWeek(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfWeek(_selectedDate);
        break;
      case 'month':
        startDate = app_date.AppDateUtils.getStartOfMonth(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfMonth(_selectedDate);
        break;
      case 'year':
        startDate = app_date.AppDateUtils.getStartOfYear(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfYear(_selectedDate);
        break;
      default:
        startDate = app_date.AppDateUtils.getStartOfMonth(_selectedDate);
        endDate = app_date.AppDateUtils.getEndOfMonth(_selectedDate);
    }
    
    ref.read(transactionViewModelProvider.notifier).loadTransactions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账单列表'),
      ),
      body: Column(
        children: [
          // 筛选器
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _filterPeriod = 'week';
                        loadTransactions();
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _filterPeriod == 'week' ? Colors.blue : Colors.grey,
                      ),
                      child: const Text('周'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _filterPeriod = 'month';
                        loadTransactions();
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _filterPeriod == 'month' ? Colors.blue : Colors.grey,
                      ),
                      child: const Text('月'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _filterPeriod = 'year';
                        loadTransactions();
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _filterPeriod == 'year' ? Colors.blue : Colors.grey,
                      ),
                      child: const Text('年'),
                    ),
                  ],
                ),
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
                      setState(() {
                        _selectedDate = pickedDate;
                        loadTransactions();
                      });
                    }
                  },
                  child: Text('${_selectedDate.year}年${_selectedDate.month}月'),
                ),
              ],
            ),
          ),
          
          // 账单列表
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Dismissible(
                  key: Key(transaction.id.toString()),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      // 左滑删除
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认删除'),
                          content: const Text('确定要删除这条账单吗？'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  // 恢复项目
                                });
                              },
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.read(transactionViewModelProvider.notifier).deleteTransaction(transaction.id);
                                Navigator.pop(context);
                              },
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                    } else if (direction == DismissDirection.startToEnd) {
                      // 右滑编辑
                      context.push('/edit-transaction', extra: transaction);
                    }
                  },
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
                  child: Card(
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
                                transaction.category?.name ?? '未分类',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app_date.AppDateUtils.formatDateTime(transaction.date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (transaction.note != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  transaction.note!.replaceAll('\n', ' '),
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            MoneyUtils.formatMoney(transaction.amount),
                            style: TextStyle(
                              color: transaction.isIncome ? Colors.green : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}