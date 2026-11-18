import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/controller.dart';
import '../app/routes.dart';
import '../core/domain/engines.dart';
import '../core/services/reminder_service.dart';
import '../core/theme/design.dart';
import '../core/domain/models.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});
  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  late final custom = TextEditingController(
    text: '${ref.read(appProvider).interval}',
  );
  @override
  void dispose() {
    custom.dispose();
    super.dispose();
  }

  Future<void> enable(bool value) async {
    await runAction(context, () async {
      final service = ref.read(reminderProvider);
      if (value && (!service.initialized || !await service.permission())) {
        if (mounted) toast(context, context.l.permissionDenied);
        return;
      }
      await ref.read(appProvider.notifier).patch({'reminders': value});
      if (mounted) await service.schedule(ref.read(appProvider), context.l);
    });
  }

  @override
  Widget build(BuildContext c) {
    final d = ref.watch(appProvider),
        l = c.l,
        slots = ReminderEngine.plan(ref.watch(appProvider), DateTime.now());
    return PageBody(
      children: [
        Panel(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.enableReminders),
                value: d.reminders,
                onChanged: enable,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.silent),
                value: d.silent,
                onChanged: (v) => runAction(
                  c,
                  () => ref.read(appProvider.notifier).patch({'silent': v}),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.adaptive),
                value: d.adaptive,
                onChanged: (v) => runAction(
                  c,
                  () => ref.read(appProvider.notifier).patch({'adaptive': v}),
                ),
              ),
            ],
          ),
        ),
        Notice(l.adaptiveInfo),
        SectionTitle(l.interval),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [30, 45, 60, 90, 120]
              .map(
                (n) => ChoiceChip(
                  label: Text(c.n(n)),
                  selected: d.interval == n,
                  onSelected: (_) => runAction(
                    c,
                    () => ref.read(appProvider.notifier).patch({'interval': n}),
                  ),
                ),
              )
              .toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: custom,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.custom),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => runAction(c, () async {
                final value = parseInt(custom.text);
                if (value == null || value < 15 || value > 720) {
                  toast(c, l.invalid);
                  return;
                }
                await ref.read(appProvider.notifier).patch({'interval': value});
              }),
              child: Text(l.save),
            ),
          ],
        ),
        Panel(
          child: Column(
            children: [
              ListTile(
                title: Text(l.wake),
                trailing: Text(
                  TimeOfDay(
                    hour: d.profile.wakeMinute ~/ 60,
                    minute: d.profile.wakeMinute % 60,
                  ).format(c),
                ),
              ),
              ListTile(
                title: Text(l.bed),
                trailing: Text(
                  TimeOfDay(
                    hour: d.profile.bedMinute ~/ 60,
                    minute: d.profile.bedMinute % 60,
                  ).format(c),
                ),
              ),
              TextButton(
                onPressed: () => openDetail(c, Detail.profile),
                child: Text(l.edit),
              ),
            ],
          ),
        ),
        Notice(
          '${l.nextReminder}: ${slots.isEmpty ? l.notScheduled : c.time(slots.first)}',
        ),
        Notice(l.reminderLimits),
        OutlinedButton(
          onPressed: openAppSettings,
          child: Text(l.openDeviceSettings),
        ),
        SectionTitle(l.notificationHistory),
        Panel(
          child: d.notificationHistory.isEmpty
              ? Text(l.noData)
              : Column(
                  children: d.notificationHistory.reversed.take(30).map((e) {
                    final at = DateTime.parse(e['at']).toLocal();
                    return ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: Text(l.reminders),
                      subtitle: Text('${c.date(at)} • ${c.time(at)}'),
                    );
                  }).toList(),
                ),
        ),
        Notice(l.engagementInfo),
      ],
    );
  }
}

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider),
        l = c.l,
        h = HabitEngine.analyze(
          ref.watch(appProvider).entries,
          DateTime.now(),
          HydrationEngine.estimate(ref.watch(appProvider).profile).beverageMl,
          wakeMinute: d.profile.wakeMinute,
          bedMinute: d.profile.bedMinute,
        );
    return PageBody(
      children: [
        Notice(l.habitIntro, icon: Icons.psychology_outlined),
        Panel(
          child: SwitchListTile(
            title: Text(l.enableHabits),
            value: d.habitLearning,
            onChanged: (v) => runAction(
              c,
              () => ref.read(appProvider.notifier).patch({'habit': v}),
            ),
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(c.n(h.days), style: Theme.of(c).textTheme.headlineLarge),
              Text(l.history),
              const SizedBox(height: 14),
              Text(
                !d.habitLearning
                    ? l.predictionDisabled
                    : h.quietHour == null
                    ? l.insufficient
                    : '${l.quietHour}: ${TimeOfDay(hour: h.quietHour!, minute: 0).format(c)}',
              ),
            ],
          ),
        ),
        if (d.habitLearning && h.quietHour != null)
          OutlinedButton(
            onPressed: () => openDetail(c, Detail.reminders),
            child: Text(l.reminders),
          ),
        Notice(l.habitResetInfo),
        OutlinedButton(
          onPressed: () => runAction(
            c,
            () => ref.read(appProvider.notifier).patch({'habit': false}),
          ),
          child: Text(l.resetHabits),
        ),
      ],
    );
  }
}
