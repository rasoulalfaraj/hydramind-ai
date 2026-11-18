import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/controller.dart';
import '../core/domain/models.dart';
import '../core/domain/engines.dart';
import '../core/theme/design.dart';

class ProfileWizard extends ConsumerStatefulWidget {
  final bool editing;
  const ProfileWizard({super.key, this.editing = false});
  @override
  ConsumerState<ProfileWizard> createState() => _ProfileWizardState();
}

class _ProfileWizardState extends ConsumerState<ProfileWizard> {
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  int step = 0, wake = 420, bed = 1380;
  Activity activity = Activity.light;
  String sex = 'unspecified', environment = 'indoor', sweating = 'normal';
  bool pregnancy = false,
      feeding = false,
      caution = false,
      consent = false,
      busy = false;
  @override
  void initState() {
    super.initState();
    final d = ref.read(appProvider), p = d.profile;
    if (!widget.editing) step = d.onboardingStep.clamp(0, 2);
    for (final e in {
      'name': p.name,
      'age': '${p.age}',
      'weight': '${p.weight}',
      'height': '${p.height}',
      'exercise': '${p.exerciseMinutes}',
      'outdoor': '${p.outdoorMinutes}',
      'limit': p.fluidLimit?.toString() ?? '',
      'medical': p.medicalNotes,
      'medications': p.medications,
    }.entries) {
      fields[e.key] = TextEditingController(text: e.value);
    }
    wake = p.wakeMinute;
    bed = p.bedMinute;
    activity = p.activity;
    sex = p.sex;
    environment = p.environment;
    sweating = p.sweating;
    pregnancy = p.pregnancy;
    feeding = p.breastfeeding;
    caution = p.medicalCaution;
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Profile get profile => Profile(
    name: fields['name']!.text.trim(),
    age: parseInt(fields['age']!.text)!,
    weight: parseDouble(fields['weight']!.text)!,
    height: parseDouble(fields['height']!.text)!,
    exerciseMinutes: parseInt(fields['exercise']!.text)!,
    outdoorMinutes: parseInt(fields['outdoor']!.text)!,
    fluidLimit: parseInt(fields['limit']!.text),
    medicalNotes: fields['medical']!.text.trim(),
    medications: fields['medications']!.text.trim(),
    wakeMinute: wake,
    bedMinute: bed,
    activity: activity,
    sex: sex,
    environment: environment,
    sweating: sweating,
    pregnancy: pregnancy,
    breastfeeding: feeding,
    medicalCaution: caution,
  );
  Widget field(
    String key,
    String label, {
    bool numeric = false,
    double min = 0,
    double max = 1000,
    bool optional = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: fields[key],
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      maxLength: numeric ? null : 150,
      onChanged: (_) {
        if (step == 2) setState(() {});
      },
      validator: (v) {
        if (!numeric) return null;
        if (optional && (v ?? '').isEmpty) return null;
        final n = parseDouble(v ?? '');
        if (n == null ||
            n < min ||
            n > max ||
            (['age', 'exercise', 'outdoor', 'limit'].contains(key) &&
                n != n.roundToDouble())) {
          return context.l.invalid;
        }
        return null;
      },
    ),
  );
  Widget select(
    String label,
    String value,
    Map<String, String> choices,
    void Function(String) change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: choices.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: (v) => setState(() => change(v!)),
    ),
  );
  Future<void> time(bool waking) async {
    final m = waking ? wake : bed;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
    );
    if (t != null) {
      setState(() {
        if (waking) {
          wake = t.hour * 60 + t.minute;
        } else {
          bed = t.hour * 60 + t.minute;
        }
      });
    }
  }

  Future<void> persist() async {
    if (!form.currentState!.validate()) return;
    if (wake == bed) {
      toast(context, context.l.invalid);
      return;
    }
    setState(() => busy = true);
    await runAction(context, () async {
      final finish = step == 2;
      await ref.read(appProvider.notifier).patch({
        'profile': profile.toJson(),
        if (!widget.editing) 'onboardingStep': finish ? 0 : step + 1,
        if (finish) 'onboarded': true,
      });
      if (!mounted) return;
      if (finish && widget.editing) {
        Navigator.pop(context);
      } else if (!finish) {
        setState(() => step++);
      }
    });
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext c) {
    final l = c.l, d = ref.watch(appProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? l.profile : l.appName),
        actions: [
          TextButton(
            onPressed: () => runAction(
              c,
              () => ref.read(appProvider.notifier).patch({
                'language': d.language == 'ar' ? 'en' : 'ar',
              }),
            ),
            child: Text(d.language == 'ar' ? 'English' : 'العربية'),
          ),
        ],
      ),
      body: PageBody(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  height: 5,
                  margin: const EdgeInsets.all(3),
                  color: i <= step
                      ? ocean
                      : Theme.of(c).colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
          Icon(
            [Icons.water_drop, Icons.wb_sunny, Icons.health_and_safety][step],
            color: ocean,
            size: 56,
          ),
          Text(
            [l.basics, l.routine, l.healthFirst][step],
            style: Theme.of(c).textTheme.headlineLarge,
          ),
          Text(
            step == 0
                ? l.intro
                : step == 2
                ? l.sensitiveWhy
                : l.tagline,
          ),
          Form(
            key: form,
            child: Column(
              children: [
                if (step == 0) ...[
                  field('name', l.name),
                  field('age', l.age, numeric: true, min: 1, max: 120),
                  field('weight', l.weight, numeric: true, min: 10, max: 500),
                  field('height', l.height, numeric: true, min: 50, max: 250),
                  select(l.sex, sex, {
                    'unspecified': l.unspecified,
                    'female': l.female,
                    'male': l.male,
                  }, (v) => sex = v),
                ],
                if (step == 1) ...[
                  select(l.activity, activity.name, {
                    'light': l.light,
                    'moderate': l.moderate,
                    'active': l.active,
                  }, (v) => activity = Activity.values.byName(v)),
                  select(l.environment, environment, {
                    'indoor': l.indoor,
                    'outside': l.outside,
                    'mixed': l.mixed,
                  }, (v) => environment = v),
                  field('exercise', l.exercise, numeric: true, max: 720),
                  field('outdoor', l.outdoor, numeric: true, max: 1440),
                  select(l.sweating, sweating, {
                    'normal': l.normal,
                    'low': l.low,
                    'heavy': l.heavy,
                  }, (v) => sweating = v),
                  Panel(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(l.wake),
                          trailing: Text(
                            TimeOfDay(
                              hour: wake ~/ 60,
                              minute: wake % 60,
                            ).format(c),
                          ),
                          onTap: () => time(true),
                        ),
                        ListTile(
                          title: Text(l.bed),
                          trailing: Text(
                            TimeOfDay(
                              hour: bed ~/ 60,
                              minute: bed % 60,
                            ).format(c),
                          ),
                          onTap: () => time(false),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step == 2) ...[
                  SwitchListTile(
                    title: Text(l.medicalCaution),
                    value: caution,
                    onChanged: (v) => setState(() => caution = v),
                  ),
                  SwitchListTile(
                    title: Text(l.pregnancy),
                    value: pregnancy,
                    onChanged: (v) => setState(() => pregnancy = v),
                  ),
                  SwitchListTile(
                    title: Text(l.breastfeeding),
                    value: feeding,
                    onChanged: (v) => setState(() => feeding = v),
                  ),
                  field('medical', l.medicalNotes),
                  field('medications', l.medications),
                  field(
                    'limit',
                    l.fluidLimit,
                    numeric: true,
                    min: 1,
                    max: 10000,
                    optional: true,
                  ),
                  Panel(
                    child: Column(
                      children: [
                        Text(
                          HydrationEngine.estimate(profile).basis ==
                                  'prescribed'
                              ? l.ceiling
                              : l.target,
                        ),
                        Text(
                          HydrationEngine.estimate(profile).beverageMl == null
                              ? l.medicalInfo
                              : '${c.n(HydrationEngine.estimate(profile).beverageMl!)} ${l.ml}',
                          style: Theme.of(c).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  Notice(estimateText(c, profile)),
                  CheckboxListTile(
                    value: consent,
                    onChanged: (v) => setState(() => consent = v ?? false),
                    title: Text(l.consent),
                  ),
                ],
              ],
            ),
          ),
          if (step > 0)
            OutlinedButton(
              onPressed: busy ? null : () => setState(() => step--),
              child: Text(l.back),
            ),
          FilledButton(
            onPressed: busy || (step == 2 && !consent) ? null : persist,
            child: Text(
              busy
                  ? l.thinking
                  : step == 2
                  ? (widget.editing ? l.save : l.start)
                  : l.next,
            ),
          ),
          Text(
            l.notMedical,
            textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
