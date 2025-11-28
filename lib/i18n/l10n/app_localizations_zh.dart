import 'app_localizations.dart';

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Windows 系统控制台';

  @override
  String get opShutdown => '定时关机';

  @override
  String get opRestart => '定时重启';

  @override
  String get opHibernate => '定时休眠';

  @override
  String get opCancel => '取消任务';

  @override
  String get statusReady => '系统就绪';

  @override
  String get statusScheduled => '定时任务已启动';

  @override
  String get statusNoTask => '当前无定时任务';

  @override
  String logTaskStarted(Object time) {
    return '任务已计划在 $time 执行。';
  }

  @override
  String get logTaskAborted => '用户已取消当前任务。';

  @override
  String get logCommandFailed => '命令执行失败：请检查权限。';

  @override
  String get timeUnitMinutes => '分钟';

  @override
  String get opSchedule => '启动定时';
}
