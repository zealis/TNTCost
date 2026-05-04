import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/transaction.dart';
import '../services/database_service.dart';

class StatsViewModel extends Notifier<Map<String, dynamic>> {
  Timer? _debounceTimer;
  
  @override
  Map<String, dynamic> build() {
    return {
      'totalIncome': 0.0,
      'totalExpense': 0.0,
      'balance': 0.0,
      'categoryStats': {},
      'trendData': [],
      'isLoading': false,
    };
  }
  
  Future<void> loadStats({required DateTime startDate, required DateTime endDate, String type = 'expense'}) async {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        state = {
          ...state,
          'isLoading': true,
        };
        
        final transactions = await DatabaseService.getTransactions(
          startDate: startDate,
          endDate: endDate,
        );
        
        double totalIncome = 0.0;
        double totalExpense = 0.0;
        final categoryStats = <String, double>{};
        final categoryCounts = <String, int>{};
        
        for (final transaction in transactions) {
          if (transaction.isIncome) {
            totalIncome += transaction.amount;
            if (type == 'income' && transaction.category != null) {
              categoryStats[transaction.category!.name] = (categoryStats[transaction.category!.name] ?? 0) + transaction.amount;
              categoryCounts[transaction.category!.name] = (categoryCounts[transaction.category!.name] ?? 0) + 1;
            }
          } else {
            totalExpense += transaction.amount;
            if (type == 'expense' && transaction.category != null) {
              categoryStats[transaction.category!.name] = (categoryStats[transaction.category!.name] ?? 0) + transaction.amount;
              categoryCounts[transaction.category!.name] = (categoryCounts[transaction.category!.name] ?? 0) + 1;
            }
          }
        }
        
        final trendData = _calculateTrendData(transactions, startDate, endDate);
        
        state = {
          'totalIncome': totalIncome,
          'totalExpense': totalExpense,
          'balance': totalIncome - totalExpense,
          'categoryStats': categoryStats,
          'categoryCounts': categoryCounts,
          'trendData': trendData,
          'isLoading': false,
        };
      } catch (e) {
        state = {
          ...state,
          'isLoading': false,
        };
      }
    });
  }
  
  List<Map<String, dynamic>> _calculateTrendData(List<Transaction> transactions, DateTime startDate, DateTime endDate) {
    final trendData = <Map<String, dynamic>>[];
    
    // 使用Map存储每天的交易数据，避免嵌套循环
    final dailyData = <String, Map<String, double>>{};
    
    // 遍历所有交易，按日期分组
    for (final transaction in transactions) {
      final dateKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}';
      
      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {'income': 0.0, 'expense': 0.0};
      }
      
      if (transaction.isIncome) {
        dailyData[dateKey]!['income'] = (dailyData[dateKey]!['income'] ?? 0.0) + transaction.amount;
      } else {
        dailyData[dateKey]!['expense'] = (dailyData[dateKey]!['expense'] ?? 0.0) + transaction.amount;
      }
    }
    
    // 遍历日期范围，生成趋势数据
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dateKey = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      final dayData = dailyData[dateKey] ?? {'income': 0.0, 'expense': 0.0};
      
      trendData.add({
        'date': currentDate.toIso8601String(),
        'income': dayData['income']!,
        'expense': dayData['expense']!,
      });
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return trendData;
  }
}

final statsViewModelProvider = NotifierProvider<StatsViewModel, Map<String, dynamic>>(() {
  return StatsViewModel();
});

final budgetProvider = FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final budget = await DatabaseService.getBudget(date.month, date.year);
  return {
    'budget': budget,
    'isOverBudget': false, // 需要根据实际支出计算
  };
});