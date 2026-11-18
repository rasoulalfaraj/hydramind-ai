import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/controller.dart';
import '../app/routes.dart';
import '../core/domain/models.dart';
import '../core/domain/engines.dart';
import '../core/theme/design.dart';
import 'history.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider),
        l = c.l,
        now = DateTime.now(),
        estimate = HydrationEngine.estimate(ref.watch(appProvider).profile);
    final total = intakeForDay(d.entries, now),
        target = estimate.beverageMl,
        flags = SafetyEngine.assess(d.profile, d.entries, now),
        slots = ReminderEngine.plan(d, now),
        today = d.entries
            .where((e) => dayKey(e.at) == dayKey(now))
            .take(4)
            .toList(),
        week = AnalyticsEngine.totals(d.entries, now, 7);
    final max = math.max(1, week.reduce(math.max));
    return PageBody(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l.hello} ${d.profile.name.isEmpty ? l.friend : d.profile.name}',
                    style: Theme.of(c).textTheme.headlineSmall,
                  ),
                  Text(
                    '${c.date(now)} • ${c.time(now)}',
                    style: Theme.of(c).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => openDetail(c, Detail.reminders),
              icon: const Icon(Icons.notifications_none),
              tooltip: l.reminders,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF0067E8), Color(0xFF003E8F), Color(0xFF06274B)],
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: aqua, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.dailyJourney,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    target == null
                        ? '—'
                        : '${c.n((100 * total / target).clamp(0, 100).round())}${l.percent}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              WaterOrb(
                progress: target == null ? 0 : total / target,
                value: c.n(total),
                label: l.ml,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _Stat(l.recorded, '${c.n(total)} ${l.ml}')),
                  Expanded(
                    child: _Stat(
                      estimate.basis == 'prescribed' ? l.ceiling : l.target,
                      target == null ? l.medicalInfo : '${c.n(target)} ${l.ml}',
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      estimate.basis == 'prescribed'
                          ? l.allowance
                          : l.remaining,
                      target == null
                          ? '—'
                          : '${c.n(math.max(0, target - total))} ${l.ml}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                estimate.basis == 'prescribed'
                    ? l.prescribedInfo
                    : target == null
                    ? l.medicalInfo
                    : l.uncertainty,
                style: const TextStyle(color: Colors.white, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ...flags.map((f) => Notice(safetyText(c, f), warning: true)),
        SectionTitle(
          l.quickAdd,
          action: TextButton(
            onPressed: () => showAddDrink(c),
            child: Text(l.addDrink),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: d.favorites
              .map(
                (ml) => FilledButton.tonalIcon(
                  onPressed: () => runAction(c, () async {
                    await ref
                        .read(appProvider.notifier)
                        .add(ml, Drink.water, DateTime.now(), '');
                    if (!c.mounted) return;
                    final entry = ref.read(appProvider).entries.first;
                    ScaffoldMessenger.of(c).showSnackBar(
                      SnackBar(
                        content: Text(l.logged),
                        action: SnackBarAction(
                          label: l.undo,
                          onPressed: () => runAction(
                            c,
                            () =>
                                ref.read(appProvider.notifier).remove(entry.id),
                          ),
                        ),
                      ),
                    );
                  }),
                  icon: const Icon(Icons.water_drop_outlined),
                  label: Text('${c.n(ml)} ${l.ml}'),
                ),
              )
              .toList(),
        ),
        Panel(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => openDetail(c, Detail.weather),
            leading: Icon(
              d.weather == null
                  ? Icons.cloud_outlined
                  : weatherIcon(d.weather!.code),
              color: ocean,
              size: 36,
            ),
            title: Text(d.weather?.city ?? l.weather),
            subtitle: Text(
              d.weather == null
                  ? l.noWeather
                  : '${weatherLabel(c, d.weather!.code)}\n${d.weather!.isStale(now) ? l.cached : l.updated}: ${c.time(d.weather!.fetched)}',
            ),
            trailing: d.weather == null
                ? const Icon(Icons.chevron_right)
                : Text(
                    '${c.n(d.weather!.temperature.round())}${l.degree}',
                    style: Theme.of(c).textTheme.titleLarge,
                  ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _Tile(
                Icons.wb_sunny_outlined,
                l.iraqHeat,
                () => openDetail(c, Detail.heat),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Tile(
                Icons.psychology_outlined,
                l.habits,
                () => openDetail(c, Detail.habits),
              ),
            ),
          ],
        ),
        Panel(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule, color: ocean),
            title: Text(l.nextReminder),
            subtitle: Text(
              slots.isEmpty ? l.notScheduled : c.time(slots.first),
            ),
            trailing: TextButton(
              onPressed: () => openDetail(c, Detail.reminders),
              child: Text(l.edit),
            ),
          ),
        ),
        if (flags.isEmpty)
          Notice(
            d.iraqHeat ? heatText(c, d.weather) : l.generalCoach,
            icon: Icons.auto_awesome,
          ),
        SectionTitle(l.timeline),
        Panel(
          child: today.isEmpty
              ? Text(l.emptyHistory)
              : Column(children: today.map((e) => IntakeTile(e)).toList()),
        ),
        SectionTitle(l.weeklyPreview),
        Panel(
          child: SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          c.n(week[i]),
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: math.max(5, 70 * week[i] / max),
                          decoration: BoxDecoration(
                            color: i == 6
                                ? ocean
                                : turquoise.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c.n(
                            DateTime(now.year, now.month, now.day - 6 + i).day,
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          l.notMedical,
          style: Theme.of(c).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext c) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback tap;
  const _Tile(this.icon, this.label, this.tap);
  @override
  Widget build(BuildContext c) => Panel(
    child: InkWell(
      onTap: tap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ocean, size: 32),
          const SizedBox(height: 10),
          Text(label, style: Theme.of(c).textTheme.titleMedium),
        ],
      ),
    ),
  );
}
