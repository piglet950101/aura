// Builds the clinical PDF from ReportData. Pure layout — all numbers are
// precomputed on ReportData. The document is light (it's a printout for a
// doctor), independent of the app's dark theme.

import 'dart:typed_data';

import 'package:aura/domain/calendar/month_overview.dart' show IntensityTier;
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/report/report_data.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportGenerator {
  const ReportGenerator();

  static const _accent = PdfColor.fromInt(0xFF7C5CFA);
  static const _ink = PdfColor.fromInt(0xFF1A1625);
  static const _muted = PdfColor.fromInt(0xFF6B6685);
  static const _line = PdfColor.fromInt(0xFFE2DEF0);
  static const _low = PdfColor.fromInt(0xFF3CB371);
  static const _med = PdfColor.fromInt(0xFFE0A800);
  static const _high = PdfColor.fromInt(0xFFE5484D);

  Future<Uint8List> generate(ReportData data) async {
    final df = DateFormat("d 'de' MMM yyyy", 'pt_PT');
    final dfFull = DateFormat("d 'de' MMMM yyyy 'às' HH:mm", 'pt_PT');
    final dfRow = DateFormat('dd/MM HH:mm', 'pt_PT');
    final dec = NumberFormat('0.0', 'pt_PT');

    final doc = pw.Document(title: 'AURA · Relatório da enxaqueca')
      ..addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          build: (context) => [
            _header(data, df, dfFull),
            pw.SizedBox(height: 18),
            _summary(data, dec),
            pw.SizedBox(height: 18),
            _intensity(data),
            pw.SizedBox(height: 18),
            if (data.symptomFrequency.isNotEmpty) ...[_symptoms(data), pw.SizedBox(height: 18)],
            if (data.medicationUsage.isNotEmpty) ...[_medications(data), pw.SizedBox(height: 18)],
            _crisisTable(data, dfRow),
          ],
          footer: _footer,
        ),
      );

    return doc.save();
  }

  pw.Widget _header(ReportData d, DateFormat df, DateFormat dfFull) {
    final age = d.age;
    final patient = (d.patientName != null && d.patientName!.isNotEmpty) ? d.patientName! : '—';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              'AURA',
              // pw.FontWeight.bold isn't const-evaluable in this package.
              // ignore: prefer_const_constructors
              style: pw.TextStyle(color: _accent, fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'Relatório da enxaqueca',
              style: const pw.TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
        pw.Divider(color: _line, thickness: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Paciente: $patient${age != null ? '  ·  $age anos' : ''}',
                  style: const pw.TextStyle(color: _ink, fontSize: 11),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Período: ${df.format(d.start)} – ${df.format(d.end.subtract(const Duration(days: 1)))}',
                  style: const pw.TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
            pw.Text(
              'Gerado em ${dfFull.format(d.generatedAt)}',
              style: const pw.TextStyle(color: _muted, fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _summary(ReportData d, NumberFormat dec) {
    final avg = d.averageIntensity;
    return _section('Resumo do período', [
      pw.Row(
        children: [
          _stat('${d.totalCrises}', 'crises'),
          _stat('${d.affectedDays}/${d.periodDays}', 'dias afetados'),
          _stat(avg == null ? '—' : dec.format(avg), 'intensidade média'),
          _stat('${d.sosDays}', 'dias medicação SOS', highlight: d.sosDays >= 10),
        ],
      ),
    ]);
  }

  pw.Widget _intensity(ReportData d) {
    return _section('Intensidade (dias)', [
      _bar('Sem dor de cabeça', d.daysNoPain, d.periodDays, _muted),
      _bar('Dor leve', d.daysLeve, d.periodDays, _low),
      _bar('Moderada', d.daysModerada, d.periodDays, _med),
      _bar('Forte', d.daysForte, d.periodDays, _high),
    ]);
  }

  pw.Widget _symptoms(ReportData d) {
    return _section('Sintomas mais frequentes', [
      pw.Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          for (final e in d.symptomFrequency)
            pw.Text(
              '${e.key.labelPt}: ${e.value}',
              style: const pw.TextStyle(color: _ink, fontSize: 10),
            ),
        ],
      ),
    ]);
  }

  pw.Widget _medications(ReportData d) {
    return _section('Medicação', [
      for (final u in d.medicationUsage)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(
            '${u.name} — ${u.times}x  '
            '(eficácia: ${u.total} total · ${u.partial} parcial · ${u.none} nenhuma)',
            style: const pw.TextStyle(color: _ink, fontSize: 10),
          ),
        ),
    ]);
  }

  pw.Widget _crisisTable(ReportData d, DateFormat dfRow) {
    pw.Widget cell(String t, {bool head = false, PdfColor? color}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        t,
        style: pw.TextStyle(
          color: color ?? (head ? _muted : _ink),
          fontSize: 9,
          fontWeight: head ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );

    final rows = <pw.TableRow>[
      pw.TableRow(
        children: [
          cell('Data', head: true),
          cell('Int.', head: true),
          cell('Sintomas', head: true),
          cell('Medicação', head: true),
          cell('Resposta', head: true),
        ],
      ),
      for (final c in d.crises)
        pw.TableRow(
          children: [
            cell(dfRow.format(c.occurredAt)),
            cell('${c.intensity} · ${_tierLabel(c.tier)}', color: _tierColor(c.tier)),
            cell(c.symptomCodes.map((code) => Symptom.fromCode(code)?.labelPt ?? code).join(', ')),
            cell(c.medications.map((m) => m.name).join(', ')),
            cell(c.medications.map((m) => _responseLabel(m.response)).join(', ')),
          ],
        ),
    ];

    return _section('Registo de crises', [
      if (d.crises.isEmpty)
        pw.Text('Sem crises no período.', style: const pw.TextStyle(color: _muted, fontSize: 10))
      else
        pw.Table(
          border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _line)),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.4),
            1: pw.FlexColumnWidth(1.4),
            2: pw.FlexColumnWidth(3),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(1.6),
          },
          children: rows,
        ),
    ]);
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Gerado pela AURA · dados privados',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
          pw.Text(
            '${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ---- small building blocks ----

  pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          // pw.FontWeight.bold isn't const-evaluable in this package.
          // ignore: prefer_const_constructors
          style: pw.TextStyle(
            color: _accent,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 6),
        ...children,
      ],
    );
  }

  pw.Widget _stat(String value, String label, {bool highlight = false}) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(right: 8),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: highlight ? _high : _line),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                color: highlight ? _high : _ink,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(label, style: const pw.TextStyle(color: _muted, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  pw.Widget _bar(String label, int value, int max, PdfColor color) {
    final filled = value.clamp(0, max);
    final rest = (max - filled).clamp(0, max);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label, style: const pw.TextStyle(color: _ink, fontSize: 9)),
          ),
          pw.Expanded(
            child: pw.Row(
              children: [
                if (filled > 0)
                  pw.Expanded(
                    flex: filled,
                    child: pw.Container(height: 8, color: color),
                  ),
                if (rest > 0)
                  pw.Expanded(
                    flex: rest,
                    child: pw.Container(height: 8, color: _line),
                  ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            '$value',
            style: pw.TextStyle(color: _ink, fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static String _tierLabel(IntensityTier t) => switch (t) {
    IntensityTier.none => 'sem dor',
    IntensityTier.low => 'leve',
    IntensityTier.med => 'moderada',
    IntensityTier.high => 'forte',
  };

  static PdfColor _tierColor(IntensityTier t) => switch (t) {
    IntensityTier.none => _muted,
    IntensityTier.low => _low,
    IntensityTier.med => _med,
    IntensityTier.high => _high,
  };

  static String _responseLabel(String? r) => switch (r) {
    'none' => 'nenhuma',
    'partial' => 'parcial',
    'total' => 'total',
    _ => '—',
  };
}
