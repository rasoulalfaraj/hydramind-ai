import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;
import 'package:hydramind/core/domain/models.dart';
import 'package:hydramind/core/domain/engines.dart';

void main() {
  final now = DateTime(2026, 7, 15, 12);
  Intake log(int ml, DateTime at, {String id = '1'}) =>
      Intake(id: id, ml: ml, drink: Drink.water, at: at);
  test('Adult population estimate and food share are explicit', () {
    expect(
      HydrationEngine.estimate(const Profile(sex: 'female')).beverageMl,
      1600,
    );
    expect(
      HydrationEngine.estimate(const Profile(sex: 'male')).beverageMl,
      2000,
    );
    expect(HydrationEngine.estimate(const Profile()).beverageMl, 1800);
  });
  test('Medical limit takes priority over activity and pregnancy', () {
    expect(
      HydrationEngine.estimate(
        const Profile(
          fluidLimit: 1200,
          activity: Activity.active,
          pregnancy: true,
          weight: 160,
        ),
      ).beverageMl,
      1200,
    );
  });
  test('Children and health cautions receive no automated target', () {
    for (final p in [
      const Profile(age: 12),
      const Profile(medicalCaution: true),
      const Profile(pregnancy: true),
      const Profile(breastfeeding: true),
      const Profile(medications: 'fluid medicine'),
      const Profile(medicalNotes: 'condition'),
    ]) {
      expect(HydrationEngine.estimate(p).beverageMl, isNull);
    }
  });
  test('No unsupported weight or activity multipliers', () {
    expect(
      HydrationEngine.estimate(
        const Profile(weight: 150, activity: Activity.active),
      ).beverageMl,
      1800,
    );
  });
  test('Rapid-volume flag uses rolling hour and excludes future logs', () {
    expect(
      SafetyEngine.assess(const Profile(), [
        log(500, now),
        log(500, now.subtract(const Duration(minutes: 59))),
      ], now),
      contains(SafetyFlag.rapid),
    );
    expect(
      SafetyEngine.assess(const Profile(), [
        log(500, now),
        log(500, now.subtract(const Duration(minutes: 61))),
        log(2000, now.add(const Duration(minutes: 5))),
      ], now),
      isNot(contains(SafetyFlag.rapid)),
    );
  });
  test('Prescribed ceiling and high daily volume are enforced', () {
    expect(
      SafetyEngine.assess(const Profile(fluidLimit: 800), [log(800, now)], now),
      contains(SafetyFlag.limit),
    );
    expect(
      SafetyEngine.assess(const Profile(), [
        log(4000, now.subtract(const Duration(hours: 3))),
      ], now),
      contains(SafetyFlag.highDaily),
    );
  });
  test('No AI topic bypasses the medical gate', () {
    for (final topic in [
      'target',
      'weather',
      'habits',
      'routine',
      'general',
      'unsafe prescription',
    ]) {
      expect(
        SafetyEngine.validatedTopic(topic, const Profile(fluidLimit: 800), [
          log(1000, now),
        ], now),
        'safety',
      );
      expect(
        SafetyEngine.validatedTopic(
          topic,
          const Profile(medicalCaution: true),
          [],
          now,
        ),
        'medical',
      );
    }
  });
  test('Urgent symptoms and provider emergency take priority', () {
    expect(
      SafetyEngine.validatedTopic(
        'target',
        const Profile(),
        [],
        now,
        prompt: 'لدي ارتباك مع الحر',
      ),
      'emergency',
    );
    expect(
      SafetyEngine.validatedTopic(
        'emergency',
        const Profile(fluidLimit: 800),
        [],
        now,
      ),
      'emergency',
    );
    expect(
      SafetyEngine.validatedTopic('drink 10 litres', const Profile(), [], now),
      'general',
    );
  });
  test('Arabic and Persian numeric entry normalizes correctly', () {
    expect(parseInt('٢٥٠'), 250);
    expect(parseDouble('٧٠٫٥'), 70.5);
    expect(parseInt('۵۰۰'), 500);
    expect(parseInt('١٢٫٥'), isNull);
  });
  test('Normal reminder plan stays awake and respects queue limit', () {
    final slots = ReminderEngine.schedule(now, const Profile(), 45);
    expect(slots, isNotEmpty);
    expect(slots.length, lessThanOrEqualTo(48));
    expect(
      slots.every((t) => t.isAfter(now) && t.hour >= 7 && t.hour < 23),
      isTrue,
    );
  });
  test('Night shift crosses midnight without sleep reminders', () {
    expect(
      ReminderEngine.schedule(
        now,
        const Profile(wakeMinute: 1320, bedMinute: 360),
        60,
      ).every((t) => t.hour >= 22 || t.hour < 6),
      isTrue,
    );
  });
  test('Invalid interval and empty wake window are handled', () {
    expect(
      () => ReminderEngine.schedule(now, const Profile(), 0),
      throwsArgumentError,
    );
    expect(
      ReminderEngine.schedule(
        now,
        const Profile(wakeMinute: 0, bedMinute: 0),
        60,
      ),
      isEmpty,
    );
  });
  test('DST spring gap is normalized without duplicate instants', () {
    data.initializeTimeZones();
    final zone = tz.getLocation('America/New_York');
    final times = ReminderEngine.schedule(
      tz.TZDateTime(zone, 2026, 3, 8),
      const Profile(wakeMinute: 60, bedMinute: 240),
      30,
      wallTime: (y, m, d, h, min) => tz.TZDateTime(zone, y, m, d, h, min),
    );
    expect(
      times.map((t) => t.millisecondsSinceEpoch).toSet().length,
      times.length,
    );
    expect(
      times.where((t) => t.day == 8).every((t) => t.hour == 1 || t.hour == 3),
      isTrue,
    );
  });
  test('Time zone rebuilding retains local waking hour', () {
    data.initializeTimeZones();
    for (final name in ['Asia/Baghdad', 'Europe/London']) {
      final zone = tz.getLocation(name);
      final times = ReminderEngine.schedule(
        tz.TZDateTime(zone, 2026, 7, 1, 6),
        const Profile(),
        60,
        wallTime: (y, m, d, h, min) => tz.TZDateTime(zone, y, m, d, h, min),
      );
      expect(times.first.hour, 7);
      expect((times.first as tz.TZDateTime).location.name, name);
    }
  });
  test('Adaptive plan suppresses recent drinking prompts', () {
    final d = AppData(reminders: true, interval: 30, entries: [log(250, now)]);
    expect(ReminderEngine.plan(d, now).first.hour, 13);
    expect(
      ReminderEngine.plan(d.patch({'adaptive': false}), now).first.minute,
      30,
    );
  });
  test('Meeting estimate stops reminders for today only', () {
    final slots = ReminderEngine.plan(
      AppData(reminders: true, entries: [log(1800, now)]),
      now,
    );
    expect(slots, isNotEmpty);
    expect(slots.every((t) => dayKey(t) != dayKey(now)), isTrue);
  });
  test('No fabricated habit prediction before seven prior days', () {
    final h = HabitEngine.analyze([log(500, now)], now, 1800);
    expect(h.expected, isNull);
    expect(h.quietHour, isNull);
  });
  test('History-based projections use actual rest-of-day amounts', () {
    final entries = [
      for (var i = 1; i <= 7; i++)
        log(1000, DateTime(2026, 7, 15 - i, 18), id: '$i'),
      log(500, now, id: 'today'),
    ];
    final h = HabitEngine.analyze(entries, now, 1800);
    expect(h.days, 7);
    expect(h.expected, 1500);
    expect(h.likelihood, 0);
  });
  test('Analytics preserves unlogged days as zero', () {
    expect(AnalyticsEngine.totals([log(250, now)], now, 7), [
      0,
      0,
      0,
      0,
      0,
      0,
      250,
    ]);
  });
  test('Stale or missing weather never becomes a live heat alert', () {
    final w = Weather(
      temperature: 49,
      feels: 51,
      humidity: 40,
      wind: 10,
      uv: 10,
      lat: 30,
      lon: 47,
      city: 'Basra',
      fetched: now.subtract(const Duration(hours: 2)),
      code: 0,
    );
    expect(HeatEngine.level(w, now), 0);
    expect(HeatEngine.level(null, now), 0);
  });
}
