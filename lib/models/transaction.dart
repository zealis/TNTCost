import 'package:isar/isar.dart';
import 'category.dart';
import 'account.dart';

part 'transaction.g.dart';

@Collection()
class Transaction {
  Id id = Isar.autoIncrement;
  
  @Index()
  DateTime date;
  
  double amount;
  
  bool isIncome;
  
  String? note;
  
  String? imagePath;
  
  int? categoryId;
  
  int? accountId;
  
  @ignore
  Category? category;
  
  @ignore
  Account? account;
  
  Transaction({
    required this.date,
    required this.amount,
    required this.isIncome,
    this.note,
    this.imagePath,
    Category? category,
    Account? account,
  }) {
    if (category != null) {
      categoryId = category.id;
      this.category = category;
    }
    if (account != null) {
      accountId = account.id;
      this.account = account;
    }
  }
}