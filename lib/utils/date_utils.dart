import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
  
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }
  
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
  
  static DateTime getStartOfWeek(DateTime date) {
    final int weekday = date.weekday; // 1=周一, 7=周日
    return getStartOfDay(DateTime(date.year, date.month, date.day - (weekday - 1)));
  }
  
  static DateTime getEndOfWeek(DateTime date) {
    final int weekday = date.weekday;
    return getEndOfDay(DateTime(date.year, date.month, date.day + (7 - weekday)));
  }
  
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  static DateTime getEndOfMonth(DateTime date) {
    final nextMonth = date.month == 12 ? DateTime(date.year + 1, 1, 1) : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(Duration(seconds: 1));
  }
  
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }
  
  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }
}