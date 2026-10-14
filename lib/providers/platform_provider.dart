import 'package:flutter/foundation.dart';
import '../data/demo_data.dart';
import '../models/app_data.dart';
import '../models/competition.dart';
import '../models/evaluation.dart';
import '../models/submission.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import '../services/scoring_service.dart';
import '../core/formatters.dart';

class PlatformProvider extends ChangeNotifier {
  PlatformProvider({LocalStorageService? storage, DateTime Function()? clock})
    : _storage = storage ?? LocalStorageService(),
      _clock = clock ?? DateTime.now;
  final LocalStorageService _storage;
  final DateTime Function() _clock;
  AppData? _data;
  bool loading = true;
  bool saving = false;
  String? loadError;
  DateTime get now => _clock();
  List<User> get users => _data?.users ?? [];
  List<Competition> get competitions => _data?.competitions ?? [];
  List<Submission> get submissions => _data?.submissions ?? [];
  List<Evaluation> get evaluations => _data?.evaluations ?? [];
  User? get currentUser =>
      users.where((u) => u.id == _data?.selectedUserId).firstOrNull;
  User user(String id) => users.firstWhere((u) => u.id == id);
  Competition competition(String id) =>
      competitions.firstWhere((c) => c.id == id);
  Submission submission(String id) => submissions.firstWhere((s) => s.id == id);
  CompetitionStatus status(Competition c) => c.statusAt(now);
  List<Submission> worksFor(String id) =>
      submissions.where((s) => s.competitionId == id).toList();
  List<Evaluation> gradesFor(String id) =>
      evaluations.where((e) => e.submissionId == id).toList();
  Evaluation? myGrade(String id) =>
      gradesFor(id).where((e) => e.juryId == currentUser?.id).firstOrNull;
  double? scoreFor(String id) => ScoringService.average(gradesFor(id));
  List<RankedSubmission> ranking(String id) =>
      ScoringService.ranking(worksFor(id), evaluations);
  bool canSeeResults(Competition c) =>
      status(c) == CompetitionStatus.published ||
      currentUser?.role == UserRole.jury ||
      currentUser?.id == c.organizerId;
  SubmissionStatus workStatus(Submission s) =>
      status(competition(s.competitionId)) == CompetitionStatus.published
      ? SubmissionStatus.published
      : gradesFor(s.id).isNotEmpty
      ? SubmissionStatus.evaluated
      : SubmissionStatus.submitted;

  Future<void> initialize() async {
    loading = true;
    loadError = null;
    notifyListeners();
    try {
      final loaded = await _storage.load();
      final data = loaded ?? createDemoData(now);
      _validate(data);
      if (loaded == null) {
        await _storage.save(data);
      }
      _data = data;
    } catch (_) {
      loadError =
          'Жергілікті деректерді оқу мүмкін болмады. Қайта көріңіз. Сақталған деректер өзгертілмеді.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _validate(AppData data) {
    final ids = data.users.map((u) => u.id).toSet();
    final contestIds = data.competitions.map((c) => c.id).toSet();
    final workIds = data.submissions.map((s) => s.id).toSet();
    if (ids.length != data.users.length ||
        contestIds.length != data.competitions.length ||
        workIds.length != data.submissions.length ||
        (data.selectedUserId != null && !ids.contains(data.selectedUserId))) {
      throw const FormatException('Invalid IDs');
    }
    final pairs = <String>{};
    for (final c in data.competitions) {
      if (!ids.contains(c.organizerId) ||
          data.users.firstWhere((u) => u.id == c.organizerId).role !=
              UserRole.organizer) {
        throw const FormatException('Invalid organizer');
      }
    }
    for (final s in data.submissions) {
      if (!ids.contains(s.participantId) ||
          !contestIds.contains(s.competitionId) ||
          data.users.firstWhere((u) => u.id == s.participantId).role !=
              UserRole.participant ||
          !pairs.add('${s.competitionId}:${s.participantId}')) {
        throw const FormatException('Invalid submission');
      }
    }
    pairs.clear();
    for (final e in data.evaluations) {
      if (!workIds.contains(e.submissionId) ||
          !ids.contains(e.juryId) ||
          data.users.firstWhere((u) => u.id == e.juryId).role !=
              UserRole.jury ||
          !pairs.add('${e.submissionId}:${e.juryId}')) {
        throw const FormatException('Invalid evaluation');
      }
      ScoringService.score(e.creativity, e.quality, e.presentation);
    }
  }

  Future<void> _commit(AppData next) async {
    if (saving) {
      throw StateError('Алдыңғы әрекеттің сақталуын күтіңіз.');
    }
    saving = true;
    notifyListeners();
    try {
      await _storage.save(next);
      _data = next;
    } catch (_) {
      throw StateError('Сақтау мүмкін болмады. Қайта көріңіз.');
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  User _require(UserRole role) {
    final selected = currentUser;
    if (selected == null || selected.role != role) {
      throw StateError('Бұл әрекетке рөліңіз сәйкес емес.');
    }
    return selected;
  }

  String _id(String prefix) =>
      '$prefix-${now.microsecondsSinceEpoch}-${competitions.length + submissions.length}';
  Future<void> selectUser(String id) async {
    user(id);
    await _commit(_data!.copyWith(selectedUserId: id));
  }

  Future<String> createCompetition({
    required String title,
    required String description,
    required String category,
    required DateTime deadline,
    required String rules,
  }) async {
    final organizer = _require(UserRole.organizer);
    if (requiredText(title) != null ||
        requiredText(description, min: 10) != null ||
        requiredText(rules, min: 10) != null ||
        !categories.contains(category) ||
        !deadline.isAfter(now)) {
      throw ArgumentError('Өрістерді тексеріңіз. Мерзім болашақта болуы тиіс.');
    }
    final c = Competition(
      id: _id('c'),
      title: title.trim(),
      description: description.trim(),
      category: category,
      deadline: deadline,
      createdAt: now,
      organizerId: organizer.id,
      rules: rules.trim(),
    );
    await _commit(_data!.copyWith(competitions: [c, ...competitions]));
    return c.id;
  }

  Future<void> submitWork({
    required String competitionId,
    required String title,
    required String description,
    required String link,
  }) async {
    final participant = _require(UserRole.participant);
    final c = competition(competitionId);
    if (status(c) != CompetitionStatus.active) {
      throw StateError('Жұмыс қабылдау аяқталды.');
    }
    if (worksFor(c.id).any((s) => s.participantId == participant.id)) {
      throw StateError('Сіз бұл байқауға жұмыс жібердіңіз.');
    }
    if (requiredText(title) != null ||
        requiredText(description, min: 10) != null ||
        linkError(link) != null) {
      throw ArgumentError('Жұмыс туралы ақпаратты тексеріңіз.');
    }
    final s = Submission(
      id: _id('s'),
      competitionId: c.id,
      participantId: participant.id,
      title: title.trim(),
      description: description.trim(),
      link: link.trim(),
      createdAt: now,
    );
    await _commit(_data!.copyWith(submissions: [s, ...submissions]));
  }

  Future<void> evaluate({
    required String submissionId,
    required double creativity,
    required double quality,
    required double presentation,
    required String comment,
  }) async {
    final jury = _require(UserRole.jury);
    final s = submission(submissionId);
    if (status(competition(s.competitionId)) == CompetitionStatus.published) {
      throw StateError('Жарияланған нәтиже өзгертілмейді.');
    }
    ScoringService.score(creativity, quality, presentation);
    if (requiredText(comment, min: 5) != null) {
      throw ArgumentError('Кемінде 5 таңбалы пікір жазыңыз.');
    }
    final e = Evaluation(
      submissionId: s.id,
      juryId: jury.id,
      creativity: creativity,
      quality: quality,
      presentation: presentation,
      comment: comment.trim(),
      updatedAt: now,
    );
    await _commit(
      _data!.copyWith(
        evaluations: [
          ...evaluations.where(
            (x) => !(x.submissionId == s.id && x.juryId == jury.id),
          ),
          e,
        ],
      ),
    );
  }

  Future<void> closeSubmissions(String id) async {
    final organizer = _require(UserRole.organizer);
    final c = competition(id);
    if (c.organizerId != organizer.id ||
        status(c) != CompetitionStatus.active) {
      throw StateError('Қабылдауды тоқтату мүмкін емес.');
    }
    await _commit(
      _data!.copyWith(
        competitions: competitions
            .map(
              (x) =>
                  x.id == id ? x.withStatus(CompetitionStatus.evaluation) : x,
            )
            .toList(),
      ),
    );
  }

  Future<void> publishResults(String id) async {
    final organizer = _require(UserRole.organizer);
    final c = competition(id);
    if (c.organizerId != organizer.id ||
        status(c) == CompetitionStatus.published) {
      throw StateError('Нәтижені жариялау мүмкін емес.');
    }
    final works = worksFor(id);
    if (works.isEmpty || works.any((s) => gradesFor(s.id).isEmpty)) {
      throw StateError('Барлық жұмыстарға кемінде бір қазы баға қоюы керек.');
    }
    await _commit(
      _data!.copyWith(
        competitions: competitions
            .map(
              (x) => x.id == id ? x.withStatus(CompetitionStatus.published) : x,
            )
            .toList(),
      ),
    );
  }
}
