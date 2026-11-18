import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;
import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../domain/engines.dart';

final reminderProvider = Provider<ReminderService>((ref) => ReminderService());

class ReminderService {
  final plugin = FlutterLocalNotificationsPlugin();
  bool initialized = false;
  Future<void> zone() async {
    tz.setLocalLocation(
      tz.getLocation(await FlutterTimezone.getLocalTimezone()),
    );
  }

  Future<void> init(void Function(NotificationResponse) callback) async {
    data.initializeTimeZones();
    await zone();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: callback,
    );
    initialized = true;
  }

  Future<bool> permission() async =>
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission() ??
      await plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true, badge: true) ??
      false;
  NotificationDetails details(AppData d, AppLocalizations l) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          d.silent ? 'hydration_silent_v1' : 'hydration_v1',
          l.reminders,
          importance: Importance.defaultImportance,
          playSound: !d.silent,
          enableVibration: !d.silent,
          actions: [
            AndroidNotificationAction(
              'add',
              l.notificationAdd,
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'snooze',
              l.snooze,
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(presentSound: !d.silent),
      );
  Future<void> schedule(AppData d, AppLocalizations l) async {
    if (!initialized) {
      if (d.reminders) throw StateError('Notifications unavailable');
      return;
    }
    await zone();
    await plugin.cancelAll();
    if (!d.reminders) return;
    final slots = ReminderEngine.plan(
      d,
      tz.TZDateTime.now(tz.local),
      wallTime: (y, m, day, h, min) =>
          tz.TZDateTime(tz.local, y, m, day, h, min),
    );
    final caution = SafetyEngine.assess(
      d.profile,
      d.entries,
      DateTime.now(),
    ).isNotEmpty;
    for (var i = 0; i < slots.length; i++) {
      final hot =
          d.iraqHeat &&
          HeatEngine.level(d.weather, DateTime.now()) >= 2 &&
          slots[i].difference(d.weather!.fetched) < const Duration(hours: 1);
      await plugin.zonedSchedule(
        i + 1,
        caution ? l.notificationReviewTitle : l.notificationTitle,
        caution
            ? l.notificationSafetyBody
            : hot
            ? l.heatHigh
            : l.notificationBody,
        tz.TZDateTime.from(slots[i], tz.local),
        details(d, l),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'reminder',
      );
    }
  }

  Future<void> snooze(AppData d, AppLocalizations l) async {
    final now = tz.TZDateTime.now(tz.local),
        at = now.add(const Duration(minutes: 10));
    if (!ReminderEngine.isAwake(
      at.hour * 60 + at.minute,
      d.profile.wakeMinute,
      d.profile.bedMinute,
    )) {
      return;
    }
    final target = HydrationEngine.estimate(d.profile).beverageMl;
    if (d.adaptive &&
        target != null &&
        intakeForDay(d.entries, now) >= target) {
      return;
    }
    final caution = SafetyEngine.assess(d.profile, d.entries, now).isNotEmpty;
    await plugin.zonedSchedule(
      900,
      caution ? l.notificationReviewTitle : l.notificationTitle,
      caution ? l.notificationSafetyBody : l.notificationBody,
      at,
      details(d, l),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
