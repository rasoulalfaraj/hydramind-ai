import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../domain/models.dart';
import '../domain/engines.dart';

const ocean = Color(0xFF0077FF),
    aqua = Color(0xFF00D4FF),
    navy = Color(0xFF071B35),
    turquoise = Color(0xFF00C9B7);

extension LocalizedContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
  String n(num value) =>
      NumberFormat.decimalPattern(l.localeName).format(value);
  String date(DateTime d) => DateFormat.yMMMd(l.localeName).format(d);
  String time(DateTime d) => DateFormat.Hm(l.localeName).format(d);
}

ThemeData hydraTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors = ColorScheme.fromSeed(
    seedColor: ocean,
    brightness: brightness,
    primary: dark ? const Color(0xFF79BEFF) : ocean,
    secondary: turquoise,
    surface: dark ? const Color(0xFF10253F) : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: colors,
    brightness: brightness,
    scaffoldBackgroundColor: dark ? navy : const Color(0xFFF3F8FC),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? navy : const Color(0xFFF3F8FC),
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .3)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.primary.withValues(alpha: .12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontSize: 14, height: 1.7),
      bodySmall: TextStyle(fontSize: 12, height: 1.6),
    ),
  );
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext c) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children
              .expand((w) => [w, const SizedBox(height: 18)])
              .toList(),
        ),
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  @override
  Widget build(BuildContext c) => Card(
    child: Padding(padding: padding, child: child),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? action;
  const SectionTitle(this.text, {super.key, this.action});
  @override
  Widget build(BuildContext c) => Row(
    children: [
      Expanded(child: Text(text, style: Theme.of(c).textTheme.titleLarge)),
      ?action,
    ],
  );
}

class Notice extends StatelessWidget {
  final String text;
  final bool warning;
  final IconData icon;
  const Notice(
    this.text, {
    super.key,
    this.warning = false,
    this.icon = Icons.info_outline,
  });
  @override
  Widget build(BuildContext c) {
    final color = warning
        ? Theme.of(c).colorScheme.error
        : Theme.of(c).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(warning ? Icons.health_and_safety_outlined : icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

String drinkLabel(BuildContext c, Drink d) =>
    [c.l.water, c.l.tea, c.l.coffee, c.l.milk, c.l.juice, c.l.other][d.index];
IconData drinkIcon(Drink d) => [
  Icons.water_drop_rounded,
  Icons.emoji_food_beverage,
  Icons.coffee,
  Icons.local_drink,
  Icons.local_bar,
  Icons.liquor,
][d.index];
String estimateText(BuildContext c, Profile p) =>
    switch (HydrationEngine.estimate(p).basis) {
      'prescribed' => c.l.prescribedInfo,
      'review' => c.l.medicalInfo,
      _ => c.l.estimateInfo,
    };
String safetyText(BuildContext c, SafetyFlag f) => switch (f) {
  SafetyFlag.rapid => c.l.rapidWarning,
  SafetyFlag.limit => c.l.limitWarning,
  SafetyFlag.highDaily => c.l.highWarning,
  SafetyFlag.medical => c.l.medicalInfo,
};
String heatText(BuildContext c, Weather? w) =>
    w == null || w.isStale(DateTime.now())
    ? c.l.heatStale
    : [
        c.l.heatNormal,
        c.l.heatModerate,
        c.l.heatHigh,
        c.l.heatExtreme,
      ][HeatEngine.level(w, DateTime.now())];
String weatherLabel(BuildContext c, int code) => code == 0
    ? c.l.clear
    : code <= 3
    ? c.l.cloudy
    : const [45, 48].contains(code)
    ? c.l.fog
    : const [71, 73, 75, 77, 85, 86].contains(code)
    ? c.l.snow
    : code >= 95
    ? c.l.storm
    : c.l.rain;
IconData weatherIcon(int code) => code == 0
    ? Icons.wb_sunny
    : code <= 3
    ? Icons.cloud
    : code >= 95
    ? Icons.thunderstorm
    : Icons.water_drop_outlined;
void toast(BuildContext c, String text) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(text)));
Future<void> runAction(BuildContext c, Future<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    if (c.mounted) toast(c, c.l.error);
  }
}

Future<bool> confirmDelete(BuildContext c) => showDialog<bool>(
  context: c,
  builder: (d) => AlertDialog(
    title: Text(c.l.delete),
    content: Text(c.l.confirmDelete),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(d, false),
        child: Text(c.l.cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(d, true),
        child: Text(c.l.confirm),
      ),
    ],
  ),
).then((v) => v ?? false);

class WaterOrb extends StatefulWidget {
  final double progress;
  final String value, label;
  const WaterOrb({
    super.key,
    required this.progress,
    required this.value,
    required this.label,
  });
  @override
  State<WaterOrb> createState() => _WaterOrbState();
}

class _WaterOrbState extends State<WaterOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      animation.stop();
    } else {
      animation.repeat();
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Semantics(
    label: '${widget.label} ${widget.value}',
    excludeSemantics: true,
    child: SizedBox.square(
      dimension: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (c, _) => CustomPaint(
              size: const Size.square(210),
              painter: _WaterPainter(
                widget.progress.clamp(0, 1),
                animation.value,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, color: Colors.white),
              Text(
                widget.value,
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(widget.label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _WaterPainter extends CustomPainter {
  final double level, phase;
  _WaterPainter(this.level, this.phase);
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2),
        r = s.width / 2 - 5,
        rect = Rect.fromCircle(center: center, radius: r);
    c.drawCircle(
      center,
      r,
      Paint()..color = Colors.white.withValues(alpha: .09),
    );
    c.save();
    c.clipPath(Path()..addOval(rect));
    for (var i = 0; i < 2; i++) {
      final p = Path();
      for (var x = 0.0; x <= s.width; x += 2) {
        final y =
            s.height * (1 - level * .88) -
            12 +
            math.sin(x / s.width * 2 * math.pi + phase * 2 * math.pi + i * 2) *
                7;
        if (x == 0) {
          p.moveTo(x, y);
        } else {
          p.lineTo(x, y);
        }
      }
      p.lineTo(s.width, s.height);
      p.lineTo(0, s.height);
      p.close();
      c.drawPath(
        p,
        Paint()
          ..color = (i == 0 ? aqua : turquoise).withValues(
            alpha: i == 0 ? .55 : .65,
          ),
      );
    }
    c.restore();
    c.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white38,
    );
    c.drawArc(
      rect,
      -math.pi / 2,
      level * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_WaterPainter p) => p.level != level || p.phase != phase;
}
