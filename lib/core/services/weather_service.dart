import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../domain/models.dart';

class WeatherService {
  final http.Client client;
  WeatherService({http.Client? client}) : client = client ?? http.Client();
  Future<Map<String, dynamic>> get(Uri uri) async {
    final r = await client.get(uri).timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) throw StateError('Weather unavailable');
    return jsonDecode(r.body);
  }

  Future<List<Map<String, dynamic>>> search(String query, String lang) async {
    final j = await get(
      Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': query.trim(),
        'count': '6',
        'language': lang,
        'format': 'json',
      }),
    );
    return (j['results'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  Future<Weather> fetch(double lat, double lon, String city) async {
    final j = await get(
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lon',
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code,relative_humidity_2m',
        'daily':
            'temperature_2m_max,temperature_2m_min,weather_code,uv_index_max',
        'timezone': 'auto',
        'forecast_days': '5',
        'timeformat': 'unixtime',
      }),
    );
    final c = j['current'] as Map,
        h = j['hourly'] as Map,
        d = j['daily'] as Map,
        now = DateTime.now();
    String at(num seconds) => DateTime.fromMillisecondsSinceEpoch(
      seconds.toInt() * 1000,
      isUtc: true,
    ).toIso8601String();
    final hourly = <Map<String, dynamic>>[];
    for (var i = 0; i < (h['time'] as List).length; i++) {
      if (DateTime.parse(
            at(h['time'][i]),
          ).isAfter(now.subtract(const Duration(hours: 1))) &&
          hourly.length < 24) {
        hourly.add({
          'at': at(h['time'][i]),
          'temp': h['temperature_2m'][i],
          'code': h['weather_code'][i],
        });
      }
    }
    final daily = List.generate(
      (d['time'] as List).length,
      (i) => <String, dynamic>{
        'at': at(d['time'][i]),
        'min': d['temperature_2m_min'][i],
        'max': d['temperature_2m_max'][i],
        'code': d['weather_code'][i],
        'uv': d['uv_index_max'][i],
      },
    );
    return Weather(
      temperature: (c['temperature_2m'] as num).toDouble(),
      feels: (c['apparent_temperature'] as num).toDouble(),
      humidity: (c['relative_humidity_2m'] as num).toDouble(),
      wind: (c['wind_speed_10m'] as num).toDouble(),
      uv: (d['uv_index_max'][0] as num).toDouble(),
      lat: lat,
      lon: lon,
      city: city,
      fetched: now,
      code: c['weather_code'],
      utcOffsetSeconds: (j['utc_offset_seconds'] as num? ?? 0).toInt(),
      hourly: hourly,
      daily: daily,
    );
  }

  Future<Weather> locate(String label) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Location unavailable');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Location permission');
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return fetch(
      (p.latitude * 10).round() / 10,
      (p.longitude * 10).round() / 10,
      label,
    );
  }
}
