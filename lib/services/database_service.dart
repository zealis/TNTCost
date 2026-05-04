import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../models/budget.dart';

class DatabaseService {
  static late Isar isar;
  
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        TransactionSchema,
        CategorySchema,
        AccountSchema,
        BudgetSchema,
      ],
      directory: dir.path,
    );
    
    // 初始化默认分类
    await _initializeDefaultCategories();
  }
  
  static Future<void> _initializeDefaultCategories() async {
    final existingCategories = await isar.categorys.count();
    if (existingCategories == 0) {
      final defaultCategories = [
        Category(name: '餐饮', icon: 'restaurant', isDefault: true),
        Category(name: '交通', icon: 'directions_car', isDefault: true),
        Category(name: '购物', icon: 'shopping_cart', isDefault: true),
        Category(name: '娱乐', icon: 'movie', isDefault: true),
        Category(name: '医疗', icon: 'local_hospital', isDefault: true),
        Category(name: '教育', icon: 'school', isDefault: true),
        Category(name: '工资', icon: 'attach_money', isDefault: true),
        Category(name: '转账', icon: 'swap_horiz', isDefault: true),
        Category(name: '其他', icon: 'more_horiz', isDefault: true),
      ];
      
      await isar.writeTxn(() async {
        for (final category in defaultCategories) {
          await isar.categorys.put(category);
        }
      });
    } else {
      // 检查转账分类是否存在，不存在则添加
      final transferCategory = await isar.categorys
          .filter()
          .nameEqualTo('转账')
          .findFirst();
      
      if (transferCategory == null) {
        await isar.writeTxn(() async {
          await isar.categorys.put(
            Category(name: '转账', icon: 'swap_horiz', isDefault: true),
          );
        });
      }
    }
  }
  
  // 交易相关操作
  static Future<void> addTransaction(Transaction transaction) async {
    await isar.writeTxn(() async {
      // 首先添加交易
      await isar.transactions.put(transaction);
      
      // 如果交易关联了账户，更新账户余额
      if (transaction.accountId != null) {
        final account = await isar.accounts.get(transaction.accountId!);
        if (account != null) {
          // 根据交易类型更新余额
          if (transaction.isIncome) {
            account.balance += transaction.amount;
          } else {
            account.balance -= transaction.amount;
          }
          // 保存更新后的账户
          await isar.accounts.put(account);
        }
      }
    });
  }
  
  static Future<void> updateTransaction(Transaction transaction) async {
    await isar.writeTxn(() async {
      // 1. 获取旧交易记录
      final oldTransaction = await isar.transactions.get(transaction.id);
      
      // 2. 回滚旧交易对账户余额的影响
      if (oldTransaction?.accountId != null) {
        final account = await isar.accounts.get(oldTransaction!.accountId!);
        if (account != null) {
          // 回滚旧交易：收入则减去，支出则加上
          if (oldTransaction.isIncome) {
            account.balance -= oldTransaction.amount;
          } else {
            account.balance += oldTransaction.amount;
          }
          
          // 3. 应用新交易到账户余额
          if (transaction.isIncome) {
            account.balance += transaction.amount;
          } else {
            account.balance -= transaction.amount;
          }
          
          // 4. 保存更新后的账户
          await isar.accounts.put(account);
        }
      }
      
      // 保存更新后的交易
      await isar.transactions.put(transaction);
    });
  }
  
  static Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      // 获取要删除的交易记录
      final transaction = await isar.transactions.get(id);
      
      // 回滚交易对账户余额的影响
      if (transaction?.accountId != null) {
        final account = await isar.accounts.get(transaction!.accountId!);
        if (account != null) {
          // 回滚交易：收入则减去，支出则加上
          if (transaction.isIncome) {
            account.balance -= transaction.amount;
          } else {
            account.balance += transaction.amount;
          }
          // 保存更新后的账户
          await isar.accounts.put(account);
        }
      }
      
      // 删除交易
      await isar.transactions.delete(id);
    });
  }
  
  static Future<List<Transaction>> getTransactions({DateTime? startDate, DateTime? endDate}) async {
    late final List<Transaction> transactions;
    
    if (startDate != null && endDate != null) {
      transactions = await isar.transactions
          .filter()
          .dateGreaterThan(startDate, include: true)
          .dateLessThan(endDate, include: true)
          .sortByDateDesc()
          .findAll();
    } else if (startDate != null) {
      transactions = await isar.transactions
          .filter()
          .dateGreaterThan(startDate, include: true)
          .sortByDateDesc()
          .findAll();
    } else if (endDate != null) {
      transactions = await isar.transactions
          .filter()
          .dateLessThan(endDate, include: true)
          .sortByDateDesc()
          .findAll();
    } else {
      transactions = await isar.transactions
          .where()
          .sortByDateDesc()
          .findAll();
    }
    
    // 加载所有分类和账户
    final categories = await isar.categorys.where().findAll();
    final accounts = await isar.accounts.where().findAll();
    
    // 创建分类和账户的映射
    final categoryMap = {for (var cat in categories) cat.id: cat};
    final accountMap = {for (var acc in accounts) acc.id: acc};
    
    // 关联分类和账户信息
    for (var transaction in transactions) {
      if (transaction.categoryId != null) {
        transaction.category = categoryMap[transaction.categoryId!];
      }
      if (transaction.accountId != null) {
        transaction.account = accountMap[transaction.accountId!];
      }
    }
    
    return transactions;
  }
  
  // 分类相关操作
  static Future<List<Category>> getCategories() async {
    return await isar.categorys.where().findAll();
  }
  
  static Future<List<Category>> getParentCategories() async {
    return await isar.categorys
        .filter()
        .parentIdIsNull()
        .findAll();
  }
  
  static Future<List<Category>> getSubCategories(int parentId) async {
    return await isar.categorys
        .filter()
        .parentIdEqualTo(parentId)
        .findAll();
  }
  
  static Future<void> addCategory(Category category) async {
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }
  
  static Future<void> updateCategory(Category category) async {
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }
  
  static Future<void> deleteCategory(int id) async {
    await isar.writeTxn(() async {
      // 先删除所有子分类
      final subCategories = await getSubCategories(id);
      for (final sub in subCategories) {
        await isar.categorys.delete(sub.id);
      }
      // 再删除当前分类
      await isar.categorys.delete(id);
    });
  }
  
  // 账户相关操作
  static Future<List<Account>> getAccounts() async {
    return await isar.accounts.where().findAll();
  }
  
  static Future<void> addAccount(Account account) async {
    await isar.writeTxn(() async {
      await isar.accounts.put(account);
    });
  }
  
  static Future<void> updateAccount(Account account) async {
    await isar.writeTxn(() async {
      await isar.accounts.put(account);
    });
  }
  
  static Future<void> deleteAccount(int id) async {
    await isar.writeTxn(() async {
      await isar.accounts.delete(id);
    });
  }

  // 转账操作
  static Future<void> transfer({
    required Account fromAccount,
    required Account toAccount,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    await isar.writeTxn(() async {
      // 从转出账户扣除金额
      final from = await isar.accounts.get(fromAccount.id);
      if (from != null) {
        from.balance -= amount;
        await isar.accounts.put(from);
      }

      // 向转入账户增加金额
      final to = await isar.accounts.get(toAccount.id);
      if (to != null) {
        to.balance += amount;
        await isar.accounts.put(to);
      }

      // 获取转账分类
      final transferCategory = await isar.categorys
          .filter()
          .nameEqualTo('转账')
          .findFirst();

      // 创建一条转账记录
      final transferNote = note.isEmpty 
          ? '${fromAccount.name} -> ${toAccount.name}'
          : '${fromAccount.name} -> ${toAccount.name}: $note';
      
      final transferTransaction = Transaction(
        date: date,
        amount: amount,
        isIncome: false, // 转账记录作为支出类型，但显示时需要特殊处理
        note: transferNote,
        account: fromAccount,
      );
      
      if (transferCategory != null) {
        transferTransaction.category = transferCategory;
        transferTransaction.categoryId = transferCategory.id;
      }
      
      await isar.transactions.put(transferTransaction);
    });
  }
  
  // 预算相关操作
  static Future<Budget?> getBudget(int month, int year) async {
    return null;
  }
  
  static Future<void> setBudget(Budget budget) async {
    await isar.writeTxn(() async {
      await isar.budgets.put(budget);
    });
  }
}