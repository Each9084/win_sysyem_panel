//实现系统控制逻辑

// --- Riverpod Provider 定义 ---

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win_system_panel/features/power_control/domain/power_task.dart';

// 全局访问 PowerController 的实例和状态
//Riverpod 框架中用于创建和管理业务逻辑类（PowerController）的入口点
//实现 依赖注入（Dependency Injection, DI） 和 响应式状态管理
final powerControllerProvider =
//ref 是 Riverpod 传递的一个对象，它负责处理依赖注入和资源清理。
    StateNotifierProvider<PowerController, PowerTask>((ref) {
  return PowerController();
});

class PowerController extends StateNotifier<PowerTask> {
  // 状态默认为空任务 (无任务)
  //构造函数 super() 用于调用父类 StateNotifier 的构造函数,将 StateNotifier初始状态设置为 PowerTask.empty。
  PowerController() : super(PowerTask.empty);

  //存储 Timer.periodic 的实例 设定的时间间隔（例如每秒）触发回调的工具。
  // ?是不希望在 Controller 刚创建时就启动计时器和 Stream，只有当用户真正启动任务时才需要。
  Timer? _countdownTimer;

  //数据流的核心控制对象,允许“注入”数据（每秒剩余的 Duration），然后让 UI 监听这些数据。
  StreamController<Duration>? _timerStreamController;

// 提供给 UI 的倒计时 Stream,这是一个getter为外部（即 UI 层）提供了一个可监听的接口
  Stream<Duration> get countdownStream {
    //随时变化的数据(倒计时) 就先显得很科幻感
    _timerStreamController ??= StreamController<Duration>.broadcast();
    return _timerStreamController!.stream;
  }

  // ----------------------------------------------------
  // 核心业务方法：调度电源操作
  // ----------------------------------------------------

  Future<void> schedule(PowerOperation operation, Duration delay) async {
    // 取消任何现有的任务和计时器 确保在启动新任务之前，取消所有可能正在运行的旧任务。
    await abortTask();

    // 计算出定时任务实际执行的具体时间点
    final scheduledTime = DateTime.now().add(delay);

    //更新状态
    state = PowerTask(
      operation: operation,
      duration: delay,
      scheduledAt: scheduledTime,
    );

    //执行indows 命令行
    //这里让 Windows 的 shutdown 命令来处理定时，更稳定。
    final seconds = delay.inSeconds;
    String command;
    List<String> args = [];

    //Dart 3.0 及更高版本中,switch 语句被设计为穷尽性检查
    //当对一个枚举类型（enum，比如 PowerOperation）进行 switch 判断时，Dart 编译器要求必须确保：
    // 1.处理了所有的枚举值（shutdown, restart, hibernate, abort）。
    // 2.或者，提供一个默认的 default 语句来捕获所有未明确列出的值。
    switch (operation) {
      case PowerOperation.shutdown:
        command = "shutdown";
        args = ["/s", "/t", "$seconds", "/f"]; // /s:关机 /t:延迟 /f:强制关闭
        break;

      case PowerOperation.restart:
        command = "shutdown";
        args = ["/r", "/t", "$seconds", "/f"]; // /r:重启
        break;
      case PowerOperation.hibernate:
        // Windows没有定时休眠的 shutdown 命令，只能立即执行。
        // 我们这里使用 shutdown /s (关机) 并让用户理解为最接近的“断电”操作。
        // *专业做法是使用 /h (休眠) 但它不支持 /t (定时)，需应用层监听倒计时。
        // 为了简化，我们暂时用 /s /t。未来再优化休眠逻辑。
        command = "shutdown";
        args = ["/s", "/t", "second", "/f"];
        break;
      case PowerOperation.abort:
        return; //不执行
    }

    try {
      final result = await Process.run(command, args, runInShell: true);
      //0代表命令成功执行
      if (result.exitCode != 0) {
        print("命令执行失败:${result.stderr}");
      }
      //启动 Flutter 内部计时器来实时更新 UI 倒计时
      _startInternalTimer();
    } catch (e) {
      print("执行命令时出错: $e");
      state = PowerTask.empty; // 失败则清空任务
    }
  }

  // ----------------------------------------------------
  // 核心业务方法：取消任务
  // ----------------------------------------------------
  Future<void> abortTask() async {
    // 1. 执行 Windows 取消命令
    await Process.run("shutdown", ['/a'], runInShell: true);

    //2. 清理 Flutter 内部资源
    _countdownTimer?.cancel();
    _timerStreamController?.close();
    _timerStreamController = null;

    //3.更新状态
    state = PowerTask.empty;
  }

  // ----------------------------------------------------
  // 内部方法：控制 UI 倒计时
  // ----------------------------------------------------
  void _startInternalTimer() {
    _countdownTimer?.cancel(); //取消现有的倒计时

    //检查状态是否有效
    if (state.scheduledAt == null) return;

    //每秒更新一次
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {

      //计算剩余时间
      final remianing = state.scheduledAt!.difference(DateTime.now());

      if (remianing.isNegative) {
        // 倒计时结束,清理
        //?是为了不为null再调用,如果都是null了那就说明已经结束了,没必要cancel了
        _countdownTimer?.cancel();
        //向所有坚挺的widget发送结束信号
        _timerStreamController?.close();
        //垃圾回收机制,虽然close了stream的数据流,但是这个变量本身还占用着空间
        _timerStreamController = null;
        state = PowerTask.empty;
      } else {
        //发送剩余时间 Stream (UI 监听并刷新)
        _timerStreamController?.add(remianing);
      }
    });
  }

  //资源清理
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timerStreamController?.close();
    super.dispose();
  }
}
