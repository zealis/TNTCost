import 'package:flutter/material.dart';

class ThemeUtils {
  // 深色/浅色模式切换
  static ThemeMode getThemeMode() {
    return ThemeMode.system;
  }
  
  // 主色调
  static const primaryColor = Colors.blue;
  
  // 收入颜色
  static const incomeColor = Colors.green;
  
  // 支出颜色
  static const expenseColor = Colors.red;
  
  // 卡片阴影
  static const cardShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  
  // 页面过渡动画
  static const pageTransition = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    },
  );
  
  // 按钮样式
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  // 卡片样式
  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [cardShadow],
    );
  }
}