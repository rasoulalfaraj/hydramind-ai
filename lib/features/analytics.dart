import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app/controller.dart';
import '../core/domain/models.dart';
import '../core/domain/engines.dart';
import '../core/services/export_service.dart';
import '../core/theme/design.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int days = 7;
  bool exporting = false;
  Future<void> export(bool pdf, List<Intake> entries) async {
    setState(() => exporting = true);
    await runAction(context, () async {
      final box = context.findRenderObject() as RenderBox?;
      await ExportService.share(
        entries,
        context.l,
        pdf: pdf,
        origin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      );
    });
    if (mounted) setState(() => exporting = false);
  }

  @override
  Widget build(BuildContext c) {
    final d = ref.watch(appProvider),
        l = c.l,
        now = DateTime.now(),
        totals = AnalyticsEngine.totals(
          ref.watch(appProvider).entries,
          DateTime.now(),
          days,
        ),
        start = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day - days + 1,
        );
    final entries = d.entries
            .where((e) => !e.at.isBefore(start) && !e.at.isAfter(now))
            .toList(),
        total = totals.fold(0, (a, n) => a + n),
        max = math.max(500, totals.reduce(math.max)).toDouble(),
        h = HabitEngine.analyze(
          d.entries,
          now,
          HydrationEngine.estimate(d.profile).beverageMl,
        );
    return PageBody(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: {1: l.daily, 7: l.weekly, 30: l.monthly, 365: l.yearly}
              .entries
              .map(
                (e) => ChoiceChip(
                  label: Text(e.value),
                  selected: days == e.key,
                  onSelected: (_) => setState(() => days = e.key),
                ),
              )
              .toList(),
        ),
        Panel(
          child: Column(
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _Stat(l.total, '${c.n(total)} ${l.ml}'),
                  _Stat(l.average, '${c.n((total / days).round())} ${l.ml}'),
                  _Stat(l.frequency, c.n(entries.length)),
                ],
              ),
              const SizedBox(height: 24),
              Semantics(
                label: '${l.recorded}: ${totals.map(c.n).join(', ')}',
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: 190,
                    child: LineChart(
                      duration: MediaQuery.disableAnimationsOf(c)
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      LineChartData(
                        minX: 0,
                        maxX: math.max(1, days - 1).toDouble(),
                        minY: 0,
                        maxY: max * 1.2,
                        gridData: const FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              days,
                              (i) => FlSpot(i.toDouble(), totals[i].toDouble()),
                            ),
                            isCurved: false,
                            color: ocean,
                            barWidth: 3,
                            dotData: FlDotData(show: days <= 7),
                            belowBarData: BarAreaData(
                              show: true,
                              color: aqua.withValues(alpha: .15),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots
                                .map(
                                  (s) => LineTooltipItem(
                                    '${c.date(start.add(Duration(days: s.x.toInt())))}\n${c.n(s.y.round())} ${l.ml}',
                                    TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Theme.of(c).colorScheme.onSurface,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${c.date(start)} — ${c.date(now)}',
                style: Theme.of(c).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (entries.isEmpty) Notice(l.noData),
        SectionTitle(l.beverageBreakdown),
        Panel(
          child: Column(
            children: Drink.values
                .map(
                  (drink) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(drinkIcon(drink), color: ocean),
                    title: Text(drinkLabel(c, drink)),
                    trailing: Text(
                      '${c.n(entries.where((e) => e.drink == drink).fold(0, (a, e) => a + e.ml))} ${l.ml}',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (days <= 30)
          Panel(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(days, (i) {
                final date = DateTime(start.year, start.month, start.day + i);
                return Tooltip(
                  message: '${c.date(date)}: ${c.n(totals[i])} ${l.ml}',
                  child: Semantics(
                    label: '${c.date(date)} ${c.n(totals[i])} ${l.ml}',
                    child: Container(
                      width: 50,
                      height: 64,
                      decoration: BoxDecoration(
                        color: ocean.withValues(
                          alpha: totals[i] == 0
                              ? .04
                              : .12 + .55 * (totals[i] / 2000).clamp(0, 1),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.n(date.day)),
                          Text(
                            c.n(totals[i]),
                            style: const TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        SectionTitle(l.expected),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                !d.habitLearning
                    ? l.predictionDisabled
                    : h.expected == null
                    ? l.insufficient
                    : '${c.n(h.expected!.round())} ${l.ml}',
                style: Theme.of(c).textTheme.titleLarge,
              ),
              if (d.habitLearning && h.likelihood != null)
                Text('${l.chance}: ${c.n(h.likelihood!)}${l.percent}'),
              Text(l.predictionInfo, style: Theme.of(c).textTheme.bodySmall),
            ],
          ),
        ),
        Notice(l.correlationInfo),
        Notice(l.engagementInfo),
        OutlinedButton.icon(
          onPressed: exporting ? null : () => export(false, entries),
          icon: const Icon(Icons.table_view),
          label: Text(l.exportCsv),
        ),
        FilledButton.icon(
          onPressed: exporting ? null : () => export(true, entries),
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(l.exportPdf),
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
      Text(value, style: Theme.of(c).textTheme.titleMedium),
      Text(label, style: Theme.of(c).textTheme.bodySmall),
    ],
  );
}

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider),
        l = c.l,
        count = d.entries.map((e) => dayKey(e.at)).toSet().length;
    return PageBody(
      children: [
        const Icon(Icons.workspace_premium, size: 80, color: turquoise),
        Text(
          c.n(AnalyticsEngine.streak(d.entries, DateTime.now())),
          style: Theme.of(c).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        Text(l.streak, textAlign: TextAlign.center),
        Notice(l.achievementInfo),
        ...{
          l.firstSip: d.entries.isNotEmpty,
          l.weekHabit: count >= 7,
        }.entries.map(
          (e) => Panel(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                e.value ? Icons.verified : Icons.lock_outline,
                color: e.value ? turquoise : Colors.grey,
              ),
              title: Text(e.key),
              subtitle: Text(e.value ? l.earned : l.inProgress),
            ),
          ),
        ),
      ],
    );
  }
}
