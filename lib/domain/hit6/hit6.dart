/// HIT-6 (Headache Impact Test) — the 6-question instrument the client asked
/// us to surface in "Preparar Consulta" + carry into the medical report.
///
/// Each answer scores one of {6, 8, 10, 11, 13}. The score is the sum across
/// the six questions (range 36..78), categorised as:
///   ≤49  little or no impact
///   50-55 some impact
///   56-59 substantial impact
///   ≥60  severe impact
///
/// We persist the full answer array (JSON-encoded `[q1..q6]`) so future
/// versions can re-categorise without re-asking; the `score` column is the
/// cached sum so screens can sort/render without parsing.
library;

/// Stable codes for the 5 HIT-6 answer options + their points.
enum Hit6Answer {
  never('never', 6),
  rarely('rarely', 8),
  sometimes('sometimes', 10),
  veryOften('very_often', 11),
  always('always', 13);

  const Hit6Answer(this.code, this.points);
  final String code;
  final int points;

  static Hit6Answer? fromCode(String? code) {
    if (code == null) return null;
    for (final a in Hit6Answer.values) {
      if (a.code == code) return a;
    }
    return null;
  }
}

/// Severity bucket for a HIT-6 score (used by the score card + the report).
enum Hit6Category {
  littleOrNone, // 36..49
  some, // 50..55
  substantial, // 56..59
  severe; // 60..78

  static Hit6Category fromScore(int score) {
    if (score <= 49) return Hit6Category.littleOrNone;
    if (score <= 55) return Hit6Category.some;
    if (score <= 59) return Hit6Category.substantial;
    return Hit6Category.severe;
  }
}

/// One question = one answer.
class Hit6Submission {
  const Hit6Submission({
    required this.id,
    required this.submittedAt,
    required this.score,
    required this.answers,
  });

  final String id;
  final DateTime submittedAt;
  final int score;
  final List<Hit6Answer> answers;

  Hit6Category get category => Hit6Category.fromScore(score);
}

/// How long after the last submission a fresh one becomes available again.
const hit6CooldownDays = 30;

/// True if [last] is null OR submitted more than [hit6CooldownDays] ago.
bool hit6IsDue(DateTime? last, DateTime now) {
  if (last == null) return true;
  return now.difference(last).inDays >= hit6CooldownDays;
}
