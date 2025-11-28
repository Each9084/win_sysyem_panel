import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

// 主题文件

class AppTheme {
  // 私有构造函数，防止实例化
  AppTheme._();

  static const Color _scaffoldBackGround = Color(0xFF0F172A);

  // 卡片/表面色：稍亮的深灰色
  static const Color _surface = Color(0xFF1E293B);

  // 强调色：霓虹青 (Cyber Cyan) - 深色背景效果不错
  static const Color _primary = Color(0xFF00F0FF);

  // 次要强调色 用于辅助元素
  static const Color _secondary = Color(0xFF7C3AED);

  //报错颜色
  static const Color _error = Color(0xFFFF2B2B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _scaffoldBackGround,

      //定义颜色方案
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        surface: _surface,
        error: _error,
        onPrimary: Colors.black, // 在霓虹色上的文字用黑色，对比度最高
      ),

      // 定义卡片样式
      cardTheme: CardTheme(
        color: _surface,
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _primary.withOpacity(0.1), width: 1), // 边框发光感
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }
}
