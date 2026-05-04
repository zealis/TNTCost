import 'package:isar/isar.dart';
import 'transaction.dart';

part 'category.g.dart';

@Collection()
class Category {
  Id id = Isar.autoIncrement;
  
  String name;
  
  String icon;
  
  bool isDefault;
  
  int? parentId;
  
  @Backlink(to: 'category')
  @ignore
  List<Transaction> transactions = [];
  
  Category({
    required this.name,
    required this.icon,
    this.isDefault = false,
    this.parentId,
  });
}