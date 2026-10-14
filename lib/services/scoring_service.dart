import '../models/evaluation.dart';
import '../models/submission.dart';

class RankedSubmission {
  const RankedSubmission(
    this.submission,
    this.score,
    this.juryCount,
    this.rank,
  );
  final Submission submission;
  final double score;
  final int juryCount;
  final int rank;
}

class ScoringService {
  static double score(double creativity, double quality, double presentation) {
    for (final value in [creativity, quality, presentation]) {
      if (!value.isFinite || value < 0 || value > 10) {
        throw ArgumentError('Критерий 0–10 аралығында болуы керек.');
      }
    }
    return (creativity * EvaluationCriteria.creativity.weight +
            quality * EvaluationCriteria.quality.weight +
            presentation * EvaluationCriteria.presentation.weight) *
        10;
  }

  static double? average(Iterable<Evaluation> evaluations) {
    final values = evaluations.toList();
    if (values.isEmpty) {
      return null;
    }
    return values
            .map((e) => score(e.creativity, e.quality, e.presentation))
            .reduce((a, b) => a + b) /
        values.length;
  }

  static List<RankedSubmission> ranking(
    Iterable<Submission> submissions,
    Iterable<Evaluation> evaluations,
  ) {
    final rows = <RankedSubmission>[];
    for (final work in submissions) {
      final grades = evaluations
          .where((e) => e.submissionId == work.id)
          .toList();
      final value = average(grades);
      if (value != null) {
        rows.add(RankedSubmission(work, value, grades.length, 0));
      }
    }
    rows.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      if (scoreOrder != 0) {
        return scoreOrder;
      }
      final dateOrder = a.submission.createdAt.compareTo(
        b.submission.createdAt,
      );
      return dateOrder != 0
          ? dateOrder
          : a.submission.id.compareTo(b.submission.id);
    });
    // Тең ұпайға тең орын беріледі: 1, 1, 3.
    var rank = 0;
    return List.generate(rows.length, (i) {
      if (i == 0 || (rows[i].score - rows[i - 1].score).abs() > .0000001) {
        rank = i + 1;
      }
      return RankedSubmission(
        rows[i].submission,
        rows[i].score,
        rows[i].juryCount,
        rank,
      );
    });
  }
}
