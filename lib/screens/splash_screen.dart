import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/platform_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'app_shell.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _introDone = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _introDone = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlatformProvider>();
    if (p.loadError != null && !p.loading) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: StateMessage(
              title: 'Деректер ашылмады',
              message: p.loadError!,
              icon: Icons.error_outline_rounded,
              action: 'Қайта жүктеу',
              onAction: p.initialize,
            ),
          ),
        ),
      );
    }
    if (!_introDone || p.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandLogo(size: 86),
              SizedBox(height: 24),
              Text(
                'baiqau',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Идеядан жеңіске.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return p.currentUser == null
        ? const RoleSelectionScreen()
        : AppShell(key: ValueKey(p.currentUser!.id));
  }
}
