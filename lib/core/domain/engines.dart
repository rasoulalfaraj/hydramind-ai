import 'models.dart';

class HydrationEstimate {
  final int? beverageMl;
  final String basis;
  final bool medicalReview;
  const HydrationEstimate(this.beverageMl, this.basis, this.medicalReview);
}

class HydrationEngine {
  // EFSA 2010 total-water population references; illustrative 20% food share.
  // Midpoint 1800 ml is an assumption when no sex reference is selected.
  // No weight, per-degree, pregnancy or exercise dose multipliers are used.
  static HydrationEstimate estimate(Profile p) {
    if (p.fluidLimit != null) {
      return HydrationEstimate(p.fluidLimit, 'prescribed', true);
    }
    if (p.age < 18 ||
        p.medicalCaution ||
        p.pregnancy ||
        p.breastfeeding ||
        p.medications.isNotEmpty ||
        p.medicalNotes.isNotEmpty) {
      return const HydrationEstimate(null, 'review', true);
    }
    return HydrationEstimate(
      p.sex == 'female'
          ? 1600
          : p.sex == 'male'
          ? 2000
          : 1800,
      'population',
      false,
    );
  }
}

enum SafetyFlag { rapid, limit, highDaily, medical }

class SafetyEngine {
  // App review triggers, not clinical safe maxima or diagnoses.
  static Set<SafetyFlag> assess(Profile p, List<Intake> entries, DateTime now) {
    final result = <SafetyFlag>{};
    final hour = entries
        .where(
          (e) =>
              !e.at.isAfter(now) &&
              now.difference(e.at) < const Duration(hours: 1),
        )
        .fold(0, (a, e) => a + e.ml);
    final today = intakeForDay(
      entries.where((e) => !e.at.isAfter(now)).toList(),
      now,
    );
    if (hour >= 1000) result.add(SafetyFlag.rapid);
    if (today >= 4000) result.add(SafetyFlag.highDaily);
    if (p.fluidLimit != null && today >= p.fluidLimit!) {
      result.add(SafetyFlag.limit);
    }
    if (HydrationEngine.estimate(p).medicalReview) {
      result.add(SafetyFlag.medical);
    }
    return result;
  }

  static String validatedTopic(
    String? topic,
    Profile p,
    List<Intake> entries,
    DateTime now, {
    String prompt = '',
  }) {
    if (topic == 'emergency' ||
        RegExp(
          r'heatstroke|confus|faint|seizure|chest pain|shortness of breath|ضربة شمس|إغماء|اغماء|تشنج|ارتباك|ألم الصدر|فقد الوعي|اختلاجات|صعوبة التنفس',
          caseSensitive: false,
        ).hasMatch(prompt)) {
      return 'emergency';
    }
    final f = assess(p, entries, now);
    if (f.contains(SafetyFlag.rapid) ||
        f.contains(SafetyFlag.limit) ||
        f.contains(SafetyFlag.highDaily)) {
      return 'safety';
    }
    if (HydrationEngine.estimate(p).medicalReview) return 'medical';
    return const {
          'target',
          'weather',
          'habits',
          'routine',
          'safety',
          'general',
        }.contains(topic)
        ? topic!
        : 'general';
  }
}

class HeatEngine {
  // Informational UI triggers, not official warnings/WBGT or clinical limits.
  static int level(Weather? w, DateTime now) {
    if (w == null || w.isStale(now)) return 0;
    if (w.temperature >= 40 || w.feels >= 40) return 3;
    if (w.temperature >= 35 || w.feels >= 32) return 2;
    return w.feels >= 27 ? 1 : 0;
  }
}

class HabitInsight {
  final int days;
  final int? quietHour;
  final double? expected;
  final int? likelihood;
  const HabitInsight(this.days, this.quietHour, this.expected, this.likelihood);
}

class HabitEngine {
  static HabitInsight analyze(
    List<Intake> entries,
    DateTime now,
    int? target, {
    int wakeMinute = 420,
    int bedMinute = 1380,
  }) {
    final prior = entries
        .where(
          (e) =>
              e.at.isBefore(dayStart(now)) &&
              !e.at.isBefore(dayStart(now).subtract(const Duration(days: 28))),
        )
        .toList();
    final days = prior.map((e) => dayKey(e.at)).toSet();
    if (days.length < 7) return HabitInsight(days.length, null, null, null);
    final counts = List.filled(24, 0);
    for (final e in prior) {
      counts[e.at.hour]++;
    }
    final hours =
        List.generate(24, (i) => i)
            .where((h) => ReminderEngine.isAwake(h * 60, wakeMinute, bedMinute))
            .toList()
          ..sort((a, b) => counts[a].compareTo(counts[b]));
    final current = intakeForDay(entries, now);
    final projections = days
        .map(
          (day) =>
              current +
              prior
                  .where(
                    (e) =>
                        dayKey(e.at) == day &&
                        e.at.hour * 60 + e.at.minute >
                            now.hour * 60 + now.minute,
                  )
                  .fold(0, (a, e) => a + e.ml),
        )
        .toList();
    return HabitInsight(
      days.length,
      hours.isEmpty ? null : hours.first,
      projections.reduce((a, b) => a + b) / projections.length,
      target == null
          ? null
          : (100 *
                    projections.where((p) => p >= target).length /
                    projections.length)
                .round(),
    );
  }
}

class ReminderEngine {
  static bool isAwake(int minute, int wake, int bed) => wake == bed
      ? false
      : wake < bed
      ? minute >= wake && minute < bed
      : minute >= wake || minute < bed;
  static List<DateTime> schedule(
    DateTime now,
    Profile p,
    int interval, {
    int maxCount = 48,
    DateTime Function(int, int, int, int, int)? wallTime,
  }) {
    if (interval < 15 || interval > 720) throw ArgumentError('interval');
    final make =
        wallTime ??
        ((int y, int m, int d, int h, int min) => DateTime(y, m, d, h, min));
    final result = <DateTime>[], seen = <int>{};
    for (var day = 0; day < 4 && result.length < maxCount; day++) {
      final d = make(now.year, now.month, now.day + day, 0, 0);
      for (
        var minute = 0;
        minute < 1440 && result.length < maxCount;
        minute += interval
      ) {
        if (!isAwake(minute, p.wakeMinute, p.bedMinute)) continue;
        final t = make(d.year, d.month, d.day, minute ~/ 60, minute % 60);
        if (isAwake(t.hour * 60 + t.minute, p.wakeMinute, p.bedMinute) &&
            t.isAfter(now) &&
            seen.add(t.millisecondsSinceEpoch)) {
          result.add(t);
        }
      }
    }
    return result;
  }

  static List<DateTime> plan(
    AppData d,
    DateTime now, {
    DateTime Function(int, int, int, int, int)? wallTime,
  }) {
    if (!d.reminders) return [];
    final slots = schedule(now, d.profile, d.interval, wallTime: wallTime);
    if (!d.adaptive) return slots;
    final target = HydrationEngine.estimate(d.profile).beverageMl;
    return slots.where((t) {
      if (target != null &&
          intakeForDay(d.entries, now) >= target &&
          dayKey(t) == dayKey(now)) {
        return false;
      }
      return !d.entries.any(
        (e) =>
            !e.at.isAfter(now) &&
            t.isAfter(e.at) &&
            t.difference(e.at) < const Duration(minutes: 45),
      );
    }).toList();
  }
}

class AnalyticsEngine {
  static List<int> totals(List<Intake> entries, DateTime now, int days) =>
      List.generate(
        days,
        (i) => intakeForDay(
          entries,
          DateTime(now.year, now.month, now.day - days + i + 1),
        ),
      );
  static int streak(List<Intake> entries, DateTime now) {
    var result = 0;
    for (var i = 0; i < 366; i++) {
      if (intakeForDay(entries, DateTime(now.year, now.month, now.day - i)) >
          0) {
        result++;
      } else if (i != 0) {
        break;
      }
    }
    return result;
  }
}
