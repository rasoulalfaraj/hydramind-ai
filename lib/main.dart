import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app/controller.dart';
import 'core/database/vault.dart';
import 'core/domain/models.dart';
import 'core/services/reminder_service.dart';
import 'core/theme/design.dart';
import 'features/onboarding.dart';
import 'features/dashboard.dart';
import 'features/history.dart';
import 'features/coach.dart';
import 'features/analytics.dart';
import 'features/settings.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final vault = await Vault.open();
    // Load only after the encrypted vault has opened. Never erase on failure.
    final initial = await vault.load();
    final container = ProviderContainer(
      overrides: [
        vaultProvider.overrideWithValue(vault),
        initialProvider.overrideWithValue(initial),
      ],
    );
    final reminders = container.read(reminderProvider);
    Future<void> handle(NotificationResponse response) async {
      try {
        final controller = container.read(appProvider.notifier);
        await controller.mutate(
          (s) => s.patch({
            'notifications': [
              ...s.notificationHistory,
              {
                'at': DateTime.now().toUtc().toIso8601String(),
                'action': response.actionId ?? 'open',
              },
            ].reversed.take(100).toList().reversed.toList(),
          }),
        );
        if (response.actionId == 'add') {
          await controller.add(250, Drink.water, DateTime.now(), '');
        }
        if (response.actionId == 'snooze') {
          await reminders.snooze(
            container.read(appProvider),
            lookupAppLocalizations(
              Locale(container.read(appProvider).language),
            ),
          );
        }
      } catch (_) {
        /* A failed write never changes the displayed persistent state. */
      }
    }

    try {
      await reminders.init((r) => unawaited(handle(r)));
      final launch = await reminders.plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp == true &&
          launch?.notificationResponse != null) {
        await handle(launch!.notificationResponse!);
      }
    } catch (_) {
      reminders.initialized = false;
    }
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const HydraMindApp(),
      ),
    );
  } catch (_) {
    runApp(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: hydraTheme(Brightness.light),
        home: Builder(
          builder: (c) => Scaffold(
            body: SafeArea(
              child: PageBody(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.lock_outline, size: 64, color: ocean),
                  Text(c.l.storageError),
                  FilledButton(onPressed: main, child: Text(c.l.retry)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HydraMindApp extends ConsumerStatefulWidget {
  const HydraMindApp({super.key});
  @override
  ConsumerState<HydraMindApp> createState() => _HydraMindAppState();
}

class _HydraMindAppState extends ConsumerState<HydraMindApp>
    with WidgetsBindingObserver {
  Timer? timer;
  Future<void> queued = Future.value();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => schedule());
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void schedule() {
    queued = queued
        .catchError((Object _) {})
        .then((_) async {
          if (!mounted) return;
          final d = ref.read(appProvider);
          if (d.onboarded) {
            await ref
                .read(reminderProvider)
                .schedule(d, lookupAppLocalizations(Locale(d.language)));
          }
        })
        .catchError((Object _) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      schedule();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final d = ref.watch(appProvider);
    ref.listen(appProvider, (previous, next) {
      if (previous?.reminderSignature != next.reminderSignature) schedule();
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (c) => c.l.appName,
      locale: Locale(d.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: hydraTheme(Brightness.light),
      darkTheme: hydraTheme(Brightness.dark),
      themeMode: switch (d.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      routes: {
        '/privacy': (c) => Scaffold(
          appBar: AppBar(title: Text(c.l.privacy)),
          body: const PrivacyScreen(),
        ),
      },
      home: d.onboarded ? const AppShell() : const ProfileWizard(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  @override
  Widget build(BuildContext c) {
    final l = c.l,
        labels = [l.home, l.history, l.coach, l.analytics, l.settings];
    const icons = [
      Icons.grid_view_rounded,
      Icons.receipt_long_outlined,
      Icons.auto_awesome,
      Icons.insights,
      Icons.tune,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [ocean, turquoise]),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              index == 0 ? l.appName : labels[index],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: const [
            Dashboard(),
            HistoryScreen(),
            CoachScreen(),
            AnalyticsScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: List.generate(
          5,
          (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
        ),
      ),
    );
  }
}
