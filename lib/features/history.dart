import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/controller.dart';
import '../core/domain/models.dart';
import '../core/theme/design.dart';

Future<void> showAddDrink(BuildContext c, {Intake? entry, int? preset}) =>
    showModalBottomSheet<void>(
      context: c,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AddDrinkSheet(entry: entry, preset: preset),
    );

class AddDrinkSheet extends ConsumerStatefulWidget {
  final Intake? entry;
  final int? preset;
  const AddDrinkSheet({super.key, this.entry, this.preset});
  @override
  ConsumerState<AddDrinkSheet> createState() => _AddDrinkSheetState();
}

class _AddDrinkSheetState extends ConsumerState<AddDrinkSheet> {
  late final amount = TextEditingController(
        text: '${widget.entry?.ml ?? widget.preset ?? 250}',
      ),
      note = TextEditingController(text: widget.entry?.note ?? '');
  late Drink drink = widget.entry?.drink ?? Drink.water;
  late DateTime at = widget.entry?.at ?? DateTime.now();
  bool busy = false;
  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> pickTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: at,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(at),
    );
    if (t != null && mounted) {
      setState(() => at = DateTime(d.year, d.month, d.day, t.hour, t.minute));
    }
  }

  Future<void> save() async {
    final ml = parseInt(amount.text);
    if (ml == null || ml < 1 || ml > 3000) {
      toast(context, context.l.invalid);
      return;
    }
    if (at.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      toast(context, context.l.futureTime);
      return;
    }
    setState(() => busy = true);
    await runAction(context, () async {
      await ref
          .read(appProvider.notifier)
          .add(ml, drink, at, note.text.trim(), id: widget.entry?.id);
      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      }
    });
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext c) {
    final l = c.l;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.viewInsetsOf(c).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.entry == null ? l.addDrink : l.edit,
              style: Theme.of(c).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<Drink>(
              initialValue: drink,
              decoration: InputDecoration(labelText: l.beverage),
              items: Drink.values
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(drinkLabel(c, d)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => drink = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.quantity),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [100, 150, 200, 250, 330, 500]
                  .map(
                    (n) => ActionChip(
                      label: Text('${c.n(n)} ${l.ml}'),
                      onPressed: () => setState(() => amount.text = '$n'),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: note,
              maxLength: 200,
              decoration: InputDecoration(labelText: l.notes),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.dateTime),
              subtitle: Text('${c.date(at)} • ${c.time(at)}'),
              trailing: const Icon(Icons.edit_calendar),
              onTap: pickTime,
            ),
            FilledButton.icon(
              onPressed: busy ? null : save,
              icon: const Icon(Icons.add),
              label: Text(l.save),
            ),
            const SizedBox(height: 14),
            Text(l.contribution, style: Theme.of(c).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class IntakeTile extends ConsumerWidget {
  final Intake entry;
  const IntakeTile(this.entry, {super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: ocean.withValues(alpha: .1),
      child: Icon(drinkIcon(entry.drink), color: ocean),
    ),
    title: Text(drinkLabel(c, entry.drink)),
    subtitle: Text(
      '${c.time(entry.at)}${entry.note.isEmpty ? '' : ' • ${entry.note}'}',
    ),
    onTap: () => showAddDrink(c, entry: entry),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${c.n(entry.ml)} ${c.l.ml}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        PopupMenuButton<String>(
          tooltip: c.l.edit,
          onSelected: (v) {
            if (v == 'edit') {
              showAddDrink(c, entry: entry);
            } else {
              runAction(c, () async {
                await ref.read(appProvider.notifier).remove(entry.id);
                if (c.mounted) {
                  ScaffoldMessenger.of(c).showSnackBar(
                    SnackBar(
                      content: Text(c.l.delete),
                      action: SnackBarAction(
                        label: c.l.undo,
                        onPressed: () => runAction(
                          c,
                          () => ref
                              .read(appProvider.notifier)
                              .add(
                                entry.ml,
                                entry.drink,
                                entry.at,
                                entry.note,
                                id: entry.id,
                              ),
                        ),
                      ),
                    ),
                  );
                }
              });
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(c.l.edit)),
            PopupMenuItem(value: 'delete', child: Text(c.l.delete)),
          ],
        ),
      ],
    ),
  );
}

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final entries = ref.watch(appProvider).entries,
        groups = <String, List<Intake>>{};
    for (final e in entries) {
      groups.putIfAbsent(dayKey(e.at), () => []).add(e);
    }
    return PageBody(
      children: [
        SectionTitle(
          c.l.allHistory,
          action: IconButton.filled(
            onPressed: () => showAddDrink(c),
            icon: const Icon(Icons.add),
            tooltip: c.l.addDrink,
          ),
        ),
        Notice(c.l.contribution),
        if (entries.isEmpty) Panel(child: Text(c.l.emptyHistory)),
        ...groups.values.map(
          (g) => Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${c.date(g.first.at)} • ${c.n(g.fold(0, (a, e) => a + e.ml))} ${c.l.ml}',
                  style: Theme.of(c).textTheme.titleMedium,
                ),
                const Divider(),
                ...g.map((e) => IntakeTile(e)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
