enum CompetitionStatus {
  active('Қабылдау ашық'),
  evaluation('Бағалау кезеңі'),
  published('Нәтиже жарияланды');

  const CompetitionStatus(this.label);
  final String label;
}

class Competition {
  const Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.deadline,
    required this.createdAt,
    required this.organizerId,
    required this.rules,
    this.status = CompetitionStatus.active,
  });
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime deadline;
  final DateTime createdAt;
  final String organizerId;
  final String rules;
  final CompetitionStatus status;
  CompetitionStatus statusAt(DateTime now) =>
      status == CompetitionStatus.active && !deadline.isAfter(now)
      ? CompetitionStatus.evaluation
      : status;
  Competition withStatus(CompetitionStatus value) => Competition(
    id: id,
    title: title,
    description: description,
    category: category,
    deadline: deadline,
    createdAt: createdAt,
    organizerId: organizerId,
    rules: rules,
    status: value,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'deadline': deadline.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'organizerId': organizerId,
    'rules': rules,
    'status': status.name,
  };
  factory Competition.fromJson(Map<String, dynamic> j) => Competition(
    id: j['id'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    category: j['category'] as String,
    deadline: DateTime.parse(j['deadline'] as String),
    createdAt: DateTime.parse(j['createdAt'] as String),
    organizerId: j['organizerId'] as String,
    rules: j['rules'] as String,
    status: CompetitionStatus.values.byName(j['status'] as String),
  );
}
