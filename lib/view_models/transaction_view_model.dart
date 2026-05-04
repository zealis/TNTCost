import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../services/database_service.dart';

class TransactionViewModel extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    return [];
  }
  
  Future<void> loadTransactions({DateTime? startDate, DateTime? endDate}) async {
    final transactions = await DatabaseService.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );
    state = transactions;
  }
  
  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseService.addTransaction(transaction);
    await loadTransactions();
  }
  
  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseService.updateTransaction(transaction);
    await loadTransactions();
  }
  
  Future<void> deleteTransaction(int id) async {
    await DatabaseService.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> transfer({
    required Account fromAccount,
    required Account toAccount,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    await DatabaseService.transfer(
      fromAccount: fromAccount,
      toAccount: toAccount,
      amount: amount,
      note: note,
      date: date,
    );
    await loadTransactions();
  }
}

final transactionViewModelProvider = NotifierProvider<TransactionViewModel, List<Transaction>>(() {
  return TransactionViewModel();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await DatabaseService.getCategories();
});

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  return await DatabaseService.getAccounts();
});