// Builds the clinical PDF from ReportData. Pure layout — all numbers are
// precomputed on ReportData. The document is light (it's a printout for a
// doctor), independent of the app's dark theme.

import 'dart:typed_data';

import 'package:aura/domain/calendar/month_overview.dart' show IntensityTier;
import 'package:aura/domain/crisis/symptom.dart';
import 'package:aura/domain/hit6/hit6.dart';
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

    final doc = pw.Document(title: 'AURA · Relatório de Registos')
      ..addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          build: (context) => [
            _header(data, df, dfFull),
            pw.SizedBox(height: 14),
            _summary(data, dec),
            pw.SizedBox(height: 16),
            if (data.latestHit6 != null) ...[_hit6Card(data), pw.SizedBox(height: 16)],
            _intensity(data),
            pw.SizedBox(height: 16),
            if (_anyWeekdayData(data)) ...[_weekdayHeat(data), pw.SizedBox(height: 16)],
            if (data.auraDays > 0 || data.daysWithMenstruation > 0) ...[
              _auraMenstruationCard(data),
              pw.SizedBox(height: 16),
            ],
            if (data.symptomFrequency.isNotEmpty) ...[_symptoms(data), pw.SizedBox(height: 16)],
            if (data.medicationUsage.isNotEmpty) ...[_medications(data), pw.SizedBox(height: 16)],
            _crisisTable(data, dfRow),
          ],
          footer: _footer,
        ),
      );

    return doc.save();
  }

  bool _anyWeekdayData(ReportData d) {
    return d.intensityByWeekday.values.any((v) => v > 0);
  }

  pw.Widget _header(ReportData d, DateFormat df, DateFormat dfFull) {
    final age = d.age;
    final patient = (d.patientName != null && d.patientName!.isNotEmpty) ? d.patientName! : '—';
    final email = (d.patientEmail != null && d.patientEmail!.isNotEmpty) ? d.patientEmail! : null;
    final sexLabel = switch (d.sex) {
      'f' => 'Feminino',
      'm' => 'Masculino',
      'other' => 'Outro',
      _ => null,
    };
    final patientLine = [
      patient,
      if (age != null) '$age anos',
      if (sexLabel != null) sexLabel,
    ].join(' · ');

    // Next appointment context, when scheduled.
    final next = d.nextAppointment;
    String? consultLine;
    if (next != null) {
      final ctxFmt = DateFormat("d 'de' MMM 'às' HH:mm", 'pt_PT');
      final who = next.doctorName != null ? ' com ${next.doctorName}' : '';
      final where = next.location != null ? ', ${next.location}' : '';
      consultLine = 'Próxima consulta: ${ctxFmt.format(next.occursAt)}$who$where';
    }

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
              'Relatório da Enxaqueca',
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
                pw.Text(patientLine, style: const pw.TextStyle(color: _ink, fontSize: 11)),
                if (email != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(email, style: const pw.TextStyle(color: _muted, fontSize: 9)),
                ],
                pw.SizedBox(height: 2),
                pw.Text(
                  'Período: ${df.format(d.start)} – ${df.format(d.end.subtract(const Duration(days: 1)))}',
                  style: const pw.TextStyle(color: _muted, fontSize: 10),
                ),
                if (consultLine != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(consultLine, style: const pw.TextStyle(color: _accent, fontSize: 10)),
                ],
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
    // Comparative deltas against the immediately previous window of the
    // same length. Green when the metric improved (went down), red when
    // it worsened. Affected days is the headline number per the spec.
    final prev = _prevStats(d, dec);
    return _section('Resumo do período', [
      pw.Row(
        children: [
          _stat('${d.totalCrises}', 'crises', sub: prev?.crises),
          _stat('${d.affectedDays}/${d.periodDays}', 'dias afetados', sub: prev?.affected),
          _stat(avg == null ? '—' : dec.format(avg), 'intensidade média', sub: prev?.intensity),
          _stat('${d.sosDays}', 'dias SOS', highlight: d.sosDays >= 10, sub: prev?.sos),
        ],
      ),
    ]);
  }

  /// Previous-period subtitle strings ("vs. 9 (-2)"). Returns null when no
  /// previous-window crises exist.
  _PrevStats? _prevStats(ReportData d, NumberFormat dec) {
    if (d.previousCrises.isEmpty) return null;
    final prevCount = d.previousCrises.length;
    final prevDays = d.previousCrises
        .map((c) => DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day))
        .toSet()
        .length;
    final prevAvg = d.previousCrises.fold<int>(0, (s, c) => s + c.intensity) / prevCount;
    final prevSos = d.previousCrises
        .where((c) => c.tookSos)
        .map((c) => DateTime(c.occurredAt.year, c.occurredAt.month, c.occurredAt.day))
        .toSet()
        .length;
    return _PrevStats(
      crises: 'vs. $prevCount (${_delta(d.totalCrises - prevCount)})',
      affected: 'vs. $prevDays (${_delta(d.affectedDays - prevDays)})',
      intensity: d.averageIntensity == null
          ? null
          : 'vs. ${dec.format(prevAvg)} (${_delta((d.averageIntensity! - prevAvg).round())})',
      sos: 'vs. $prevSos (${_delta(d.sosDays - prevSos)})',
    );
  }

  String _delta(int n) {
    if (n == 0) return '=';
    return n > 0 ? '+$n' : '$n';
  }

  pw.Widget _hit6Card(ReportData d) {
    final h = d.latestHit6!;
    final cat = switch (h.category) {
      Hit6Category.littleOrNone => 'Impacto pouco / nenhum',
      Hit6Category.some => 'Algum impacto',
      Hit6Category.substantial => 'Impacto substancial',
      Hit6Category.severe => 'Impacto severo',
    };
    final danger = h.category == Hit6Category.severe;
    return _section('Avaliação de impacto (HIT-6)', [
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: danger ? _high : _line),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  '${h.score}',
                  style: pw.TextStyle(
                    color: danger ? _high : _accent,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  cat,
                  style: pw.TextStyle(
                    color: danger ? _high : _ink,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            // 36..78 severity scale with a marker at the current score.
            pw.LayoutBuilder(
              builder: (ctx, constraints) {
                final width = constraints?.maxWidth ?? 400;
                final ratio = ((h.score - 36) / (78 - 36)).clamp(0.0, 1.0);
                final markerX = width * ratio;
                return pw.SizedBox(
                  height: 14,
                  child: pw.Stack(
                    children: [
                      pw.Container(
                        height: 6,
                        margin: const pw.EdgeInsets.only(top: 4),
                        decoration: pw.BoxDecoration(
                          color: _line,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                      ),
                      pw.Positioned(
                        left: (markerX - 5).clamp(0.0, width - 10),
                        top: 0,
                        child: pw.Container(
                          width: 10,
                          height: 14,
                          decoration: pw.BoxDecoration(
                            color: danger ? _high : _accent,
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            pw.SizedBox(height: 2),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('36 baixo', style: const pw.TextStyle(color: _muted, fontSize: 7)),
                pw.Text('60', style: const pw.TextStyle(color: _muted, fontSize: 7)),
                pw.Text('78 muito grave', style: const pw.TextStyle(color: _muted, fontSize: 7)),
              ],
            ),
            if (d.hit6History.length > 1) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                'Histórico: ${d.hit6History.map((s) => s.score).join(' → ')}',
                style: const pw.TextStyle(color: _muted, fontSize: 9),
              ),
            ],
          ],
        ),
      ),
    ]);
  }

  pw.Widget _weekdayHeat(ReportData d) {
    final byWeekday = d.intensityByWeekday;
    final maxValue = byWeekday.values.fold<double>(0, (m, v) => v > m ? v : m);
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    PdfColor colorFor(double v) {
      if (v == 0) return _line;
      if (v <= 3) return _low;
      if (v <= 6) return _med;
      return _high;
    }

    return _section('Intensidade por dia da semana', [
      pw.Row(
        children: [
          for (var i = 1; i <= 7; i++)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                child: pw.Column(
                  children: [
                    pw.Container(
                      height: 36,
                      decoration: pw.BoxDecoration(
                        color: colorFor(byWeekday[i] ?? 0),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      alignment: pw.Alignment.center,
                      child: (byWeekday[i] ?? 0) > 0
                          ? pw.Text(
                              (byWeekday[i]!).toStringAsFixed(1),
                              style: pw.TextStyle(
                                color: ((byWeekday[i] ?? 0) / (maxValue == 0 ? 1 : maxValue)) > 0.5
                                    ? PdfColors.white
                                    : _ink,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            )
                          : pw.SizedBox.shrink(),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(labels[i - 1], style: const pw.TextStyle(color: _muted, fontSize: 8)),
                  ],
                ),
              ),
            ),
        ],
      ),
    ]);
  }

  pw.Widget _auraMenstruationCard(ReportData d) {
    final pct = d.totalCrises == 0
        ? 0
        : ((d.crises.where((c) => c.menstruation ?? false).length / d.totalCrises) * 100).round();
    return _section('Aura e ciclo menstrual', [
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _line),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '✨ Aura',
                    style: pw.TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${d.auraDays} dias com aura',
                    style: const pw.TextStyle(color: _ink, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (d.daysWithMenstruation > 0) ...[
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _line),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Correlação hormonal',
                      style: pw.TextStyle(
                        color: _accent,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '$pct% das crises coincidem com o período menstrual',
                      style: const pw.TextStyle(color: _ink, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  pw.Widget _stat(String value, String label, {bool highlight = false, String? sub}) {
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
            if (sub != null) ...[
              pw.SizedBox(height: 1),
              pw.Text(sub, style: const pw.TextStyle(color: _muted, fontSize: 7)),
            ],
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

/// Subtitle strings for the comparative summary tiles ("vs. 9 (-2)").
class _PrevStats {
  const _PrevStats({this.crises, this.affected, this.intensity, this.sos});
  final String? crises;
  final String? affected;
  final String? intensity;
  final String? sos;
}
