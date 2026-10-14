enum UserRole {
  organizer('Ұйымдастырушы', 'Байқау ұйымдастырып, жаңа таланттарды ашыңыз'),
  participant('Қатысушы', 'Идеяңызды көрсетіп, жеңіске бір қадам жасаңыз'),
  jury('Қазы', 'Жұмыстарды бағалап, үздіктерді анықтаңыз');

  const UserRole(this.label, this.description);
  final String label;
  final String description;
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
  });
  final String id;
  final String name;
  final UserRole role;
  final String department;
  String get initials => name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0])
      .join();
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'department': department,
  };
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    role: UserRole.values.byName(json['role'] as String),
    department: json['department'] as String,
  );
}
