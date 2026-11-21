// lib/widgets/book_card.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/book_model.dart';
import 'book_cover.dart';
import 'book_detail_sheet.dart';
import 'stock_badge.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      color: isDark ? AppColors.darkSurface : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => BookDetailSheet.show(
          context,
          book: book,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sampul Buku Dinamis dengan Hero Tag
              BookCover(
                title: book.title,
                id: book.id,
                width: 44,
                height: 60,
                borderRadius: 8,
                heroTag: 'book-cover-${book.id}',
              ),
              const SizedBox(width: 14),

              // Informasi Buku
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} · ${book.publishedYear}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StockBadge(stock: book.stock, compact: true),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Action Buttons: Edit & Hapus (touch target >= 48px)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    button: true,
                    label: 'Edit buku ${book.title}',
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      tooltip: 'Edit Buku',
                      splashRadius: 22,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      onPressed: onEdit,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Hapus buku ${book.title}',
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: isDark ? const Color(0xFFF87171) : AppColors.stockZero,
                      tooltip: 'Hapus Buku',
                      splashRadius: 22,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      onPressed: onDelete,
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
