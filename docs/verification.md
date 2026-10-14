# Тексеру нәтижелері

2026-10-12, Flutter 3.44.6 / Dart 3.12.2.

- `flutter pub get` — сәтті.
- `flutter analyze` — No issues found.
- `flutter test` — 18 тест өтті.
- `flutter build web --release --no-web-resources-cdn` — сәтті.
- `flutter build apk --debug` — сәтті.
- `apksigner verify --verbose` — APK Signature Scheme v2 жарамды.
- Браузерде 390×844 өлшемдегі басты бет пен рейтинг визуалды тексерілді; console error/warning байқалмады.
- Қайта жүктелгенде браузердегі таңдалған қолданушы сақталды.
- Widget тесті 320×720 экранда үш рөлдің бес navigation бөлімін тексерді.
- Экрандық тест толық қорғау сценарийін өтті: байқау құру, жұмыс жіберу, қазының бағасы, жариялау, қорытынды рейтинг.
- Provider тесті бағасын түзетуді, екінші қазының орташа ұпайын және деректердің қайта ашылғанда сақталуын тексерді.

APK: `build/app/outputs/flutter-apk/app-debug.apk` (150 593 158 байт).

SHA-256:

```text
9a43db66166fc1d5564ae9293b40d37b128ceabccdea9b9818f8115cc67a5502
```

Release AOT жинағы Windows Application Control саясаты `gen_snapshot.EXE` орындауына рұқсат бермегендіктен аяқталмады. Қауіпсіздік саясаты өзгертілген жоқ. Дайын debug APK қорғау үшін қолданылады.

Android телефоны немесе эмуляторы қосылмаған: нақты құрылғыда іске қосу тексерісі орындалмады. Тексеру Android жинағын, қолтаңбаны, unit/widget тесттерін және web көрінісін қамтиды.

APK метадеректері: атауы **Baiqau**, application ID `kz.baiqa.baiqa`, нұсқа 1.0.0, Android API 24+, target API 36. ABI: arm64-v8a, armeabi-v7a, x86_64. MainActivity: `kz.baiqau.baiqau.MainActivity`. Application ID бұрынғы орнату мен сақталған деректерді сақтау үшін өзгертілмеген.
