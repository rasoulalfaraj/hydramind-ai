import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydramind/main.dart';
import 'package:hydramind/app/controller.dart';
import 'package:hydramind/core/domain/models.dart';
import 'package:hydramind/core/database/vault.dart';
import 'package:hydramind/core/services/reminder_service.dart';
import 'package:hydramind/l10n/app_localizations.dart';

class DeviceFreeReminders extends ReminderService {
  @override
  Future<void> schedule(AppData d, AppLocalizations l) async {}
}

Future<ProviderContainer> setup(WidgetTester tester, AppData initial) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  final vault = Vault(
    VaultDatabase(NativeDatabase.memory()),
    await AesGcm.with256bits().newSecretKey(),
  );
  final container = ProviderContainer(
    overrides: [
      vaultProvider.overrideWithValue(vault),
      initialProvider.overrideWithValue(initial),
      reminderProvider.overrideWithValue(DeviceFreeReminders()),
    ],
  );
  addTearDown(() async {
    container.dispose();
    await vault.db.close();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const HydraMindApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo.ttf'));
    await loader.load();
  });
  testWidgets(
    'First install stays Arabic RTL on an English OS and language persists',
    (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final c = await setup(tester, AppData());
      expect(find.text('لنتعرّف عليك'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('لنتعرّف عليك'))),
        TextDirection.rtl,
      );
      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(find.text('About you'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('About you'))),
        TextDirection.ltr,
      );
      expect((await c.read(vaultProvider).load()).language, 'en');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Arabic dashboard, persistent logs and all navigation tabs connect',
    (tester) async {
      final c = await setup(
        tester,
        AppData(
          onboarded: true,
          profile: const Profile(name: 'سارة'),
          entries: [
            Intake(id: 'x', ml: 250, drink: Drink.water, at: DateTime.now()),
          ],
        ),
      );
      expect(find.textContaining('سارة'), findsWidgets);
      await tester.tap(find.text('السجل'));
      await tester.pump();
      expect(find.text('كل السجلات'), findsOneWidget);
      await c
          .read(appProvider.notifier)
          .add(150, Drink.tea, DateTime.now(), '');
      await tester.pump();
      expect((await c.read(vaultProvider).load()).entries.length, 2);
      await tester.tap(find.text('الإحصائيات'));
      await tester.pump();
      expect(find.text('حسب المشروب'), findsOneWidget);
      await tester.tap(find.text('الإعدادات'));
      await tester.pump();
      expect(find.text('الخصوصية والبيانات'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Large English text and reduced motion render LTR without overflow',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await setup(tester, AppData(onboarded: true, language: 'en'));
      expect(
        Directionality.of(tester.element(find.text('Home'))),
        TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Arabic onboarding persists each step and completes after consent',
    (tester) async {
      final c = await setup(tester, AppData());
      await tester.enterText(find.byType(TextFormField).first, 'ليان');
      Future<void> next() async {
        await tester.ensureVisible(find.text('التالي'));
        await tester.tap(find.text('التالي'));
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        await tester.pump();
      }

      await next();
      expect(c.read(appProvider).onboardingStep, 1);
      await next();
      expect(find.text('صحتك أولاً'), findsOneWidget);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.ensureVisible(find.text('لنبدأ'));
      await tester.tap(find.text('لنبدأ'));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(c.read(appProvider).onboarded, isTrue);
      expect((await c.read(vaultProvider).load()).profile.name, 'ليان');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
