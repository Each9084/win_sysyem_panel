import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Win System Panel';

  @override
  String get opShutdown => 'Shutdown';

  @override
  String get opRestart => 'Restart';

  @override
  String get opHibernate => 'Hibernate';

  @override
  String get opCancel => 'Cancel Task';

  @override
  String get statusReady => 'System Ready';

  @override
  String get statusScheduled => 'Scheduled Shutdown';

  @override
  String get statusNoTask => 'No Task Scheduled';

  @override
  String logTaskStarted(Object time) {
    return 'Task scheduled for $time.';
  }

  @override
  String get logTaskAborted => 'Task aborted by user.';

  @override
  String get logCommandFailed => 'Command execution failed: Check permissions.';

  @override
  String get timeUnitMinutes => 'minutes';

  @override
  String get opSchedule => 'Schedule Task';
}
