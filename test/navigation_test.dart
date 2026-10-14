import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baiqau/main.dart';
import 'package:baiqau/models/competition.dart';
import 'package:baiqau/providers/platform_provider.dart';
import 'package:baiqau/screens/competition_details_screen.dart';
import 'package:baiqau/screens/create_competition_screen.dart';
import 'package:baiqau/screens/evaluation_screen.dart';
import 'package:baiqau/screens/results_screen.dart';
import 'package:baiqau/screens/submit_work_screen.dart';

void main() {
  late PlatformProvider p;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    p = PlatformProvider(clock: () => DateTime(2026, 10, 12, 10));
    await p.initialize();
  });
  tearDown(() => p.dispose());
  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: p, child: const BaiqauApp()),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  Future<void> click(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> switchRole(WidgetTester tester, String label) async {
    await click(tester, find.byKey(const Key('switch-role')));
    await click(tester, find.text(label));
    await click(tester, find.byKey(const Key('enter-role')));
  }

  testWidgets('all roles navigate all five tabs on a narrow phone', (
    tester,
  ) async {
    await p.selectUser('p0');
    await mount(tester, size: const Size(320, 720));
    for (final role in ['Қазы', 'Ұйымдастырушы', 'Қатысушы']) {
      await switchRole(tester, role);
      for (var i = 0; i < 5; i++) {
        await click(tester, find.byType(NavigationDestination).at(i));
      }
    }
  });

  testWidgets('defense scenario works through forms and role switching', (
    tester,
  ) async {
    await p.selectUser('organizer');
    await mount(tester);
    await click(tester, find.text('Байқау құру'));
    expect(find.byType(CreateCompetitionScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('contest-title')),
      'Қорғау байқауы',
    );
    await tester.enterText(
      find.byKey(const Key('contest-description')),
      'Жаңа цифрлық идеяларға арналған байқау.',
    );
    await click(tester, find.byKey(const Key('save-contest')));
    expect(find.byType(CompetitionDetailsScreen), findsOneWidget);
    final c = p.competitions.first;
    expect(c.title, 'Қорғау байқауы');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await switchRole(tester, 'Қатысушы');
    await click(tester, find.text('Қорғау байқауы').first);
    await click(tester, find.byKey(const Key('submit-work')));
    expect(find.byType(SubmitWorkScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('work-title')),
      'Жаңа мобильді шешім',
    );
    await tester.enterText(
      find.byKey(const Key('work-description')),
      'Студенттерге арналған авторлық мобильді жоба.',
    );
    await tester.enterText(
      find.byKey(const Key('work-link')),
      'https://example.com/demo',
    );
    await click(tester, find.byKey(const Key('save-work')));
    expect(p.worksFor(c.id).length, 1);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await switchRole(tester, 'Қазы');
    await click(tester, find.text('Бағалауды бастау'));
    await click(tester, find.text('Жаңа мобильді шешім'));
    expect(find.byType(EvaluationScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('jury-comment')),
      'Идея өте жақсы, шешім анық көрсетілген.',
    );
    await click(tester, find.byKey(const Key('save-evaluation')));
    final s = p.worksFor(c.id).single;
    expect(p.scoreFor(s.id), closeTo(70, 1e-9));
    await switchRole(tester, 'Ұйымдастырушы');
    await click(tester, find.text('Қорғау байқауы').first);
    await click(tester, find.byKey(const Key('publish-results')));
    await click(tester, find.text('Жариялау'));
    expect(p.status(p.competition(c.id)), CompetitionStatus.published);
    await click(tester, find.text('Қорытынды рейтинг'));
    expect(find.byType(ResultsScreen), findsWidgets);
    expect(find.text('70.0 ұпай'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
