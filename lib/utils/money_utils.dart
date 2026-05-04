import 'package:intl/intl.dart';

class MoneyUtils {
  static String formatMoney(double amount) {
    return NumberFormat.currency(locale: 'zh_CN', symbol: '¥').format(amount);
  }
  
  static String formatMoneyWithoutSymbol(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
  
  static double parseMoney(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
  
  static double calculateTotal(List<double> amounts) {
    return amounts.fold(0.0, (sum, amount) => sum + amount);
  }
  
  static double calculateBalance(double income, double expense) {
    return income - expense;
  }
  
  static String formatCompact(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
