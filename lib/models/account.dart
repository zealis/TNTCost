import 'package:isar/isar.dart';
import 'transaction.dart';

part 'account.g.dart';

@Collection()
class Account {
  Id id = Isar.autoIncrement;
  
  String name;
  
  String type;
  
  double balance;
  
  @Backlink(to: 'account')
  @ignore
  List<Transaction> transactions = [];
  
  Account({
    required this.name,
    required this.type,
    required this.balance,
  });
}