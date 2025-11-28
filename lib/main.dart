import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win_system_panel/core/theme/app_theme.dart';
import 'package:win_system_panel/features/power_control/presentation/pages/power_control_page.dart';
import 'package:window_manager/window_manager.dart';

import 'i18n/l10n/app_localizations.dart';

void main() async {
  //确保 Flutter Widgets 绑定已被初始化
  WidgetsFlutterBinding.ensureInitialized();

  // --- 窗口初始化配置 ---
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
      size: Size(1000, 800),
      minimumSize: Size(800, 500),
      center: true,
      //启动时居中
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      //用于指定窗口是否应该出现在操作系统的任务栏
      titleBarStyle: TitleBarStyle.hidden,
      // 隐藏原生标题栏 太丑陋了
      title: "WinSystemPanel");

  //等待窗口管理器准备就绪后，再显示和聚焦应用窗口。
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: WinSystemPanelApp()));
}

class WinSystemPanelApp extends StatelessWidget {
  const WinSystemPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ---多语言配置 ---
      // 自动从 ARB 文件中获取支持的语言
      supportedLocales: AppLocalizations.supportedLocales,
      //支持的语言列表
      localizationsDelegates: const [
        //本地化代理列表
        AppLocalizations.delegate,
        // 我们的代理 加载在 ARB 文件中定义的字符串。
        GlobalMaterialLocalizations.delegate,
        //加载标准 Material 组件中需要的文本。
        GlobalCupertinoLocalizations.delegate,
        //加载 iOS 风格（Cupertino）组件的文本。
        GlobalWidgetsLocalizations.delegate,
        //加载所有其他不属于 Material 或 Cupertino 的基础 Widgets 文本。
      ],

      // Fallback 语言（如果没有用户的语言包，则使用英文）
      locale: const Locale('en'),

      //去掉debug
      title: 'WinSystemPanel',

      //应用我的科幻主题
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      // 使用 core/theme/app_theme.dart 中的配置

      home: const MainScaffold(),
    );
  }
}

// 这是一个临时的脚手架，用于展示自定义标题栏效果
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 32,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.bolt, size: 18, color: Color(0xFF00F0FF)),
                const SizedBox(width: 8),
                Text(
                  "WIN SYSTEM PANEL",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.7)),
                ),
                Expanded(
                  // 这一行非常关键：让这块区域可以拖动窗口
                  child: DragToMoveArea(
                    child: Container(color: Colors.transparent),
                  ),
                ),
                IconButton(
                  onPressed: () => windowManager.close,
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          //2.主要区域
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topCenter,
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "SYSTEM READY",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text("INITIALIZE SEQUENCE"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 20),
                  ),
                )
              ],
            )),
          ),
          const Expanded(
            child: PowerControlPage(),
          )
        ],
      ),
    );
  }
}
