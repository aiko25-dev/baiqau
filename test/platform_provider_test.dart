import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiqau/models/app_data.dart';
import 'package:baiqau/models/competition.dart';
import 'package:baiqau/models/submission.dart';
import 'package:baiqau/providers/platform_provider.dart';
import 'package:baiqau/services/local_storage_service.dart';

class FailingStorage extends LocalStorageService {
  bool fail = false;
  @override
  Future<void> save(AppData data) async {
    if (fail) {
      throw StateError('disk full');
    }
    await super.save(data);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PlatformProvider p;
  var now = DateTime(2026, 10, 12, 10);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 10, 12, 10);
    p = PlatformProvider(clock: () => now);
    await p.initialize();
  });
  tearDown(() => p.dispose());
  Future<String> create() async {
    await p.selectUser('organizer');
    return p.createCompetition(
      title: 'Жаңа байқау',
      description: 'Жаңа идеяларға арналған байқау',
      category: 'Дизайн',
      deadline: now.add(const Duration(days: 1)),
      rules: 'Тек авторлық жұмыстар қабылданады.',
    );
  }

  Future<void> submit(String id, {String participant = 'p0'}) async {
    await p.selectUser(participant);
    await p.submitWork(
      competitionId: id,
      title: 'Менің жобам',
      description: 'Жобаның толық сипаттамасы',
      link: 'https://example.com/work',
    );
  }

  test('demo seeds once and selection persists across restart', () async {
    expect(p.competitions.length, 5);
    expect(p.users.length, 14);
    final id = await create();
    final reopened = PlatformProvider(clock: () => now);
    await reopened.initialize();
    expect(reopened.loadError, isNull);
    expect(reopened.competitions.length, 6);
    expect(reopened.competition(id).title, 'Жаңа байқау');
    expect(reopened.currentUser!.id, 'organizer');
    reopened.dispose();
  });
  test(
    'complete defense flow: create → submit → evaluate → edit → average → publish → reload',
    () async {
      final id = await create();
      await submit(id);
      final s = p.worksFor(id).single;
      expect(p.workStatus(s), SubmissionStatus.submitted);
      expect(p.canSeeResults(p.competition(id)), false);
      await p.selectUser('jury1');
      await p.evaluate(
        submissionId: s.id,
        creativity: 8,
        quality: 9,
        presentation: 7,
        comment: 'Жақсы авторлық жұмыс.',
      );
      expect(p.scoreFor(s.id), closeTo(81, 1e-9));
      expect(p.workStatus(s), SubmissionStatus.evaluated);
      await p.evaluate(
        submissionId: s.id,
        creativity: 9,
        quality: 9,
        presentation: 9,
        comment: 'Түзетілген баға.',
      );
      expect(p.gradesFor(s.id).length, 1);
      expect(p.scoreFor(s.id), closeTo(90, 1e-9));
      await p.selectUser('jury2');
      await p.evaluate(
        submissionId: s.id,
        creativity: 7,
        quality: 7,
        presentation: 7,
        comment: 'Екінші қазы пікірі.',
      );
      expect(p.scoreFor(s.id), closeTo(80, 1e-9));
      expect(p.ranking(id).single.rank, 1);
      expect(p.ranking(id).single.juryCount, 2);
      await p.selectUser('organizer');
      await p.publishResults(id);
      expect(p.status(p.competition(id)), CompetitionStatus.published);
      await p.selectUser('p0');
      expect(p.canSeeResults(p.competition(id)), true);
      expect(p.workStatus(s), SubmissionStatus.published);
      final reopened = PlatformProvider(clock: () => now);
      await reopened.initialize();
      expect(reopened.ranking(id).single.score, closeTo(80, 1e-9));
      expect(
        reopened.status(reopened.competition(id)),
        CompetitionStatus.published,
      );
      expect(reopened.currentUser!.id, 'p0');
      reopened.dispose();
    },
  );
  test('roles cannot execute other roles actions', () async {
    final id = await create();
    await p.selectUser('p0');
    await expectLater(p.publishResults(id), throwsStateError);
    await expectLater(
      p.createCompetition(
        title: 'Тест',
        description: 'Тест сипаттамасы',
        category: 'Дизайн',
        deadline: now.add(const Duration(days: 1)),
        rules: 'Тест ережелері',
      ),
      throwsStateError,
    );
    await expectLater(
      p.evaluate(
        submissionId: 's0',
        creativity: 7,
        quality: 7,
        presentation: 7,
        comment: 'Тест пікір',
      ),
      throwsStateError,
    );
    await p.selectUser('jury1');
    await expectLater(
      p.submitWork(
        competitionId: id,
        title: 'Жоба',
        description: 'Жоба сипаттамасы',
        link: 'https://example.com',
      ),
      throwsStateError,
    );
  });
  test('duplicate participation is rejected', () async {
    final id = await create();
    await submit(id);
    await expectLater(
      p.submitWork(
        competitionId: id,
        title: 'Екінші жоба',
        description: 'Екінші сипаттама',
        link: 'https://example.com',
      ),
      throwsStateError,
    );
    expect(p.worksFor(id).length, 1);
  });
  test('deadline closes submissions at its exact boundary', () async {
    final id = await create();
    now = p.competition(id).deadline;
    expect(p.status(p.competition(id)), CompetitionStatus.evaluation);
    await p.selectUser('p0');
    await expectLater(
      p.submitWork(
        competitionId: id,
        title: 'Жоба',
        description: 'Жоба сипаттамасы',
        link: 'https://example.com',
      ),
      throwsStateError,
    );
  });
  test(
    'publication requires at least one evaluation for every submission',
    () async {
      final id = await create();
      await expectLater(p.publishResults(id), throwsStateError);
      await submit(id);
      final s = p.worksFor(id).single;
      await submit(id, participant: 'p1');
      await p.selectUser('jury1');
      await p.evaluate(
        submissionId: s.id,
        creativity: 0,
        quality: 0,
        presentation: 0,
        comment: 'Нөлдік баға.',
      );
      await p.selectUser('organizer');
      await expectLater(p.publishResults(id), throwsStateError);
      expect(p.status(p.competition(id)), CompetitionStatus.active);
    },
  );
  test('published evaluations and participation are locked', () async {
    await p.selectUser('jury1');
    await expectLater(
      p.evaluate(
        submissionId: 's8',
        creativity: 10,
        quality: 10,
        presentation: 10,
        comment: 'Жаңа баға',
      ),
      throwsStateError,
    );
    await p.selectUser('p5');
    await expectLater(
      p.submitWork(
        competitionId: 'c4',
        title: 'Жоба',
        description: 'Жоба сипаттамасы',
        link: 'https://example.com',
      ),
      throwsStateError,
    );
  });
  test('invalid link and expired creation are rejected', () async {
    final id = await create();
    await p.selectUser('p0');
    await expectLater(
      p.submitWork(
        competitionId: id,
        title: 'Жоба',
        description: 'Жоба сипаттамасы',
        link: 'javascript:alert(1)',
      ),
      throwsArgumentError,
    );
    await p.selectUser('organizer');
    await expectLater(
      p.createCompetition(
        title: 'Тест',
        description: 'Тест сипаттамасы',
        category: 'Дизайн',
        deadline: now.subtract(const Duration(days: 1)),
        rules: 'Тест ережелері',
      ),
      throwsArgumentError,
    );
  });
  test('failed storage does not commit in-memory changes', () async {
    final storage = FailingStorage();
    final store = PlatformProvider(storage: storage, clock: () => now);
    await store.initialize();
    await store.selectUser('organizer');
    storage.fail = true;
    await expectLater(
      store.createCompetition(
        title: 'Тест',
        description: 'Тест сипаттамасы',
        category: 'Дизайн',
        deadline: now.add(const Duration(days: 1)),
        rules: 'Тест ережелері',
      ),
      throwsStateError,
    );
    expect(store.competitions.length, 5);
    expect(store.saving, false);
    store.dispose();
  });
  test('corrupt persistence is reported without replacing user data', () async {
    SharedPreferences.setMockInitialValues({
      LocalStorageService.key: '{broken',
    });
    final reopened = PlatformProvider(clock: () => now);
    await reopened.initialize();
    expect(reopened.loadError, isNotNull);
    expect(reopened.competitions, isEmpty);
    expect(
      (await SharedPreferences.getInstance()).getString(
        LocalStorageService.key,
      ),
      '{broken',
    );
    reopened.dispose();
  });
}
