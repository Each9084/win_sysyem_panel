import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win_system_panel/core/config/navigation_controller.dart';
import 'package:win_system_panel/core/config/theme_controller.dart';
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

class WinSystemPanelApp extends ConsumerWidget {
  const WinSystemPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听主题状态，当状态变化时，MaterialApp 会自动重建
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      //去掉debug
      debugShowCheckedModeBanner: false,
      title: 'WinSystemPanel',

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

      //应用我的科幻主题
      //themeMode: ThemeMode.dark,老版本
      themeMode: themeMode,
      //新版本使用Controller 提供的状态
      // 使用 core/theme/app_theme.dart 中的配置
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,

      home: const MainScaffold(),
    );
  }
}

class EmptyPage extends StatelessWidget {
  final String label; //加构造函数来显示不同的占位符
  const EmptyPage(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(label,
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)));
  }
}

// 这是一个临时的脚手架，用于展示自定义标题栏效果
class MainScaffold extends ConsumerWidget with WindowListener {
  // 继承 WindowListener 用于窗口事件
  const MainScaffold({super.key});

  // 用于根据选中的页面返回对应的 Widget
  Widget _getPageWidget(MainPanelPage page, AppLocalizations t) {
    switch (page) {
      case MainPanelPage.powerControl:
        return const PowerControlPage();
      //TODO 未来完善deviceInfo
      case MainPanelPage.deviceInfo:
        return EmptyPage('${t.deviceInfoTitle} ${t.underConstruction}');
      //TODO 未来完善settings
      case MainPanelPage.settings:
        return EmptyPage('${t.deviceInfoTitle} ${t.underConstruction}');
      //TODO 未来完善about
      case MainPanelPage.about:
        return EmptyPage('${t.deviceInfoTitle} ${t.underConstruction}');
      // 暂时使用占位符
      default:
        return const Center(
          child: Text("Error Page"),
        );
    }
  }

  // 构建Sidebar
  Widget _buildSidebar(
      BuildContext context, WidgetRef ref, AppLocalizations t) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedPage = ref.watch(navigationProvider);
    final controller = ref.read(navigationProvider.notifier);

    // 映射导航枚举到 UI 细节
    final Map<MainPanelPage, ({IconData icon, String label})> navItems = {
      MainPanelPage.powerControl: (
        icon: Icons.power_settings_new,
        label: t.opShutdown
      ),
      MainPanelPage.deviceInfo: (
        icon: Icons.monitor_heart,
        label: t.deviceInfoTitle
      ),
      MainPanelPage.settings: (
        icon: CupertinoIcons.settings,
        label: t.settingsTitle
      ),
      MainPanelPage.about: (
      icon: CupertinoIcons.info,
      label: t.infoTitle
      )
    };

    return Container(
      //控制侧边栏的宽度
      width: 180,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.5),
        border: Border(
            right: BorderSide(
                color: colorScheme.primary.withOpacity(0.1), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // 顶部的导航按钮
          ...navItems.entries.map((entry) {
            final page = entry.key;
            final item = entry.value;
            final isSelected = page == selectedPage;

            return _buildSidebarItem(
              context: context,
              icon: item.icon,
              label: item.label,
              isSelected: isSelected,
              onTap: () => controller.selectPage(page),
              colorScheme: colorScheme,
            );
          }).toList(),

          const Spacer(),
          // 底部控制图标 - 垂直分割线
          Divider(color: colorScheme.onSurface.withOpacity(0.1), height: 1),

          //底部右侧：设置齿轮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBottomIcon(
                      icon: CupertinoIcons.settings,
                      tooltip: t.settingsTitle,
                      onTap: () {
                        // TODO: 未来打开设置页
                      },
                      color: colorScheme.onSurface),
                  _buildBottomIcon(
                      icon: CupertinoIcons.info_circle,
                      tooltip: t.infoTitle,
                      onTap: () {
                        // TODO: 未来打开信息页
                      },
                      color: colorScheme.onSurface),
                ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeControllerProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    //获取多语言实例
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // 监听当前选中的页面
    final currentPage = ref.watch(navigationProvider);

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 32,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.bolt,
                    size: 18,
                    color: isDarkMode ? Color(0xFF00F0FF) : Colors.cyanAccent),
                const SizedBox(width: 8),
                Text(
                  "WIN SYSTEM PANEL",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7)),
                ),
                Expanded(
                  // 这一行非常关键：让这块区域可以拖动窗口
                  child: DragToMoveArea(
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // 主题切换按钮
                IconButton(
                    onPressed: themeController.toggleTheme,
                    icon: Icon(
                      isDarkMode
                          ? Icons.wb_sunny_outlined
                          : Icons.mode_night_outlined,
                      size: 16,
                    ),
                    tooltip: isDarkMode ? t.switchDarkMode : t.switchLightMode),

                IconButton(
                  icon: const Icon(Icons.minimize, size: 16),
                  onPressed: () => windowManager.minimize(),
                ),
                IconButton(
                  onPressed: () => windowManager.close(),
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // 侧边栏
                _buildSidebar(context, ref, t),
                Expanded(
                  child: SingleChildScrollView(
                    child: _getPageWidget(currentPage,t),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// 辅助方法：构建单个侧边栏选项 (图标 + 文本)
// ----------------------------------------------------
Widget _buildSidebarItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
  required ColorScheme colorScheme,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              // 确保文本在剩余空间内显示
              child: Text(
                label,
                style: TextStyle(
                    color: isSelected
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.8),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBottomIcon(
    {required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 9.0),
    child: Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Icon(
            icon,
            color: color.withOpacity(0.6),
            size: 20,
          ),
        ),
      ),
    ),
  );
}
