// 定义操作类型
import 'package:flutter/cupertino.dart';

enum PowerOperation{
  shutdown,//关机
  restart,//重启
  hibernate,//休眠
  abort,//取消任务
}



//定义任务模型
class PowerTask {
  //定义了一个全局唯一的 当前没有定时任务在运行
  static const PowerTask empty = PowerTask(
    operation: PowerOperation.abort,
    duration:Duration.zero,
    scheduledAt:null,
  );

  //Riverpod推荐PowerTask 对象创建后不可修改,状态变化创建新对象
  final PowerOperation operation;
  final Duration duration;
  final DateTime? scheduledAt; //任务计划启动的时间点

  const PowerTask({
    required this.operation,
    required this.duration,
    required this.scheduledAt,
});

@override
  String toString() {
    // TODO: implement toString
  // 现在我们可以使用枚举的 name 属性作为日志 key
  if (operation == PowerOperation.abort) return "Task: None (Abort)";
  // ⚠️ 注意：这里仍然硬编码，因为 toString() 不应该依赖 Context
  return 'Task: ${operation.name}, Delay: ${duration.inMinutes} mins';
  }

}