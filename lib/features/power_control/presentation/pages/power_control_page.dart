//这个页面将作为应用侧边栏切换后的主要内容
//不执行系统命令，只负责监听状态、收集用户输入，并将指令发送给 PowerController

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../i18n/l10n/app_localizations.dart';
import '../../../../i18n/localization_manager.dart';
import '../../application/power_controller.dart';
import '../../domain/power_task.dart';


class PowerControlPage extends ConsumerStatefulWidget {
  const PowerControlPage({super.key});

  // 使用 ConsumerStatefulWidget 来访问 Riverpod 状态
  //允许许 State 对象_PowerControlPageState 访问 Riverpod 容器，从而读取或监听全局状态（例如 PowerController）
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PowerControlPageState();
}

class _PowerControlPageState extends ConsumerState<PowerControlPage> {
  //默认选择30分钟
  double _selectedDelayMinutes = 30;

  @override
  Widget build(BuildContext context) {
    //引入新的本地化管理器
    // 使用 ref.t 扩展属性，它返回 LocalizationManager.notifier
    final manager = ref.t;
    //监听PowerController的状态(当前任务)
    // 如果状态发生变化（例如启动、取消），即重新运行build 方法来更新 UI。
    final currentTask = ref.watch(powerControllerProvider);
    // 监听 PowerController 的实例（用于执行操作）
    // 获取 PowerController 的实例（Notifier 对象）

    final controller = ref.read(powerControllerProvider.notifier);

    // 监听 PowerOperation 的选中状态
    final selectedOperation = ref.watch(selectedOperationProvider);
    // 获取 Notifier，用于更新状态
    final selectedOperationNotifier =
        ref.read(selectedOperationProvider.notifier);

    //判断是否有任务在执行
    final bool isTaskRuning = currentTask.operation != PowerOperation.abort;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            child: Container(
              padding: const EdgeInsets.all(40.0),
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //标题/状态显示
                  Text(
                    manager.translate(isTaskRuning ? 'statusScheduled' : 'statusReady'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: isTaskRuning
                              ? colorScheme.primary
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.blueGrey,
                          fontSize: 28,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //倒计时/选择时间区域
                  _buildTimeDisplay(
                      context, currentTask, isTaskRuning, controller,manager),
                  const SizedBox(height: 40),

                  //操作选择区域 (关机/重启/休眠)
                  _buildOperationSelector(manager, colorScheme, isTaskRuning,
                      selectedOperation, selectedOperationNotifier),
                  const SizedBox(
                    height: 40,
                  ),

                  // 主要操作按钮 (启动/取消)
                  isTaskRuning
                      ? _buildCancelButton(manager, controller)
                      : _buildScheduleButton(manager, colorScheme, controller,selectedOperation),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 辅助构建方法 ---

  // 在 PowerControlPage 中添加一个辅助方法（或直接在 build 中实现）：
  String _getOperationName(PowerOperation op, LocalizationManager manager) {
    switch (op) {
      case PowerOperation.shutdown:
        return manager.translate('opShutdown');
      case PowerOperation.restart:
        return manager.translate('opRestart');
      case PowerOperation.hibernate:
        return manager.translate('opHibernate');
      default:
        return manager.translate('opCancel');
    }
  }

  // 倒计时或时间选择器
  Widget _buildTimeDisplay(BuildContext context, PowerTask currentTask,
      bool isTaskRunning, PowerController controller,LocalizationManager manager) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isTaskRunning) {
      return StreamBuilder<Duration>(
        stream: controller.countdownStream,
        builder: (context, snapshot) {
          final remaining = snapshot.data ?? currentTask.duration;
          final totalMinutes = currentTask.duration.inMinutes;
          final remainingSeconds = remaining.inSeconds;

          // 格式化时间： HH:MM:SS
          final String timeText = [
            if (remaining.inHours > 0)
              remaining.inHours.toString().padLeft(2, "0"),
            (remaining.inMinutes % 60).toString().padLeft(2, "0"),
            (remaining.inSeconds % 60).toString().padLeft(2, "0"),
          ].join(":");

          // TODO: 下一阶段优化为 CustomPainter 环形进度条
          return Column(
            children: [
              Text(
                timeText,
                style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w100,
                    color: colorScheme.primary,
                    fontFamily: "monospace"),
              ),
              Text(
                manager.translate('statusScheduled') + "(${_getOperationName(currentTask.operation, manager)})",
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              )
            ],
          );
        },
      );
    } else {
      // 否则显示时间选择滑块
      return Column(
        children: [
          Text(
            manager.translate('statusNoTask'),
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "${_selectedDelayMinutes.round()}${manager.translate('timeUnitMinutes')}",
            // 假设 'timeUnitMinutes' 在 ARB 中是 '分钟'
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary),
          ),
          Slider(
            value: _selectedDelayMinutes,
            min: 5,
            max: 120,
            divisions: 23,
            //分5钟一档
            label: "${_selectedDelayMinutes.round()} ${manager.translate('timeUnitMinutes')}",
            onChanged: (double value) {
              setState(() {
                _selectedDelayMinutes = value;
              });
            },
          ),
        ],
      );
    }
  }

  //操作类型选择器
  Widget _buildOperationSelector(
      LocalizationManager manager,
      ColorScheme colorScheme,
      bool isTaskRunning,
      PowerOperation selectedOperation,
      StateController<PowerOperation> selectedOperationNotifier) {
    // 创建操作类型列表，并映射到多语言文本
    final List<PowerOperation> options = [
      PowerOperation.shutdown,
      PowerOperation.restart,
      PowerOperation.hibernate,
    ];

    final Map<PowerOperation, String> labels = {
      PowerOperation.shutdown: manager.translate('opShutdown'),
      PowerOperation.restart: manager.translate('opRestart'),
      PowerOperation.hibernate: manager.translate('opHibernate'),
    };

    // 使用 SegmentedButton 来实现科幻感的按钮组
    return AbsorbPointer(
        // 任务运行时禁用选择器,让用户不能再切换
        absorbing: isTaskRunning,
        child: SegmentedButton<PowerOperation>(
          style: SegmentedButton.styleFrom(
              selectedBackgroundColor: colorScheme.primary,
              selectedForegroundColor: Colors.black, // 选中时文字颜色
              backgroundColor: colorScheme.surface.withOpacity(0.5) //未选中时半透明
              ),
          segments: options
              .map((op) => ButtonSegment<PowerOperation>(
                    value: op,
                    label: Text(labels[op] ?? ""),
                    icon: Icon(_getIconForOperation(op)),
                  ))
              .toList(),
          selected: {selectedOperation},
          onSelectionChanged: (Set<PowerOperation> newSelection) {
            // 写入 Riverpod 状态
            selectedOperationNotifier.state = newSelection.first;
          },
        ));
  }

  // 启动任务按钮
  Widget _buildScheduleButton(
      LocalizationManager manager,
      ColorScheme colorScheme,
      PowerController controller,
      PowerOperation selectedOperation) {
    return FilledButton.icon(
      onPressed: () {
        final delay = Duration(minutes: _selectedDelayMinutes.round());
        controller.schedule(selectedOperation, delay);
      },
      label: Text(
        // 假设 'opSchedule' 在 ARB 中是 '启动定时'
        manager.translate('opSchedule'),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

// 取消任务按钮
  Widget _buildCancelButton(LocalizationManager manager, PowerController controller) {
    return OutlinedButton.icon(
      onPressed: controller.abortTask,
      icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
      label: Text(
          manager.translate('opCancel'),
        style: const TextStyle(fontSize: 18, color: Colors.redAccent),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: const BorderSide(color: Colors.redAccent, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  IconData _getIconForOperation(PowerOperation op) {
    switch (op) {
      case PowerOperation.shutdown:
        return Icons.power_settings_new;
      case PowerOperation.restart:
        return Icons.restart_alt;
      case PowerOperation.hibernate:
        return Icons.bedtime_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
