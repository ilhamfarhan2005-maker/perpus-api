// lib/views/auth/splash_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_vm.dart';

/// Cek token tersimpan saat aplikasi dibuka → langsung ke daftar buku jika valid.
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final loggedIn = await ref.read(authProvider.notifier).restoreSession();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, loggedIn ? AppRoutes.books : AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.darkPrimary, const Color(0xFF0F766E)]
                      : [AppColors.primary, const Color(0xFF115E59)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.local_library_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Perpustakaan Kampus',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sistem Manajemen Buku Terintegrasi',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
