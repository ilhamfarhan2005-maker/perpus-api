// lib/widgets/stats_dashboard.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/book_model.dart';

/// Mini dashboard ringkasan statistik buku: Total Judul, Total Unit, Stok Menipis.
class StatsDashboard extends StatelessWidget {
  final List<BookModel> books;
  final int totalBooksCount;

  const StatsDashboard({
    super.key,
    required this.books,
    required this.totalBooksCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalStock = books.fold<int>(0, (sum, b) => sum + b.stock);
    final lowStockCount = books.where((b) => b.stock < 10).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Total Judul',
              value: totalBooksCount.toString(),
              icon: Icons.menu_book_rounded,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
          Container(
            height: 38,
            width: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          Expanded(
            child: _StatItem(
              label: 'Total Unit',
              value: totalStock.toString(),
              icon: Icons.inventory_2_outlined,
              color: isDark ? AppColors.darkAccent : const Color(0xFF0284C7),
            ),
          ),
          Container(
            height: 38,
            width: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          Expanded(
            child: _StatItem(
              label: 'Stok Menipis',
              value: lowStockCount.toString(),
              icon: Icons.priority_high_rounded,
              color: isDark ? const Color(0xFFFB923C) : AppColors.stockMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
