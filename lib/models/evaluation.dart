class EvaluationCriteria {
  const EvaluationCriteria(this.name, this.weight);
  final String name;
  final double weight;
  static const creativity = EvaluationCriteria('Шығармашылық', .40);
  static const quality = EvaluationCriteria('Орындау сапасы', .35);
  static const presentation = EvaluationCriteria('Ұсыну деңгейі', .25);
  static const values = [creativity, quality, presentation];
}

class Evaluation {
  const Evaluation({
    required this.submissionId,
    required this.juryId,
    required this.creativity,
    required this.quality,
    required this.presentation,
    required this.comment,
    required this.updatedAt,
  });
  final String submissionId;
  final String juryId;
  final double creativity;
  final double quality;
  final double presentation;
  final String comment;
  final DateTime updatedAt;
  Map<String, dynamic> toJson() => {
    'submissionId': submissionId,
    'juryId': juryId,
    'creativity': creativity,
    'quality': quality,
    'presentation': presentation,
    'comment': comment,
    'updatedAt': updatedAt.toIso8601String(),
  };
  factory Evaluation.fromJson(Map<String, dynamic> j) => Evaluation(
    submissionId: j['submissionId'] as String,
    juryId: j['juryId'] as String,
    creativity: (j['creativity'] as num).toDouble(),
    quality: (j['quality'] as num).toDouble(),
    presentation: (j['presentation'] as num).toDouble(),
    comment: j['comment'] as String,
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );
}
