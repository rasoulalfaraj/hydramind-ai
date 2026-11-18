import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/controller.dart';
import '../app/routes.dart';
import '../core/database/vault.dart';
import '../core/domain/models.dart';
import '../core/domain/engines.dart';
import '../core/services/export_service.dart';
import '../core/services/reminder_service.dart';
import '../core/theme/design.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider), l = c.l;
    Widget link(IconData icon, Detail detail) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: ocean),
      title: Text(detailTitle(c, detail)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => openDetail(c, detail),
    );
    return PageBody(
      children: [
        Panel(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: ocean,
              child: Icon(Icons.person_outline, color: Colors.white),
            ),
            title: Text(d.profile.name.isEmpty ? l.friend : d.profile.name),
            subtitle: Text(l.profile),
            trailing: IconButton(
              onPressed: () => openDetail(c, Detail.profile),
              icon: const Icon(Icons.edit),
              tooltip: l.edit,
            ),
          ),
        ),
        Panel(
          child: Column(
            children: [
              link(Icons.language, Detail.language),
              DropdownButtonFormField<String>(
                initialValue: d.theme,
                decoration: InputDecoration(labelText: l.theme),
                items:
                    {'system': l.system, 'light': l.lightTheme, 'dark': l.dark}
                        .entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                onChanged: (v) => runAction(
                  c,
                  () => ref.read(appProvider.notifier).patch({'theme': v}),
                ),
              ),
              const SizedBox(height: 10),
              link(Icons.notifications_outlined, Detail.reminders),
              link(Icons.health_and_safety_outlined, Detail.safety),
              link(Icons.psychology_outlined, Detail.habits),
              link(Icons.wb_sunny_outlined, Detail.heat),
            ],
          ),
        ),
        Panel(
          child: Column(
            children: [
              link(Icons.workspace_premium_outlined, Detail.achievements),
              link(Icons.monitor_heart_outlined, Detail.health),
              link(Icons.cloud_outlined, Detail.cloud),
              link(Icons.lock_outline, Detail.privacy),
            ],
          ),
        ),
        Panel(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.iraqiDialect),
                value: d.iraqi,
                onChanged: (v) => runAction(
                  c,
                  () => ref.read(appProvider.notifier).patch({'iraqi': v}),
                ),
              ),
              TextFormField(
                initialValue: d.favorites.join(', '),
                decoration: InputDecoration(labelText: l.favorites),
                onFieldSubmitted: (text) => runAction(c, () async {
                  final cups = text
                      .replaceAll('،', ',')
                      .split(',')
                      .map(parseInt)
                      .toList();
                  if (cups.isEmpty ||
                      cups.length > 5 ||
                      cups.any((n) => n == null || n < 1 || n > 1000)) {
                    toast(c, l.invalid);
                    return;
                  }
                  await ref.read(appProvider.notifier).patch({
                    'favorites': cups.cast<int>(),
                  });
                  if (c.mounted) toast(c, l.saved);
                }),
              ),
            ],
          ),
        ),
        Text(
          '${l.appName} • 1.0.1\n${l.notMedical}',
          style: Theme.of(c).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider);
    return PageBody(
      children: [
        Panel(
          child: Column(
            children: {'ar': c.l.arabic, 'en': c.l.english}.entries
                .map(
                  (e) => ListTile(
                    title: Text(e.value),
                    leading: Icon(
                      d.language == e.key
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: ocean,
                    ),
                    onTap: () => runAction(
                      c,
                      () => ref.read(appProvider.notifier).patch({
                        'language': e.key,
                      }),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider),
        l = c.l,
        flags = SafetyEngine.assess(
          ref.watch(appProvider).profile,
          ref.watch(appProvider).entries,
          DateTime.now(),
        );
    return PageBody(
      children: [
        Notice(l.safetyAlways, icon: Icons.verified_user_outlined),
        ...flags.map((f) => Notice(safetyText(c, f), warning: true)),
        Notice(estimateText(c, d.profile)),
        FilledButton(
          onPressed: () => openDetail(c, Detail.profile),
          child: Text(l.profile),
        ),
        Notice(l.safetyEducation, warning: true),
        Notice(l.safetyThresholds),
        Notice(l.emergency, warning: true),
      ],
    );
  }
}

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final l = c.l;
    return PageBody(
      children: [
        Notice(l.privacyText, icon: Icons.lock_outline),
        FilledButton.icon(
          onPressed: () => runAction(c, () async {
            final box = c.findRenderObject() as RenderBox?;
            await ExportService.share(
              ref.read(appProvider).entries,
              l,
              origin: box == null
                  ? null
                  : box.localToGlobal(Offset.zero) & box.size,
            );
          }),
          icon: const Icon(Icons.download),
          label: Text(l.exportCsv),
        ),
        OutlinedButton(
          onPressed: () => runAction(c, () async {
            if (await confirmDelete(c)) {
              await ref.read(appProvider.notifier).patch({
                'entries': [],
                'targets': {},
              });
            }
          }),
          child: Text(l.deleteHistory),
        ),
        OutlinedButton(
          onPressed: () => runAction(c, () async {
            if (!await confirmDelete(c)) return;
            final reminders = ref.read(reminderProvider);
            if (reminders.initialized) await reminders.plugin.cancelAll();
            await ref.read(appProvider.notifier).erase();
            if (c.mounted) Navigator.popUntil(c, (r) => r.isFirst);
          }),
          child: Text(l.deleteAll),
        ),
      ],
    );
  }
}

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});
  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  final url = TextEditingController(), token = TextEditingController();
  bool consent = false, busy = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    await runAction(context, () async {
      url.text = await Vault.secure.read(key: 'backend_url') ?? '';
      token.text = await Vault.secure.read(key: 'backend_token') ?? '';
    });
    if (mounted) setState(() => busy = false);
  }

  @override
  void dispose() {
    url.dispose();
    token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final l = c.l;
    return PageBody(
      children: [
        Notice(l.setupInfo),
        Notice(l.privacyText),
        TextField(
          controller: url,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: l.backendUrl),
        ),
        TextField(
          controller: token,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(labelText: l.backendToken),
        ),
        CheckboxListTile(
          title: Text(l.cloudConsent),
          value: consent,
          onChanged: (v) => setState(() => consent = v ?? false),
        ),
        FilledButton(
          onPressed: busy || !consent
              ? null
              : () => runAction(c, () async {
                  final uri = Uri.tryParse(url.text.trim());
                  if (uri == null ||
                      uri.scheme != 'https' ||
                      uri.host.isEmpty ||
                      uri.hasQuery ||
                      uri.hasFragment ||
                      uri.userInfo.isNotEmpty ||
                      token.text.trim().length < 32) {
                    toast(c, l.invalid);
                    return;
                  }
                  await Vault.secure.write(
                    key: 'backend_url',
                    value: url.text.trim().replaceAll(RegExp(r'/+$'), ''),
                  );
                  await Vault.secure.write(
                    key: 'backend_token',
                    value: token.text.trim(),
                  );
                  if (c.mounted) toast(c, l.saved);
                }),
          child: Text(l.save),
        ),
        OutlinedButton(
          onPressed: () => runAction(c, () async {
            await Vault.secure.delete(key: 'backend_url');
            await Vault.secure.delete(key: 'backend_token');
            url.clear();
            token.clear();
            if (c.mounted) toast(c, l.saved);
          }),
          child: Text(l.disconnect),
        ),
      ],
    );
  }
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  bool busy = false;
  int? minutes;
  Future<void> connect() async {
    setState(() => busy = true);
    try {
      final health = Health();
      await health.configure();
      await Permission.activityRecognition.request();
      if (!await health.requestAuthorization(
        [HealthDataType.WORKOUT],
        permissions: [HealthDataAccess.READ],
      )) {
        throw StateError('Permission');
      }
      final now = DateTime.now();
      final data = health.removeDuplicates(
        await health.getHealthDataFromTypes(
          types: [HealthDataType.WORKOUT],
          startTime: now.subtract(const Duration(days: 7)),
          endTime: now,
        ),
      );
      final ranges = data.map((p) => (p.dateFrom, p.dateTo)).toList()
        ..sort((a, b) => a.$1.compareTo(b.$1));
      DateTime? start, end;
      var sum = Duration.zero;
      for (final r in ranges) {
        if (start == null) {
          start = r.$1;
          end = r.$2;
        } else if (!r.$1.isAfter(end!)) {
          if (r.$2.isAfter(end)) end = r.$2;
        } else {
          sum += end.difference(start);
          start = r.$1;
          end = r.$2;
        }
      }
      if (start != null) sum += end!.difference(start);
      if (mounted) setState(() => minutes = sum.inMinutes);
    } catch (_) {
      if (mounted) toast(context, context.l.healthUnavailable);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) => PageBody(
    children: [
      Notice(c.l.healthIntro),
      const Icon(Icons.monitor_heart_outlined, size: 72, color: turquoise),
      if (minutes != null)
        Panel(
          child: Column(
            children: [
              Text(c.n(minutes!), style: Theme.of(c).textTheme.headlineLarge),
              Text(c.l.exerciseMinutes),
            ],
          ),
        ),
      FilledButton.icon(
        onPressed: busy ? null : connect,
        icon: const Icon(Icons.favorite_outline),
        label: Text(c.l.connectHealth),
      ),
      OutlinedButton(
        onPressed: openAppSettings,
        child: Text(c.l.openDeviceSettings),
      ),
    ],
  );
}
