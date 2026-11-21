// lib/widgets/stock_badge.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Badge indikator ketersediaan stok buku.
/// - Hijau (>= 10): Stok aman
/// - Oranye (1 - 9): Sisa sedikit
/// - Merah (0): Habis
class StockBadge extends StatelessWidget {
  final int stock;
  final bool compact;

  const StockBadge({
    super.key,
    required this.stock,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fg;
    final Color bg;
    final String label;
    final IconData icon;

    if (stock == 0) {
      fg = isDark ? const Color(0xFFF87171) : AppColors.stockZero;
      bg = isDark ? const Color(0xFF450A0A) : AppColors.stockZeroBg;
      label = 'Habis';
      icon = Icons.cancel_outlined;
    } else if (stock < 10) {
      fg = isDark ? const Color(0xFFFB923C) : AppColors.stockMedium;
      bg = isDark ? const Color(0xFF431407) : AppColors.stockMediumBg;
      label = compact ? '$stock sisa' : 'Sisa $stock';
      icon = Icons.warning_amber_rounded;
    } else {
      fg = isDark ? const Color(0xFF4ADE80) : AppColors.stockHigh;
      bg = isDark ? const Color(0xFF052E16) : AppColors.stockHighBg;
      label = 'Stok: $stock';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
