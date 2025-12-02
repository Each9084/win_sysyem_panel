//创建服务层
// 使用 Riverpod 的 StreamProvider 来持续获取实时数据。

// ----------------------------------------------------
// Stream Provider：实时性能数据
// ----------------------------------------------------

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_info2/system_info2.dart';
import '../domain/device_info.dart';


// ----------------------------------------------------
// Stream Provider：实时性能数据 (使用 WMIC)
// ----------------------------------------------------

final systemMetricsStreamProvider = StreamProvider<SystemMetrics>((ref) async* {
  if (!Platform.isWindows) {
    // 非 Windows 平台，可以返回一个错误或默认流
    yield* Stream.value(SystemMetrics.empty);
    return;
  }

  //定义获取区间
  const interval = Duration(seconds: 1);
  final streamController = StreamController<SystemMetrics>();
  Timer? timer;


  Future<void> _fetchData() async {
    try {
      // 1. 获取 CPU 负载 (Win32_Processor LoadPercentage)
      final cpuResult = await Process.run(
          'wmic', ['cpu', 'get', 'LoadPercentage', '/value']);
      final cpuOutput = cpuResult.stdout.toString().trim();

      // 提取 LoadPercentage=XX 中的 XX
      final cpuMatch = RegExp(r'LoadPercentage=(\d+)').firstMatch(cpuOutput);
      final cpuLoad = cpuMatch != null ? double.tryParse(
          cpuMatch.group(1) ?? '0.0') ?? 0.0 : 0.0;


      // 2. 获取内存使用百分比 (使用 system_info2 的免费内存 / 总内存)
      // WMIC 也可以获取，但 system_info2 提供了另一种可靠方式
      const int megabyte = 1024 * 1024;
      final totalMemoryMB = SysInfo.getTotalPhysicalMemory() ~/ megabyte;
      final freeMemoryMB = SysInfo.getFreePhysicalMemory() ~/ megabyte;

      final usedMemoryMB = totalMemoryMB - freeMemoryMB;
      final memoryUsage = totalMemoryMB > 0 ? (usedMemoryMB / totalMemoryMB) *
          100 : 0.0;

      // 3. 构建 Metrics 对象
      final metrics = SystemMetrics(
        cpuLoad: cpuLoad,
        memoryUsage: memoryUsage,
        timeStamp: DateTime.now(),
        // 磁盘/GPU 实时数据更复杂，暂保持 0.0
      );

      streamController.add(metrics);
    } catch (e) {
      print("获取系统资源失败 (WMIC/system_info2): $e");
      timer?.cancel();
    }
  }

  await _fetchData();
  timer = Timer.periodic(interval, (t) => _fetchData());

  yield* streamController.stream;

  ref.onDispose(() {
    timer?.cancel();
    streamController.close();
  });
});

// ----------------------------------------------------
// Future Provider：静态硬件信息 (使用 system_info2)
// ----------------------------------------------------
final hardwareInfoProvider = FutureProvider<HardwareInfo>((ref) async {
  // 💡 使用 system_info2 获取静态信息
  try {
    const int megabyte = 1024 * 1024;
    final cores = SysInfo.cores;

    return HardwareInfo(
      osName: SysInfo.operatingSystemName,
      cpuName: cores.isNotEmpty ? cores.first.name : 'Unknown CPU',
      // 转换为 GB
      totalMemoryGB: (SysInfo.getTotalPhysicalMemory() ~/ megabyte ~/ 1024),
      systemManufacturer: 'N/A (system_info2 not supported)',
      systemModel: 'N/A',
      gpuName: 'N/A (WMIC/system_info2 not supported)',
    );
  } catch (e) {
    print("获取静态硬件信息失败: $e");
    return HardwareInfo();
  }
});
