// lib/features/device_info/presentation/device_info_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win_system_panel/lib/features/device_info/presentation/widgets/performance_chart.dart';

import '../../../i18n/l10n/app_localizations.dart';
import '../../power_control/application/device_service.dart';
import '../../power_control/domain/device_info.dart';


class DeviceInfoPage extends ConsumerWidget {
  const DeviceInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // 1. 顶部：实时性能监控区 (Chart)
          // ----------------------------------------------------
          _buildSectionTitle(context, t.performanceMonitoring, colorScheme),
          const SizedBox(height: 10),

          _buildPerformanceChartSection(ref, colorScheme, t),

          const SizedBox(height: 20),
          Divider(color: colorScheme.onBackground.withOpacity(0.1)),
          const SizedBox(height: 20),

          // ----------------------------------------------------
          // 2. 底部：硬件/系统信息详情区
          // ----------------------------------------------------
          _buildSectionTitle(context, t.systemDetails, colorScheme),
          const SizedBox(height: 10),

          _buildHardwareInfoSection(ref, colorScheme, t),
        ],
      ),
    );
  }

  // 辅助方法：构建标题
  Widget _buildSectionTitle(BuildContext context, String title, ColorScheme colorScheme) {
    return Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary
        )
    );
  }

  // 性能图表区
  Widget _buildPerformanceChartSection(WidgetRef ref, ColorScheme colorScheme, AppLocalizations t) {
    // 监听实时数据流，判断是否正在加载或出错
    final metricsAsync = ref.watch(systemMetricsStreamProvider);

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: metricsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(
            t.dataLoadFailed(err.toString()), // 假设 dataLoadFailed 是存在的 i18n 键
            style: TextStyle(color: colorScheme.error)
        )),
        // 只要能获取到数据 (metrics)，就显示图表组件
        data: (_) {
          return const PerformanceChart(); // 引入并显示 PerformanceChart
        },
      ),
    );
  }

  // 硬件信息展示区
  Widget _buildHardwareInfoSection(WidgetRef ref, ColorScheme colorScheme, AppLocalizations t) {
    final infoAsync = ref.watch(hardwareInfoProvider);

    return infoAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text(
          t.dataLoadFailed(err.toString()),
          style: TextStyle(color: colorScheme.error)
      ),
      data: (info) {
        return _buildInfoTable(info, colorScheme, t);
      },
    );
  }

  // 构建信息表格
  Widget _buildInfoTable(HardwareInfo info, ColorScheme colorScheme, AppLocalizations t) {
    // 定义 Key-Value 对，使用 i18n 键
    final infoMap = {
      t.osName: info.osName,
      t.cpuModel: info.cpuName,
      t.totalMemory: '${info.totalMemoryGB} GB',
      t.systemManufacturer: info.systemManufacturer,
      t.systemModel: info.systemModel,
      t.gpuModel: info.gpuName,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        children: infoMap.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // 使用图标增加视觉效果
              Icon(Icons.monitor_heart, size: 20, color: colorScheme.primary.withOpacity(0.7)),
              const SizedBox(width: 15),
              SizedBox(
                width: 150,
                child: Text(
                    entry.key,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onBackground.withOpacity(0.8)
                    )
                ),
              ),
              Expanded(
                child: Text(
                    entry.value,
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w500, // 稍微加粗值
                    )
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}