//这是历史数据管理器
// 由于 systemMetricsStreamProvider 每次只提供一个数据点
// 我们需要一个 Riverpod 的 StateNotifier 来持续监听这个流
// 并维护一个包含最新 N 个数据点的列表，供图表使用。

// 定义图表需要保留的最大历史数据点数量
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/device_info.dart';
import 'device_service.dart';

const int maxHistoryLength = 60; // 保留 60 秒（1分钟）的历史数据

// 状态：一个包含 SystemMetrics 历史记录的列表
typedef MetricsHistory = List<SystemMetrics>;

// Provider: 用于访问和管理性能指标历史记录
final metricsHistoryProvider =
StateNotifierProvider<MetricsHistoryNotifier, MetricsHistory>((ref) {
  // 监听实时数据流，并将 Stream 传递给 Notifier
  final stream = ref.watch(systemMetricsStreamProvider.stream);
  return MetricsHistoryNotifier(stream);
});


class MetricsHistoryNotifier extends StateNotifier<MetricsHistory> {
  final Stream<SystemMetrics> _metricsStream;

  // 构造函数：接受 Stream 并开始监听
  MetricsHistoryNotifier(this._metricsStream) : super([]) {
    _metricsStream.listen(_onNewMetrics);
  }

  // 监听回调：每当有新数据时执行
  void _onNewMetrics(SystemMetrics newMetrics) {
    // 1. 创建新的历史列表 (StateNotifier要求不可变状态)
    final newState = List<SystemMetrics>.from(state);

    // 2. 添加新数据
    newState.add(newMetrics);

    // 3. 保持列表长度不超过最大值
    if (newState.length > maxHistoryLength) {
      newState.removeAt(0); // 移除最旧的数据点
    }

    // 4. 更新状态
    state = newState;
  }
}