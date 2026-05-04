import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'category_management_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App功能',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.monetization_on),
                title: const Text('多币种'),
                subtitle: const Text('功能已关闭'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('多币种功能已关闭')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '数据管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('分类管理'),
                subtitle: const Text('管理收支分类'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push('/category-management');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
