// lib/widgets/book_detail_sheet.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/book_model.dart';
import 'book_cover.dart';
import 'stock_badge.dart';

/// Bottom sheet elegan untuk melihat rincian lengkap sebuah buku.
class BookDetailSheet extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookDetailSheet({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required BookModel book,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookDetailSheet(
        book: book,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header: Cover + Info Utama
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(
                    title: book.title,
                    id: book.id,
                    width: 72,
                    height: 100,
                    borderRadius: 12,
                    heroTag: 'book-cover-${book.id}',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Oleh ${book.author}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        StockBadge(stock: book.stock),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                height: 1,
              ),
              const SizedBox(height: 16),

              // Metadata Grid / Detail List
              _DetailRow(
                icon: Icons.qr_code_2_rounded,
                label: 'ISBN',
                value: book.isbn,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Tahun Terbit',
                value: book.publishedYear.toString(),
                isDark: isDark,
              ),
              if (book.publisher != null && book.publisher!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _DetailRow(
                  icon: Icons.business_outlined,
                  label: 'Penerbit',
                  value: book.publisher!,
                  isDark: isDark,
                ),
              ],

              // Deskripsi jika ada
              if (book.description != null && book.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputFill : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    book.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.stockZero, size: 20),
                      label: const Text('Hapus Buku', style: TextStyle(color: AppColors.stockZero)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.stockZero),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Edit Buku'),
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
