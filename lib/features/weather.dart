import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/controller.dart';
import '../core/domain/models.dart';
import '../core/domain/engines.dart';
import '../core/services/weather_service.dart';
import '../core/theme/design.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});
  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final query = TextEditingController(), service = WeatherService();
  List<Map<String, dynamic>> results = [];
  bool busy = false, searched = false;
  @override
  void dispose() {
    query.dispose();
    service.client.close();
    super.dispose();
  }

  Future<void> task(Future<void> Function() action) async {
    setState(() => busy = true);
    await runAction(context, action);
    if (mounted) setState(() => busy = false);
  }

  Future<void> choose(Map<String, dynamic> city) async {
    final w = await service.fetch(
      (city['latitude'] as num).toDouble(),
      (city['longitude'] as num).toDouble(),
      city['name'],
    );
    await ref.read(appProvider.notifier).mutate((d) {
      final cities = [...d.savedCities];
      if (!cities.any((c) => c['id'] == city['id'])) cities.add(city);
      return d.patch({
        'weather': w.toJson(),
        'cities': cities.take(10).toList(),
      });
    });
    if (mounted) setState(() => results = []);
  }

  Future<void> search() async {
    final list = await service.search(
      query.text,
      ref.read(appProvider).language,
    );
    if (mounted) {
      setState(() {
        results = list;
        searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    final d = ref.watch(appProvider), l = c.l, w = d.weather;
    return PageBody(
      children: [
        TextField(
          controller: query,
          onSubmitted: (_) => busy ? null : task(search),
          decoration: InputDecoration(
            labelText: l.searchCity,
            suffixIcon: IconButton(
              onPressed: busy ? null : () => task(search),
              icon: const Icon(Icons.search),
              tooltip: l.search,
            ),
          ),
        ),
        if (busy) const LinearProgressIndicator(),
        if (searched && results.isEmpty && !busy) Text(l.noResults),
        ...results.map(
          (city) => Panel(
            padding: EdgeInsets.zero,
            child: ListTile(
              title: Text(city['name']),
              subtitle: Text(
                [
                  city['admin1'],
                  city['country'],
                ].whereType<String>().join(' • '),
              ),
              onTap: busy ? null : () => task(() => choose(city)),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: busy
              ? null
              : () => task(() async {
                  final fresh = await service.locate(l.useLocation);
                  await ref.read(appProvider.notifier).patch({
                    'weather': fresh.toJson(),
                  });
                }),
          icon: const Icon(Icons.my_location),
          label: Text(l.useLocation),
        ),
        if (w == null)
          Notice(l.noWeather)
        else ...[
          Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        w.city,
                        style: Theme.of(c).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l.refresh,
                      onPressed: busy
                          ? null
                          : () => task(() async {
                              if (!w.isStale(DateTime.now())) {
                                toast(c, l.saved);
                                return;
                              }
                              final fresh = await service.fetch(
                                w.lat,
                                w.lon,
                                w.city,
                              );
                              await ref.read(appProvider.notifier).patch({
                                'weather': fresh.toJson(),
                              });
                            }),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                Icon(weatherIcon(w.code), size: 64, color: ocean),
                Text(
                  '${c.n(w.temperature.round())}${l.degree}',
                  style: Theme.of(c).textTheme.headlineLarge,
                ),
                Text(weatherLabel(c, w.code)),
                const SizedBox(height: 14),
                Text(
                  '${w.isStale(DateTime.now()) ? l.cached : l.updated}\n${c.date(w.fetched)} • ${c.time(w.fetched)}',
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                Wrap(
                  spacing: 20,
                  runSpacing: 14,
                  children: [
                    _Metric(l.feels, '${c.n(w.feels.round())}${l.degree}'),
                    _Metric(
                      l.humidity,
                      '${c.n(w.humidity.round())}${l.percent}',
                    ),
                    _Metric(l.wind, c.n(w.wind)),
                    _Metric(l.uv, c.n(w.uv)),
                  ],
                ),
              ],
            ),
          ),
          Notice(
            heatText(c, w),
            warning: HeatEngine.level(w, DateTime.now()) >= 2,
          ),
          SectionTitle(l.hourly),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: w.hourly.length,
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemBuilder: (c, i) {
                final h = w.hourly[i];
                return SizedBox(
                  width: 90,
                  child: Panel(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.time(w.cityTime(h['at'])),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Icon(weatherIcon(h['code']), color: ocean),
                        const SizedBox(height: 10),
                        Text('${c.n((h['temp'] as num).round())}${l.degree}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SectionTitle(l.forecast),
          Panel(
            child: Column(
              children: w.daily
                  .map(
                    (day) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(weatherIcon(day['code']), color: ocean),
                      title: Text(c.date(w.cityTime(day['at']))),
                      trailing: Text(
                        '${c.n(day['max'])} / ${c.n(day['min'])}${l.degree}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        Notice(l.weatherProvider),
        if (d.savedCities.isNotEmpty) ...[
          SectionTitle(l.savedCities),
          Panel(
            child: Column(
              children: d.savedCities
                  .map(
                    (city) => ListTile(
                      title: Text(city['name']),
                      onTap: busy ? null : () => task(() => choose(city)),
                      trailing: IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.close),
                        onPressed: () => runAction(
                          c,
                          () => ref.read(appProvider.notifier).patch({
                            'cities': d.savedCities
                                .where((v) => v['id'] != city['id'])
                                .toList(),
                          }),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  const _Metric(this.label, this.value);
  @override
  Widget build(BuildContext c) => Column(
    children: [
      Text(label, style: Theme.of(c).textTheme.bodySmall),
      Text(value, style: Theme.of(c).textTheme.titleLarge),
    ],
  );
}

class HeatScreen extends ConsumerWidget {
  const HeatScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final d = ref.watch(appProvider), l = c.l;
    final names = [l.general, l.worker, l.athlete, l.commuter, l.office];
    return PageBody(
      children: [
        Notice(l.heatIntro, icon: Icons.wb_sunny),
        Panel(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.enableHeat),
            value: d.iraqHeat,
            onChanged: (v) => runAction(
              c,
              () => ref.read(appProvider.notifier).patch({'heat': v}),
            ),
          ),
        ),
        DropdownButtonFormField<HeatProfile>(
          initialValue: d.heatProfile,
          decoration: InputDecoration(labelText: l.heatProfile),
          items: HeatProfile.values
              .map(
                (p) => DropdownMenuItem(value: p, child: Text(names[p.index])),
              )
              .toList(),
          onChanged: (v) => runAction(
            c,
            () =>
                ref.read(appProvider.notifier).patch({'heatProfile': v!.name}),
          ),
        ),
        Notice(
          heatText(c, d.weather),
          warning: HeatEngine.level(d.weather, DateTime.now()) >= 2,
        ),
        Notice(switch (d.heatProfile) {
          HeatProfile.worker => l.workerAdvice,
          HeatProfile.athlete => l.athleteAdvice,
          HeatProfile.commuter => l.commuterAdvice,
          HeatProfile.office => l.officeAdvice,
          _ => l.heatModerate,
        }),
        Notice(l.emergency, warning: true),
        Notice(estimateText(c, d.profile)),
      ],
    );
  }
}
