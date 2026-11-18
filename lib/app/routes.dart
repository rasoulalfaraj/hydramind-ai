import 'package:flutter/material.dart';
import '../core/theme/design.dart';
import '../features/onboarding.dart';
import '../features/weather.dart';
import '../features/reminders.dart';
import '../features/settings.dart';
import '../features/analytics.dart';

enum Detail {
  profile,
  weather,
  heat,
  reminders,
  habits,
  safety,
  achievements,
  health,
  privacy,
  cloud,
  language,
}

String detailTitle(BuildContext c, Detail p) => switch (p) {
  Detail.profile => c.l.profile,
  Detail.weather => c.l.weather,
  Detail.heat => c.l.iraqHeat,
  Detail.reminders => c.l.reminders,
  Detail.habits => c.l.habits,
  Detail.safety => c.l.safety,
  Detail.achievements => c.l.achievements,
  Detail.health => c.l.health,
  Detail.privacy => c.l.privacy,
  Detail.cloud => c.l.cloudSetup,
  Detail.language => c.l.language,
};
void openDetail(BuildContext c, Detail p) => Navigator.push(
  c,
  MaterialPageRoute<void>(
    builder: (c) => p == Detail.profile
        ? const ProfileWizard(editing: true)
        : Scaffold(
            appBar: AppBar(title: Text(detailTitle(c, p))),
            body: switch (p) {
              Detail.weather => const WeatherScreen(),
              Detail.heat => const HeatScreen(),
              Detail.reminders => const ReminderScreen(),
              Detail.habits => const HabitScreen(),
              Detail.safety => const SafetyScreen(),
              Detail.achievements => const AchievementScreen(),
              Detail.health => const HealthScreen(),
              Detail.privacy => const PrivacyScreen(),
              Detail.cloud => const CloudScreen(),
              Detail.language => const LanguageScreen(),
              _ => const SizedBox.shrink(),
            },
          ),
  ),
);
