import 'competition.dart';
import 'evaluation.dart';
import 'submission.dart';
import 'user.dart';

class AppData {
  AppData({
    required List<User> users,
    required List<Competition> competitions,
    required List<Submission> submissions,
    required List<Evaluation> evaluations,
    this.selectedUserId,
  }) : users = List.unmodifiable(users),
       competitions = List.unmodifiable(competitions),
       submissions = List.unmodifiable(submissions),
       evaluations = List.unmodifiable(evaluations);
  final List<User> users;
  final List<Competition> competitions;
  final List<Submission> submissions;
  final List<Evaluation> evaluations;
  final String? selectedUserId;
  AppData copyWith({
    List<Competition>? competitions,
    List<Submission>? submissions,
    List<Evaluation>? evaluations,
    String? selectedUserId,
  }) => AppData(
    users: users,
    competitions: competitions ?? this.competitions,
    submissions: submissions ?? this.submissions,
    evaluations: evaluations ?? this.evaluations,
    selectedUserId: selectedUserId ?? this.selectedUserId,
  );
  Map<String, dynamic> toJson() => {
    'version': 1,
    'users': users.map((x) => x.toJson()).toList(),
    'competitions': competitions.map((x) => x.toJson()).toList(),
    'submissions': submissions.map((x) => x.toJson()).toList(),
    'evaluations': evaluations.map((x) => x.toJson()).toList(),
    'selectedUserId': selectedUserId,
  };
  factory AppData.fromJson(Map<String, dynamic> j) {
    if (j['version'] != 1) {
      throw const FormatException('Unsupported data version');
    }
    return AppData(
      users: (j['users'] as List)
          .map((x) => User.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList(),
      competitions: (j['competitions'] as List)
          .map((x) => Competition.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList(),
      submissions: (j['submissions'] as List)
          .map((x) => Submission.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList(),
      evaluations: (j['evaluations'] as List)
          .map((x) => Evaluation.fromJson(Map<String, dynamic>.from(x as Map)))
          .toList(),
      selectedUserId: j['selectedUserId'] as String?,
    );
  }
}
