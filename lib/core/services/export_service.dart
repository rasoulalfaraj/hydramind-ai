import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../l10n/app_localizations.dart';
import '../domain/models.dart';

String csvCell(String s) {
  if (RegExp(r'^\s*[=+@\-\t\r]').hasMatch(s)) s = "'$s";
  return '"${s.replaceAll('"', '""')}"';
}

String buildCsv(List<Intake> entries, AppLocalizations l) {
  final names = [l.water, l.tea, l.coffee, l.milk, l.juice, l.other];
  return '\uFEFF${[l.dateTime, l.beverage, l.quantity, l.notes].map(csvCell).join(',')}\r\n${entries.map((e) => [e.at.toIso8601String(), names[e.drink.index], '${e.ml}', e.note].map(csvCell).join(',')).join('\r\n')}';
}

class ExportService {
  static Future<Uint8List> pdfBytes(
    List<Intake> entries,
    AppLocalizations l,
  ) async {
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo.ttf'));
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    final grouped = <String, int>{};
    for (final e in entries) {
      grouped.update(dayKey(e.at), (n) => n + e.ml, ifAbsent: () => e.ml);
    }
    final days = grouped.keys.toList()..sort();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: l.localeName == 'ar'
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        build: (c) => [
          pw.Text(l.appName, style: const pw.TextStyle(fontSize: 26)),
          pw.Text(l.report),
          pw.SizedBox(height: 16),
          pw.Text('${l.total}: ${entries.fold(0, (a, e) => a + e.ml)} ${l.ml}'),
          pw.Text(l.notMedical),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [l.dateTime, l.recorded],
            data: days.map((day) => [day, '${grouped[day]} ${l.ml}']).toList(),
            headerStyle: pw.TextStyle(font: font),
            cellStyle: pw.TextStyle(font: font),
          ),
        ],
      ),
    );
    return document.save();
  }

  static Future<void> share(
    List<Intake> entries,
    AppLocalizations l, {
    bool pdf = false,
    Rect? origin,
  }) async {
    final ext = pdf ? 'pdf' : 'csv',
        file = File(
          '${(await getTemporaryDirectory()).path}/hydramind-${DateTime.now().millisecondsSinceEpoch}.$ext',
        );
    try {
      await file.writeAsBytes(
        pdf ? await pdfBytes(entries, l) : utf8.encode(buildCsv(entries, l)),
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: pdf ? 'application/pdf' : 'text/csv'),
          ],
          sharePositionOrigin: origin,
        ),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
