import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydramind/core/domain/models.dart';
import 'package:hydramind/core/services/reminder_service.dart';
import 'package:hydramind/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications'),
      zone = MethodChannel('flutter_timezone');
  final calls = <MethodCall>[];
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(zone, (_) async => 'Asia/Baghdad');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'requestNotificationsPermission' ? false : true;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(zone, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test('Denied native permission remains denied', () async {
    final s = ReminderService();
    await s.init((_) {});
    expect(await s.permission(), isFalse);
  });
  test('Native queue is bounded and uses Arabic inexact scheduling', () async {
    final s = ReminderService();
    await s.init((_) {});
    final l = lookupAppLocalizations(const Locale('ar'));
    await s.schedule(AppData(reminders: true), l);
    final scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(scheduled, isNotEmpty);
    expect(scheduled.length, lessThanOrEqualTo(48));
    expect((scheduled.first.arguments as Map)['title'], l.notificationTitle);
    expect(
      ((scheduled.first.arguments as Map)['platformSpecifics']
          as Map)['scheduleMode'],
      'inexactAllowWhileIdle',
    );
  });
  test(
    'Medical reminders use review guidance, never drinking prompts',
    () async {
      final s = ReminderService();
      await s.init((_) {});
      final l = lookupAppLocalizations(const Locale('ar'));
      await s.schedule(
        AppData(reminders: true, profile: const Profile(fluidLimit: 1000)),
        l,
      );
      final first =
          calls.firstWhere((c) => c.method == 'zonedSchedule').arguments as Map;
      expect(first['title'], l.notificationReviewTitle);
      expect(first['body'], l.notificationSafetyBody);
    },
  );
  test('Pausing cancels notifications without rescheduling', () async {
    final s = ReminderService();
    await s.init((_) {});
    await s.schedule(AppData(), lookupAppLocalizations(const Locale('ar')));
    expect(calls.any((c) => c.method == 'cancelAll'), isTrue);
    expect(calls.any((c) => c.method == 'zonedSchedule'), isFalse);
  });
}
