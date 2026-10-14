const categories = ['IT және инновация', 'Дизайн', 'Өнер', 'Ғылым', 'Әдебиет'];
String shortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
String longDate(DateTime date) {
  const months = [
    'қаңтар',
    'ақпан',
    'наурыз',
    'сәуір',
    'мамыр',
    'маусым',
    'шілде',
    'тамыз',
    'қыркүйек',
    'қазан',
    'қараша',
    'желтоқсан',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String? requiredText(String? value, {int min = 3}) =>
    (value?.trim().length ?? 0) < min ? 'Кемінде $min таңба енгізіңіз' : null;
String? linkError(String? value) {
  final uri = Uri.tryParse(value?.trim() ?? '');
  return uri == null ||
          !['https', 'http'].contains(uri.scheme) ||
          uri.host.isEmpty ||
          !uri.host.contains('.')
      ? 'Дұрыс http немесе https сілтемесін енгізіңіз'
      : null;
}
