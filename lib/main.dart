import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/platform_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlatformProvider()..initialize(),
      child: const BaiqauApp(),
    ),
  );
}

class BaiqauApp extends StatelessWidget {
  const BaiqauApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'baiqau — Идеядан жеңіске',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('kk'),
    supportedLocales: const [Locale('kk')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const SplashScreen(),
  );
}
