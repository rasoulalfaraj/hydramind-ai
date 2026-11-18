import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hydramind/core/domain/models.dart';
import 'package:hydramind/core/domain/engines.dart';
import 'package:hydramind/core/services/weather_service.dart';
import 'package:hydramind/core/services/coach_service.dart';
import 'package:hydramind/core/services/export_service.dart';
import 'package:hydramind/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Weather failure remains an error, not fabricated live data', () async {
    final s = WeatherService(
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    await expectLater(s.fetch(30, 47, 'Basra'), throwsStateError);
  });
  test('Missing search results remain empty', () async {
    expect(
      await WeatherService(
        client: MockClient((_) async => http.Response('{}', 200)),
      ).search('absent', 'ar'),
      isEmpty,
    );
  });
  test(
    'Weather fields, forecast and city offset are provider derived',
    () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final s = WeatherService(
        client: MockClient((request) async {
          expect(request.url.scheme, 'https');
          expect(request.url.host, 'api.open-meteo.com');
          return http.Response(
            jsonEncode({
              'utc_offset_seconds': 10800,
              'current': {
                'temperature_2m': 42,
                'apparent_temperature': 43,
                'relative_humidity_2m': 30,
                'wind_speed_10m': 12,
                'weather_code': 0,
              },
              'hourly': {
                'time': [now],
                'temperature_2m': [42],
                'weather_code': [0],
              },
              'daily': {
                'time': [now],
                'temperature_2m_max': [44],
                'temperature_2m_min': [30],
                'weather_code': [0],
                'uv_index_max': [9],
              },
            }),
            200,
          );
        }),
      );
      final w = await s.fetch(30, 47, 'Basra');
      expect(w.feels, 43);
      expect(w.utcOffsetSeconds, 10800);
      expect(w.hourly.length, 1);
      expect(HeatEngine.level(w, DateTime.now()), 3);
    },
  );
  test('CSV escapes spreadsheet injection, quotes and commas', () {
    final l = lookupAppLocalizations(const Locale('ar'));
    final csv = buildCsv([
      Intake(
        id: 'x',
        ml: 250,
        drink: Drink.water,
        at: DateTime(2026),
        note: '=SUM(1,2)\n"quote"',
      ),
    ], l);
    expect(csv, contains("'=SUM(1,2)"));
    expect(csv, contains('""quote""'));
    expect(csv, contains(l.water));
  });
  test(
    'Arabic PDF includes an embedded font and real recorded volume',
    () async {
      final bytes = await ExportService.pdfBytes([
        Intake(id: 'x', ml: 250, drink: Drink.water, at: DateTime(2026)),
      ], lookupAppLocalizations(const Locale('ar')));
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
      expect(latin1.decode(bytes), contains('/FontFile2'));
    },
  );
  test('Medical and emergency coaching is local and deterministic', () async {
    final l = lookupAppLocalizations(const Locale('ar'));
    expect(
      (await CoachService.reply('لدي ارتباك في الحر', AppData(), l)).text,
      l.emergency,
    );
    expect(
      (await CoachService.reply(
        'كيف أزيد الهدف؟',
        AppData(profile: const Profile(fluidLimit: 1200)),
        l,
      )).text,
      l.prescribedInfo,
    );
  });
}
