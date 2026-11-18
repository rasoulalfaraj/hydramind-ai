import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../l10n/app_localizations.dart';
import '../database/vault.dart';
import '../domain/models.dart';
import '../domain/engines.dart';

class CoachReply {
  final String text;
  final bool cloud;
  const CoachReply(this.text, this.cloud);
}

class CoachService {
  // Raw model text and numbers are never displayed. Only a topic enum is used.
  static Future<CoachReply> reply(
    String question,
    AppData d,
    AppLocalizations l,
  ) async {
    var topic =
        RegExp(
          r'target|goal|هدف|حُسب|حسب',
          caseSensitive: false,
        ).hasMatch(question)
        ? 'target'
        : RegExp(
            r'weather|heat|حر|طقس',
            caseSensitive: false,
          ).hasMatch(question)
        ? 'weather'
        : RegExp(
            r'habit|pattern|عادة|عادات|نمط',
            caseSensitive: false,
          ).hasMatch(question)
        ? 'habits'
        : 'general';
    final first = SafetyEngine.validatedTopic(
      topic,
      d.profile,
      d.entries,
      DateTime.now(),
      prompt: question,
    );
    if (const {'emergency', 'medical', 'safety'}.contains(first)) {
      return CoachReply(render(first, d, l), false);
    }
    final url = await Vault.secure.read(key: 'backend_url'),
        token = await Vault.secure.read(key: 'backend_token');
    var cloud = false;
    if (url != null && token != null) {
      final uri = Uri.parse('$url/v1/coach');
      if (uri.scheme != 'https') throw StateError('HTTPS required');
      final r = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'question': question,
              'language': d.language,
              'iraqi': d.iraqi,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (r.statusCode != 200) throw StateError('Coach unavailable');
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      topic = j['topic'] is String ? j['topic'] : 'general';
      cloud = true;
    }
    return CoachReply(
      render(
        SafetyEngine.validatedTopic(
          topic,
          d.profile,
          d.entries,
          DateTime.now(),
          prompt: question,
        ),
        d,
        l,
      ),
      cloud,
    );
  }

  static String render(
    String topic,
    AppData d,
    AppLocalizations l,
  ) => switch (topic) {
    'emergency' => l.emergency,
    'safety' =>
      '${l.rapidWarning}\n${l.safetyEducation}${d.profile.fluidLimit == null ? '' : '\n${l.prescribedInfo}'}',
    'medical' =>
      d.profile.fluidLimit != null ? l.prescribedInfo : l.medicalInfo,
    'target' => '${l.estimateInfo}\n${l.uncertainty}',
    'weather' =>
      d.weather == null || d.weather!.isStale(DateTime.now())
          ? l.heatStale
          : [
              l.heatNormal,
              l.heatModerate,
              l.heatHigh,
              l.heatExtreme,
            ][HeatEngine.level(d.weather, DateTime.now())],
    'habits' =>
      !d.habitLearning
          ? l.predictionDisabled
          : HabitEngine.analyze(
                  d.entries,
                  DateTime.now(),
                  HydrationEngine.estimate(d.profile).beverageMl,
                ).days <
                7
          ? l.insufficient
          : l.habitIntro,
    'routine' => l.coachRoutine,
    _ => d.iraqi && d.language == 'ar' ? l.iraqiCoach : l.generalCoach,
  };
}
