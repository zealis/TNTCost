import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'services/database_service.dart';
import 'services/security_service.dart';
import 'views/main_page.dart';
import 'views/add_transaction_page.dart';
import 'views/login_page.dart';
import 'views/category_management_page.dart';
import 'utils/theme_utils.dart';
import 'models/transaction.dart';

// 创建认证状态提供者
final authProvider = StateProvider<bool>((ref) => false);

// 创建路由提供者
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      // 不需要重定向，直接在首页处理
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return Consumer(builder: (context, ref, child) {
            final isAuthenticated = ref.watch(authProvider);
            return isAuthenticated ? const MainPage() : LoginPage(
              onAuthenticated: () => ref.read(authProvider.notifier).state = true,
            );
          });
        },
      ),
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) {
          final transaction = state.extra as Transaction?;
          return AddTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/edit-transaction',
        builder: (context, state) {
          final transaction = state.extra as Transaction?;
          return AddTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/category-management',
        builder: (context, state) {
          return const CategoryManagementPage();
        },
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '记账本',
      theme: ThemeData(
        primarySwatch: ThemeUtils.primaryColor,
        useMaterial3: true,
        pageTransitionsTheme: ThemeUtils.pageTransition,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: ThemeUtils.primaryColor,
        useMaterial3: true,
        pageTransitionsTheme: ThemeUtils.pageTransition,
      ),
      themeMode: ThemeUtils.getThemeMode(),
      routerConfig: router,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CN'),
      ],
    );
  }
}