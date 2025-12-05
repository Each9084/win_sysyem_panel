//为实时监控数据创建一个简单的数据模型
import 'dart:ffi';

import 'package:flutter/services.dart';

class SystemMetrics {
  final double cpuLoad; // CPU 总负载百分比
  final double memoryUsage; // 内存占用百分比
  final double diskLoad; // 磁盘活动百分比
  final double gpuLoad; // GPU 占用百分比
  final DateTime timeStamp; // 数据采集时间

  SystemMetrics({
    required this.cpuLoad,
    required this.memoryUsage,
    this.diskLoad = 0.0,
    this.gpuLoad = 0.0,
    required this.timeStamp,
  });

  static SystemMetrics get empty => SystemMetrics(
        cpuLoad: 0.0,
        memoryUsage: 0.0,
        timeStamp: DateTime.now(),
      );
}
// ------------------------------------------------------------------
// 硬件信息模型 (用于底部详情展示)
// ------------------------------------------------------------------

class HardwareInfo {
  final String osName;
  final String osVersion;
  final String cpuName;
  final int totalMemoryGB;
  final String gpuName;
  final String systemManufacturer;
  final String systemModel;

  HardwareInfo({
    this.osName = "N/A",
    this.osVersion = "N/A",
    this.cpuName = 'N/A',
    this.totalMemoryGB = 0,
    this.gpuName = 'N/A',
    this.systemManufacturer = 'N/A',
    this.systemModel = 'N/A',
  });
}
