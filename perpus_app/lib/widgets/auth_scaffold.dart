// lib/widgets/auth_scaffold.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Loading Button reusable dengan indikator progress di dalam tombol
class LoadingButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onPressed;

  const LoadingButton({
    super.key,
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

/// Kerangka halaman login/register responsif (2 kolom di layar lebar >768px, 1 kolom di layar sempit)
class AuthScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? error;
  final List<Widget> children;

  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.error,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;

    final formContent = Container(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Card(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern App Icon Badge (hanya tampil di mode 1 kolom agar tidak redundant)
              if (!isWide) ...[
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkPrimary, const Color(0xFF0F766E)]
                            : [AppColors.primary, const Color(0xFF115E59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_library_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
                textAlign: isWide ? CrossAxisAlignment.start == CrossAxisAlignment.start ? TextAlign.left : TextAlign.center : TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  textAlign: isWide ? TextAlign.left : TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // Error Alert Banner yang ramah
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF450A0A) : AppColors.stockZeroBg,
                    border: Border.all(
                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: isDark ? const Color(0xFFF87171) : AppColors.stockZero,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          error!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              ...children,
            ],
          ),
        ),
      ),
    );

    if (!isWide) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: formContent,
            ),
          ),
        ),
      );
    }

    // Layar Lebar: 2 Kolom (Panel Branding di Kiri, Form Card di Kanan)
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Row(
        children: [
          // Kolom Kiri: Branding Kampus Modern
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF134E4A)]
                      : [AppColors.primary, const Color(0xFF042F2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo & Brand Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(
                          Icons.local_library_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Perpus Kampus',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  // Hero Text & Feature Pills
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars_rounded, size: 16, color: AppColors.accent),
                            SizedBox(width: 6),
                            Text(
                              'Sistem Informasi Perpustakaan',
                              style: TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Jelajahi Ilmu Tanpa Batas,\nKelola Buku Lebih Cepat.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Platform terintegrasi untuk katalogisasi, inventarisasi stok, dan peminjaman buku civitas akademika.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _FeatureRow(icon: Icons.search_rounded, text: 'Pencarian Instan dengan Debounce & Filter'),
                      const SizedBox(height: 14),
                      _FeatureRow(icon: Icons.inventory_2_outlined, text: 'Monitoring Stok & Peringatan Otomatis'),
                      const SizedBox(height: 14),
                      _FeatureRow(icon: Icons.verified_user_outlined, text: 'Autentikasi Aman dengan Sanctum'),
                    ],
                  ),

                  // Footer Copyright
                  Text(
                    '© 2026 Perpustakaan Digital · Edisi Kampus Modern',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kolom Kanan: Form Card
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                child: formContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
