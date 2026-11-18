import 'dart:convert';

enum Drink { water, tea, coffee, milk, juice, other }

enum Activity { light, moderate, active }

enum HeatProfile { general, worker, athlete, commuter, office }

class Profile {
  final String name, sex, environment, sweating, medicalNotes, medications;
  final int age, wakeMinute, bedMinute, exerciseMinutes, outdoorMinutes;
  final double weight, height;
  final Activity activity;
  final bool pregnancy, breastfeeding, medicalCaution;
  final int? fluidLimit;
  const Profile({
    this.name = '',
    this.age = 30,
    this.weight = 70,
    this.height = 170,
    this.sex = 'unspecified',
    this.environment = 'indoor',
    this.sweating = 'normal',
    this.medicalNotes = '',
    this.medications = '',
    this.wakeMinute = 420,
    this.bedMinute = 1380,
    this.exerciseMinutes = 0,
    this.outdoorMinutes = 0,
    this.activity = Activity.light,
    this.pregnancy = false,
    this.breastfeeding = false,
    this.medicalCaution = false,
    this.fluidLimit,
  });
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'weight': weight,
    'height': height,
    'sex': sex,
    'environment': environment,
    'sweating': sweating,
    'medicalNotes': medicalNotes,
    'medications': medications,
    'wake': wakeMinute,
    'bed': bedMinute,
    'exercise': exerciseMinutes,
    'outdoor': outdoorMinutes,
    'activity': activity.name,
    'pregnancy': pregnancy,
    'breastfeeding': breastfeeding,
    'caution': medicalCaution,
    'limit': fluidLimit,
  };
  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    name: j['name'] ?? '',
    age: j['age'] ?? 30,
    weight: (j['weight'] ?? 70).toDouble(),
    height: (j['height'] ?? 170).toDouble(),
    sex: j['sex'] ?? 'unspecified',
    environment: j['environment'] ?? 'indoor',
    sweating: j['sweating'] ?? 'normal',
    medicalNotes: j['medicalNotes'] ?? '',
    medications: j['medications'] ?? '',
    wakeMinute: j['wake'] ?? 420,
    bedMinute: j['bed'] ?? 1380,
    exerciseMinutes: j['exercise'] ?? 0,
    outdoorMinutes: j['outdoor'] ?? 0,
    activity: Activity.values.byName(j['activity'] ?? 'light'),
    pregnancy: j['pregnancy'] ?? false,
    breastfeeding: j['breastfeeding'] ?? false,
    medicalCaution: j['caution'] ?? false,
    fluidLimit: j['limit'],
  );
}

class Intake {
  final String id, note;
  final int ml;
  final Drink drink;
  final DateTime at;
  const Intake({
    required this.id,
    required this.ml,
    required this.drink,
    required this.at,
    this.note = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'ml': ml,
    'drink': drink.name,
    'at': at.toUtc().toIso8601String(),
    'note': note,
  };
  factory Intake.fromJson(Map<String, dynamic> j) => Intake(
    id: j['id'],
    ml: j['ml'],
    drink: Drink.values.byName(j['drink']),
    at: DateTime.parse(j['at']).toLocal(),
    note: j['note'] ?? '',
  );
}

class Weather {
  final double temperature, feels, humidity, wind, uv, lat, lon;
  final String city;
  final DateTime fetched;
  final int code, utcOffsetSeconds;
  final List<Map<String, dynamic>> hourly, daily;
  const Weather({
    required this.temperature,
    required this.feels,
    required this.humidity,
    required this.wind,
    required this.uv,
    required this.lat,
    required this.lon,
    required this.city,
    required this.fetched,
    required this.code,
    this.utcOffsetSeconds = 0,
    this.hourly = const [],
    this.daily = const [],
  });
  bool isStale(DateTime now) =>
      now.difference(fetched) > const Duration(minutes: 30);
  DateTime cityTime(String value) =>
      DateTime.parse(value).toUtc().add(Duration(seconds: utcOffsetSeconds));
  Map<String, dynamic> toJson() => {
    'temp': temperature,
    'feels': feels,
    'humidity': humidity,
    'wind': wind,
    'uv': uv,
    'lat': lat,
    'lon': lon,
    'city': city,
    'fetched': fetched.toUtc().toIso8601String(),
    'code': code,
    'offset': utcOffsetSeconds,
    'hourly': hourly,
    'daily': daily,
  };
  factory Weather.fromJson(Map<String, dynamic> j) => Weather(
    temperature: j['temp'].toDouble(),
    feels: j['feels'].toDouble(),
    humidity: j['humidity'].toDouble(),
    wind: j['wind'].toDouble(),
    uv: j['uv'].toDouble(),
    lat: j['lat'].toDouble(),
    lon: j['lon'].toDouble(),
    city: j['city'],
    fetched: DateTime.parse(j['fetched']).toLocal(),
    code: j['code'],
    utcOffsetSeconds: j['offset'] ?? 0,
    hourly: (j['hourly'] as List? ?? []).cast<Map<String, dynamic>>(),
    daily: (j['daily'] as List? ?? []).cast<Map<String, dynamic>>(),
  );
}

class AppData {
  final Profile profile;
  final List<Intake> entries;
  final String language, theme;
  final bool onboarded,
      reminders,
      habitLearning,
      iraqHeat,
      silent,
      iraqi,
      adaptive;
  final int interval, onboardingStep;
  final HeatProfile heatProfile;
  final Weather? weather;
  final List<Map<String, dynamic>> chat, notificationHistory, savedCities;
  final List<int> favorites;
  final Map<String, int> dailyTargets;
  AppData({
    this.profile = const Profile(),
    this.entries = const [],
    this.language = 'ar',
    this.theme = 'system',
    this.onboarded = false,
    this.reminders = false,
    this.habitLearning = true,
    this.iraqHeat = false,
    this.silent = false,
    this.iraqi = false,
    this.adaptive = true,
    this.interval = 60,
    this.onboardingStep = 0,
    this.heatProfile = HeatProfile.general,
    this.weather,
    this.chat = const [],
    this.notificationHistory = const [],
    this.savedCities = const [],
    this.favorites = const [150, 250, 500],
    this.dailyTargets = const {},
  });
  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'language': language,
    'theme': theme,
    'onboarded': onboarded,
    'reminders': reminders,
    'habit': habitLearning,
    'heat': iraqHeat,
    'silent': silent,
    'iraqi': iraqi,
    'adaptive': adaptive,
    'interval': interval,
    'onboardingStep': onboardingStep,
    'heatProfile': heatProfile.name,
    'weather': weather?.toJson(),
    'chat': chat,
    'notifications': notificationHistory,
    'cities': savedCities,
    'favorites': favorites,
    'targets': dailyTargets,
  };
  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
    profile: Profile.fromJson(j['profile'] ?? {}),
    entries: (j['entries'] as List? ?? [])
        .map((e) => Intake.fromJson(e))
        .toList(),
    language: j['language'] ?? 'ar',
    theme: j['theme'] ?? 'system',
    onboarded: j['onboarded'] ?? false,
    reminders: j['reminders'] ?? false,
    habitLearning: j['habit'] ?? true,
    iraqHeat: j['heat'] ?? false,
    silent: j['silent'] ?? false,
    iraqi: j['iraqi'] ?? false,
    adaptive: j['adaptive'] ?? true,
    interval: j['interval'] ?? 60,
    onboardingStep: j['onboardingStep'] ?? 0,
    heatProfile: HeatProfile.values.byName(j['heatProfile'] ?? 'general'),
    weather: j['weather'] == null ? null : Weather.fromJson(j['weather']),
    chat: (j['chat'] as List? ?? []).cast<Map<String, dynamic>>(),
    notificationHistory: (j['notifications'] as List? ?? [])
        .cast<Map<String, dynamic>>(),
    savedCities: (j['cities'] as List? ?? []).cast<Map<String, dynamic>>(),
    favorites: (j['favorites'] as List? ?? [150, 250, 500]).cast<int>(),
    dailyTargets: (j['targets'] as Map? ?? {}).cast<String, int>(),
  );
  AppData patch(Map<String, dynamic> j) =>
      AppData.fromJson({...toJson(), ...j});
  String encode() => jsonEncode(toJson());
  String get reminderSignature => jsonEncode({
    'profile': profile.toJson(),
    'entries': entries.map((e) => e.toJson()).toList(),
    'reminders': reminders,
    'language': language,
    'interval': interval,
    'silent': silent,
    'adaptive': adaptive,
    'heat': iraqHeat,
    'weather': weather?.toJson(),
  });
}

DateTime dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
int intakeForDay(List<Intake> entries, DateTime day) => entries
    .where((e) => dayKey(e.at) == dayKey(day))
    .fold(0, (a, e) => a + e.ml);
String latinDigits(String input) {
  const ar = '٠١٢٣٤٥٦٧٨٩', fa = '۰۱۲۳۴۵۶۷۸۹';
  var s = input.trim().replaceAll('٫', '.').replaceAll('٬', '');
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(ar[i], '$i').replaceAll(fa[i], '$i');
  }
  return s;
}

int? parseInt(String s) => int.tryParse(latinDigits(s));
double? parseDouble(String s) => double.tryParse(latinDigits(s));
