import 'package:flutter_test/flutter_test.dart' hide Evaluation;
import 'package:baiqau/models/evaluation.dart';
import 'package:baiqau/models/submission.dart';
import 'package:baiqau/services/scoring_service.dart';

Evaluation grade(String work, String jury, double a, double b, double c) =>
    Evaluation(
      submissionId: work,
      juryId: jury,
      creativity: a,
      quality: b,
      presentation: c,
      comment: 'Пікір',
      updatedAt: DateTime(2026, 10, 12),
    );
Submission work(String id) => Submission(
  id: id,
  competitionId: 'contest',
  participantId: id,
  title: id,
  description: 'Жұмыс',
  link: 'https://example.com',
  createdAt: DateTime(2026, 10, 12),
);

void main() {
  test('40/35/25 weighted score on a 100-point scale', () {
    expect(ScoringService.score(8, 9, 7), closeTo(81, 1e-9));
    expect(ScoringService.score(10, 0, 0), 40);
    expect(ScoringService.score(0, 10, 0), 35);
    expect(ScoringService.score(0, 0, 10), 25);
  });
  test('zero and maximum scores are valid', () {
    expect(ScoringService.score(0, 0, 0), 0);
    expect(ScoringService.score(10, 10, 10), 100);
  });
  test('out of range and non-finite values are rejected', () {
    for (final value in [-.5, 10.5, double.nan, double.infinity]) {
      expect(() => ScoringService.score(value, 7, 7), throwsArgumentError);
      expect(() => ScoringService.score(7, value, 7), throwsArgumentError);
      expect(() => ScoringService.score(7, 7, value), throwsArgumentError);
    }
  });
  test('multiple juries use the arithmetic mean', () {
    expect(
      ScoringService.average([
        grade('w', 'j1', 8, 9, 7),
        grade('w', 'j2', 10, 10, 10),
      ]),
      closeTo(90.5, 1e-9),
    );
    expect(ScoringService.average([]), isNull);
    expect(ScoringService.average([grade('w', 'j1', 0, 0, 0)]), 0);
  });
  test('ranking excludes ungraded work and sorts descending', () {
    final ranking = ScoringService.ranking(
      [work('a'), work('b'), work('c')],
      [grade('a', 'j1', 6, 6, 6), grade('b', 'j1', 9, 9, 9)],
    );
    expect(ranking.map((r) => r.submission.id), ['b', 'a']);
    expect(ranking.map((r) => r.rank), [1, 2]);
  });
  test('tied scores share rank with stable ordering', () {
    final ranking = ScoringService.ranking(
      [work('b'), work('a'), work('c')],
      [
        grade('a', 'j1', 9, 9, 9),
        grade('b', 'j1', 9, 9, 9),
        grade('c', 'j1', 5, 5, 5),
      ],
    );
    expect(ranking.map((r) => r.submission.id), ['a', 'b', 'c']);
    expect(ranking.map((r) => r.rank), [1, 1, 3]);
  });
}
