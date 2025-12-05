// lib/features/device_info/presentation/widgets/performance_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../power_control/application/metrics_history_notifier.dart';


class PerformanceChart extends ConsumerWidget {
  const PerformanceChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听历史数据
    final history = ref.watch(metricsHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 如果没有数据，显示加载或默认状态
    if (history.isEmpty) {
      return const Center(child: Text("Waiting for data..."));
    }

    // 获取 CPU 和 Memory 的折线数据
    final lineData = _getLineChartData(history, colorScheme);

    return Padding(
      padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
      child: LineChart(
        lineData,
        duration: Duration.zero, // 禁用动画，让数据更实时
      ),
    );
  }

  // ----------------------------------------------------
  // 核心方法：构建 fl_chart 所需的 LineChartData
  // ----------------------------------------------------
  LineChartData _getLineChartData(MetricsHistory history, ColorScheme colorScheme) {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final startTime = now - (maxHistoryLength * 1000); // 图表的最小时间戳（x 轴起点）

    // 映射 CPU 和 Memory 数据点
    final cpuSpots = history.asMap().entries.map((entry) {
      // X 轴：时间戳（从 0 开始的秒数）
      final x = entry.key.toDouble();
      // Y 轴：CPU 负载百分比
      final y = entry.value.cpuLoad;
      return FlSpot(x, y);
    }).toList();

    final memorySpots = history.asMap().entries.map((entry) {
      final x = entry.key.toDouble();
      final y = entry.value.memoryUsage;
      return FlSpot(x, y);
    }).toList();

    return LineChartData(
      // 1. 网格和边框设置
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Colors.white12,
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        // Y 轴标题（百分比）
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 20, // 每隔 20% 显示一个标签
            getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ),
        ),
        // X 轴标题（时间，以秒为单位）
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            interval: 10, // 每隔 10 秒显示一个标签
            getTitlesWidget: (value, meta) {
              final secondsAgo = (history.length - 1) - value.toInt();
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text('-${secondsAgo}s', style: const TextStyle(fontSize: 10, color: Colors.white70)),
              );
            },
          ),
        ),
      ),
      // 2. 坐标轴范围
      minX: 0,
      maxX: (maxHistoryLength - 1).toDouble(), // X 轴最大值为历史记录长度 - 1
      minY: 0,
      maxY: 100, // Y 轴最大值为 100%

      // 3. 折线设置
      lineBarsData: [
        // CPU 负载折线 (红色/主题色)
        LineChartBarData(
          spots: cpuSpots,
          isCurved: true,
          color: colorScheme.error, // 红色用于 CPU
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: colorScheme.error.withOpacity(0.1)),
        ),
        // Memory 负载折线 (蓝色/次要色)
        LineChartBarData(
          spots: memorySpots,
          isCurved: true,
          color: colorScheme.tertiary, // 蓝色用于内存
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: colorScheme.tertiary.withOpacity(0.1)),
        ),
      ],
    );
  }
}