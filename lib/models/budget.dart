import 'package:isar/isar.dart';

part 'budget.g.dart';

@Collection()
class Budget {
  Id id = Isar.autoIncrement;
  
  double totalBudget;
  
  int month;
  
  int year;
  
  @ignore
  Map<String, double> categoryBudgets;
  
  Budget({
    required this.totalBudget,
    required this.month,
    required this.year,
    this.categoryBudgets = const {},
  });
}