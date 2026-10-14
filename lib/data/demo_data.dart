import '../models/app_data.dart';
import '../models/competition.dart';
import '../models/evaluation.dart';
import '../models/submission.dart';
import '../models/user.dart';
import '../core/formatters.dart';

AppData createDemoData(DateTime now) {
  final users = <User>[
    const User(
      id: 'organizer',
      name: 'Айдана Сәрсен',
      role: UserRole.organizer,
      department: 'Колледж • Ұйымдастыру бөлімі',
    ),
    const User(
      id: 'jury1',
      name: 'Ерлан Әбілов',
      role: UserRole.jury,
      department: 'IT және дизайн сарапшысы',
    ),
    const User(
      id: 'jury2',
      name: 'Дана Омарова',
      role: UserRole.jury,
      department: 'Шығармашылық бағыт сарапшысы',
    ),
    const User(
      id: 'jury3',
      name: 'Мұрат Асқар',
      role: UserRole.jury,
      department: 'Ғылыми жобалар сарапшысы',
    ),
  ];
  const names = [
    'Аяужан Төлеген',
    'Әлихан Нұрлан',
    'Аружан Қасым',
    'Данияр Әсет',
    'Айша Ермек',
    'Нұрасыл Болат',
    'Мадина Серік',
    'Санжар Дәулет',
    'Іңкәр Ораз',
    'Тимур Қанат',
  ];
  for (var i = 0; i < names.length; i++) {
    users.add(
      User(
        id: 'p$i',
        name: names[i],
        role: UserRole.participant,
        department: '${i.isEven ? 'IT' : 'Дизайн'} • ${i % 3 + 1}-курс',
      ),
    );
  }
  const titles = [
    'Digital: болашақ сенен басталады',
    'Дизайн арқылы өзгеріс',
    'Өнердің жаңа толқыны',
    'Жас зерттеуші',
    'Сөз құдіреті',
  ];
  const descriptions = [
    'Күнделікті өмірді жақсартатын цифрлық шешім ойлап тап. Мобильді қосымша, веб-жоба немесе прототип арқылы идеяңды көрсет.',
    'Қалаға, колледжге немесе қоғамға арналған визуалды шешім жаса. Жақсы дизайнның өзгеріс әкелетінін дәлелде.',
    'Еркін шығармашылық алаңы. Иллюстрация, фотосурет немесе музыкалық туынды арқылы өз әлеміңмен бөліс.',
    'Ғылыми идеяңды шағын зерттеуге айналдыр. Мәселені, әдісті және нәтижені анық әрі түсінікті ұсын.',
    'Қазақ тіліндегі эссе, әңгіме немесе поэзия. Ойыңды көркем жеткіз, оқырманға жаңа көзқарас сыйла.',
  ];
  final competitions = List.generate(
    5,
    (i) => Competition(
      id: 'c$i',
      title: titles[i],
      description: descriptions[i],
      category: categories[i],
      organizerId: 'organizer',
      createdAt: now.subtract(Duration(days: 15 + i)),
      deadline: now.add(Duration(days: i < 3 ? 12 + i * 4 : -3)),
      status: i == 3
          ? CompetitionStatus.evaluation
          : i == 4
          ? CompetitionStatus.published
          : CompetitionStatus.active,
      rules:
          'Жұмыс авторлық болуы тиіс. Бір қатысушы бір жұмыс жібере алады. Жоба сипаттамасын және жалпыға қолжетімді сілтемені қосыңыз. Бағалау үш критерий бойынша жүргізіледі.',
    ),
  );
  final submissions = <Submission>[];
  const workTitles = [
    'Smart Campus',
    'EcoStep',
    'Qazaq Learn',
    'Жаңа көзқарас',
    'Таза қала',
    'Көкжиек',
    'Күн энергиясы',
    'Су – өмір',
    'Менің Қазақстаным',
    'Дала дауысы',
    'Арманға жол',
  ];
  const contestIds = [
    'c0',
    'c0',
    'c0',
    'c1',
    'c1',
    'c2',
    'c3',
    'c3',
    'c4',
    'c4',
    'c4',
  ];
  for (var i = 0; i < workTitles.length; i++) {
    submissions.add(
      Submission(
        id: 's$i',
        competitionId: contestIds[i],
        participantId: 'p${i % 10}',
        title: workTitles[i],
        description:
            'Бұл – ${workTitles[i]} атты авторлық demo жоба. Мақсаты: шығармашылық идеяны нақты шешімге айналдыру. Қорғауда өз жұмысыңыздың сілтемесін енгізуге болады.',
        link: 'https://example.com/projects/$i',
        createdAt: now.subtract(Duration(days: i + 1)),
      ),
    );
  }
  final evaluations = <Evaluation>[];
  for (final i in [0, 1, 3, 6, 7, 8, 9, 10]) {
    for (var j = 1; j <= 2; j++) {
      evaluations.add(
        Evaluation(
          submissionId: 's$i',
          juryId: 'jury$j',
          creativity: 7 + (i % 3) + j * .25,
          quality: 7.5 + (i % 2),
          presentation: 8 + (j - 1) * .5,
          comment:
              'Идея анық жеткізілген. Шешімнің қолданылуын әрі қарай дамытуға болады.',
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
      );
    }
  }
  return AppData(
    users: users,
    competitions: competitions,
    submissions: submissions,
    evaluations: evaluations,
  );
}
