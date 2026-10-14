enum SubmissionStatus {
  submitted('Жіберілді'),
  evaluated('Бағаланды'),
  published('Нәтиже дайын');

  const SubmissionStatus(this.label);
  final String label;
}

class Submission {
  const Submission({
    required this.id,
    required this.competitionId,
    required this.participantId,
    required this.title,
    required this.description,
    required this.link,
    required this.createdAt,
  });
  final String id;
  final String competitionId;
  final String participantId;
  final String title;
  final String description;
  final String link;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'competitionId': competitionId,
    'participantId': participantId,
    'title': title,
    'description': description,
    'link': link,
    'createdAt': createdAt.toIso8601String(),
  };
  factory Submission.fromJson(Map<String, dynamic> j) => Submission(
    id: j['id'] as String,
    competitionId: j['competitionId'] as String,
    participantId: j['participantId'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    link: j['link'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}
